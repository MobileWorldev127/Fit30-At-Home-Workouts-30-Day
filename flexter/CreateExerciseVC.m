//
//  CreateExerciseVC.m
//  flexter
//
//  Created by Anurag Tolety on 8/26/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "CreateExerciseVC.h"
#import "HSImageSidebarView.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "AddExerciseDetailsVC.h"
#import "FDExercise.h"
#import "UIConstants.h"

#define MAXIMUM_VIDEO_DURATION 15
#define THUMBNAIL_INCREMENT_TIME 0.25
#define THUMBNAIL_TIMESCALE 60

@interface CreateExerciseVC () <HSImageSidebarViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet HSImageSidebarView *videoThumbnailsView;
@property (strong, nonatomic) UIVideoEditorController* videoEditor;
@property (strong, nonatomic) NSMutableArray* editedVideoThumnails;
@property (strong, nonatomic) NSString* editedVideoPath;
@property (strong, nonatomic) NSData* editedVideoData;
@property (weak, nonatomic) IBOutlet UIImageView *exerciseCoverView;
@property (weak, nonatomic) IBOutlet UIButton *playVideoButton;
@property (strong, nonatomic) NSFileManager* fileManager;
@property BOOL exerciseSaved;
@property (strong, nonatomic) FDExercise* exercise;
@property (strong, nonatomic) NSString* youtubeLink;

@end

@implementation CreateExerciseVC

