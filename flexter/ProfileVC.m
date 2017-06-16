//
//  ProfileVC.m
//  flexter
//
//  Created by Anurag Tolety on 12/5/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "ProfileVC.h"
#import "UIConstants.h"
#import <Parse/Parse.h>
#import "FDConstants.h"
#import "FlexterAnalyticsEvents.h"
#import "ImageAndLabelCollectionViewCell.h"
#import "FDWorkout.h"
#import "WorkoutOverviewVC.h"
#import "ProfileCollectionViewCell.h"
#import "FDActivity.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+ProportionalFill.h"
#import "IBActionSheet.h"
#import "FXBlurView.h"
#import <Crashlytics/Crashlytics.h>

#define PROFILE_CELL_HEIGHT 275
#define SECTION_COUNT 2
#define PROFILE_SECTION 0
#define WORKOUT_SECTION 1
#define USER_DATA_FOLDER @"UserData"

@interface ProfileVC () <ProfileImageProtocol, IBActionSheetDelegate>

//@property (weak, nonatomic) IBOutlet UICollectionView *exerciseCollectionView;
@property (nonatomic) int selectedRow;
@property (strong, nonatomic) NSMutableArray* workouts;
@property (strong, nonatomic) UIRefreshControl* refreshWorkoutsControl;
@property NSInteger previousContentoffset;
@property (strong, nonatomic) UILabel* titleView;
@property (strong, nonatomic) UIImage* profileImage;
@property (strong, nonatomic) NSFileManager* fileManager;
@property (strong, nonatomic) NSString* profileImagePath;
@property (strong, nonatomic) UIImage* blurredProfileBackgroundImage;

@end

@implementation ProfileVC

@synthesize profileImage = _profileImage;

- (UIImage*)blurredProfileBackgroundImage
{
    if (!_blurredProfileBackgroundImage) {
        _blurredProfileBackgroundImage = [[UIImage imageNamed:@"LoginBackground.png"] blurredImageWithRadius:150 iterations:1 tintColor:APP_THEME_COLOR];
    }
    return _blurredProfileBackgroundImage;
}

- (NSFileManager*)fileManager
{
    if (!_fileManager) {
        _fileManager = [[NSFileManager alloc] init];
    }
    return _fileManager;
}

- (NSString*)profileImagePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString* userDataFolderPath= [cacheDirectory stringByAppendingPathComponent:USER_DATA_FOLDER];
    NSLog(@"user data storage path: %@", userDataFolderPath);
    if (![self.fileManager fileExistsAtPath:userDataFolderPath isDirectory:nil]) {
        BOOL succeeded = [self.fileManager createDirectoryAtPath:userDataFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"create user data storage directory pass or fail: %d", succeeded);
    }
    _profileImagePath = [userDataFolderPath stringByAppendingPathComponent:@"ProfilePicture.png"];
    return _profileImagePath;
}

- (void)setProfileImage:(UIImage *)profileImage
{
    if (profileImage) {
        _profileImage = profileImage;
        NSData* data = UIImagePNGRepresentation(profileImage);
        [data writeToFile:self.profileImagePath atomically:NO];
        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:PROFILE_SECTION], nil]];
    }
}

- (UIImage*)profileImage
{
    if (!_profileImage) {
        if ([self.fileManager fileExistsAtPath:self.profileImagePath]) {
            NSData* imageData = [NSData dataWithContentsOfFile:self.profileImagePath];
            if (imageData) {
                _profileImage = [UIImage imageWithData:imageData];
            }
        } else {
            if ([PFUser currentUser][USER_PROFILE_IMAGE]) {
                PFFile* profileImageFile = [PFUser currentUser][USER_PROFILE_IMAGE];
                [profileImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    self.profileImage = [UIImage imageWithData:data];
                }];
            }
        }
        if (!_profileImage) {
            _profileImage = [UIImage imageNamed:@"ProfilePicture.png"];
        }
    }
    return _profileImage;
}

- (NSMutableArray*)workouts
{
    if (!_workouts) {
        _workouts = [[NSMutableArray alloc] init];
    }
    return _workouts;
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

- (UILabel*)titleView
{
    if (!_titleView) {
        _titleView = [[UILabel alloc] init];
        _titleView.font = [UIFont fontWithName:GLOBAL_FONT_TYPE_TEXT size:18];
        _titleView.numberOfLines = 0;
        _titleView.textColor = [UIColor whiteColor];
    }
    return _titleView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ImageAndLabelCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"ExploreCell"];
    [self.collectionView registerClass:[ProfileCollectionViewCell class] forCellWithReuseIdentifier:@"ProfileCell"];
    self.selectedRow = -1;
    self.previousContentoffset = 0;
    [self loadLikedWorkoutsAndRemoveExisting:YES];
}

