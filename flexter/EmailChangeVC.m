//
//  EmailChangeVC.m
//  flexter
//
//  Created by Anurag Tolety on 12/21/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "EmailChangeVC.h"
#import <Parse/Parse.h>
#import "FDConstants.h"
#import "StatusView.h"

#define EMAIL_RIGHT_VIEW_WIDTH 30

@interface EmailChangeVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) UIActivityIndicatorView* spinner;
@property (weak, nonatomic) IBOutlet UIView *emailUnavailableView;
@property (strong, nonatomic) StatusView* statusView;

@end

@implementation EmailChangeVC

- (StatusView*)statusView
{
    if (!_statusView) {
        _statusView = [[StatusView alloc] initWithFrame:CGRectMake(0, 0, EMAIL_RIGHT_VIEW_WIDTH, _emailTextField.frame.size.height)];
    }
    return _statusView;
}

- (UIActivityIndicatorView*)spinner
{
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _spinner;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.emailTextField.frame.size.height)];
    [self.emailTextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.emailTextField setLeftView:spacerView];
    self.emailTextField.text = [PFUser currentUser].email;
    self.emailTextField.rightView = self.statusView;
    self.emailTextField.rightViewMode = UITextFieldViewModeAlways;
    [self.saveButton addTarget:self action:@selector(saveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)configureSaveButton
{
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
    self.saveButton.titleLabel.text = @"SAVE";
    self.saveButton.enabled = YES;
    [self.saveButton addTarget:self action:@selector(saveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)checkEmailStringValidity:(NSString*)email
{
    if (([email rangeOfString:@"@"].location == NSNotFound) || ([email rangeOfString:@"."].location == NSNotFound)) {
        return NO;
    } else {
        return YES;
    }

}

- (void)initiateEmailUnavailabilityAnimation
{
    self.emailUnavailableView.hidden = NO;
    self.emailUnavailableView.frame = CGRectMake(self.emailUnavailableView.frame.origin.x, self.emailUnavailableView.frame.origin.y, self.emailUnavailableView.frame.size.width, 40);
    [UIView animateWithDuration:0.5 delay:1 options:0 animations:^{
        self.emailUnavailableView.frame = CGRectMake(self.emailUnavailableView.frame.origin.x, self.emailUnavailableView.frame.origin.y, self.emailUnavailableView.frame.size.width, 0);
    } completion:^(BOOL finished) {
        self.emailUnavailableView.hidden = YES;
    }];
}
- (void)saveButtonPressed:(id)sender {
    if ([self.emailTextField.text isEqualToString:[PFUser currentUser].email]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"The Email did not change from your current email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (![self checkEmailStringValidity:self.emailTextField.text]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"The Email is not a valid one" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    self.saveButton.titleLabel.text = @"";
    self.saveButton.enabled = NO;
    [self.spinner startAnimating];
    self.spinner.center = CGPointMake(self.saveButton.frame.size.width/2, self.saveButton.frame.size.height/2);
    [self.saveButton addSubview:self.spinner];
    PFUser* currentUser = [PFUser currentUser];
    PFQuery* userQuery = [PFUser query];
    [userQuery whereKey:@"email" equalTo:self.emailTextField.text];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && [objects count] == 0) {
            currentUser.email = self.emailTextField.text;
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!succeeded) {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                [self configureSaveButton];
            }];
        } else {
            if (!error) {
                [self initiateEmailUnavailabilityAnimation];
            }
            [self configureSaveButton];
        }
    }];
}


- (IBAction)emailEditingChanged:(UITextField *)sender {
    NSLog(@"EmailChangeVC email value while editing: %@", sender.text);
    if (![self checkEmailStringValidity:sender.text]) {
        self.statusView.isValid = NO;
    } else {
        [self checkForEmailAvailability:sender.text];

    }
}

- (void)checkForEmailAvailability:(NSString*)email
{
    self.statusView.isSpinning = YES;
    PFQuery* userQuery = [PFUser query];
    [userQuery whereKey:@"email" equalTo:email];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.spinner stopAnimating];
        if (!error) {
            if ([objects count] == 0) {
                self.statusView.isValid = YES;
            } else {
                self.statusView.isValid = NO;
                [self initiateEmailUnavailabilityAnimation];
            }
        } else {
            self.statusView.isSpinning = NO;
        }
    }];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

@end
