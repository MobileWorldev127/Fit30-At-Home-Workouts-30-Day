//
//  ImageAndLabelCollectionViewCell.m
//  flexter
//
//  Created by Anurag Tolety on 7/12/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "ImageAndLabelCollectionViewCell.h"

@interface ImageAndLabelCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIView *imageTintView;
@property (weak, nonatomic) IBOutlet UIImageView *workoutTypeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *premiumImageView;

@end
@implementation ImageAndLabelCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _workoutTypeImageView.contentMode = UIViewContentModeCenter;
        _isHomeWorkout = YES;
    }
    return self;
}

- (void)setIsHomeWorkout:(BOOL)isHomeWorkout
{
    _isHomeWorkout = isHomeWorkout;
    if (_isHomeWorkout) {
        _workoutTypeImageView.image = [UIImage imageNamed:@"HomeWorkoutIcon.png"];
    } else {
        _workoutTypeImageView.image = [UIImage imageNamed:@"GymWorkoutIcon.png"];
    }
}
- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.imageTintView.alpha = selected ? 0.60 : 0.30;
}

- (void)setIsPremium:(BOOL)isPremium
{
    _isPremium = isPremium;
    self.premiumImageView.hidden = !_isPremium;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
