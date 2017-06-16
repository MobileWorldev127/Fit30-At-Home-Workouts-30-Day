//
//  UserEntryView.m
//  flexter
//
//  Created by Anurag Tolety on 12/11/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "UserEntryView.h"
#import "UIConstants.h"
#import "StatusView.h"
#define STATUS_VIEW_WIDTH 50

@interface UserEntryView () <UITextFieldDelegate>

@property (strong, nonatomic, readwrite) NSString* email;
@property (strong, nonatomic, readwrite) NSString* userName;
@property (strong, nonatomic, readwrite) NSString* password;
@property (nonatomic, readwrite) UserEntryMode mode;
@property (strong, nonatomic) UITextField* emailTextField;
@property (strong, nonatomic) UITextField* userNameTextField;
@property (strong, nonatomic) UITextField* passwordTextField;
@property (strong, nonatomic) UIButton* forgotPasswordButton;
@property (strong, nonatomic) UIImageView* borderImageView;
@property (strong, nonatomic) UIImageView* emailImageView;
@property (strong, nonatomic) UIImageView* userNameImageView;
@property (strong, nonatomic) UIImageView* passwordImageView;
@property (strong, nonatomic) UIImageView* userNameSeparator;
@property (strong, nonatomic) UIImageView* emailSeparator;
@property BOOL isConfigured;
@property (strong, nonatomic) StatusView* emailStatusView;
@property (strong, nonatomic) StatusView* userNameStatusView;
@property (strong, nonatomic) StatusView* passwordStatusView;

@end

@implementation UserEntryView

- (NSString*)email
{
    _email = _emailTextField.text;
    return _email;
}

- (NSString*)userName
{
    _userName = _userNameTextField.text;
    return _userName;
}

- (NSString*)password
{
    _password = _passwordTextField.text;
    return _password;
}

