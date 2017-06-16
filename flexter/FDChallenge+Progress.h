//
//  FDChallenge+Progress.h
//  flexter
//
//  Created by Anurag Tolety on 6/27/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#import "FDChallenge.h"

@interface FDChallenge (Progress)

- (void)setInProgressDayIndex:(NSUInteger)dayIndex;
- (NSUInteger)inProgressDayIndex;

@end
