//
//  WorkoutOverviewVC.m
//  flexter
//
//  Created by Anurag Tolety on 7/16/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//
//  Purpose: Provide an overview of the workout including the exercises
//

#import "WorkoutOverviewVC.h"
#import "WorkoutHeaderView.h"
#import "ExerciseTableViewCell.h"
#import "MSCellAccessory.h"
#import "UIConstants.h"
#import "FDCustomKeyValuePairs.h"
#import "YLProgressBar.h"
#import "OvalTimerView.h"
#import "FlexterAnalyticsEvents.h"
#import <AVFoundation/AVFoundation.h>
#import "FDWorkout.h"
#import "FDActivity.h"
#import "ZoomTransitioningDelegate.h"
#import "YLProgressBar.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FDExercise.h"
#import <Crashlytics/Crashlytics.h>

#define EXERCISE_VIDEO_STORAGE_FOLDER @"ExerciseVideoStorageFolder"
#define EXERCISE_VIDEO_STORAGE_FOLDER_MAX_SIZE 200*1024*1024 // 200 MB

#define EXERCISE_SECTION 0
#define TIMER_PADDING 5.0
#define INVISIBLE_TEXT @"This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. This should be invisible. "
#define EXTRA_SPACE_FOR_LOW_EXERCISE_COUNT 60
#define LOW_EXERCISE_COUNT_CAP 6
#define END_WORKOUT_PRESS_COUNT_KEY @"EndWorkoutPressCount"
#define MIN_WORKOUT_VIEW_TIME_TO_SHOW_OPTIONS 180

@interface WorkoutOverviewVC () <UITableViewDataSource, UITableViewDelegate, ExerciseCellProtocol, UIAlertViewDelegate, AVPlayerViewControllerDelegate, MPMediaPlayback, CLLocationManagerDelegate>{
    CGFloat offset_x, offset_y, offset_width;
    BOOL playbackDurationSet;
    NSTimeInterval starttime, endtime;
}

@property (weak, nonatomic) IBOutlet UITableView *exercisesTableView;
@property (strong, nonatomic) UIActivityIndicatorView* spinner;
@property (nonatomic) NSInteger selectedRow;
@property (weak, nonatomic) IBOutlet UIView *progressBarContainerView;
@property (strong, nonatomic) NSMutableDictionary* exerciseCheckStatus;
@property BOOL workoutDataFetched;
@property BOOL showOverview;
@property BOOL showPreWorkoutEndOptions;
@property (strong, nonatomic) NSDictionary* flurryParameters;
@property (strong, nonatomic) NSDate* workoutStartTime;
@property (nonatomic, strong) NSDictionary* pushNotificationDictionary;
@property (nonatomic, strong) UIAlertView* errorAlert;
@property int runningTimerIndex;
@property int runningTimerCountdownCount;
@property (strong, nonatomic) AVAudioPlayer* audioPlayer;
@property (strong, nonatomic) ZoomTransitioningDelegate* zoomTransitioningDelegate;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (strong, nonatomic) MPMoviePlayerController* moviePlayer;
@property (strong, nonatomic) AVPlayerViewController    * AVPlayerViewController;
@property (weak, nonatomic) IBOutlet UILabel *lbl_progress_percent;
@property(nonatomic) NSTimeInterval initialPlaybackTime;
@property(nonatomic) NSTimeInterval endPlaybackTime;
@property (weak, nonatomic) IBOutlet UIView *progressbar;

@property (strong, nonatomic) FDExercise* exercise;

@end

@implementation WorkoutOverviewVC

- (ZoomTransitioningDelegate*)zoomTransitioningDelegate
{
    if (!_zoomTransitioningDelegate) {
        _zoomTransitioningDelegate = [[ZoomTransitioningDelegate alloc] init];
    }
    return _zoomTransitioningDelegate;
}

- (void)setWorkout:(FDWorkout *)workout
{
    _workout = workout;
}

- (UIAlertView*)errorAlert
{
    if (!_errorAlert) {
        _errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error!",nil) message:NSLocalizedString(@"Unable to connect to the server.",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Try Again",nil) otherButtonTitles:nil];
    }
    return _errorAlert;
}

- (NSDictionary*)flurryParameters
{
    if (!_flurryParameters) {
        _flurryParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.workout[WORKOUT_TYPE], FLEXTER_ANALYTICS_EVENT_PARAM_WORKOUT_TYPE,
                             self.workout.objectId, FLEXTER_ANALYTICS_EVENT_PARAM_OBJECT_ID,
                             nil];
    }
    return _flurryParameters;
}

