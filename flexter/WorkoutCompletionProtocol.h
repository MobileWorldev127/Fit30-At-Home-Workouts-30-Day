//
//  WorkoutCompletionProtocol.h
//  flexter
//
//  Created by Anurag Tolety on 3/27/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#ifndef flexter_WorkoutCompletionProtocol_h
#define flexter_WorkoutCompletionProtocol_h

@protocol WorkoutCompletionProtocol <NSObject>

@required

- (void)workoutCompleted;
- (void)workoutCancelledWithInProgressExerciseIndex:(int)index;
- (NSInteger)dayIndex;

@end

#endif
