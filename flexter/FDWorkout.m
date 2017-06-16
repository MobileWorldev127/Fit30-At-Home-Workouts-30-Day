//
//  FDWorkout.m
//  flexter
//
//  Created by Anurag Tolety on 5/30/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "FDWorkout.h"

#define WORKOUT_TYPE_COUNT 12
#define WORKOUT_TYPE_THIRTY_DAY_BEGINNER_CHALLENGE 0
#define WORKOUT_TYPE_THIRTY_DAY_BEGINNER_CHALLENGE_TEXT @"ThirtyDayBeginnerChallenge"
#define WORKOUT_TYPE_HOME_WORKOUTS 1
#define WORKOUT_TYPE_HOME_WORKOUTS_TEXT @"HomeWorkouts"
#define WORKOUT_TYPE_HIIT_CARDIO 2
#define WORKOUT_TYPE_HIIT_CARDIO_TEXT @"HIITCardio"
#define WORKOUT_TYPE_BEACH_ABS 3
#define WORKOUT_TYPE_BEACH_ABS_TEXT @"BeachAbs"
#define WORKOUT_TYPE_LEAN_LEGS_TIGHT_TUSH 4
#define WORKOUT_TYPE_LEAN_LEGS_TIGHT_TUSH_TEXT @"LeanLegsTightTush"
#define WORKOUT_TYPE_SEVEN_MINUTE_WORKOUT 5
#define WORKOUT_TYPE_SEVEN_MINUTE_WORKOUT_TEXT @"SevenMinutes"
#define WORKOUT_TYPE_IMPRESS_THE_LADIES 6
#define WORKOUT_TYPE_IMPRESS_THE_LADIES_TEXT @"ImpressTheLadies"
#define WORKOUT_TYPE_SHE_LIFTS 7
#define WORKOUT_TYPE_SHE_LIFTS_TEXT @"SheLifts"
#define WORKOUT_TYPE_SPECIALITY 8
#define WORKOUT_TYPE_SPECIALITY_TEXT @"Speciality"
#define WORKOUT_TYPE_ATHLETIC_TRAINING 9
#define WORKOUT_TYPE_ATHLETIC_TRAINING_TEXT @"AthleticTraining"


@implementation FDWorkout

+ (NSString*)databaseStringForType:(NSNumber*)workoutType
{
    if ([workoutType intValue] == WORKOUT_TYPE_THIRTY_DAY_BEGINNER_CHALLENGE) {
        return WORKOUT_TYPE_THIRTY_DAY_BEGINNER_CHALLENGE_TEXT;
    } else if ([workoutType intValue] == WORKOUT_TYPE_HOME_WORKOUTS) {
        return WORKOUT_TYPE_HOME_WORKOUTS_TEXT;
    } else if ([workoutType intValue] == WORKOUT_TYPE_HIIT_CARDIO) {
        return WORKOUT_TYPE_HIIT_CARDIO_TEXT;
    } else if ([workoutType intValue] == WORKOUT_TYPE_BEACH_ABS) {
        return WORKOUT_TYPE_BEACH_ABS_TEXT;
    } else if ([workoutType intValue] == WORKOUT_TYPE_LEAN_LEGS_TIGHT_TUSH) {
        return WORKOUT_TYPE_LEAN_LEGS_TIGHT_TUSH_TEXT;
    } else if ([workoutType intValue] == WORKOUT_TYPE_SEVEN_MINUTE_WORKOUT) {
        return WORKOUT_TYPE_SEVEN_MINUTE_WORKOUT_TEXT;
    } else if ([workoutType intValue] == WORKOUT_TYPE_IMPRESS_THE_LADIES) {
        return WORKOUT_TYPE_IMPRESS_THE_LADIES_TEXT;
    } else if ([workoutType intValue] == WORKOUT_TYPE_SHE_LIFTS) {
        return WORKOUT_TYPE_SHE_LIFTS_TEXT;
    } else if ([workoutType intValue] == WORKOUT_TYPE_SPECIALITY) {
        return WORKOUT_TYPE_SPECIALITY_TEXT;
    } else if ([workoutType intValue] == WORKOUT_TYPE_ATHLETIC_TRAINING) {
        return WORKOUT_TYPE_ATHLETIC_TRAINING_TEXT;
    } else if ([workoutType intValue] == WORKOUT_TYPE_THIRTY_DAY_BIKINI_BODY_CHALLENGE) {
        return WORKOUT_TYPE_THIRTY_DAY_BIKINI_BODY_CHALLENGE_TEXT;
    }
    return nil;
}

