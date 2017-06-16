//
//  StatusView.m
//  flexter
//
//  Created by Anurag Tolety on 12/27/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "StatusView.h"

@interface StatusView ()

@property (strong, nonatomic) UIActivityIndicatorView* spinner;
@property (strong, nonatomic) UIImageView* validityImageView;

@end

@implementation StatusView

- (UIActivityIndicatorView*)spinner
{
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _spinner.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _spinner.contentMode = UIViewContentModeCenter;
    }
    return _spinner;
}

- (UIImageView*)validityImageView
{
    if (!_validityImageView) {
        _validityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _validityImageView.contentMode = UIViewContentModeCenter;

    }
    return _validityImageView;
}

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"UserEntryView initWithFrame");
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeDefaults];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    NSLog(@"UserEntryView initWithCoder");
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeDefaults];
    }
    return self;
}

- (void)initializeDefaults
{
    // Initialization code
    _isValid = NO;
    _isSpinning = NO;
}

- (void)setIsValid:(BOOL)isValid
{
    if (_isSpinning) {
        [_spinner stopAnimating];
        [_spinner removeFromSuperview];
    }
    _isSpinning = NO;
    [self.validityImageView removeFromSuperview];
    self.validityImageView.image = [UIImage imageNamed:isValid ? (@"ValidTextFieldIcon.png") : (@"InvalidTextFieldIcon.png")];
    [self addSubview:self.validityImageView];
    _isValid = isValid;
}

- (void)setIsSpinning:(BOOL)isSpinning
{
    [_validityImageView removeFromSuperview];
    _isValid = NO;
    [self.spinner removeFromSuperview];
    [self addSubview:self.spinner];
    if (isSpinning) {
        [self.spinner startAnimating];
    } else {
        [self.spinner stopAnimating];
    }
    _isSpinning = isSpinning;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
