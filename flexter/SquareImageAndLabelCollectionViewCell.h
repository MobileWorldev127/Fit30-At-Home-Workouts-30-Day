//
//  SquareImageAndLabelCollectionViewCell.h
//  flexter
//
//  Created by Anurag Tolety on 12/3/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SquareImageAndLabelCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) NSString* uniqueId;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *title;

@end
