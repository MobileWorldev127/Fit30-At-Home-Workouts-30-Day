//
//  ChallengeHeaderTableViewCell.h
//  flexter
//
//  Created by Anurag Tolety on 4/8/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChallengeHeaderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (nonatomic, strong) UIImage* backgroundImage;

@end
