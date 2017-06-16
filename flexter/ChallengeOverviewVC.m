//
//  ChallengeOverviewVC.m
//  flexter
//
//  Created by Anurag Tolety on 3/17/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#import "ChallengeOverviewVC.h"
#import "Lockbox.h"
#import "YLProgressBar.h"
#import "UIConstants.h"
#import "WorkoutTableViewCell.h"
#import "WorkoutOverviewVC.h"
#import "UIImage+Tint.h"
#import "RMStore.h"
#import "ChallengeHeaderTableViewCell.h"
#import "ChallengeStatusView.h"
#import "FDChallenge+Keychain.h"
#import "FDChallenge+Purchase.h"
#import "FDChallenge+Progress.h"
#import <Crashlytics/Crashlytics.h>

#define HEADER_SECTION 0
#define WORKOUTS_SECTION 1

static const CGFloat kChallengeStatusHeight = 52.0;

@interface ChallengeOverviewVC () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, ChallengeStatusProtocol>

@property (weak, nonatomic) IBOutlet UITableView *workoutsTableView;
@property BOOL workoutsFetched;
@property NSInteger selectedWorkoutIndex;
@property (nonatomic, strong) ChallengeStatusView* statusView;
@property (nonatomic, strong) NSFileManager* fileManager;
@property (nonatomic, strong) NSString* challengeImageStorageFolderPath;
@property (nonatomic, strong) UIImage* coverImage;
@property (nonatomic, strong) UIImage* headerCellImage;

@end

@implementation ChallengeOverviewVC

NSString *descText = nil;
NSString *updatedPrice = nil;

- (ChallengeStatusView*)statusView {
    if (!_statusView) {
        _statusView = [[ChallengeStatusView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kChallengeStatusHeight)];
    }
    return _statusView;
}

