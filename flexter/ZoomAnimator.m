//
//  ZoomAnimator.m
//  flexter
//
//  Created by Anurag Tolety on 1/1/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#import "ZoomAnimator.h"

@implementation ZoomAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.375;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController* toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (self.reverse) {
        [[transitionContext containerView] insertSubview:toVC.view belowSubview:fromVC.view];
        toVC.view.alpha = 1;
        toVC.view.transform = CGAffineTransformIdentity;
    } else {
        [[transitionContext containerView] addSubview:toVC.view];
        toVC.view.alpha = 0;
        toVC.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
    }
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (self.reverse) {
            fromVC.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
            fromVC.view.alpha = 0;
        } else {
            toVC.view.alpha = 1;
            fromVC.view.alpha = 0;
            toVC.view.transform = CGAffineTransformIdentity;
        }
    } completion:^(BOOL finished) {
        fromVC.view.alpha = self.reverse ? 0 : 1;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}
@end
