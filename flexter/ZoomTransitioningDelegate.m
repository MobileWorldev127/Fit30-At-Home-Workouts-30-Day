//
//  ZoomTransitioningDelegate.m
//  flexter
//
//  Created by Anurag Tolety on 1/2/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#import "ZoomTransitioningDelegate.h"
#import "ZoomAnimator.h"

@interface ZoomTransitioningDelegate ()

@property (strong, nonatomic) ZoomAnimator* zoomAnimator;

@end
@implementation ZoomTransitioningDelegate

- (ZoomAnimator*)zoomAnimator
{
    if (!_zoomAnimator) {
        _zoomAnimator = [[ZoomAnimator alloc] init];
    }
    return _zoomAnimator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.zoomAnimator.reverse = NO;
    return self.zoomAnimator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.zoomAnimator.reverse = YES;
    return self.zoomAnimator;
}

@end