- (NSFileManager*)fileManager
{
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

- (NSString *)challengeImageStorageFolderPath {
    if (!_challengeImageStorageFolderPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDirectory = [paths objectAtIndex:0];
        _challengeImageStorageFolderPath = [cachesDirectory stringByAppendingPathComponent:CHALLENGE_IMAGE_FOLDER_NAME];
        NSLog(@"image storage path: %@", _challengeImageStorageFolderPath);
    }
    if (![self.fileManager fileExistsAtPath:_challengeImageStorageFolderPath isDirectory:nil]) {
        NSLog(@"create image storage directory pass or fail: %d", [self.fileManager createDirectoryAtPath:_challengeImageStorageFolderPath withIntermediateDirectories:YES attributes:nil error:nil]);
    }
    return _challengeImageStorageFolderPath;
}

- (NSString*)pathForCoverImageOfChallengeWithObjectId:(NSString*)objectId
{
    if (objectId) {
        return [self.challengeImageStorageFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_cover.jpg", objectId]];
    } else {
        return nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addCustomBackButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScreenshotTaken) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    self.workoutsTableView.dataSource = self;
    self.workoutsTableView.delegate = self;
    [self.workoutsTableView registerNib:[UINib nibWithNibName:@"WorkoutTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"WorkoutCell"];
    self.workoutsFetched = NO;
    self.selectedWorkoutIndex = -1;
    self.statusView.purchased = [self.challenge isPurchased];
	if (self.statusView.purchased) {
		[PFAnalytics trackEvent:@"openedChallenge" dimensions:@{@"owned": @"yes", @"challenge": self.challenge[CHALLENGE_TITLE]}];
		NSLog(@"Parse event sent");
	} else {
		[PFAnalytics trackEvent:@"openedChallenge" dimensions:@{@"owned": @"no", @"challenge": self.challenge[CHALLENGE_TITLE]}];
		NSLog(@"Parse event sent");
	}
    [self updateChallengeProgress];
    // Hack for enabling the swipe gesture. When we take away the navigation bar, the swipe no longer works
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    if (self.challenge[CHALLENGE_PURCHASE_IDENTIFIER]) {
        NSSet *products = [NSSet setWithArray:@[self.challenge[CHALLENGE_PURCHASE_IDENTIFIER]]];
        [[RMStore defaultStore] requestProducts:products success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
            for (SKProduct* product in products) {
                NSLog(@"%@, %@, %0.02f", product.productIdentifier, product.localizedTitle, product.price.floatValue);
                if ([product.productIdentifier isEqualToString:self.challenge[CHALLENGE_PURCHASE_IDENTIFIER]] && [SKPaymentQueue canMakePayments]) {
                    self.statusView.price = product.price.floatValue;
					//SET DESC PRICE HERE
					updatedPrice = [NSString stringWithFormat:@"%0.02f", product.price.floatValue];
					[self.workoutsTableView reloadData];
                    
                    CGFloat value = product.price.floatValue;
                    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"revenue"];
                    if (self.statusView.purchased == NO) {
                        [Answers logCustomEventWithName:@"IAP Purchased" customAttributes:@{@"Revenue":[NSString stringWithFormat:@"%f",value],
                                                                                            @"IAP Name":str}];

                    }
                    
                }
            }
        } failure:^(NSError *error) {
            NSLog(@"Something went wrong: %@", error);
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",nil) message:NSLocalizedString(@"Please load this challenge again to enable the buy button.",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
            [alert show];
        }];
    }
    [self.workoutsTableView registerNib:[UINib nibWithNibName:@"ChallengeHeaderTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ChallengeHeaderCell"];
    [self loadChallengeWorkouts];
}

- (void)loadChallengeWorkouts {
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [PFObject fetchAllIfNeededInBackground:self.challenge[CHALLENGE_WORKOUTS] block:^(NSArray *objects, NSError *error) {
        [spinner stopAnimating];
        if (!error && objects) {
            self.workoutsFetched = YES;
            [self.workoutsTableView reloadData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIView animateWithDuration:0.25 animations:^{
        self.navigationController.navigationBar.translucent = YES;
        self.navigationController.view.backgroundColor = [UIColor clearColor];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    }];
}

- (void)addCustomBackButton
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame=CGRectMake(0, 0, 30, 30);
    [backButton setImage:[UIImage imageNamed:@"ChallengeOverviewBackArrow.png"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = 0;
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, barItem, nil] animated:NO];
}

#pragma mark - Challenge Status Protocol

- (void)purchaseChallenge {
    NSLog(@"ChallengeOverviewVC payment initiated for %@", self.challenge[CHALLENGE_PURCHASE_IDENTIFIER]);
    if (!self.challenge[CHALLENGE_PURCHASE_IDENTIFIER]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Purchase identifier not set" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [spinner startAnimating];
    [[RMStore defaultStore] addPayment:self.challenge[CHALLENGE_PURCHASE_IDENTIFIER] success:^(SKPaymentTransaction *transaction) {
            NSLog(@"Product purchased");
		
        [spinner stopAnimating];
        [self.challenge persistPurchase];
        [self.challenge setInProgressDayIndex:0];
        self.statusView.purchased = YES;
        self.statusView.progress = 0.0;
        [self.workoutsTableView reloadData];
		[PFAnalytics trackEvent:@"boughtIAP" dimensions:@{@"product": self.challenge[CHALLENGE_PURCHASE_IDENTIFIER]}];
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        NSLog(@"Something went wrong");
        [spinner stopAnimating];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [alert show];
    }];
}

#pragma mark - Tableview methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == HEADER_SECTION) {
        return 1;
    } else {
        return self.workoutsFetched ? 30 : 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // We show just one section after workout has been started
    if ([indexPath section] == HEADER_SECTION) {
        return 320.0;
    } else {
        return 50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == WORKOUTS_SECTION) {
        return kChallengeStatusHeight;
    } else {
        return 0;
    }
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == HEADER_SECTION) {
        return nil;
    } else {
        self.statusView.delegate = self;
        return self.statusView;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == HEADER_SECTION) {
        ChallengeHeaderTableViewCell* headerCell = (ChallengeHeaderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ChallengeHeaderCell"];
        headerCell.titleLabel.text = NSLocalizedString(self.challenge[CHALLENGE_TITLE],nil);
        headerCell.detailLabel.text = NSLocalizedString(self.challenge[CHALLENGE_DESCRIPTION],nil);
		if (updatedPrice != nil) { //UPDATE PRICE IS AVAILABLE
			headerCell.detailLabel.text = [headerCell.detailLabel.text stringByReplacingOccurrencesOfString:@"1.99" withString:updatedPrice];
			NSLog(@"just set the main text with updated price");
		} else {
			NSLog(@"just set the main text with static price");
		}
		
        if (!self.headerCellImage) {
            if (self.challenge[CHALLENGE_COVER_IMAGE_FILE_NAME]) {
                self.headerCellImage = [UIImage imageNamed:self.challenge[CHALLENGE_COVER_IMAGE_FILE_NAME]];
                headerCell.backgroundImage = self.headerCellImage;
            } else {
                PFFile* coverImage = self.challenge[CHALLENGE_COVER_IMAGE_FILE];
                [coverImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error && data) {
                        self.headerCellImage = [UIImage imageWithData:data];
                        headerCell.backgroundImage = self.headerCellImage;
                    }
                }];
            }
        } else {
            headerCell.backgroundImage = self.headerCellImage;
        }
        return headerCell;
    } else {
        WorkoutTableViewCell* cell = (WorkoutTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"WorkoutCell"];
        FDWorkout* workout = (FDWorkout*)[self.challenge[CHALLENGE_WORKOUTS] objectAtIndex:0];
        NSInteger durationInSec = 0;
        for (int i = 0; i < [workout[WORKOUT_EXERCISE_CONFIG_LIST] count]; i++) {
            NSDictionary* exerciseConfigDictionary = [workout[WORKOUT_EXERCISE_CONFIG_LIST] objectAtIndex:i];
            durationInSec += [FDExercise durationForConfig:exerciseConfigDictionary onDay:(int)(indexPath.row + 1)];
        }
        if (durationInSec <= 0) {
            cell.workoutTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Day %ld: Rest Day",nil), ((long)indexPath.row + 1)];
        } else {
            durationInSec += 30 * [workout[WORKOUT_EXERCISE_CONFIG_LIST] count];
            cell.workoutTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Day %d: %d Minutes",nil), ((int)indexPath.row + 1), (int)durationInSec/60];
        }
        NSUInteger inProgressDayIndex = [self.challenge inProgressDayIndex];
        if (![self.challenge isPurchased]) {
            cell.workoutState = WorkoutStateTypeLocked;
        } else {
            if (indexPath.row < inProgressDayIndex) {
                cell.workoutState = WorkoutStateTypeDone;
            } else if (indexPath.row == inProgressDayIndex) {
                cell.workoutState = WorkoutStateTypeInProgress;
            } else {
                cell.workoutState = WorkoutStateTypeLocked;
            }
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == HEADER_SECTION) {
        return;
    } else {
        self.selectedWorkoutIndex = indexPath.row;
        NSUInteger inProgressDayIndex = [self.challenge inProgressDayIndex];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", inProgressDayIndex] forKey:@"workoutday"];
        BOOL isPurchased = [self.challenge isPurchased];
        if (indexPath.row <= inProgressDayIndex && isPurchased) {
            if ((indexPath.row + 1)%4 == 0) {
                [self workoutCompleted];
            } else {
				[PFAnalytics trackEvent:@"workoutStarted" dimensions:@{@"Day":  [NSString stringWithFormat:@"%lu", (unsigned long)inProgressDayIndex], @"challenge": self.challenge[CHALLENGE_TITLE]}];
                [self performSegueWithIdentifier:@"ShowWorkout" sender:indexPath];
            }
        } else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Locked!",nil) message:isPurchased ? NSLocalizedString(@"Finish previous workouts to unlock this workout",nil) : NSLocalizedString(@"Purchase this challenge to unlock it",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Uncheck";
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.challenge isPurchased] && indexPath.row < [self.challenge inProgressDayIndex] && indexPath.section == WORKOUTS_SECTION;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.challenge setInProgressDayIndex:indexPath.row];
        [self updateChallengeProgress];
        [self.workoutsTableView reloadData];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateChallengeProgress {
    NSUInteger inProgressDayIndex = [self.challenge inProgressDayIndex];
    self.statusView.progress = inProgressDayIndex * 1.0 / 30;
}

#pragma mark - Workout Completion Protocol methods

- (void)workoutCompleted {
    NSUInteger inProgressDayIndex = [self.challenge inProgressDayIndex];
    if (self.selectedWorkoutIndex >= inProgressDayIndex) {
        [self.challenge setInProgressDayIndex:self.selectedWorkoutIndex+1];
    }
    [self updateChallengeProgress];
    [self.workoutsTableView reloadData];
	[PFAnalytics trackEvent:@"workoutComplete" dimensions:@{@"Day":  [NSString stringWithFormat:@"%lu", (unsigned long)inProgressDayIndex], @"challenge": self.challenge[CHALLENGE_TITLE]}];
}

- (void)workoutCancelledWithInProgressExerciseIndex:(int)index {
    // Doing nothing here. Can handle keeping track of last unchecked exercise here.
}

- (NSInteger)dayIndex {
    return self.selectedWorkoutIndex + 1;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowWorkout"]) {
        [segue.destinationViewController setWorkout:((FDWorkout*)[self.challenge[CHALLENGE_WORKOUTS] objectAtIndex:0])];
        [segue.destinationViewController setDayInChallenge:(int)(((NSIndexPath*)sender).row + 1)];
        [segue.destinationViewController setWorkoutCompleteDelegate:self];
    }
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Screenshot Action

- (void)handleScreenshotTaken
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(CANCEL_ACTION_SHEET_TITLE,nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(SEND_FEEDBACK_ACTION_SHEET_TITLE,nil), NSLocalizedString(REPORT_A_BUG_ACTION_SHEET_TITLE,nil), nil];
    [actionSheet showInView:self.view];
}


- (void) downloadvideo{
//    NSString *urlToDownload = @"http://fitthirty.s3.amazonaws.com/Jru5B044HOs-sd.mp4";
//    NSURL  *url = [NSURL URLWithString:urlToDownload];
//    NSError *error = nil;
//    NSData *urlData = [NSData dataWithContentsOfURL:url options:nil error:&error];
//    
//    if ( urlData )
//    {
//        NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString  *documentsDirectory = [paths objectAtIndex:0];
//        NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,[NSString stringWithFormat:@"%@", @"Ultimate Fat Burner.mp4"]];
//        NSLog(filePath);
//        
//        
//    }

}
@end
