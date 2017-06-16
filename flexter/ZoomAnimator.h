//
//  ZoomAnimator.h
//  flexter
//
//  Created by Anurag Tolety on 1/1/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZoomAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property BOOL reverse;
@property BOOL slide;
@end
