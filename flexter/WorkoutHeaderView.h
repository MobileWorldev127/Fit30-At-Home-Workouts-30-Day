//
//  WorkoutHeaderView.h
//  flexter
//
//  Created by Anurag Tolety on 7/17/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

typedef enum DisplayMode : NSUInteger {
    kSeeLess,
    kSeeMore
} DisplayMode;

@interface WorkoutHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *hashtagLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *descriptionLabel;
@property (nonatomic) DisplayMode displayMode;

+ (id)customView;

@end
