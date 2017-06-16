//
//  ProfileCollectionViewCell.m
//  flexter
//
//  Created by Anurag Tolety on 12/9/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "ProfileCollectionViewCell.h"
#import "UIConstants.h"
#define PROFILE_IMAGE_WIDTH 125
#define PROFILE_IMAGE_HEIGHT 125

@interface ProfileCollectionViewCell ()

@property (strong, nonatomic) UIImageView* profileImageView;
@property (strong, nonatomic) UILabel* userNameLabel;
@property (strong, nonatomic) UILabel* workoutLabel;
@property (strong, nonatomic) UIButton* profileImageButton;

@end

@implementation ProfileCollectionViewCell

- (UIImageView*)profileImageView
{
    if (!_profileImageView) {
        _profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, PROFILE_IMAGE_WIDTH, PROFILE_IMAGE_HEIGHT)];
        _profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        _profileImageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        _profileImageView.layer.cornerRadius = _profileImageView.frame.size.width / 2;
        _profileImageView.clipsToBounds = YES;
    }
    return _profileImageView;
}

- (UIButton*)profileImageButton
{
    if (!_profileImageButton) {
        _profileImageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, PROFILE_IMAGE_WIDTH, PROFILE_IMAGE_HEIGHT)];
        _profileImageButton.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [_profileImageButton addTarget:self action:@selector(profileImagePressed) forControlEvents:UIControlEventTouchUpInside];
        _profileImageButton.tintColor = [UIColor clearColor];
    }
    return _profileImageButton;
}

- (UILabel*)userNameLabel
{
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] init];
        _userNameLabel.font = [UIFont fontWithName:GLOBAL_FONT_TYPE_TEXT size:18];
        _userNameLabel.numberOfLines = 0;
        _userNameLabel.textColor = [UIColor whiteColor];
    }
    return _userNameLabel;
}

- (UILabel*)workoutLabel
{
    if (!_workoutLabel) {
        _workoutLabel = [[UILabel alloc] init];
        _workoutLabel.font = [UIFont fontWithName:GLOBAL_FONT_TYPE_TEXT size:18];
        _workoutLabel.numberOfLines = 0;
        _workoutLabel.textColor = [UIColor whiteColor];
    }
    return _workoutLabel;
}

- (void)profileImagePressed
{
    NSLog(@"profile image pressed");
    [self.delegate handleProfileCellSelection];
}

- (void)configureWithUserName:(NSString*)userName andWorkoutCount:(int)workoutCount  andProfileImage:(UIImage*)profileImage
{
    self.backgroundColor = [UIColor blackColor];
    [self.profileImageView removeFromSuperview];
    [self.userNameLabel removeFromSuperview];
    [self.workoutLabel removeFromSuperview];
    
    self.profileImageView.image = profileImage;
    [self addSubview:self.profileImageView];
    [self addSubview:self.profileImageButton];
    
    self.userNameLabel.text = [NSString stringWithFormat:@"@%@", userName];
    [self.userNameLabel sizeToFit];
    self.userNameLabel.center = CGPointMake(self.frame.size.width/2, self.profileImageView.frame.origin.y + self.profileImageView.frame.size.height + 25);
    [self addSubview:self.userNameLabel];
    
    self.workoutLabel.text = [NSString stringWithFormat:@"%d workouts", workoutCount];
    [self.workoutLabel sizeToFit];
    self.workoutLabel.center = CGPointMake(self.frame.size.width/2, self.userNameLabel.frame.origin.y + self.userNameLabel.frame.size.height + 10);
    [self addSubview:self.workoutLabel];
}

@end
