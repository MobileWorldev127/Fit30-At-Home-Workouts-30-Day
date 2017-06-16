//
//  ChallengeHeaderTableViewCell.m
//  flexter
//
//  Created by Anurag Tolety on 4/8/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#import "ChallengeHeaderTableViewCell.h"
#import "UIImage+Tint.h"

@interface ChallengeHeaderTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *pageImageView;



@end
@implementation ChallengeHeaderTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self initializeDefaults];
}

- (void)initializeDefaults {
    self.titleLabel.alpha = 0;
    self.detailLabel.alpha = 0;
    self.pageImageView.image = [UIImage imageNamed:@"NoDescriptionPageControlImage.png"];
    // Add left swipe to show the title and description
    UISwipeGestureRecognizer* leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeRecognized:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:leftSwipe];
    // Add right swipe to get back
    UISwipeGestureRecognizer* rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeRecognized:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:rightSwipe];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)leftSwipeRecognized:(UISwipeGestureRecognizer *)sender {
    NSLog(@"left swipe");
    self.pageImageView.image = [UIImage imageNamed:@"DescriptionPageControlImage.png"];
    [UIView animateWithDuration:0.5 animations:^{
        self.detailLabel.alpha = 1;
        self.titleLabel.alpha = 1;
        self.backgroundImageView.image = [self.backgroundImage imageTintedWithColor:[UIColor blackColor] fraction:0.21];
    }];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    self.backgroundImageView.image = _backgroundImage;
}

- (void)rightSwipeRecognized:(UISwipeGestureRecognizer *)sender {
    self.pageImageView.image = [UIImage imageNamed:@"NoDescriptionPageControlImage.png"];
    [UIView animateWithDuration:0.5 animations:^{
        self.detailLabel.alpha = 0;
        self.titleLabel.alpha = 0;
        self.backgroundImageView.image = self.backgroundImage;
    }];
}
@end
