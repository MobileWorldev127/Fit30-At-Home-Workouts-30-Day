//
//  ShareAppVC.h
//  flexter
//
//  Created by Anurag Tolety on 9/24/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareAppVC : UIViewController

@property (nonatomic) int day;
@property (weak, nonatomic) IBOutlet UIButton *btnRequestAFeature;
@property (weak, nonatomic) IBOutlet UIButton *btnTextAFriend;

@end