- (void)showFeedbackOptions
{
    self.showPreWorkoutEndOptions = YES;
    [self performSegueWithIdentifier:@"ShowFeedbackOptions" sender:nil];
}

- (void)showShareOptions
{
    self.showPreWorkoutEndOptions = YES;
    [self performSegueWithIdentifier:@"ShowShareAppOptions" sender:nil];
}

- (void)showPushOptions:(NSString*)channel
{
    self.showPreWorkoutEndOptions = YES;
    [self performSegueWithIdentifier:@"ShowPushOptions" sender:channel];
}

- (void)showFilterOptions
{
    [self performSegueWithIdentifier:@"ShowFilterOptions" sender:nil];
}

- (NSMutableDictionary*)exerciseCheckStatus
{
    if (!_exerciseCheckStatus) {
        _exerciseCheckStatus = [[NSMutableDictionary alloc] init];
    }
    return _exerciseCheckStatus;
}

- (UIActivityIndicatorView*)spinner
{
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _spinner;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    offset_x = _progressbar.frame.origin.x;
    offset_y = _progressbar.frame.origin.y;
    
    _progressbar.frame = CGRectMake(offset_x, offset_y, 0, 54);
    
    [self.doneButton setTitle:NSLocalizedString(@"Success", nil) forState:UIControlStateNormal];
    [self.btnCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    self.showPreWorkoutEndOptions = NO;
    self.exercisesTableView.dataSource = self;
    self.exercisesTableView.delegate = self;
    [self.exercisesTableView registerNib:[UINib nibWithNibName:@"ExerciseTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ExerciseCell"];
    [self.exercisesTableView setSeparatorColor:[UIColor lightTextColor]];
    self.showOverview = YES;
    

    _lbl_progress_percent.text = @"0%";
    // Load the workout header and download the exercises. The workout header is displayed as a cell in its own section
    [self loadWorkoutAndExercises];
    self.selectedRow = -1;
    self.runningTimerIndex = -1;
    self.runningTimerCountdownCount = 0;
    [self setupAudioPlayer];

}

- (void)handleScreenshotTaken
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(CANCEL_ACTION_SHEET_TITLE,nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(SEND_FEEDBACK_ACTION_SHEET_TITLE,nil), NSLocalizedString(REPORT_A_BUG_ACTION_SHEET_TITLE,nil), nil];
    [actionSheet showInView:self.view];
}

- (void)doneButtonPressed
{
    [self showFilterOptions];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedPushNotification:)
                                                 name:PUSH_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleScreenshotTaken)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];
    
}

