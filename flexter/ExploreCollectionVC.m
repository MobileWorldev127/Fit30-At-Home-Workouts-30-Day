//
//  ExploreCollectionVC.m
//  flexter
//
//  Created by Anurag Tolety on 7/10/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//
//  Purpose: Displays a collection of workouts based on the filter criteria passed to it
//

#import "ExploreCollectionVC.h"
#import "ImageAndLabelCollectionViewCell.h"
#import "FDWorkout.h"
#import "ExploreFilterCollectionVC.h"
#import "WorkoutOverviewVC.h"
#import "EarlyAccessOptionsView.h"
#import "UIConstants.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "FlexterAnalyticsEvents.h"
#import "UIConstants.h"
#import "FDChallenge.h"
#import "ChallengeOverviewVC.h"
#import "Lockbox.h"
#import "PurchaseAllChallengesVC.h"
#import "FDChallenge+Purchase.h"
#import "FDChallenge+Progress.h"
#import "RMStore.h"
#import "WhiteSpaceCollectionViewCell.h"
#import <Crashlytics/Crashlytics.h>

#define HIDE_BUILD_WORKOUT 0
#define RESET_CHALLENGE_PURCHASE 0

@interface ExploreCollectionVC () <UICollectionViewDataSource, UICollectionViewDelegate, EarlyAccessOptionsProtocol, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray* challenges;

@property (strong, nonatomic) NSMutableDictionary* challengeImages;

// Used to find out the direction of scrolling so that more workouts can be loaded. Basically does pagination.
@property NSInteger previousContentoffset;

// Used to display a refresh status when the user drags down on the collection view.
@property (strong, nonatomic) UIRefreshControl* refreshWorkoutsControl;

// Only animated after receiving new filter options. We don't want both the above refresh control and this spinner rotating at the same time. Looks ugly.
@property (strong, nonatomic) UIActivityIndicatorView* spinner;

@property (strong, nonatomic) EarlyAccessOptionsView* earlyAccessView;

@property (nonatomic) NSInteger selectedRow;

@property (nonatomic, strong) NSDictionary* pushNotificationDictionary;

@property (nonatomic, strong) NSFileManager* fileManager;

@property (nonatomic, strong) NSString* challengeImageStorageFolderPath;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ExploreCollectionVC

- (NSMutableDictionary*)challengeImages
{
    if (!_challengeImages) {
        _challengeImages = [[NSMutableDictionary alloc] init];
    }
    return _challengeImages;
}

- (void)emailPressed
{
    if ([MFMailComposeViewController canSendMail]) {
        // Show the composer
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"Flexter Early Access"];
        [controller setToRecipients:[NSArray arrayWithObject:@"support@flexterapp.com"]];
        if (controller) [self presentViewController:controller animated:YES completion:nil];
    } else {
        // Handle the error
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"This device is not configured to send email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    self.navigationController.navigationBarHidden = NO;
    [self.earlyAccessView removeFromSuperview];
}


- (UIRefreshControl*)refreshWorkoutsControl
{
    if (!_refreshWorkoutsControl) {
        _refreshWorkoutsControl = [[UIRefreshControl alloc] init];
        [_refreshWorkoutsControl addTarget:self action:@selector(refreshWorkouts)
                 forControlEvents:UIControlEventValueChanged];
        [self.collectionView addSubview:_refreshWorkoutsControl];
    }
    return _refreshWorkoutsControl;
}

- (NSMutableArray*)challenges
{
    if (!_challenges) {
        _challenges = [[NSMutableArray alloc] init];
    }
    return _challenges;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*!
 * @discussion Reloads workouts by removing existing workouts
 */
- (void)refreshWorkouts
{
    NSLog(@"ExploreCollectionVC refreshWorkouts");
    // Start the refresh control
    [self.refreshWorkoutsControl beginRefreshing];
    
    // We want to remove all existing workouts from the collection view and display once again
    [self loadChallengesAndRemoveExisting:YES];
}

/*!
 * @discussion Loads challenges from the server
 * @param removes existing challenges
 */
- (void)loadChallengesAndRemoveExisting:(BOOL)removeExisting
{
    self.selectedRow = -1;
    
    // Setup the query
    PFQuery *query = [PFQuery queryWithClassName:CHALLENGE_CLASS];
    [query orderByDescending:CHALLENGE_PRIORITY];
    [query addDescendingOrder:UPDATED_AT];
    [query whereKey:CHALLENGE_PUBLIC equalTo:[NSNumber numberWithBool:YES]];
    // If remove exising is not set, we want skip the existing results. Since we always order them, we skip the ones we
    // fetched. This is not bullet proof. Ideally we would need to check things based on objectId. Continued with this
    // to avoid the performance hit. (ex: 100 new and 100 old would mean 10,000 comparisons! We could use a hash table though)
    if (!removeExisting) {
        query.skip = [self.challenges count];
    }
    // Not really needed. Parse limits result count to 100.
    query.limit = 100;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.refreshWorkoutsControl endRefreshing];
        if ([error code] == 0) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %ld workouts.", (unsigned long)objects.count);
            if (removeExisting) {
                [self.challenges removeAllObjects];
            }
            if ([objects count]) {
                [self.challenges addObjectsFromArray:objects];
                if (RESET_CHALLENGE_PURCHASE) {
                    for (FDChallenge* challenge in self.challenges) {
                        if (challenge[CHALLENGE_PURCHASE_IDENTIFIER]) {
                            NSString* key = challenge[CHALLENGE_PURCHASE_IDENTIFIER] ? challenge[CHALLENGE_PURCHASE_IDENTIFIER] : challenge.objectId;
                            [Lockbox setDictionary:nil forKey:key];
                            break;
                        }
                    }
                }
                [self.collectionView reloadData];
				[self updateUnlockAllButton];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            if ([error code] == PARSE_REQUEST_LIMIT_EXCEEDED_CODE) {
                [[Crashlytics sharedInstance] crash];
            }
        }
    }];
}

