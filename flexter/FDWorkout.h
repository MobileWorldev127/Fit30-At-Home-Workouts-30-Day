//
//  FDWorkout.h
//  flexter
//
//  Created by Anurag Tolety on 5/30/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "FDExercise.h"
#define WORKOUT_TYPE_THIRTY_DAY_BIKINI_BODY_CHALLENGE 10
#define WORKOUT_TYPE_THIRTY_DAY_BIKINI_BODY_CHALLENGE_TEXT @"ThirtyDayBikiniBodyChallenge"
#define WORKOUT_TYPE_MOST_POPULAR 11

@interface FDWorkout : PFObject

+ (NSString*)userDisplayStringForType:(NSNumber*)workoutType;
+ (UIImage*)userDisplayImageForWorkoutType:(NSNumber*)workoutType;
+ (NSString*)databaseStringForType:(NSNumber*)workoutType;
+ (NSString*)homeWorkoutStringForHomeStatus:(NSNumber*)homeStatus;
+ (int)numberOfWorkoutTypes;
+ (int)numberOfPushNotificationWorkoutTypes;
+ (NSNumber*)workoutTypeAtIndex:(NSInteger)index;
+ (NSNumber*)pushNotificationWorkoutTypeAtIndex:(NSInteger)index;

@end