- (void) receivedPushNotification:(NSNotification *) notification
{
    self.pushNotificationDictionary = notification.userInfo;
    UIAlertView* pushAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification",nil) message:NSLocalizedString([notification.userInfo objectForKey:PUSH_NOTIFICATION_MESSAGE],nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"Show me!",nil), nil];
    [pushAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.errorAlert) {
        if (buttonIndex == 0) {
            [self loadWorkoutAndExercises];
        }
    } else {
        if (buttonIndex != 0) {
            self.workout = [self.pushNotificationDictionary objectForKey:WORKOUT_CLASS];
            [self loadWorkoutAndExercises];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.showPreWorkoutEndOptions) {
        self.showPreWorkoutEndOptions = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)loadWorkoutAndExercises
{
    self.workoutDataFetched = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.spinner];
    [self.spinner startAnimating];
    NSDictionary * seenAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [PFObject fetchAllIfNeededInBackground:self.workout[WORKOUT_EXERCISE_LIST] block:^(NSArray *objects, NSError *error) {
        [self.spinner stopAnimating];
        if ([error code] == 0) {
            NSLog(@"WorkoutOverviewVC all of the workout downloaded objectid: %@", self.workout.objectId);
            self.workoutDataFetched = YES;
            if ([self.workout[WORKOUT_EXERCISE_LIST] count] < LOW_EXERCISE_COUNT_CAP) {
                [self.exercisesTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, EXTRA_SPACE_FOR_LOW_EXERCISE_COUNT * (LOW_EXERCISE_COUNT_CAP - [self.workout[WORKOUT_EXERCISE_LIST] count]))]];
            }
            [UIView transitionWithView: self.exercisesTableView
                              duration: 0.5
                               options: UIViewAnimationOptionTransitionCrossDissolve
                            animations: ^(void)
             {
                 [self.exercisesTableView reloadData];
             }
                            completion: ^(BOOL isFinished)
             {
                 
             }];
        } else {
            NSLog(@"error: %@", [error description]);
            self.navigationItem.rightBarButtonItem = nil;
            [self.errorAlert show];
        }
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // We show just one section after workout has been started
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // We show just one section after workout has been started
    if (!self.workoutDataFetched) {
        self.exercisesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else {
        self.exercisesTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.exercisesTableView.separatorColor = [UIColor colorWithRed:0.823 green:0.815 blue:0.815 alpha:1.0];
        self.exercisesTableView.separatorInset = UIEdgeInsetsZero;
    }
    return (self.workoutDataFetched) ? ([self.workout[WORKOUT_EXERCISE_LIST] count]) : 0;
}

- (void)videoButtonPressedWithIndex:(NSInteger)index
{
    self.selectedRow = index;
    //    [self performSegueWithIdentifier:@"ShowExerciseFromOverview" sender:(FDExercise*)[self.workout[WORKOUT_EXERCISE_LIST] objectAtIndex:index]];
}

- (void)checkMarkPressedWithCurrentStatus:(BOOL)selected andIndex:(NSInteger)index
{
    // Check off the current exercise
    FDExercise* exercise = (FDExercise*)[self.workout[WORKOUT_EXERCISE_LIST] objectAtIndex:index];
    [self.exerciseCheckStatus setObject:[NSNumber numberWithBool:selected] forKey:[FDExercise checkStatusStorageKeyForExercise:exercise atIndex:index]];
    int firstUncheckedIndex = -1;
    for (int i = 0; i < [self.workout[WORKOUT_EXERCISE_LIST] count]; i++) {
        if (![[self.exerciseCheckStatus objectForKey:[FDExercise checkStatusStorageKeyForExercise:((FDExercise*)[self.workout[WORKOUT_EXERCISE_LIST] objectAtIndex:i]) atIndex:i]] boolValue]) {
            firstUncheckedIndex = i;
            NSLog(@"WorkoutOverviewVC first unchecked index: %d", i);
            break;
        }
    }
    
    // Handle selecting and deselecting the rows.
    if ((self.selectedRow >= 0) && (self.selectedRow < [self.workout[WORKOUT_EXERCISE_LIST] count])) {
        [self tableView:self.exercisesTableView didDeselectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:EXERCISE_SECTION]];
    }
    if (firstUncheckedIndex != -1) {
        [self.exercisesTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:firstUncheckedIndex inSection:EXERCISE_SECTION] animated:YES scrollPosition:UITableViewScrollPositionBottom];
        self.selectedRow = firstUncheckedIndex;
    }
    [self updateWorkoutProgress];
}

