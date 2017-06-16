//
//  WorkoutHeaderView.m
//  flexter
//
//  Created by Anurag Tolety on 7/17/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "WorkoutHeaderView.h"
#import "UIConstants.h"
#define DISPLAY_MODE_Y_CONSTRAINT_DIFFERENCE 150

@interface WorkoutHeaderView ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hashtagYConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionYConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBackgroundYConstraint;

@end
@implementation WorkoutHeaderView

- (void)setDisplayMode:(DisplayMode)displayMode
{
    if (_displayMode == displayMode) {
        return;
    }
    _displayMode = displayMode;
    if (_displayMode == kSeeLess) {
        _descriptionLabel.truncationTokenString = @" ... See less";
        _descriptionLabel.numberOfLines = 14;
        _hashtagYConstraint.constant = _hashtagYConstraint.constant - DISPLAY_MODE_Y_CONSTRAINT_DIFFERENCE;
        _descriptionYConstraint.constant = _descriptionYConstraint.constant - DISPLAY_MODE_Y_CONSTRAINT_DIFFERENCE;
        _textBackgroundYConstraint.constant = _textBackgroundYConstraint.constant - DISPLAY_MODE_Y_CONSTRAINT_DIFFERENCE;
    } else {
        _descriptionLabel.truncationTokenString = @" ... See more";
        _descriptionLabel.numberOfLines = 2;
        if (_textBackgroundYConstraint.constant + DISPLAY_MODE_Y_CONSTRAINT_DIFFERENCE > self.frame.size.height) {
            return;
        }
        _hashtagYConstraint.constant = _hashtagYConstraint.constant + DISPLAY_MODE_Y_CONSTRAINT_DIFFERENCE;
        _descriptionYConstraint.constant = _descriptionYConstraint.constant + DISPLAY_MODE_Y_CONSTRAINT_DIFFERENCE;
        _textBackgroundYConstraint.constant = _textBackgroundYConstraint.constant + DISPLAY_MODE_Y_CONSTRAINT_DIFFERENCE;
    }
    [_descriptionLabel setNeedsDisplay];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)customView
{
    WorkoutHeaderView *customView = [[[NSBundle mainBundle] loadNibNamed:@"WorkoutHeaderView" owner:nil options:nil] lastObject];
    
    // make sure WorkoutHeaderView is not nil or the wrong class!
    if ([customView isKindOfClass:[WorkoutHeaderView class]]) {
        customView.descriptionLabel.truncationTokenStringAttributes = [NSDictionary dictionaryWithObject:[UIColor lightTextColor] forKey:NSForegroundColorAttributeName];
        customView.descriptionLabel.font = [UIFont fontWithName:GLOBAL_FONT_TYPE_TEXT size:15];
        customView.displayMode = kSeeMore;
        customView.descriptionLabel.numberOfLines = 2;
        return customView;
    }
    else {
        return nil;
    }
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
