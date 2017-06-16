//
//  TimerFinishedProtocol.h
//  flexter
//
//  Created by Anurag Tolety on 7/23/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TimerFinishedProtocol <NSObject>

- (void)timerFinished:(int)countdownTimeInSec withTag:(NSInteger)tag;
- (void)timerStarted:(int)countdownTimeInSec withTag:(NSInteger)tag;

@end