- (void)updateWorkoutProgress
{
    int finishCount = 0;
    for (int i = 0; i < [self.workout[WORKOUT_EXERCISE_LIST] count]; i++) {
        FDExercise* exercise = [self.workout[WORKOUT_EXERCISE_LIST] objectAtIndex:i];
        if ([[self.exerciseCheckStatus objectForKey:[FDExercise checkStatusStorageKeyForExercise:exercise atIndex:i]] boolValue]) {
            finishCount++;
        }
    }
    NSLog(@"WorkoutOverviewVC finish count: %ld, %ld", (long)finishCount, (long)[self.workout[WORKOUT_EXERCISE_LIST] count]);
    
    CGFloat percentf = floor(finishCount*1.0/[self.workout[WORKOUT_EXERCISE_LIST] count]*100);
    self.lbl_progress_percent.text = [NSString stringWithFormat:@"%@%@", [NSString stringWithFormat:@"%.f",floor(finishCount*1.0/[self.workout[WORKOUT_EXERCISE_LIST] count]*100)], @"%"];
    offset_width = self.view.frame.size.width*percentf/100;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         _progressbar.frame = CGRectMake(offset_x, offset_y, offset_width, 54);
                         NSLog(@"sdf");
                     }
                     completion:^(BOOL finished){

                     }];

}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // We show just one section after workout has been started
    NSLog(@"WorkoutOverviewVC cellForRowAtIndexPath indexPath section: %ld, row: %ld", (long)[indexPath section], (long)[indexPath row]);
    ExerciseTableViewCell *cell = (ExerciseTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ExerciseCell"];
    [cell configureWithIndex:indexPath.row withWorkoutRunningMode:YES];
    cell.showCheckMark = YES;
    cell.delegate = self;
    FDExercise* exercise = (FDExercise*)[self.workout[WORKOUT_EXERCISE_LIST] objectAtIndex:[indexPath row]];
    cell.titleLabel.text = NSLocalizedString(exercise[EXERCISE_TITLE],nil);
    NSDictionary* exerciseConfigDictionary = [self.workout[WORKOUT_EXERCISE_CONFIG_LIST] objectAtIndex:[indexPath row]];
    // The exercise config stuff is zero based
    cell.subtitleLabel.text = NSLocalizedString([FDExercise exerciseConfigStringForConfig:exerciseConfigDictionary onDay:self.dayInChallenge],nil);
    cell.showTimer = NO;
    cell.checked = [[self.exerciseCheckStatus objectForKey:[FDExercise checkStatusStorageKeyForExercise:exercise atIndex:indexPath.row]] boolValue];
    PFFile* iconImage = exercise[EXERCISE_ICON_IMAGE];
    cell.leftImageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell.leftImageView setClipsToBounds:YES];
    cell.leftImageView.image = [UIImage imageNamed:@"ThumbnailExercise.png"];
    if (self.selectedRow == indexPath.row) {
        cell.selected = YES;
    } else {
        cell.selected = NO;
    }
    cell.showVideoButton = NO;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSLog(@"WorkoutOverviewVC place holder set");
    [iconImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            if (cell) {
                UIImage *image = [UIImage imageWithData:data];
                cell.leftImageView.image = image;
                NSLog(@"WorkoutOverviewVC image set");
                [cell setNeedsLayout];
            }
        }
    }];
    return cell;
}

- (void)setupAudioPlayer
{
    NSString *toneFilename = [[NSBundle mainBundle] pathForResource:@"ParkNotifySound" ofType:@"wav"];
    NSURL *toneURLRef = [NSURL fileURLWithPath:toneFilename];
    NSLog(@"ParkingSM setUpAudioSession toneURLRef: %@", toneURLRef);
    NSError* error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: toneURLRef error: &error];
    NSLog(@"ParkingSM setUpAudioSession error: %@", [error description]);
    self.audioPlayer.currentTime = 0;
    self.audioPlayer.volume = 1.0f;
    self.audioPlayer.numberOfLoops = 0;
    [self.audioPlayer prepareToPlay];
}


- (void)timerStarted:(int)countdownTimeInSec withTag:(NSInteger)tag
{
    NSLog(@"WorkoutOverviewVC timer started with tag: %ld", (long)tag);
    self.runningTimerIndex = (int)tag;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExerciseTableViewCell* cell = (ExerciseTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    NSLog(@"cell class %@", [[cell class] description]);
    cell.showVideoButton = NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // We show just one section after workout has been started
    
    NSLog(@"WorkoutOverview didSelectRowAtIndexPath. section: %ld, row: %ld", (long)indexPath.section, (long)indexPath.row);
    self.selectedRow = indexPath.row;
    FDExercise* currentExercise = (FDExercise*)[self.workout[WORKOUT_EXERCISE_LIST] objectAtIndex:indexPath.row];
    starttime = [currentExercise[EXERCISE_START_TIME] intValue];
    endtime = [currentExercise[EXERCISE_END_TIME] intValue];
    NSString *youtubeId = currentExercise[EXERCISE_YOUTUBE_ID];

    [self setupMoviePlayerForS3:[NSString stringWithFormat:@"http://fitthirty.s3.amazonaws.com/%@-sd.mp4",youtubeId]];
  
    int days_completed = [[[NSUserDefaults standardUserDefaults] objectForKey:@"workoutday"] intValue];
    int days_left = 30 - days_completed;
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", days_left] forKey:@"daysleft"];

}

- (void)notificationTime{
    
    NSString *str = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"workoutday"]];
    UIAlertView *pushAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Push Notification", nil) message:[NSString stringWithFormat:@"Don't forget your workout! Only %@ to go in your workout challenge!", str] delegate:self cancelButtonTitle:NSLocalizedString(@"Ok",nil) otherButtonTitles:nil, nil];
    [pushAlert show];
}

