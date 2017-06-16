//
//  EarlyAccessOptionsView.m
//  flexter
//
//  Created by Anurag Tolety on 9/18/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "EarlyAccessOptionsView.h"

@implementation EarlyAccessOptionsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (IBAction)closePressed:(id)sender {
    [self.delegate closePressed];
}

- (IBAction)emailPressed:(id)sender {
    [self.delegate emailPressed];
}

+ (id)customView
{
    EarlyAccessOptionsView *customView = [[[NSBundle mainBundle] loadNibNamed:@"EarlyAccessOptionsView" owner:nil options:nil] lastObject];
    
    // make sure WorkoutHeaderView is not nil or the wrong class!
    if ([customView isKindOfClass:[EarlyAccessOptionsView class]])
        return customView;
    else
        return nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