- (UITextField*)emailTextField
{
    if (!_emailTextField) {
        _emailTextField = [[UITextField alloc] init];
        _emailTextField.delegate = self;
        _emailTextField.borderStyle = UITextBorderStyleNone;
        _emailTextField.textColor = [UIColor whiteColor];
        _emailTextField.backgroundColor = [UIColor clearColor];
        _emailTextField.font = [UIFont fontWithName:GLOBAL_FONT_TYPE_TEXT size:14];
        _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        _emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _emailTextField.returnKeyType = UIReturnKeyNext;
        _emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter your email" attributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    }
    return _emailTextField;
}

- (UITextField*)userNameTextField
{
    if (!_userNameTextField) {
        _userNameTextField = [[UITextField alloc] init];
        _userNameTextField.delegate = self;
        _userNameTextField.borderStyle = UITextBorderStyleNone;
        _userNameTextField.textColor = [UIColor whiteColor];
        _userNameTextField.backgroundColor = [UIColor clearColor];
        _userNameTextField.font = [UIFont fontWithName:GLOBAL_FONT_TYPE_TEXT size:14];
        _userNameTextField.keyboardType = UIKeyboardTypeDefault;
        _userNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _userNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _userNameTextField.returnKeyType = UIReturnKeyNext;
        _userNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter username" attributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    }
    return _userNameTextField;
}

- (UITextField*)passwordTextField
{
    if (!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.delegate = self;
        _passwordTextField.borderStyle = UITextBorderStyleNone;
        _passwordTextField.textColor = [UIColor whiteColor];
        _passwordTextField.backgroundColor = [UIColor clearColor];
        _passwordTextField.font = [UIFont fontWithName:GLOBAL_FONT_TYPE_TEXT size:14];
        _passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        _passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter password" attributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    }
    return _passwordTextField;
}

- (UIButton*)forgotPasswordButton
{
    if (!_forgotPasswordButton) {
        _forgotPasswordButton = [[UIButton alloc] init];
        _forgotPasswordButton.titleLabel.font = [UIFont fontWithName:GLOBAL_FONT_TYPE_TEXT size:13];
        [_forgotPasswordButton setTitle:@"Forgot?" forState:UIControlStateNormal];
        [_forgotPasswordButton setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [_forgotPasswordButton addTarget:self action:@selector(forgotPasswordButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _forgotPasswordButton;
}

- (void)forgotPasswordButtonPressed
{
    [self configureWithEmailVisibility:YES userNameVisibility:NO passwordVisibility:NO];
    self.mode = UserEntryModeForgotPassword;
    self.emailStatusView.hidden = YES;
    [self.delegate prepareForForgotPassword];
}

- (UIImageView*)borderImageView
{
    if (!_borderImageView) {
        _borderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _borderImageView.image = [UIImage imageNamed:@"LoginDetailsBoundaryFull.png"];
        _borderImageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _borderImageView;
}

- (UIImageView*)emailImageView
{
    if (!_emailImageView) {
        _emailImageView = [[UIImageView alloc] init];
        _emailImageView.image = [UIImage imageNamed:@"EmailIcon.png"];
        _emailImageView.contentMode = UIViewContentModeCenter;
    }
    return _emailImageView;
}

- (UIImageView*)userNameImageView
{
    if (!_userNameImageView) {
        _userNameImageView = [[UIImageView alloc] init];
        _userNameImageView.image = [UIImage imageNamed:@"UserNameIcon.png"];
        _userNameImageView.contentMode = UIViewContentModeCenter;
    }
    return _userNameImageView;
}


- (UIImageView*)passwordImageView
{
    if (!_passwordImageView) {
        _passwordImageView = [[UIImageView alloc] init];
        _passwordImageView.image = [UIImage imageNamed:@"PasswordIcon.png"];
        _passwordImageView.contentMode = UIViewContentModeCenter;
    }
    return _passwordImageView;
}

- (UIImageView*)userNameSeparator
{
    if (!_userNameSeparator) {
        _userNameSeparator = [[UIImageView alloc] init];
        _userNameSeparator.backgroundColor = [UIColor whiteColor];
    }
    return _userNameSeparator;
}

- (UIImageView*)emailSeparator
{
    if (!_emailSeparator) {
        _emailSeparator = [[UIImageView alloc] init];
        _emailSeparator.backgroundColor = [UIColor whiteColor];
    }
    return _emailSeparator;
}

- (StatusView*)emailStatusView
{
    if (!_emailStatusView) {
        _emailStatusView = [[StatusView alloc] init];
        _emailStatusView.contentMode = UIViewContentModeCenter;
    }
    return _emailStatusView;
}

- (StatusView*)userNameStatusView
{
    if (!_userNameStatusView) {
        _userNameStatusView = [[StatusView alloc] init];
        _userNameStatusView.contentMode = UIViewContentModeCenter;
    }
    return _userNameStatusView;
}


- (StatusView*)passwordStatusView
{
    if (!_passwordStatusView) {
        _passwordStatusView = [[StatusView alloc] init];
        _passwordStatusView.contentMode = UIViewContentModeCenter;
    }
    return _passwordStatusView;
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
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.borderImageView];
    self.isConfigured = NO;
    self.mode = UserEntryModeNone;
}


- (void)configureWithEmailVisibility:(BOOL)emailVisible userNameVisibility:(BOOL)userNameVisible passwordVisibility:(BOOL)passwordVisible
{
    NSLog(@"UserEntryView configure called with email: %d, username: %d, password: %d", emailVisible, userNameVisible, passwordVisible);
    self.emailTextField.hidden = !emailVisible;
    self.emailImageView.hidden = !emailVisible;
    self.userNameTextField.hidden = !userNameVisible;
    self.userNameImageView.hidden = !userNameVisible;
    self.passwordTextField.hidden = !passwordVisible;
    self.passwordImageView.hidden = !passwordVisible;
    self.forgotPasswordButton.hidden = YES;
    if (emailVisible && !userNameVisible && !passwordVisible) {
        self.emailSeparator.hidden = YES;
        self.userNameSeparator.hidden = YES;
        self.emailStatusView.hidden = NO;
        self.borderImageView.image = [UIImage imageNamed:@"LoginDetailsBoundarySmall.png"];
        self.borderImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/3 + 5);
        self.emailImageView.hidden = YES;
        self.emailTextField.textAlignment = NSTextAlignmentCenter;
        self.mode = UserEntryModeSignUpEmailOnly;
    }
    if (emailVisible && userNameVisible && passwordVisible) {
        self.emailSeparator.hidden = NO;
        self.userNameSeparator.hidden = NO;
        self.emailStatusView.hidden = NO;
        self.userNameStatusView.hidden = NO;
        self.passwordStatusView.hidden = NO;
        self.borderImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.borderImageView.image = [UIImage imageNamed:@"LoginDetailsBoundaryFull.png"];
        self.emailImageView.hidden = NO;
        self.emailTextField.textAlignment = NSTextAlignmentLeft;
        self.mode = UserEntryModeSignUpAll;
        [self.emailTextField becomeFirstResponder];
        [self.delegate prepareForEmailEntered];
    }
    if (!emailVisible && userNameVisible && passwordVisible) {
        self.emailSeparator.hidden = YES;
        self.emailStatusView.hidden = YES;
        self.userNameSeparator.hidden = NO;
        self.borderImageView.frame = CGRectMake(0, self.frame.size.height/3, self.frame.size.width, 2*self.frame.size.height/3);
        self.borderImageView.image = [UIImage imageNamed:@"LoginDetailsBoundaryMedium.png"];
        self.userNameTextField.hidden = NO;
        self.userNameImageView.hidden = NO;
        self.userNameStatusView.hidden = YES;
        self.passwordImageView.hidden = NO;
        self.passwordTextField.hidden = NO;
        self.passwordStatusView.hidden = YES;
        self.mode = UserEntryModeLogin;
        self.forgotPasswordButton.hidden = NO;
    }
    if (!self.isConfigured) {
        self.emailImageView.frame = CGRectMake(20, 22, 17, 13);
        self.emailTextField.frame = CGRectMake(50, 17, 185, 22);
        self.emailSeparator.frame = CGRectMake(14, 52, 244, 1);
        self.emailStatusView.frame = CGRectMake(self.frame.size.width - STATUS_VIEW_WIDTH, self.emailTextField.frame.origin.y, STATUS_VIEW_WIDTH, self.emailTextField.frame.size.height);
        [self.emailTextField addTarget:self
                      action:@selector(textFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
        [self addSubview:self.emailImageView];
        [self addSubview:self.emailTextField];
        [self addSubview:self.emailSeparator];
        [self addSubview:self.emailStatusView];
        
        self.userNameImageView.frame = CGRectMake(20, 69, 17, 13);
        self.userNameTextField.frame = CGRectMake(50, 65, 185, 22);
        self.userNameSeparator.frame = CGRectMake(14, 103, 244, 1);
        self.userNameStatusView.frame = CGRectMake(self.frame.size.width - STATUS_VIEW_WIDTH, self.userNameTextField.frame.origin.y, STATUS_VIEW_WIDTH, self.userNameTextField.frame.size.height);
        [self.userNameTextField addTarget:self
                                action:@selector(textFieldDidChange:)
                      forControlEvents:UIControlEventEditingChanged];
        [self addSubview:self.userNameImageView];
        [self addSubview:self.userNameTextField];
        [self addSubview:self.userNameSeparator];
        [self addSubview:self.userNameStatusView];
        
        self.passwordImageView.frame = CGRectMake(20, 118, 15, 20);
        self.passwordTextField.frame = CGRectMake(50, 116, 114, 22);
        self.forgotPasswordButton.frame = CGRectMake(214, 118, 46, 18);
        self.passwordStatusView.frame = CGRectMake(self.frame.size.width - STATUS_VIEW_WIDTH, self.passwordTextField.frame.origin.y, STATUS_VIEW_WIDTH, self.passwordTextField.frame.size.height);
        [self.passwordTextField addTarget:self
                                   action:@selector(textFieldDidChange:)
                         forControlEvents:UIControlEventEditingChanged];
        [self addSubview:self.passwordImageView];
        [self addSubview:self.passwordTextField];
        [self addSubview:self.forgotPasswordButton];
        [self addSubview:self.passwordStatusView];
    }
    self.isConfigured = YES;
}

- (void)textFieldDidChange:(UITextField*)sender
{
    if (sender == self.emailTextField) {
        if ([self.delegate validateWithString:sender.text andType:UserInputTypeEmail]) {
            self.emailStatusView.isSpinning = YES;
            [self.delegate checkAvailabilityWithString:sender.text andType:UserInputTypeEmail withCompletionBlock:^(BOOL succeeded) {
                if (succeeded) {
                    self.emailStatusView.isValid = YES;
                } else {
                    self.emailStatusView.isValid = NO;
                }
            }];
        } else {
            self.emailStatusView.isValid = NO;
        }
    }
    if (sender == self.userNameTextField) {
        if ([self.delegate validateWithString:sender.text andType:UserInputTypeUserName]) {
            self.userNameStatusView.isSpinning = YES;
            [self.delegate checkAvailabilityWithString:sender.text andType:UserInputTypeUserName withCompletionBlock:^(BOOL succeeded) {
                if (succeeded) {
                    self.userNameStatusView.isValid = YES;
                } else {
                    self.userNameStatusView.isValid = NO;
                }
            }];
        } else {
            self.userNameStatusView.isValid = NO;
        }
    }
    if (sender == self.passwordTextField) {
        self.passwordStatusView.isValid = ![sender.text isEqualToString:@""];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"UserEntryView text field began");
    if (textField == self.passwordTextField) {
        [self.delegate prepareForRegisteringUser];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"UserEntryView text field ended");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordTextField) {
        [self resignFirstResponder];
        return YES;
    } else {
        if (textField == self.emailTextField) {
            if (self.mode == UserEntryModeSignUpEmailOnly) {
                [self configureWithEmailVisibility:YES userNameVisibility:YES passwordVisibility:YES];
            } else if (self.mode == UserEntryModeForgotPassword) {
                [self.delegate handleForgotPassword];
            } else if (self.mode == UserEntryModeSignUpAll) {
                [self.userNameTextField becomeFirstResponder];
            }
            return YES;
        } else {
            [self.passwordTextField becomeFirstResponder];
            return YES;
        }
    }
}

- (BOOL)resignFirstResponder
{
    [self.emailTextField resignFirstResponder];
    [self.userNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    return [super resignFirstResponder];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