-(void)DownloadVideo
{
    NSLog(@"sdfdsf");
    //download the file in a seperate thread.
    
    NSLog(@"Downloading Started");
    NSString *urlToDownload = @"http://fitthirty.s3.amazonaws.com/Jru5B044HOs-sd.mp4";
    NSURL  *url = [NSURL URLWithString:urlToDownload];
    NSError *error = nil;
    NSData *urlData = [NSData dataWithContentsOfURL:url options:nil error:&error];
    
    if ( urlData )
    {
        NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];
        
        NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"thefile.mp4"];
        
    }
    
}



- (void)configureCloseButton
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ShowExerciseFromOverview"]) {
        [segue.destinationViewController setExercise:sender];
        ((UIViewController*)segue.destinationViewController).transitioningDelegate = self.zoomTransitioningDelegate;
    } else if ([segue.identifier isEqualToString:@"ShowPushOptions"]) {
        [segue.destinationViewController setChannel:sender];
    } else if ([segue.identifier isEqualToString:@"ShowShareAppOptions"]) {
        [segue.destinationViewController setDay:[self.workoutCompleteDelegate dayIndex]];
    }
}

- (void)dealloc
{
    NSLog(@"WorkoutOverviewVC dealloc");
    self.exercisesTableView.delegate = nil;
    self.exercisesTableView.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (IBAction)doneButtonPressed:(id)sender {
    [self showShareOptions];
    [self.workoutCompleteDelegate workoutCompleted];
    
    NSString *day = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"workoutday"]];
    NSString *challengename = [[NSUserDefaults standardUserDefaults] objectForKey:@"revenue"];
    [Answers logCustomEventWithName:@"Workout completed" customAttributes:@{@"Challenge Name":challengename,
                                                                       @"Day#":day}];
}

- (IBAction)cancelButtonPressed:(id)sender {
    int firstUncheckedIndex = -1;
    for (int i = 0; i < [self.workout[WORKOUT_EXERCISE_LIST] count]; i++) {
        if (![[self.exerciseCheckStatus objectForKey:[FDExercise checkStatusStorageKeyForExercise:((FDExercise*)[self.workout[WORKOUT_EXERCISE_LIST] objectAtIndex:i]) atIndex:i]] boolValue]) {
            firstUncheckedIndex = i;
            NSLog(@"WorkoutOverviewVC first unchecked index: %d", i);
            break;
        }
    }
    [self resetPlayerDurationVar];
    [self.workoutCompleteDelegate workoutCancelledWithInProgressExerciseIndex:firstUncheckedIndex];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setupMoviePlayerForS3:(NSString *)url
{
    playbackDurationSet=NO;
    
    NSString *video_url = url;
    NSURL *videofileURL = [NSURL URLWithString:video_url];
    
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:videofileURL];
    [self.moviePlayer play];
    
    self.moviePlayer.initialPlaybackTime = starttime;
    self.moviePlayer.endPlaybackTime = endtime;

 
    [self.moviePlayer.view setFrame:CGRectMake(0, 0, self.videoView.frame.size.width, self.videoView.frame.size.height)];
    [self.moviePlayer.backgroundView setBackgroundColor:[UIColor whiteColor]];
    [self.videoView addSubview:self.moviePlayer.view];
    self.moviePlayer.repeatMode = MPMovieRepeatModeOne;
    [self.moviePlayer setCurrentPlaybackTime:self.moviePlayer.initialPlaybackTime];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerPlaybackStateChanged:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];

}

- (void)moviePlayerPlaybackStateChanged:(NSNotification*)notification{
    self.moviePlayer = (MPMoviePlayerController*)notification.object;
    
    switch ( self.moviePlayer.playbackState ) {
        case MPMoviePlaybackStatePlaying:
            
            if(!playbackDurationSet){
                [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
                [self.moviePlayer setCurrentPlaybackTime:self.moviePlayer.initialPlaybackTime];
                playbackDurationSet=YES;
            }

            break;

        default:
            break;
    }
}

- (void)timeAction{
    
    if (_moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        
        NSTimeInterval positcurrent = self.moviePlayer.currentPlaybackTime;
        NSTimeInterval positend = self.moviePlayer.endPlaybackTime;
        if (positcurrent > positend) {
            [self.moviePlayer pause];
            playbackDurationSet = YES;
            NSLog(@"stop");
        }
        
        
    }
}

- (void)resetPlayerDurationVar{
    playbackDurationSet=NO;
}

@end