- (void) updateUnlockAllButton {
	if ([self isAllPurchased]) {
		self.btnUnlockAll.hidden = YES;
		self.valueLabel.hidden = YES;
        self.valueOffLabel.hidden = YES;
		self.allChallengesLabel.text = NSLocalizedString(@"ALL CHALLENGES UNLOCKED",nil);
		return;
	}
	
	__block float unlockAllPrice = 0;
	__block float productTotal = 0;
	__block NSLocale *locale = nil;
	NSMutableArray *productIdentifiers = [NSMutableArray array];
	if ([self.challenges count]) {
		for (FDChallenge* challenge in self.challenges) {
			if (challenge[CHALLENGE_PURCHASE_IDENTIFIER]) {
					[productIdentifiers addObject:challenge[CHALLENGE_PURCHASE_IDENTIFIER]];

			}
		}
		[productIdentifiers addObject:@"com.eleventyninellc.thirtydaychallenge.purchase.unlockall"];
		
		NSSet *products = [NSSet setWithArray:productIdentifiers];
		[[RMStore defaultStore] requestProducts:products success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
			NSLog(@"Products loaded");
			for (SKProduct *product in products) {
				NSLog(@"Product: %@, %@",product.localizedTitle, product.price);
				if (![product.productIdentifier isEqualToString:@"com.eleventyninellc.thirtydaychallenge.purchase.unlockall"]) {
					//[productTotal decimalNumberByAdding:product.price];
					productTotal = productTotal + [product.price floatValue];
				} else {
					NSLog(@"got it %@",product.price);
					unlockAllPrice = unlockAllPrice + [product.price floatValue];
				}
				locale = product.priceLocale;
				
			}
			NSLog(@"%f - %f - %@",productTotal,unlockAllPrice,locale);
			if (productTotal > 0 && unlockAllPrice > 0 && locale != nil) {
				
				NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
				[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
				[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
				[numberFormatter setLocale:locale];
				NSString *productTotalFormatted = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:productTotal]];
				NSString *unlockAllFormatted = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:unlockAllPrice]];
				NSLog(@"%@ for %@",productTotalFormatted,unlockAllFormatted);

				self.valueLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@",nil), productTotalFormatted];
                self.valueOffLabel.text = [NSString stringWithFormat:@"%d%% OFF", (int)(100 - (unlockAllPrice / productTotal * 100))];
                self.allChallengesLabel.text = [NSString stringWithFormat:@"Unlock All Challenges"];
                self.challengesUnlockValue.text = [NSString stringWithFormat:@"%@", unlockAllFormatted];
                self.valueDeleteLine.hidden = NO;

                [[NSUserDefaults standardUserDefaults] setObject:self.allChallengesLabel.text forKey:@"str1"];
                [[NSUserDefaults standardUserDefaults] setObject:self.challengesUnlockValue.text forKey:@"str2"];
                [[NSUserDefaults standardUserDefaults] setObject:self.valueLabel.text forKey:@"str3"];
                [[NSUserDefaults standardUserDefaults] setObject:self.valueOffLabel.text forKey:@"str4"];
				
			}
			
			
		} failure:^(NSError *error) {
			NSLog(@"Something went wrong");
		}];
		
	} else {
		NSLog(@"no challenges");
	}
}

