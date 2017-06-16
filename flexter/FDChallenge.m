//
//  FDChallenge.m
//  flexter
//
//  Created by Anurag Tolety on 3/17/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#import "FDChallenge.h"
#import <Parse/PFObject+Subclass.h>

@implementation FDChallenge

+ (NSString*)userDisplayStringForLevel:(NSNumber*)level {
    NSString* levelString = nil;
    switch ([level intValue]) {
        case CHALLENGE_LEVEL_BEGINNER:
            levelString = NSLocalizedString(@"Beginner", nil);
            break;
            
        case CHALLENGE_LEVEL_INTERMEDIATE:
            levelString = NSLocalizedString(@"Intermediate",nil);
            break;
            
        case CHALLENGE_LEVEL_ADVANCED:
            levelString = NSLocalizedString(@"Advanced",nil);
            break;
            
        default:
            break;
    }
    return levelString;
}

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Challenge";
}

@end