//
// refreshWorkouts
//
// Reloads the workouts
//
- (void)refreshWorkouts
{
    NSLog(@"ExploreCollectionVC refreshWorkouts");
    // Start the refresh control
    [self.refreshWorkoutsControl beginRefreshing];
    
    // We want to remove all existing workouts from the collection view and display once again
    [self loadLikedWorkoutsAndRemoveExisting:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureNavigationBarToInitialConfiguration
{
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.collectionView.delegate = self;
    [UIView animateWithDuration:0.25 animations:^{
        self.collectionView.frame = CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height + 64);
        [self configureNavigationBarToInitialConfiguration];
        if (self.collectionView.contentOffset.y > PROFILE_CELL_HEIGHT - 64) {
            [self addNavigationTitle:YES];
        }
    }];
    NSUserDefaults* defaults = [[NSUserDefaults alloc] init];
    NSArray* likedWorkoutArray = [defaults objectForKey:LIKED_WORKOUTS_ARRAY_KEY];
    if ([likedWorkoutArray count] != [self.workouts count] && [self.workouts count] != 0) {
        [self refreshWorkouts];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.titleView removeFromSuperview];
    self.collectionView.delegate = nil;
}
//
// loadWorkoutsWithOptions
//
// Loads the workouts based on the filter options and the remove existing boolean.
//
- (void)loadLikedWorkoutsAndRemoveExisting:(BOOL)removeExisting
{
    self.selectedRow = -1;
    
    // Setup the query
    PFQuery *query = [PFQuery queryWithClassName:ACTIVITY_CLASS];
    [query orderByDescending:CREATED_AT];
    [query whereKey:ACTIVITY_FROM_USER equalTo:[PFUser currentUser]];
    [query whereKey:ACTIVITY_TYPE equalTo:ACTIVITY_TYPE_LIKE];
    [query includeKey:ACTIVITY_WORKOUT];
    // If remove exising is not set, we want skip the existing results. Since we always order them, we skip the ones we
    // fetched. This is not bullet proof. Ideally we would need to check things based on objectId. Continued with this
    // to avoid the performance hit. (ex: 100 new and 100 old would mean 10,000 comparisons! We could use a hash table though)
    if (!removeExisting) {
        query.skip = [self.workouts count];
    }
    // Not really needed. Parse limits result count to 100.
    query.limit = 100;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.refreshWorkoutsControl endRefreshing];
        if ([error code] == 0) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %ld workouts.", (unsigned long)objects.count);
            if (removeExisting) {
                [self.workouts removeAllObjects];
            }
            if ([objects count]) {
                for (FDActivity* activity in objects) {
                    [self.workouts addObject:activity[ACTIVITY_WORKOUT]];
                }
                [self.collectionView reloadData];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            if ([error code] == PARSE_REQUEST_LIMIT_EXCEEDED_CODE) {
            }
        }
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //-----------------------------------------------------------
    // Coder: Anurag Tolety
    // Changed the code here to show UIVideoEditController for the
    // selected video. The current max duration is set to 15s
    //-----------------------------------------------------------
    if ([type isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
        self.profileImage = image;
        PFUser* currentUser = [PFUser currentUser];
        PFFile* profileImage = [PFFile fileWithName:@"ProfileImage.png" data:UIImagePNGRepresentation(image)];
        PFFile* profileThumbnail = [PFFile fileWithName:@"ProfileThumbnail.png" data:UIImagePNGRepresentation([image imageCroppedToFitSize:CGSizeMake(70, 70)])];
        currentUser[USER_PROFILE_IMAGE] = profileImage;
        currentUser[USER_PROFILE_THUMBNAIL] = profileThumbnail;
        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:PROFILE_SECTION], nil]];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"ProfileVC saving profile pic succeeded");
            } else {
                NSLog(@"ProfileVC saving profile pic FAILED!");
            }
        }];
    }
}

