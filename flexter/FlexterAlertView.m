//
//  FlexterAlertView.m
//  flexter
//
//  Created by Anurag Tolety on 10/25/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "FlexterAlertView.h"
#import "UIConstants.h"

@implementation FlexterAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews
{
    for (UIView *subview in self.subviews){ //Fast Enumeration
        if ([subview isMemberOfClass:[UIImageView class]]) {
            subview.backgroundColor = [UIColor whiteColor]; //Hide UIImageView Containing Blue Background
        }
        
        if ([subview isMemberOfClass:[UILabel class]]) { //Point to UILabels To Change Text
            UILabel *label = (UILabel*)subview; //Cast From UIView to UILabel
            label.font = [UIFont fontWithName:GLOBAL_FONT_TYPE_TEXT size:19];
        }
    }
}

@end
