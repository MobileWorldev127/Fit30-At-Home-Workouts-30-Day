//
//  WorkoutOverviewVC.h
//  flexter
//
//  Created by Anurag Tolety on 7/16/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//
//  Purpose: Provide an overview of the workout including the exercises
//

#import <UIKit/UIKit.h>
#import "FDWorkout.h"
#import "TimerFinishedProtocol.h"
#import "WorkoutCompletionProtocol.h"

@interface WorkoutOverviewVC : UIViewController <UIActionSheetDelegate, TimerFinishedProtocol>

@property (strong, nonatomic) FDWorkout* workout;
@property (nonatomic) int dayInChallenge;
@property (weak, nonatomic) id<WorkoutCompletionProtocol> workoutCompleteDelegate;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@end
