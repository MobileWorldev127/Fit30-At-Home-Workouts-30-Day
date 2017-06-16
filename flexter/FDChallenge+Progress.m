//
//  FDChallenge+Progress.m
//  flexter
//
//  Created by Anurag Tolety on 6/27/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#import "FDChallenge+Progress.h"
#import "FDChallenge+Keychain.h"
#import "UIConstants.h"

@implementation FDChallenge (Progress)

- (void)setInProgressDayIndex:(NSUInteger)dayIndex {
    NSMutableDictionary* keychainDictionary = [[self getKeychainDictionary] mutableCopy];
    [keychainDictionary setObject:[NSNumber numberWithInteger:dayIndex] forKey:IN_PROGRESS_DAY_INDEX];
    [self setKeychainDictionary:[keychainDictionary copy]];
}

- (NSUInteger)inProgressDayIndex {
    NSDictionary* keychainDictionary = [self getKeychainDictionary];
    return [[keychainDictionary objectForKey:IN_PROGRESS_DAY_INDEX] integerValue];
}

@end