- (BOOL)isAllPurchased {

    if (self.challenges.count == 0) {
        return NO;
    }
    for (FDChallenge* challenge in self.challenges) {
        if (![challenge isPurchased]) {
            return NO;
        }
    }
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.collectionView registerNib:[UINib nibWithNibName:@"ImageAndLabelCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"ExploreCell"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.previousContentoffset = 0;
    self.earlyAccessView = [EarlyAccessOptionsView customView];
    self.earlyAccessView.delegate = self;
    self.selectedRow = -1;
    self.navigationItem.title = @"Fit30";
    self.valueDeleteLine.hidden = YES;
	
    
    [self loadChallengesAndRemoveExisting:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"str1"]) {
        self.allChallengesLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"str1"];
        self.challengesUnlockValue.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"str2"];
        self.valueLabel.text =  [[NSUserDefaults standardUserDefaults] objectForKey:@"str3"];
        self.valueOffLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"str4"];
        self.valueDeleteLine.hidden = NO;
    }
    else{
        [self updateUnlockAllButton];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedPushNotification:)
                                                 name:PUSH_NOTIFICATION
                                               object:nil];

    NSLog(@"ExploreCollectionVC viewWillAppear navigation bar subview count: %ld", (long)[self.navigationController.navigationBar.subviews count]);
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GLOBAL_FONT_TYPE_TEXT size:27],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    self.navigationController.navigationBar.barTintColor = APP_THEME_COLOR;
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    [self addCustomRightBarButtonWithImage:nil];
    if (self.selectedRow != -1) {
        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.selectedRow inSection:0]]];
    } else {
        [self.collectionView reloadData];
    }
}