- (void)handleProfileCellSelection
{
    IBActionSheet *actionSheet = [[IBActionSheet alloc] initWithTitle:@"Change your profile picture"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take Photo", @"Choose from Library", nil];
    [actionSheet setFont:[UIFont fontWithName:GLOBAL_FONT_TYPE_TEXT size:18]];
    [actionSheet setButtonTextColor:APP_THEME_COLOR forButtonAtIndex:0];
    [actionSheet setButtonTextColor:APP_THEME_COLOR forButtonAtIndex:1];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.delegate = self;
    if (buttonIndex == 0) {
        mediaUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else if (buttonIndex == 1) {
        mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    } else {
        return;
    }
    mediaUI.mediaTypes = @[(NSString *) kUTTypeImage];
    mediaUI.allowsEditing = YES;
    [self presentViewController:mediaUI animated:YES completion:nil];
}
//
// scrollViewWillBeginDecelerating
//
// Load more workouts if the user is scrolling down and starting to decelerate.
// About 15 workouts are visible in one screen length and we download 100 at a time.
// So, one swipe down should give us enough time to download before the scroll view stops.
//
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"current content offset: %f, content size height: %f, cell height: %f", scrollView.contentOffset.y, self.collectionView.contentSize.height, ((UIView*)[[self.collectionView visibleCells] lastObject]).frame.size.height);
    if ((scrollView.contentOffset.y > self.collectionView.contentSize.height - 10 * ((UIView*)[[self.collectionView visibleCells] lastObject]).frame.size.height) && (scrollView.contentOffset.y > self.previousContentoffset)) {
        self.previousContentoffset = scrollView.contentOffset.y;
        NSLog(@"ExploreCollectionVC loading more because of scrolling");
        [self loadLikedWorkoutsAndRemoveExisting:NO];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == PROFILE_SECTION) {
        return CGSizeMake(self.view.frame.size.width, PROFILE_CELL_HEIGHT);
    } else {
        return CGSizeMake(self.view.frame.size.width, 160);
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return SECTION_COUNT;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    } else {
        return [self.workouts count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == PROFILE_SECTION) {
        ProfileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileCell" forIndexPath:indexPath];
        cell.delegate = self;
        [cell configureWithUserName:[PFUser currentUser].username andWorkoutCount:(int)[self.workouts count] andProfileImage:self.profileImage];
        cell.layer.contents = (id)self.blurredProfileBackgroundImage.CGImage;
        return cell;
    }
    ImageAndLabelCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ExploreCell" forIndexPath:indexPath];
    FDWorkout* workout = (FDWorkout*)[self.workouts objectAtIndex:[indexPath row]];
    [cell.title setText:workout[WORKOUT_TITLE]];
    cell.isPremium = [workout[WORKOUT_PREMIUM] boolValue];
    // Not doing this will temporarily show wrong images.
    cell.imageView.image = nil;
    PFFile* iconImage = workout[WORKOUT_ICON_IMAGE];
    if (indexPath.row == self.selectedRow) {
        cell.selected = YES;
    } else {
        cell.selected = NO;
    }
    [iconImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
            cell.imageView.image = image;
        }
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == PROFILE_SECTION) {
        return;
    }
    FDWorkout* currentWorkout = [self.workouts objectAtIndex:[indexPath row]];
    NSDictionary* eventParams = [NSDictionary dictionaryWithObjectsAndKeys:currentWorkout.objectId, FLEXTER_ANALYTICS_EVENT_PARAM_OBJECT_ID,
                                 currentWorkout[WORKOUT_TYPE], FLEXTER_ANALYTICS_EVENT_PARAM_WORKOUT_TYPE, nil];
    NSInteger previousSelectedRow = self.selectedRow;
    self.selectedRow = (int)indexPath.row;
    if (previousSelectedRow != -1 && previousSelectedRow != self.selectedRow) {
        [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:previousSelectedRow inSection:WORKOUT_SECTION], [NSIndexPath indexPathForRow:self.selectedRow inSection:WORKOUT_SECTION], nil]];
    } else {
        [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.selectedRow inSection:WORKOUT_SECTION]]];
    }
    [self performSegueWithIdentifier:@"ShowWorkout" sender:[self.workouts objectAtIndex:[indexPath row]]];
}


- (void)addNavigationTitle:(BOOL)addTitle
{
    if (addTitle) {
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.view.backgroundColor = [UIColor blackColor];
        self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
        [self.titleView removeFromSuperview];
        self.titleView.text = [NSString stringWithFormat:@"@%@",[PFUser currentUser].username];
        [self.titleView sizeToFit];
        self.titleView.center = CGPointMake(self.view.frame.size.width/2, 32 - self.titleView.frame.size.height/2);
        //if (![self.titleView superview]) {
        [self.navigationController.navigationBar addSubview:self.titleView];
        //}
    } else {
        [self configureNavigationBarToInitialConfiguration];
        [self.titleView removeFromSuperview];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > PROFILE_CELL_HEIGHT - 64) {
        [self addNavigationTitle:YES];
    } else {
        [self addNavigationTitle:NO];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ShowWorkout"]) {
        [segue.destinationViewController setWorkout:sender];
    }
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

@end
