//
//  OvalTimerView.h
//  flexter
//
//  Created by Anurag Tolety on 7/19/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimerFinishedProtocol.h"

@interface OvalTimerView : UIView

@property (nonatomic) NSInteger countdownTimeInSec;
@property (readonly) BOOL isRunning;
@property (weak, nonatomic) id<TimerFinishedProtocol> finishDelegate;

- (void)startTimer;
- (void)stopTimer;
- (void)resetTimer;

@end
