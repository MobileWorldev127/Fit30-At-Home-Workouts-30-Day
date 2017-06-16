//
//  ChallengeStatusView.m
//  flexter
//
//  Created by Anurag Tolety on 4/8/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#import "ChallengeStatusView.h"
#import "YLProgressBar.h"
#import "UIConstants.h"

@interface ChallengeStatusView ()

@property (strong, nonatomic) UIButton* purchaseButton;
@property (strong, nonatomic) YLProgressBar* progressBar;

@end
@implementation ChallengeStatusView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIButton*)purchaseButton {
    if (!_purchaseButton) {
        _purchaseButton = [[UIButton alloc] initWithFrame:CGRectMake(6, 6, self.frame.size.width - 12, self.frame.size.height - 12)];
    }
    return _purchaseButton;
}

- (YLProgressBar*)progressBar {
    if (!_progressBar) {
        _progressBar = [[YLProgressBar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
    return _progressBar;
}

- (void)setPurchased:(BOOL)purchased {
    _purchased = purchased;
    if (_purchased) {
        [_purchaseButton removeFromSuperview];
        self.layer.borderColor = APP_THEME_COLOR.CGColor;
        self.layer.borderWidth = 1;
    }
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    if (_purchased) {
        _progressBar.progress = progress;
    }
}

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

- (void)setPrice:(CGFloat)price {
    _price = price;
    [self.purchaseButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"BUY CHALLENGE ($%0.02f)", nil), self.price] forState:UIControlStateNormal];
    self.purchaseButton.enabled = YES;
}

- (void)initializeDefaults {
    [self.purchaseButton setBackgroundImage:[UIImage imageNamed:@"BuyChallengeImage.png"] forState:UIControlStateNormal];
    self.purchaseButton.titleLabel.font = [UIFont fontWithName:GLOBAL_FONT_TYPE_TEXT size:20];
    [self.purchaseButton setTitle:NSLocalizedString(@"BUY CHALLENGE",nil) forState:UIControlStateNormal];
    self.purchaseButton.titleLabel.textColor = [UIColor whiteColor];
    self.purchaseButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.purchaseButton.enabled = NO;
    [self.purchaseButton addTarget:self action:@selector(purchaseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.progressBar.type = YLProgressBarTypeFlat;
    self.progressBar.progressTintColors = [NSArray arrayWithObjects:APP_THEME_COLOR, APP_THEME_COLOR, nil];
    self.progressBar.hideStripes = YES;
    self.progressBar.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
    self.progressBar.trackTintColor = [UIColor whiteColor];
    self.progressBar.indicatorTextLabel.font = [UIFont fontWithName:GLOBAL_FONT_TYPE_TEXT size:15];
    self.progressBar.indicatorTextLabel.textColor = [UIColor whiteColor];
    self.progressBar.progress = 0.0;
    [self addSubview:self.progressBar];
    [self addSubview:self.purchaseButton];
}

- (void)purchaseButtonPressed {
    NSLog(@"purchase button pressed");
    [self.delegate purchaseChallenge];
}
@end
