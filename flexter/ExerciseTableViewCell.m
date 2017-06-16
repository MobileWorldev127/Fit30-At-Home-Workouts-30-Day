//
//  ExerciseTableViewCell.m
//  flexter
//
//  Created by Anurag Tolety on 7/19/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "ExerciseTableViewCell.h"
#import "UIConstants.h"

#define VIDEO_PLAY_BUTTON_WIDTH 45.0
#define VIDEO_PLAY_BUTTON_HEIGHT 45.0

@interface ExerciseTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkMarkButton;
@property (strong, nonatomic) UIButton* leftImageSelectButton;
@property (strong, nonatomic) UIImageView* playButtonImageView;
@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL workoutRunningMode;
@property BOOL firstPassDone;
@property (strong, nonatomic) UIView* imageTintView;

@end

@implementation ExerciseTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView*)imageTintView
{
    if (!_imageTintView) {
        _imageTintView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.leftImageView.frame.size.width, self.leftImageView.frame.size.height)];
        _imageTintView.backgroundColor = [UIColor blackColor];
        _imageTintView.alpha = 0.5;
    }
    return _imageTintView;
}

- (UIImageView*)playButtonImageView
{
    if (!_playButtonImageView) {
        _playButtonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.leftImageView.frame.size.width/2 - ((float)VIDEO_PLAY_BUTTON_WIDTH)/2, self.leftImageView.frame.size.height/2 - ((float)VIDEO_PLAY_BUTTON_HEIGHT)/2, VIDEO_PLAY_BUTTON_WIDTH, VIDEO_PLAY_BUTTON_HEIGHT)];
        _playButtonImageView.contentMode = UIViewContentModeScaleAspectFit;
        _playButtonImageView.image = [UIImage imageNamed:@"VideoPlayButton.png"];
    }
    return _playButtonImageView;
}

- (UIButton*)leftImageSelectButton
{
    if (!_leftImageSelectButton) {
        _leftImageSelectButton = [[UIButton alloc] initWithFrame:CGRectMake(self.leftImageView.frame.origin.x, 0, self.leftImageView.frame.size.width, self.leftImageView.frame.size.height)];
        [_leftImageSelectButton addTarget:self action:@selector(videoButtonSelected) forControlEvents:UIControlEventTouchDown];
    }
    return _leftImageSelectButton;
}

- (void)awakeFromNib
{
    // Initialization code
    _leftImageView.layer.borderWidth = 1.0f;
    _leftImageView.layer.borderColor = [UIColor colorWithRed:104.f/255 green:148.f/255 blue:242.f/255 alpha:1.0f].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.backgroundColor = selected ? [UIColor colorWithWhite:0.95 alpha:1] : [UIColor whiteColor];
    self.timer.backgroundColor = selected ? [UIColor colorWithWhite:0.95 alpha:1] : [UIColor whiteColor];
    if (selected) {
        [self.leftImageView addSubview:self.imageTintView];
    } else {
        [self.imageTintView removeFromSuperview];
    }
    // Configure the view for the selected state
}

+ (id)customView
{
    ExerciseTableViewCell *customView = [[[NSBundle mainBundle] loadNibNamed:@"ExerciseTableViewCell" owner:nil options:nil] lastObject];
    // make sure WorkoutHeaderView is not nil or the wrong class!
    if ([customView isKindOfClass:[ExerciseTableViewCell class]]) {
        return customView;
    } else
        return nil;
}

- (void)setIndex:(NSInteger)index
{
    _index = index;
    _indexLabel.text = [NSString stringWithFormat:@"%ld", ((long)_index + 1)];
}

- (void)setWorkoutRunningMode:(BOOL)workoutRunningMode
{
    if (_workoutRunningMode == workoutRunningMode && self.firstPassDone) {
        return;
    }
    _workoutRunningMode = workoutRunningMode;
    if (_workoutRunningMode) {
        [self addSubview:self.leftImageSelectButton];
    } else {
        [self.leftImageSelectButton removeFromSuperview];
    }
}

- (void)setShowVideoButton:(BOOL)showVideoButton
{
    if ((_showVideoButton == showVideoButton) && self.firstPassDone) {
        return;
    }
    self.firstPassDone = YES;
    NSLog(@"firstpassdone index: %ld", (long)self.index);
    _showVideoButton = showVideoButton;
    if (showVideoButton) {
        [self.leftImageView addSubview:self.playButtonImageView];
    } else {
        [self.playButtonImageView removeFromSuperview];
    }
}

- (void)videoButtonSelected
{
    if (self.delegate) {
        [self.delegate videoButtonPressedWithIndex:self.index];
    }
}

- (void)setShowCheckMark:(BOOL)showCheckMark
{
    _showCheckMark = showCheckMark;
    if (showCheckMark) {
        _checkMarkButton.alpha = 1;
    } else {
        // Setting alpha to zero doesn't register button down events. Why?
        _checkMarkButton.alpha = 0;
    }
}

- (void)setShowTimer:(BOOL)showTimer
{
    self.timer.hidden = !showTimer;
}

- (void)setChecked:(BOOL)checked
{
    if (_showCheckMark) {
        _checked = checked;
        [_checkMarkButton setImage:[UIImage imageNamed:checked ? @"CellCheckMark.png" : @"CellUncheckMark.png"] forState:UIControlStateNormal];
        _checkMarkButton.contentMode = UIViewContentModeCenter;
    }
}

- (IBAction)checkMarkPressed:(id)sender {
    if (!self.showCheckMark) {
        return;
    }
    self.checked = !self.checked;
    if (self.delegate) {
        [self.delegate checkMarkPressedWithCurrentStatus:self.checked andIndex:self.index];
    }
}

- (void)configureWithIndex:(NSInteger)index withWorkoutRunningMode:(BOOL)workoutRunningMode
{
    [self.leftImageSelectButton removeFromSuperview];
    [self.playButtonImageView removeFromSuperview];
    self.firstPassDone = NO;
    self.index = index;
    self.workoutRunningMode = workoutRunningMode;
    self.showTimer = NO;
}
@end
