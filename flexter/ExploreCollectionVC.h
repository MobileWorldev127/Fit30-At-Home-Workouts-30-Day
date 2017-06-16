//
//  ExploreCollectionVC.h
//  flexter
//
//  Created by Anurag Tolety on 7/10/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//
//  Purpose: Displays a collection of workouts based on the filter criteria passed to it
//

#import <UIKit/UIKit.h>
#import "FilterOptionsExchangeProtocol.h"

@interface ExploreCollectionVC : UIViewController <UIActionSheetDelegate>

@property (strong, nonatomic) NSString* currentTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnUnlockAll;
@property (weak, nonatomic) IBOutlet UILabel *allChallengesLabel;
@property (weak, nonatomic) IBOutlet UILabel *challengesUnlockValue;

@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueOffLabel;
@property (weak, nonatomic) IBOutlet UIImageView *valueDeleteLine;

@end