- (NSFileManager*)fileManager
{
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

- (NSString *)editedVideoPath {
    if (!_editedVideoPath) {
        NSURL* baseURL = [[self.fileManager URLsForDirectory:NSDocumentDirectory
                                              inDomains:NSUserDomainMask] lastObject];
        _editedVideoPath = [baseURL.path stringByAppendingPathComponent:@"tempVideo.mp4"];
        NSLog(@"CreateExercise file path: %@", _editedVideoPath);
    }
    return _editedVideoPath;
}

- (NSMutableArray*)editedVideoThumnails
{
    if (!_editedVideoThumnails) {
        _editedVideoThumnails = [[NSMutableArray alloc] init];
    }
    return _editedVideoThumnails;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIVideoEditorController*)videoEditor
{
    if (!_videoEditor) {
        _videoEditor = [[UIVideoEditorController alloc] init];
        _videoEditor.videoMaximumDuration = MAXIMUM_VIDEO_DURATION;
    }
    return _videoEditor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"CreateExerciseVC viewDidLoad");
    // Do any additional setup after loading the view.
    [self.playVideoButton setHidden:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    self.videoThumbnailsView.delegate = self;
    self.exerciseCoverView.contentMode = UIViewContentModeScaleAspectFill;
    self.exerciseCoverView.clipsToBounds = YES;
    self.videoThumbnailsView.rowHeight = 120;
    self.exerciseSaved = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sidebar:(HSImageSidebarView *)sidebar didTapImageAtIndex:(NSUInteger)anIndex
{
    self.exerciseCoverView.image = [self.editedVideoThumnails objectAtIndex:anIndex];
}

- (NSUInteger)countOfImagesInSidebar:(HSImageSidebarView *)sidebar
{
    return [self.editedVideoThumnails count];
}

- (UIImage *)sidebar:(HSImageSidebarView *)sidebar imageForIndex:(NSUInteger)anIndex
{
    return [self.editedVideoThumnails objectAtIndex:anIndex];
}

- (void)videoEditorController:(UIVideoEditorController*)editor
     didSaveEditedVideoToPath:(NSString*)editedVideoPath
{
    NSLog(@"CreateExerciseVC editedVideoPath %@", editedVideoPath);
    if (editedVideoPath) {
        [self.editedVideoThumnails removeAllObjects];
        self.editedVideoData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:editedVideoPath]];
        if (![self.fileManager createFileAtPath:self.editedVideoPath contents:self.editedVideoData attributes:nil]) {
            NSLog(@"CreateExerciseVC saving edited video failed!!!");
            [self dismissViewControllerAnimated:YES completion:nil];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Saving edited video failed. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        AVURLAsset* editedVideoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:editedVideoPath] options:nil];
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:editedVideoAsset];
        generator.appliesPreferredTrackTransform=TRUE;
        NSMutableArray *requestedTimes = [[NSMutableArray alloc] init];
        for (float i = THUMBNAIL_INCREMENT_TIME; i < CMTimeGetSeconds(editedVideoAsset.duration) ; i = i+THUMBNAIL_INCREMENT_TIME) {
            NSValue *requestedTime = [NSNumber valueWithCMTime:CMTimeMakeWithSeconds(i, THUMBNAIL_TIMESCALE)];
            [requestedTimes addObject:requestedTime];
        }
        AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
            if (result != AVAssetImageGeneratorSucceeded) {
                NSLog(@"couldn't generate thumbnail, error:%@", error);
                [self dismissViewControllerAnimated:YES completion:nil];
                return;
            }
            NSLog(@"CreateExerciseVC thumbnail time. Value: %lld, timescale: %d", requestedTime.value, requestedTime.timescale);
            [self.editedVideoThumnails addObject:[UIImage imageWithCGImage:im]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (requestedTime.value == THUMBNAIL_INCREMENT_TIME*THUMBNAIL_TIMESCALE) {
                    self.exerciseCoverView.image = [UIImage imageWithCGImage:im];
                    [self.navigationItem.rightBarButtonItem setEnabled:YES];
                    [self.playVideoButton setHidden:NO];
                }
                [self.videoThumbnailsView reloadData];
            });
        };
        [generator generateCGImagesAsynchronouslyForTimes:requestedTimes completionHandler:handler];
    } else {
        NSLog(@"CreatedExerciseVC edited video has NO data!!!");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    NSURL* mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
    //-----------------------------------------------------------
    // Coder: Anurag Tolety
    // Changed the code here to show UIVideoEditController for the
    // selected video. The current max duration is set to 15s
    //-----------------------------------------------------------
    if ([type isEqualToString:(NSString *)kUTTypeVideo] ||
        [type isEqualToString:(NSString *)kUTTypeMovie])
    {
        self.videoEditor.delegate = self;
        self.videoEditor.videoPath = mediaURL.path;
        [self dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:self.videoEditor animated:YES completion:nil];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (IBAction)takeVideoButtonPressed:(id)sender {
    self.exerciseSaved = NO;
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.delegate = self;
    mediaUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    mediaUI.mediaTypes = @[(NSString *) kUTTypeVideo, (NSString*) kUTTypeMovie];
    [self presentViewController:mediaUI animated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        self.exerciseSaved = NO;
        UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
        mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        mediaUI.allowsEditing = NO;
        mediaUI.delegate = self;
        // 3 - Display image picker
        [self presentViewController:mediaUI animated:YES completion:nil];
    } else if (buttonIndex == 0) {
        UIAlertView* youtubeTextAlert = [[UIAlertView alloc] initWithTitle:@"Input" message:@"Enter the youtube link" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        youtubeTextAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        youtubeTextAlert.delegate = self;
        [youtubeTextAlert show];
    }
}

- (NSString*)youtubeIdInLink:(NSString*)link {
    NSArray* standardYoutubePrefixes = [NSArray arrayWithObjects:@"http://youtu.be/", @"https://youtu.be/",  @"http://www.youtube.com/watch?v=", @"https://www.youtube.com/watch?v=", nil];
    for (NSString* youtubePrefix in standardYoutubePrefixes) {
        if ([link containsString:youtubePrefix]) {
            NSRange range = [link rangeOfString:youtubePrefix];
            return [link substringFromIndex:range.location+range.length];
        }
    }
    return nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString* enteredLink = [alertView textFieldAtIndex:0].text;
        NSString* youtubeId = [self youtubeIdInLink:enteredLink];
        if (youtubeId) {
            self.youtubeLink = enteredLink;
            UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [spinner startAnimating];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
            [self.editedVideoThumnails removeAllObjects];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage* defaultImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/default.jpg", youtubeId]]]];
                if (defaultImage) {
                    [self.editedVideoThumnails addObject:defaultImage];
                }
                UIImage* image0 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg", youtubeId]]]];
                if (image0) {
                    [self.editedVideoThumnails addObject:image0];
                }
                UIImage* image1 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/1.jpg", youtubeId]]]];
                if (image1) {
                    [self.editedVideoThumnails addObject:image1];
                }
                UIImage* image2 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/2.jpg", youtubeId]]]];
                if (image2) {
                    [self.editedVideoThumnails addObject:image2];
                }
                UIImage* image3 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/3.jpg", youtubeId]]]];
                if (image3) {
                    [self.editedVideoThumnails addObject:image3];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner stopAnimating];
                    if ([self.editedVideoThumnails count]) {
                        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"NEXT" style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonPressed:)];
                        self.navigationItem.rightBarButtonItem.tintColor = APP_THEME_COLOR;
                        [self.navigationItem.rightBarButtonItem setEnabled:YES];
                    }
                    [self.videoThumbnailsView reloadData];
                });
            });
            
        } else {
            UIAlertView* wrongLinkAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Link does not containt http(s)://youtu.be/ prefix" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [wrongLinkAlert show];
        }
    }
}
- (IBAction)chooseVideoButtonPressed:(id)sender {
    UIActionSheet* exerciseTypeOptions = [[UIActionSheet alloc] initWithTitle:@"Is this a YouTube exercise?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Yes", @"No", nil];
    [exerciseTypeOptions showInView:self.view];
}

