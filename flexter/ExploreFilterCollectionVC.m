//
//  ExploreFilterCollectionVC.m
//  flexter
//
//  Created by Anurag Tolety on 10/17/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "ExploreFilterCollectionVC.h"
#import "ExploreCollectionVC.h"
#import "FDConstants.h"
#import "UIConstants.h"
#import "FDWorkout.h"
#import "WorkoutOverviewVC.h"

@interface ExploreFilterCollectionVC () <UIAlertViewDelegate>

@property (nonatomic, strong) NSDictionary* pushNotificationDictionary;

@end

@implementation ExploreFilterCollectionVC

static NSString * const reuseIdentifier = @"FilterOptionCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
}

- (void)handleScreenshotTaken
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:CANCEL_ACTION_SHEET_TITLE
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:SEND_FEEDBACK_ACTION_SHEET_TITLE, REPORT_A_BUG_ACTION_SHEET_TITLE, nil];
    [actionSheet showInView:self.view];
}

- (void)dealloc
{
    NSLog(@"ExploreFilterCollectionVC dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"ExploreFilterCollectionVC viewWillAppear");
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedPushNotification:)
                                                 name:PUSH_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScreenshotTaken) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GLOBAL_FONT_TYPE_TEXT size:18],NSFontAttributeName, nil]];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    self.navigationItem.title = @"TONED";
    self.navigationController.navigationBar.barTintColor = APP_THEME_COLOR;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.hidesBackButton = YES;
    // When opening this view from a workout via a push notification, if the user hits start workout there, we set a background image. That will continue influencing here is we don't set the background image to an emtpy image.
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
}

- (void) receivedPushNotification:(NSNotification *) notification
{
    NSLog(@"ExploreFilterCollectionVC Notification!");
    self.pushNotificationDictionary = notification.userInfo;
    UIAlertView* pushAlert = [[UIAlertView alloc] initWithTitle:@"Notification" message:[notification.userInfo objectForKey:PUSH_NOTIFICATION_MESSAGE] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Show me!", nil];
    [pushAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        UIStoryboard *storybboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WorkoutOverviewVC * workoutOverviewVC  = [storybboard instantiateViewControllerWithIdentifier:@"WorkoutOverviewVC"];
        workoutOverviewVC.workout = [self.pushNotificationDictionary objectForKey:WORKOUT_CLASS];
        [self.navigationController pushViewController:workoutOverviewVC animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"ExploreFilterCollectionVC viewWillDisappear");
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ShowWorkoutCollection"]) {
        [segue.destinationViewController setTitle:[FDWorkout userDisplayStringForType:[FDWorkout workoutTypeAtIndex:((NSIndexPath*)[[self.collectionView indexPathsForSelectedItems] lastObject]).row]]];
    }
}

#pragma mark <UICollectionViewDataSource>

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//#warning Incomplete method implementation -- Return the number of sections
//    return 0;
//}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    // Configure the cell
    for (UIView* view in [cell subviews]) {
        if ([view class] == [UIImageView class]) {
            [view removeFromSuperview];
        }
    }
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    imageView.image = [FDWorkout userDisplayImageForWorkoutType:[FDWorkout workoutTypeAtIndex:indexPath.row]];
    [cell addSubview:imageView];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/


// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"ExploreFilterCollectionVC workout index selected: %lu, type: %d", (long)indexPath.row, [[FDWorkout workoutTypeAtIndex:indexPath.row] intValue]);
    [self performSegueWithIdentifier:@"ShowWorkoutCollection" sender:[NSArray arrayWithObject:[FDWorkout workoutTypeAtIndex:indexPath.row]]];
}


- (BOOL)canBecomeFirstResponder
{
    return YES;
}
/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

@end
