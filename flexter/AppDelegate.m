//
//  AppDelegate.m
//  flexter
//
//  Created by Anurag Tolety on 5/30/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "FDWorkout.h"
#import "UIConstants.h"
#import "Appirater.h"
#import "WorkoutOverviewVC.h"
#import <AVFoundation/AVFoundation.h>
#import "FDChallenge.h"
#import "RMStore.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#define CREATE_TEST_EXERCISES 0

@interface AppDelegate ()


@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Fabric with:@[[Crashlytics class]]];
    [Fabric with:@[[Answers class]]];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];

	[Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
		configuration.applicationId = @"1fTz5yUjg5zJubfnh74XKLPmVlJHdxUSIzVzOBhE";
		configuration.clientKey = @"0DRiS2DadyzbBNAEM1eB0ahPYiagvYresxzqyPWq";
		configuration.server = @"https://parseapi.back4app.com";
	}]];
	
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0.0, 1.0);
    shadow.shadowColor = [UIColor whiteColor];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont fontWithName:GLOBAL_FONT_TYPE_TEXT size:17]}
     forState:UIControlStateNormal];
    // Override point for customization after application launch.
    if (CREATE_TEST_EXERCISES) {
        NSMutableArray* exercises = [[NSMutableArray alloc] init];
        NSMutableArray* workouts = [[NSMutableArray alloc] init];
        PFFile* videoFile = [PFFile fileWithName:@"TestVideo.mp4" contentsAtPath:[[NSBundle mainBundle] pathForResource:@"TestVideoUpload" ofType:@"mp4"]];
        [videoFile save];
        for (int i = 1; i <= 3; i++) {
            // Create the object.
            UIImage* fullImage = [UIImage imageNamed:[NSString stringWithFormat:@"exercise%d.png", i]];
            UIImage* scaledDownImage = [UIImage imageWithCGImage:fullImage.CGImage scale:MAX(1, 1/(fullImage.size.width/280)) orientation:UIImageOrientationUp];
            PFFile* iconImageFile = [PFFile fileWithName:@"IconImage.png" data:UIImagePNGRepresentation(scaledDownImage)];
            PFFile* fullImageFile = [PFFile fileWithName:@"FullImage.png" data:UIImagePNGRepresentation(fullImage)];
            [iconImageFile save];
            FDExercise *exercise = (FDExercise*)[PFObject objectWithClassName:EXERCISE_CLASS];
            exercise[EXERCISE_TITLE] = [NSString stringWithFormat:@"Exercise%d", i];
            exercise[EXERCISE_INSTRUCTIONS] = [NSString stringWithFormat:@"Exercise%d", i];
            exercise[EXERCISE_ICON_IMAGE] = iconImageFile;
            exercise[EXERCISE_VIDEO] = videoFile;
            [exercise save];
            [exercises addObject:exercise];
            FDWorkout* workout = (FDWorkout*)[PFObject objectWithClassName:WORKOUT_CLASS];
            workout[WORKOUT_TITLE] = [NSString stringWithFormat:@"Workout%d", i];
            workout[WORKOUT_ICON_IMAGE] = iconImageFile;
            workout[WORKOUT_FULL_IMAGE] = fullImageFile;
            workout[WORKOUT_COMMENT] = [NSString stringWithFormat:@"Workout%d", i];
            workout[WORKOUT_PUBLIC] = [NSNumber numberWithBool:YES];
            for (int j = 0; j < i; j++) {
                [workout addObject:[exercises objectAtIndex:j] forKey:WORKOUT_EXERCISE_LIST];
                NSMutableDictionary* exerciseConfigDictionary = [[NSMutableDictionary alloc] init];
                [exerciseConfigDictionary setObject:[NSNumber numberWithInt:10*(j+1)] forKey:EXERCISE_CONFIG_DAY1_REPS];
                [exerciseConfigDictionary setObject:[NSNumber numberWithInt:40*(j+1)] forKey:EXERCISE_CONFIG_DAY30_REPS];
                [exerciseConfigDictionary setObject:[NSNumber numberWithFloat:(j+0.5)] forKey:EXERCISE_CONFIG_DURATION_PER_REP_IN_SEC];
                //[exerciseConfigDictionary setObject:[NSNumber numberWithInt:(i%2 == 0) ? 30 : 60] forKey:EXERCISE_CONFIG_DURATION_IN_SEC];
                [workout addObject:exerciseConfigDictionary forKey:WORKOUT_EXERCISE_CONFIG_LIST];
            }
            if (i >= 1 && i <= 4) {
                workout[WORKOUT_TYPE] = [FDWorkout workoutTypeAtIndex:0];
                if (i <= 2) {
                    workout[WORKOUT_HOME] = WORKOUT_HOME_YES;
                }
                [workout addObject:@"India" forKey:WORKOUT_HASHTAG_LIST];
                [workout addObject:@"Delhi" forKey:WORKOUT_HASHTAG_LIST];
            }
            if (i >= 5 && i <= 8) {
                workout[WORKOUT_TYPE] = [FDWorkout workoutTypeAtIndex:1];
                if (i <= 6) {
                    workout[WORKOUT_HOME] = WORKOUT_HOME_YES;
                }
                [workout addObject:@"America" forKey:WORKOUT_HASHTAG_LIST];
                [workout addObject:@"Washington" forKey:WORKOUT_HASHTAG_LIST];
            }
            if (i >= 9 && i <= 12) {
                workout[WORKOUT_TYPE] = [FDWorkout workoutTypeAtIndex:2];
                if (i <= 10) {
                    workout[WORKOUT_HOME] = WORKOUT_HOME_YES;
                }
                [workout addObject:@"Turkey" forKey:WORKOUT_HASHTAG_LIST];
                [workout addObject:@"Istanbul" forKey:WORKOUT_HASHTAG_LIST];
            }
            if (i >= 13 && i <= 15) {
                workout[WORKOUT_TYPE] = [FDWorkout workoutTypeAtIndex:3];
                if (i <= 14) {
                    workout[WORKOUT_HOME] = WORKOUT_HOME_YES;
                }
                [workout addObject:@"England" forKey:WORKOUT_HASHTAG_LIST];
            }
            [workout save];
            [workouts addObject:workout];

        }
        // Create the challenges
        for (int i = 0; i < 3; i++) {
            FDChallenge* challenge = (FDChallenge*)[PFObject objectWithClassName:CHALLENGE_CLASS];
            challenge[CHALLENGE_PRIORITY] = [NSNumber numberWithInt:i];
            challenge[CHALLENGE_PREMIUM] = [NSNumber numberWithBool:YES];
            challenge[CHALLENGE_PUBLIC] = [NSNumber numberWithBool:NO];
            [challenge addObject:[workouts objectAtIndex:i] forKey:CHALLENGE_WORKOUTS];
            switch (i) {
                case 0:
                    challenge[CHALLENGE_TITLE] = @"Ultimate Fat Burner";
                    challenge[CHALLENGE_LEVEL] = [NSNumber numberWithInt:CHALLENGE_LEVEL_BEGINNER];
                    challenge[CHALLENGE_FULL_IMAGE_FILE_NAME] = @"UltimateFatBurnerFull.png";
                    challenge[CHALLENGE_COVER_IMAGE_FILE_NAME] = @"UltimateFatBurnerCover.png";
                    challenge[CHALLENGE_DESCRIPTION] = @"The most efficient way to burn fat. This complete 30 day workout program doesn’t require any equipment or internet connection, so it can be done anytime and anywhere. The workout is fun and challenging. Each day gets progressively harder. ";
                    break;
                  
                case 1:
                    challenge[CHALLENGE_TITLE] = @"Beach Body Abs";
                    challenge[CHALLENGE_LEVEL] = [NSNumber numberWithInt:CHALLENGE_LEVEL_INTERMEDIATE];
                    challenge[CHALLENGE_FULL_IMAGE_FILE_NAME] = @"BeachBodyAbsFull.png";
                    challenge[CHALLENGE_COVER_IMAGE_FILE_NAME] = @"BeachBodyAbsCover.png";
                    challenge[CHALLENGE_DESCRIPTION] = @"Get the beach body abs you always wanted";
                    break;
                    
                case 2:
                    challenge[CHALLENGE_TITLE] = @"Lean Long Legs";
                    challenge[CHALLENGE_LEVEL] = [NSNumber numberWithInt:CHALLENGE_LEVEL_ADVANCED];
                    challenge[CHALLENGE_FULL_IMAGE_FILE_NAME] = @"LeanLongLegsFull.png";
                    challenge[CHALLENGE_COVER_IMAGE_FILE_NAME] = @"LeanLongLegsCover.png";
                    challenge[CHALLENGE_DESCRIPTION] = @"Get those svelte legs to impress";
                    break;
                    
                default:
                    break;
            }
            [challenge save];
        }
    }

    
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification) {
        NSLog(@"AppDelegate App launched through remote notification: %@",notification);
        [self application:application didReceiveRemoteNotification:(NSDictionary*)notification];
    }else{
        NSLog(@"AppDelegate App launched without remote notification.");
    }
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSString *country = [usLocale displayNameForKey: NSLocaleCountryCode value: countryCode];
    [Answers logCustomEventWithName:@"App Launched" customAttributes:@{@"From push notifications":@"NO",
                                                                       @"User's Country":country}];

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"AppDelegate didRegisterForRemoteNotificationsWithDeviceToken called");
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"AppDelegate didRegisterForRemoteNotificationsWithDeviceToken pfinstallation save succeeded");
            NSUserDefaults* defaults = [[NSUserDefaults alloc] init];
            [defaults setObject:[NSNumber numberWithBool:YES] forKey:PUSH_REGISTRATION_SUCCESS_KEY];
        } else {
            NSLog(@"AppDelegate didRegisterForRemoteNotificationsWithDeviceToken pfinstallation save failed!");
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"AppDelegate didFailToRegisterForRemoteNotificationsWithError %@", error);
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"exit");
    NSString *days_left = [[NSUserDefaults standardUserDefaults] objectForKey:@"daysleft"];
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow: 25*60*60];
    localNotif.alertBody = [NSString stringWithFormat:@"Don't forget your workout! Only %@ to go in your workout challenge!", days_left];
    [[UIApplication sharedApplication] scheduleLocalNotification: localNotif];
}


- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    NSUInteger orientations = UIInterfaceOrientationMaskAllButUpsideDown;
    if (self.window.rootViewController) {
        UIViewController *presentedViewController = [[(UINavigationController *)self.window.rootViewController viewControllers] lastObject];
        orientations = [presentedViewController supportedInterfaceOrientations];
    }
    return orientations;
}
@end