+ (NSString*)userDisplayStringForType:(NSNumber*)workoutType
{
    if ([workoutType intValue] == WORKOUT_TYPE_THIRTY_DAY_BEGINNER_CHALLENGE) {
        return NSLocalizedString(@"30 Day Beginner Challenge",nil);
    } else if ([workoutType intValue] == WORKOUT_TYPE_HOME_WORKOUTS) {
        return NSLocalizedString(@"Home Workouts",nil);
    } else if ([workoutType intValue] == WORKOUT_TYPE_HIIT_CARDIO) {
        return NSLocalizedString(@"HIIT Cardio",nil);
    } else if ([workoutType intValue] == WORKOUT_TYPE_BEACH_ABS) {
        return NSLocalizedString(@"Beach Abs",nil);
    } else if ([workoutType intValue] == WORKOUT_TYPE_LEAN_LEGS_TIGHT_TUSH) {
        return NSLocalizedString(@"Lean Legs, Tight Tush",nil);
    } else if ([workoutType intValue] == WORKOUT_TYPE_SEVEN_MINUTE_WORKOUT) {
        return NSLocalizedString(@"7 Minutes",nil);
    } else if ([workoutType intValue] == WORKOUT_TYPE_IMPRESS_THE_LADIES) {
        return NSLocalizedString(@"Impress the Ladies",nil);
    } else if ([workoutType intValue] == WORKOUT_TYPE_SHE_LIFTS) {
        return NSLocalizedString(@"(S)he Lifts",nil);
    } else if ([workoutType intValue] == WORKOUT_TYPE_SPECIALITY) {
        return NSLocalizedString(@"Speciality",nil);
    } else if ([workoutType intValue] == WORKOUT_TYPE_ATHLETIC_TRAINING) {
        return NSLocalizedString(@"Athletic Training",nil);
    } else if ([workoutType intValue] == WORKOUT_TYPE_THIRTY_DAY_BIKINI_BODY_CHALLENGE) {
        return NSLocalizedString(@"30 Day Bikini Body Challenge",nil);
    } else if ([workoutType intValue] == WORKOUT_TYPE_MOST_POPULAR) {
        return NSLocalizedString(@"Most Popular",nil);
    }
    return nil;
}

+ (NSString*)homeWorkoutStringForHomeStatus:(NSNumber*)homeStatus
{
    if ([homeStatus boolValue]) {
        return @"Home Workout";
    } else {
        return @"Gym Workout";
    }
}

+ (int)numberOfWorkoutTypes
{
    return WORKOUT_TYPE_COUNT;
}

+ (int)numberOfPushNotificationWorkoutTypes
{
    return WORKOUT_TYPE_COUNT - 1;
}

+ (NSNumber*)pushNotificationWorkoutTypeAtIndex:(NSInteger)index
{
    NSNumber* workoutType = nil;
    switch (index) {
        case 0:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_THIRTY_DAY_BEGINNER_CHALLENGE];
            break;
            
        case 1:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_THIRTY_DAY_BIKINI_BODY_CHALLENGE];
            break;
            
        case 2:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_HOME_WORKOUTS];
            break;
            
        case 3:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_LEAN_LEGS_TIGHT_TUSH];
            break;
            
        case 4:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_BEACH_ABS];
            break;
            
        case 5:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_HIIT_CARDIO];
            break;
            
        case 6:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_SEVEN_MINUTE_WORKOUT];
            break;
            
        case 7:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_IMPRESS_THE_LADIES];
            break;
            
        case 8:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_SHE_LIFTS];
            break;
            
        case 9:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_SPECIALITY];
            break;
            
        case 10:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_ATHLETIC_TRAINING];
            break;
                        
        default:
            break;
    }
    return workoutType;
}

