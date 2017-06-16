//
//  OvalTimerView.m
//  flexter
//
//  Created by Anurag Tolety on 7/19/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "OvalTimerView.h"
#import "UIConstants.h"
#import <AudioToolbox/AudioToolbox.h>
#import "FlexterAnalyticsEvents.h"
#import <Crashlytics/Crashlytics.h>

#define TIMER_UPDATE_DURATION 1

@interface OvalTimerView ()

@property (strong, nonatomic) UILabel *countdownTimeLabel;
@property NSInteger currentCountdownTime;
@property (readwrite) BOOL isRunning;

@end

@implementation OvalTimerView

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"OvalTimerView initWithFrame");
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeDefaults];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    NSLog(@"OvalTimerView initWithCoder");
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeDefaults];
    }
    return self;
}

- (void)initializeDefaults
{
    // Initialization code
    _currentCountdownTime = 0;
    _isRunning = NO;
    _countdownTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - self.frame.size.width)/2, self.frame.size.width, self.frame.size.width)];
    _countdownTimeLabel.textAlignment = NSTextAlignmentCenter;
    _countdownTimeLabel.textColor = [UIColor lightGrayColor];
    _countdownTimeLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:25];
    //[_countdownTimeLabel sizeThatFits:self.frame.size];
    [self addSubview:_countdownTimeLabel];
    UITapGestureRecognizer* singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    singleTapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTapGesture];
}

- (void)setCountdownTimeInSec:(NSInteger)countdownTimeInSec
{
    self.currentCountdownTime = countdownTimeInSec;
    _countdownTimeInSec = countdownTimeInSec;
    self.countdownTimeLabel.text = [NSString stringWithFormat:@"%ld", (long)(self.currentCountdownTime)];
    [self setNeedsDisplay];
}

- (void)startTimer
{
    self.isRunning = YES;
    [self.finishDelegate timerStarted:(int)self.countdownTimeInSec withTag:self.tag];
    self.countdownTimeLabel.textColor = APP_THEME_COLOR;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (self.isRunning) {
            if (self.currentCountdownTime == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self stopTimer];
                    self.countdownTimeLabel.text = [NSString stringWithFormat:@"%ld", (long)(self.countdownTimeInSec)];
                    self.currentCountdownTime = self.countdownTimeInSec;
                    [self setNeedsDisplay];
                    [self.finishDelegate timerFinished:(int)self.countdownTimeInSec withTag:self.tag];
                });
                break;
            }
            self.currentCountdownTime -= TIMER_UPDATE_DURATION;
            dispatch_async(dispatch_get_main_queue(), ^{
                    self.countdownTimeLabel.text = [NSString stringWithFormat:@"%ld", (long)(self.currentCountdownTime)];
                [self setNeedsDisplay];
            });
            sleep(TIMER_UPDATE_DURATION);
        }
    });
}

- (void)stopTimer
{
    self.isRunning = NO;
    if (self.currentCountdownTime > 0 && self.currentCountdownTime < self.countdownTimeInSec) {
        self.countdownTimeLabel.textColor = APP_THEME_COLOR;
    } else {
        self.countdownTimeLabel.textColor = [UIColor lightGrayColor];
    }
    [self setNeedsDisplay];
}

- (void)resetTimer
{
    self.isRunning = NO;
    self.currentCountdownTime = self.countdownTimeInSec;
    self.countdownTimeLabel.textColor = [UIColor lightGrayColor];
    self.countdownTimeLabel.text = [NSString stringWithFormat:@"%ld", (long)(self.currentCountdownTime)];
    [self setNeedsDisplay];
}

- (void)handleSingleTap
{
    if (self.isRunning) {
        [self stopTimer];
        [self resetTimer];
    } else {
        [self startTimer];
    }
}

//+ (id)customView
//{
//    OvalTimerView *customView = [[[NSBundle mainBundle] loadNibNamed:@"OvalTimerView" owner:nil options:nil] lastObject];
//    
//    // make sure customView is not nil or the wrong class!
//    if ([customView isKindOfClass:[OvalTimerView class]])
//        return customView;
//    else
//        return nil;
//}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGFloat lineWidth = 4;
    CGFloat startAngle = ((CGFloat)(self.countdownTimeInSec - self.currentCountdownTime))*2*M_PI/((CGFloat)self.countdownTimeInSec) - M_PI_2;
    CGPoint centerPoint = CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
    float radius = MIN(rect.size.width/2, rect.size.height/2) - lineWidth/2;
    CGFloat endAngle = - M_PI/2;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [APP_THEME_COLOR CGColor]);
    
    UIBezierPath *greenPath = [UIBezierPath bezierPath];
    [greenPath addArcWithCenter:centerPoint radius:radius startAngle:startAngle endAngle:endAngle clockwise:NO];
    [greenPath setLineWidth:lineWidth];
    [greenPath stroke];
    
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    
    UIBezierPath *grayPath = [UIBezierPath bezierPath];
    if (startAngle == endAngle) {
        endAngle = 3*M_PI_2;
    }
    [grayPath addArcWithCenter:centerPoint radius:radius startAngle:endAngle endAngle:startAngle clockwise:NO];
    [grayPath setLineWidth:lineWidth];
    [grayPath stroke];
}


@end
