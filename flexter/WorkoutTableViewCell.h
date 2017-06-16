//
//  WorkoutTableViewCell.h
//  flexter
//
//  Created by Anurag Tolety on 3/25/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WorkoutStateType) {
    WorkoutStateTypeLocked,
    WorkoutStateTypeInProgress,
    WorkoutStateTypeDone
};

@interface WorkoutTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *workoutTitleLabel;
@property (nonatomic) WorkoutStateType workoutState;

@end
