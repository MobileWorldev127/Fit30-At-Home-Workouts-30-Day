//
//  ChallengeStatusView.h
//  flexter
//
//  Created by Anurag Tolety on 4/8/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChallengeStatusProtocol <NSObject>

@required
- (void)purchaseChallenge;

@end

@interface ChallengeStatusView : UIView

@property (nonatomic) BOOL purchased;
@property (nonatomic) CGFloat progress;
@property (nonatomic) CGFloat price;
@property (weak, nonatomic) id<ChallengeStatusProtocol> delegate;

@end
