//
//  FDChallenge.h
//  flexter
//
//  Created by Anurag Tolety on 3/17/15.
//  Copyright (c) 2015 Mike Xhaxho & Anurag Tolety Innovations. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "FDWorkout.h"

@interface FDChallenge : PFObject<PFSubclassing>

+ (NSString*)userDisplayStringForLevel:(NSNumber*)level;

@end
