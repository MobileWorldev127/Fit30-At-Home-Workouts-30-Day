//
//  FDExercise.m
//  flexter
//
//  Created by Anurag Tolety on 5/30/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "FDExercise.h"

@implementation FDExercise

//
// Helper methods
//

+ (BOOL)isDayValid:(int)day {
    if (day < 1) {
        return NO;
    } else {
        if (day > 0 && (day%4 == 0)) {
            return NO;
        } else {
            return YES;
        }
    }
}

+ (int)exerciseRepsCountForConfig:(NSDictionary*)exerciseConfigDictionary onDayIndex:(int)dayIndex
{
    int day1Reps = [[exerciseConfigDictionary objectForKey:EXERCISE_CONFIG_DAY1_REPS] intValue];
    int day30Reps = [[exerciseConfigDictionary objectForKey:EXERCISE_CONFIG_DAY30_REPS] intValue];
    return day1Reps + ((int)((((float)(day30Reps - day1Reps))/22.0) * (dayIndex - dayIndex/4)));
}

+ (NSString*)exerciseConfigStringForConfig:(NSDictionary*)exerciseConfigDictionary onDay:(int)day
{
    if (![FDExercise isDayValid:day]) {
        return nil;
    }
    return [NSString stringWithFormat:NSLocalizedString(@"%d Repetitions",nil), [FDExercise exerciseRepsCountForConfig:exerciseConfigDictionary onDayIndex:(day - 1)]];
}

+ (NSInteger)durationForConfig:(NSDictionary*)exerciseConfigDictionary onDay:(int)day
{
    if (![FDExercise isDayValid:day]) {
        return -1;
    }
    return (int)([[exerciseConfigDictionary objectForKey:EXERCISE_CONFIG_DURATION_PER_REP_IN_SEC] floatValue] * [FDExercise exerciseRepsCountForConfig:exerciseConfigDictionary onDayIndex:(day - 1)]);
}

+ (NSString*)checkStatusStorageKeyForExercise:(FDExercise*)exercise atIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"%@%ld", exercise.objectId, (long)index];
}

@end