- (void)addCustomRightBarButtonWithImage:(UIImage*)image
{
    UIButton* customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton setTitle:@"" forState:UIControlStateNormal];
    customButton.layer.cornerRadius = 17.5;
    customButton.clipsToBounds = YES;
    customButton.frame = CGRectMake(0, 0, 35, 35);
    if ([PFUser currentUser]) {
        if (image) {
            [customButton setImage:image forState:UIControlStateNormal];
        } else {
            PFFile* userProfileImageFile = [PFUser currentUser][USER_PROFILE_THUMBNAIL];
            if (userProfileImageFile) {
                [userProfileImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        [self addCustomRightBarButtonWithImage:[UIImage imageWithData:data]];
                    }
                }];
            } else {
                [customButton setImage:[UIImage imageNamed:@"ProfileIcon.png"] forState:UIControlStateNormal];
            }
        }
        [customButton addTarget:self action:@selector(showProfileFromRightBarButton:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [customButton setImage:[UIImage imageNamed:@"SettingsIcon.png"] forState:UIControlStateNormal];
        [customButton addTarget:self action:@selector(showSettingsFromRightBarButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    UIBarButtonItem* rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)showProfileFromRightBarButton:(id)sender
{
    [self performSegueWithIdentifier:@"ShowProfile" sender:nil];
}

- (void)showSettingsFromRightBarButton:(id)sender
{
    [self performSegueWithIdentifier:@"ShowSettings" sender:nil];
}

- (void)showPremiumWalkthroughFromRightBarButton:(id)sender
{
    [self performSegueWithIdentifier:@"ShowPremiumWalkthrough" sender:nil];
}

- (void)receivedPushNotification:(NSNotification *) notification
{
    NSLog(@"ExploreCollectionVC Notification!");
    self.pushNotificationDictionary = notification.userInfo;
    UIAlertView* pushAlert = [[UIAlertView alloc] initWithTitle:@"Notification" message:[notification.userInfo objectForKey:PUSH_NOTIFICATION_MESSAGE] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Show me!", nil];
    [pushAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        [self performSegueWithIdentifier:@"ShowWorkout" sender:[self.pushNotificationDictionary objectForKey:WORKOUT_CLASS]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)purchaseAllPressed:(id)sender {
//    [self performSegueWithIdentifier:@"ShowPurchaseAll" sender:nil];
//    [[Crashlytics sharedInstance] crash];
    [[RMStore defaultStore] addPayment:UNLOCK_ALL_PURCHASE_IDENTIFIER success:^(SKPaymentTransaction *transaction) {
        [FDChallenge persistAllPurchase];
        for (FDChallenge* challenge in self.challenges) {
            [challenge persistPurchase];
        }
        NSLog(@"Product unlock all purchased");
        [PFAnalytics trackEvent:@"boughtIAP" dimensions:@{@"product": UNLOCK_ALL_PURCHASE_IDENTIFIER}];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Hurray!",nil) message:NSLocalizedString(@"Thank you for purchasing All Challenges!",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [alert show];
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        NSLog(@"Something went wrong %@", [error localizedDescription]);
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [alert show];
    }];
}

// Load more workouts if the user is scrolling down and starting to decelerate.
// About 15 workouts are visible in one screen length and we download 100 at a time.
// So, one swipe down should give us enough time to download before the scroll view stops.
//
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"current content offset: %f, content size height: %f, cell height: %f", scrollView.contentOffset.y, self.collectionView.contentSize.height, ((UIView*)[[self.collectionView visibleCells] lastObject]).frame.size.height);
    if ((scrollView.contentOffset.y > self.collectionView.contentSize.height - 10 * ((UIView*)[[self.collectionView visibleCells] lastObject]).frame.size.height) && (scrollView.contentOffset.y > self.previousContentoffset)) {
        self.previousContentoffset = scrollView.contentOffset.y;
        NSLog(@"ExploreCollectionVC loading more because of scrolling");
        [self loadChallengesAndRemoveExisting:NO];
    }
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        if (scrollView.contentOffset.y > 1850) {
            [UIView animateWithDuration:0.2
                                  delay:0
                                options: UIViewAnimationCurveEaseIn
                             animations:^{
                                 [self.collectionView setContentOffset:CGPointMake(0, 2173)];
                                 
                             }
                             completion:^(BOOL finished){
                                 
                             }];
        }
    }
    else{
        if (scrollView.contentOffset.y > 720) {
            [UIView animateWithDuration:0.2
                                  delay:0
                                options: UIViewAnimationCurveEaseIn
                             animations:^{
                                 [self.collectionView setContentOffset:CGPointMake(0, 869)];
                                 
                             }
                             completion:^(BOOL finished){
                                 
                             }];
        }
    }

    
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.challenges count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageAndLabelCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ExploreCell" forIndexPath:indexPath];
    if (indexPath.row == 8) {
        WhiteSpaceCollectionViewCell *whitespacecell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ExploreCell" forIndexPath:indexPath];
        NSLog(@"sdf");
        return whitespacecell;

    }
    else{
        FDChallenge* challenge = (FDChallenge*)[self.challenges objectAtIndex:[indexPath row]];
        if ([challenge isPurchased]) {
            int currentIndex = (int)[challenge inProgressDayIndex];
            cell.statusLabel.text = [NSString stringWithFormat:@"%d%%", currentIndex*100/30];
        } else {
            cell.statusLabel.text = NSLocalizedString(@"NEW!",nil);
        }

        cell.difficultyLabel.text = [FDChallenge userDisplayStringForLevel:challenge[CHALLENGE_LEVEL]];
        [cell.title setText:NSLocalizedString(challenge[CHALLENGE_TITLE],nil)];
        // Not doing this will temporarily show wrong images.
        cell.imageView.image = nil;
        if (indexPath.row == self.selectedRow) {
            cell.selected = YES;
        } else {
            cell.selected = NO;
        }
        if (![self.challengeImages objectForKey:challenge.objectId]) {
            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
            if (challenge[CHALLENGE_FULL_IMAGE_FILE_NAME]) {
                UIImage* image = [UIImage imageNamed:challenge[CHALLENGE_FULL_IMAGE_FILE_NAME]];
                if (image) {
                    [self.challengeImages setObject:image forKey:challenge.objectId];
                    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
                    cell.imageView.image = image;
                }
            } else {
                PFFile* fullImage = challenge[CHALLENGE_FULL_IMAGE_FILE];
                [fullImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        if (cell) {
                            UIImage *image = [UIImage imageWithData:data];
                            if (image) {
                                [self.challengeImages setObject:image forKey:challenge.objectId];
                                cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
                                cell.imageView.image = image;
                            }
                        }
                    }
                }];
            }
        } else {
            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
            cell.imageView.image = [self.challengeImages objectForKey:challenge.objectId];
        }
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
   
    if (![[[[NSUserDefaults alloc] init] objectForKey:PUSH_REGISTRATION_SUCCESS_KEY] boolValue]) {
        [self registerForPushNotifications];
    }
    
    FDChallenge* currentChallenge = [self.challenges objectAtIndex:[indexPath row]];
    NSInteger previousSelectedRow = self.selectedRow;
    self.selectedRow = indexPath.row;
    if (previousSelectedRow != -1 && previousSelectedRow != self.selectedRow) {
        [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:previousSelectedRow inSection:0], [NSIndexPath indexPathForRow:self.selectedRow inSection:0], nil]];
    } else {
        [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.selectedRow inSection:0]]];
    }
    [self performSegueWithIdentifier:@"ShowChallenge" sender:currentChallenge];
    
    NSString *iapName = currentChallenge[@"title"];

    [[NSUserDefaults standardUserDefaults] setObject:iapName forKey:@"revenue"];
  
}
- (void)registerForPushNotifications
{
    // Register for Push Notitications, if running iOS 8
    UIApplication* application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
#endif
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ShowChallenge"]) {
        [segue.destinationViewController setChallenge:sender];
    } else if ([segue.identifier isEqualToString:@"ShowPurchaseAll"]) {
        self.selectedRow = -1;
        [segue.destinationViewController setChallenges:self.challenges];
    }
}

- (void)dealloc
{
    NSLog(@"ExploreCollectionVC dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
