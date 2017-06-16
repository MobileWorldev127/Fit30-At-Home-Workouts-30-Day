//
//  WorkoutTableViewCell.m
//  flexter
//
//  Created by Anurag Tolety on 3/25/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#import "WorkoutTableViewCell.h"

@interface WorkoutTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *stateImageView;

@end
@implementation WorkoutTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setWorkoutState:(WorkoutStateType)workoutState {
    _workoutState = workoutState;
    switch (workoutState) {
        case WorkoutStateTypeLocked:
            self.stateImageView.image = [UIImage imageNamed:@"LockIcon.png"];
            break;
        
        case WorkoutStateTypeInProgress:
            self.stateImageView.image = [UIImage imageNamed:@"DetailArrow.png"];
            break;
            
        case WorkoutStateTypeDone:
            self.stateImageView.image = [UIImage imageNamed:@"CellCheckMark.png"];
            break;
            
        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
