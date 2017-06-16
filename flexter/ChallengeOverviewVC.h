//
//  ChallengeOverviewVC.h
//  flexter
//
//  Created by Anurag Tolety on 3/17/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDChallenge.h"
#import "WorkoutCompletionProtocol.h"

@interface ChallengeOverviewVC : UIViewController <WorkoutCompletionProtocol, UIActionSheetDelegate>

@property (strong, nonatomic) FDChallenge* challenge;

@end
