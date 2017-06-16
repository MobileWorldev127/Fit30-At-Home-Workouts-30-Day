//
//  EarlyAccessOptionsView.h
//  flexter
//
//  Created by Anurag Tolety on 9/18/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EarlyAccessOptionsProtocol <NSObject>

- (void)closePressed;
- (void)emailPressed;

@end

@interface EarlyAccessOptionsView : UIView

@property (weak, nonatomic) id<EarlyAccessOptionsProtocol> delegate;
+ (id)customView;

@end