- (IBAction)playVideoButtonPressed:(id)sender {
    MPMoviePlayerViewController* movieController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:self.editedVideoPath]];
    [self presentMoviePlayerViewControllerAnimated:movieController];
    [movieController.moviePlayer play];
}

- (void)handleExerciseSaveFailure
{
    self.exerciseSaved = NO;
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to upload exercise image and video. Check network connection and try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)nextButtonPressed:(UIBarButtonItem *)sender {
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    if (self.exerciseSaved) {
        [self performSegueWithIdentifier:@"AddExerciseDetails" sender:self.exercise];
        NSLog(@"CreateExerciseVC already saved exercise objectID: %@", self.exercise.objectId);
        [spinner stopAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"NEXT" style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonPressed:)];
        self.navigationItem.rightBarButtonItem.tintColor = APP_THEME_COLOR;
        return;
        
    }
    self.exercise = (FDExercise*)[PFObject objectWithClassName:EXERCISE_CLASS];
    [self.exercise saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self performSegueWithIdentifier:@"AddExerciseDetails" sender:self.exercise];
            NSLog(@"CreateExerciseVC created exercise objectID: %@", self.exercise.objectId);
            [spinner stopAnimating];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"NEXT" style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonPressed:)];
            self.navigationItem.rightBarButtonItem.tintColor = APP_THEME_COLOR;
            PFFile* iconImageFile = [PFFile fileWithName:@"IconImage.png" data:UIImagePNGRepresentation(self.exerciseCoverView.image)];
            [iconImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    self.exercise[EXERCISE_ICON_IMAGE] = iconImageFile;
                    NSLog(@"CreateExerciseVC image saved");
                    [self.exercise saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            NSLog(@"CreateExerciseVC image assigned");
                            if (self.youtubeLink) {
                                self.exercise[EXERCISE_VIDEO_TYPE] = [NSNumber numberWithInt:EXERCISE_VIDEO_TYPE_YOUTUBE];
                                self.exercise[EXERCISE_YOUTUBE_ID] = [self youtubeIdInLink:self.youtubeLink];
                                [self.exercise saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    if (succeeded) {
                                        NSLog(@"CreateExerciseVC youtube video assigned");
                                        self.exerciseSaved = YES;
                                    } else {
                                        [self handleExerciseSaveFailure];
                                    }
                                }];
                            } else {
                                PFFile* videoFile = [PFFile fileWithName:@"ExerciseVideo.mp4" contentsAtPath:self.editedVideoPath];
                                [videoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    if (succeeded) {
                                        NSLog(@"CreateExerciseVC video saved");
                                        self.exercise[EXERCISE_VIDEO_TYPE] = [NSNumber numberWithInt:EXERCISE_VIDEO_TYPE_PARSE_STORED];
                                        self.exercise[EXERCISE_VIDEO] = videoFile;
                                        [self.exercise saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                            if (succeeded) {
                                                NSLog(@"CreateExerciseVC video assigned");
                                                self.exerciseSaved = YES;
                                            } else {
                                                [self handleExerciseSaveFailure];
                                            }
                                        }];
                                    } else {
                                        [self handleExerciseSaveFailure];
                                    }
                                }];
                            }
                        } else {
                            [self handleExerciseSaveFailure];
                        }
                    }];
                } else {
                    [self handleExerciseSaveFailure];
                }
            }];
        } else {
            NSLog(@"CreateExerciseVC creating exercise failed!");
            [self handleExerciseSaveFailure];
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"AddExerciseDetails"]) {
        [segue.destinationViewController setExercise:sender];
        [segue.destinationViewController setExerciseCoverImage:[self.exerciseCoverView.image copy]];
        [segue.destinationViewController setExerciseVideoFilePath:self.editedVideoPath];
    }
}


@end
