//
//  ImageAndLabelCollectionViewCell.h
//  flexter
//
//  Created by Anurag Tolety on 7/12/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageAndLabelCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) NSString* uniqueId;
@property (nonatomic) BOOL isHomeWorkout;
@property (nonatomic) BOOL isPremium;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *difficultyLabel;

@end