+ (NSNumber*)workoutTypeAtIndex:(NSInteger)index
{
    NSNumber* workoutType = nil;
    switch (index) {
        case 0:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_THIRTY_DAY_BEGINNER_CHALLENGE];
            break;
            
        case 1:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_THIRTY_DAY_BIKINI_BODY_CHALLENGE];
            break;
         
        case 2:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_MOST_POPULAR];
            break;
            
        case 3:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_HOME_WORKOUTS];
            break;
            
        case 4:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_LEAN_LEGS_TIGHT_TUSH];
            break;
            
        case 5:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_BEACH_ABS];
            break;
            
        case 6:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_HIIT_CARDIO];
            break;
            
        case 7:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_SEVEN_MINUTE_WORKOUT];
            break;
            
        case 8:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_IMPRESS_THE_LADIES];
            break;
            
        case 9:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_SHE_LIFTS];
            break;
            
        case 10:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_SPECIALITY];
            break;
            
        case 11:
            workoutType = [NSNumber numberWithInt:WORKOUT_TYPE_ATHLETIC_TRAINING];
            break;
            
        default:
            break;
    }
    return workoutType;
}

+ (UIImage*)userDisplayImageForWorkoutType:(NSNumber*)workoutType
{
    UIImage* workoutImage = nil;
    switch ([workoutType intValue]) {
        case WORKOUT_TYPE_THIRTY_DAY_BEGINNER_CHALLENGE:
            workoutImage = [UIImage imageNamed:@"ThirtyDayBeginnerChallenge.png"];
            break;
            
        case WORKOUT_TYPE_HOME_WORKOUTS:
            workoutImage = [UIImage imageNamed:@"HomeWorkouts.png"];
            break;
            
        case WORKOUT_TYPE_HIIT_CARDIO:
            workoutImage = [UIImage imageNamed:@"HIITCardio.png"];
            break;
            
        case WORKOUT_TYPE_SEVEN_MINUTE_WORKOUT:
            workoutImage = [UIImage imageNamed:@"SevenMinutes.png"];
            break;
            
        case WORKOUT_TYPE_LEAN_LEGS_TIGHT_TUSH:
            workoutImage = [UIImage imageNamed:@"LeanLegsTightTush.png"];
            break;
            
        case WORKOUT_TYPE_BEACH_ABS:
            workoutImage = [UIImage imageNamed:@"BeachAbs.png"];
            break;
            
        case WORKOUT_TYPE_IMPRESS_THE_LADIES:
            workoutImage = [UIImage imageNamed:@"ImpressTheLadies.png"];
            break;
            
        case WORKOUT_TYPE_SHE_LIFTS:
            workoutImage = [UIImage imageNamed:@"SheLifts.png"];
            break;
            
        case WORKOUT_TYPE_SPECIALITY:
            workoutImage = [UIImage imageNamed:@"Specialty.png"];
            break;
            
        case WORKOUT_TYPE_ATHLETIC_TRAINING:
            workoutImage = [UIImage imageNamed:@"AthleticTraining.png"];
            break;
            
        case WORKOUT_TYPE_THIRTY_DAY_BIKINI_BODY_CHALLENGE:
            workoutImage = [UIImage imageNamed:@"ThirtyDayBikiniBodyChallenge.png"];
            break;
            
        case WORKOUT_TYPE_MOST_POPULAR:
            workoutImage = [UIImage imageNamed:@"MostPopular.png"];
            break;
            
        default:
            break;
    }
    return workoutImage;
}
@end
