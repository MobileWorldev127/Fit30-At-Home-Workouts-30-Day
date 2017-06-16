//
//  ExerciseTableViewCell.h
//  flexter
//
//  Created by Anurag Tolety on 7/19/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OvalTimerView.h"

@protocol ExerciseCellProtocol <NSObject>

@optional

- (void)checkMarkPressedWithCurrentStatus:(BOOL)selected andIndex:(NSInteger)index;
- (void)videoButtonPressedWithIndex:(NSInteger)index;

@end

@interface ExerciseTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (nonatomic) BOOL showCheckMark;
@property (nonatomic) BOOL checked;
@property (nonatomic) BOOL showVideoButton;
@property (nonatomic) BOOL showTimer;
@property (strong, nonatomic) UIImage* image;
@property (weak, nonatomic) id<ExerciseCellProtocol> delegate;
@property (weak, nonatomic) IBOutlet OvalTimerView *timer;

+ (id)customView;
- (void)configureWithIndex:(NSInteger)index withWorkoutRunningMode:(BOOL)workoutRunningMode;

@end
