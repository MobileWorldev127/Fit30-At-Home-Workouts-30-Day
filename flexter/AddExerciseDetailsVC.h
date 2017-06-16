//
//  AddExerciseDetailsVC.h
//  flexter
//
//  Created by Anurag Tolety on 9/1/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDExercise.h"

@interface AddExerciseDetailsVC : UIViewController

@property (strong, nonatomic) UIImage* exerciseCoverImage;
@property (strong, nonatomic) NSString* exerciseVideoFilePath;
@property (strong, nonatomic) FDExercise* exercise;

@end
