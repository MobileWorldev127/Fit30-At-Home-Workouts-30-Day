//
//  FDExercise.h
//  flexter
//
//  Created by Anurag Tolety on 5/30/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

#include "FDConstants.h"

@interface FDExercise : PFObject

+ (int)exerciseRepsCountForConfig:(NSDictionary*)exerciseConfigDictionary onDayIndex:(int)dayIndex;
+ (NSString*)exerciseConfigStringForConfig:(NSDictionary*)exerciseConfigDictionary onDay:(int)day;
+ (NSInteger)durationForConfig:(NSDictionary*)exerciseConfigDictionary onDay:(int)day;
+ (NSString*)checkStatusStorageKeyForExercise:(FDExercise*)exercise atIndex:(NSInteger)index;

@end
