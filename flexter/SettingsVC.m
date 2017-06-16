//
//  SettingsVC.m
//  flexter
//
//  Created by Anurag Tolety on 10/25/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "SettingsVC.h"
#import "FDConstants.h"
#import "UIConstants.h"
#import "FDWorkout.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "Appirater.h"
#import "GeneralWebVC.h"
#import "FlexterAnalyticsEvents.h"
#import "AIDatePickerController.h"
#import "RMStore.h"
#import "Lockbox.h"
#import "FDChallenge+Purchase.h"
#import <Crashlytics/Crashlytics.h>

#define NUMBER_OF_SECTIONS 1

#define NUMBER_OF_ROWS 5
#define TEXT_INVITE_A_FRIEND_INDEX 0
#define TEXT_INVITE_A_FRIEND_TEXT @"Text Invite a Friend"
#define REQUEST_FEATURE_INDEX 1
#define REQUEST_FEATURE_TEXT @"Request a Feature"
#define SEND_MESSAGE_INDEX 2
#define SEND_MESSAGE_TEXT @"Send Us a Message"
#define RATE_US_INDEX 3
#define RATE_US_TEXT @"Rate Us"
#define RESTORE_PURCHASES_INDEX 4
#define RESTORE_PURCHASES_TEXT @"Restore Purchases"
#define REMINDER_INDEX 5
#define REMINDER_TEXT @"Challenge Reminder"

@interface SettingsVC () <UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (strong, nonatomic) NSUserDefaults* defaults;
@property (strong, nonatomic) UIActivityIndicatorView* spinner;
@property (strong, nonatomic) AIDatePickerController* timePicker;

@end

@implementation SettingsVC

- (AIDatePickerController*)timePicker {
    if (!_timePicker) {
        _timePicker = [AIDatePickerController pickerWithDate:[NSDate date] selectedBlock:^(NSDate *date) {
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
            localNotification.repeatInterval = NSDayCalendarUnit;
            localNotification.alertBody = NSLocalizedString(@"Reminder for next day",nil);
            localNotification.fireDate = date;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.settingsTableView reloadData];
        } cancelBlock:^{
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.settingsTableView reloadData];
        }];
    }
    return _timePicker;
}

- (UIActivityIndicatorView*)spinner
{
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _spinner;
}

- (NSUserDefaults*)defaults
{
    if (!_defaults) {
        _defaults = [[NSUserDefaults alloc] init];
    }
    return _defaults;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.settingsTableView.delegate = self;
    self.settingsTableView.dataSource = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScreenshotTaken) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}

- (void)handleScreenshotTaken
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(CANCEL_ACTION_SHEET_TITLE,nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(SEND_FEEDBACK_ACTION_SHEET_TITLE,nil), NSLocalizedString(REPORT_A_BUG_ACTION_SHEET_TITLE,nil), nil];
    [actionSheet showInView:self.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GLOBAL_FONT_TYPE_TEXT size:18],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    self.navigationController.navigationBar.barTintColor = APP_THEME_COLOR;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.settingsTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*)nextNotificationTimeString {
    UIApplication* application = [UIApplication sharedApplication];
    if ([[application scheduledLocalNotifications] count]) {
        UILocalNotification* nextNotification = [[application scheduledLocalNotifications] firstObject];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
        return [dateFormatter stringFromDate:nextNotification.fireDate];
    } else {
        return @"";
    }
}

#pragma mark - Table View methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUMBER_OF_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NUMBER_OF_ROWS;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell"];
    cell.detailTextLabel.text = @"";
    switch (indexPath.row) {
        case TEXT_INVITE_A_FRIEND_INDEX:
            cell.textLabel.text = NSLocalizedString(TEXT_INVITE_A_FRIEND_TEXT,nil);
            cell.detailTextLabel.text = @"";
            cell.imageView.image = [UIImage imageNamed:@"InviteAFriendSettingsIcon.png"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
        case REQUEST_FEATURE_INDEX:
            cell.textLabel.text = NSLocalizedString(REQUEST_FEATURE_TEXT,nil);
            cell.detailTextLabel.text = @"";
            cell.imageView.image = [UIImage imageNamed:@"RequestFeature.png"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
        case SEND_MESSAGE_INDEX:
            cell.textLabel.text = NSLocalizedString(SEND_MESSAGE_TEXT,nil);
            cell.detailTextLabel.text = @"";
            cell.imageView.image = [UIImage imageNamed:@"SendMessageIcon.png"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
          
        case RATE_US_INDEX:
            cell.textLabel.text = NSLocalizedString(RATE_US_TEXT,nil);
            cell.detailTextLabel.text = @"";
            cell.imageView.image = [UIImage imageNamed:@"RateUsIcon.png"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
        case RESTORE_PURCHASES_INDEX:
            cell.textLabel.text = NSLocalizedString(RESTORE_PURCHASES_TEXT,nil);
            cell.detailTextLabel.text = @"";
            cell.imageView.image = [UIImage imageNamed:@"RestorePurchasesIcon.png"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
        case REMINDER_INDEX:
            cell.textLabel.text = NSLocalizedString(REMINDER_TEXT,nil);
            cell.detailTextLabel.text = [self nextNotificationTimeString];
            cell.imageView.image = [UIImage imageNamed:@"ReminderIcon.png"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
            
        default:
            break;
    }
    return cell;
}


- (void)termsAndConditionsButtonPressed
{
    NSLog(@"Terms and Conditions button pressed");
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"TODO" message:@"Show T&Cs here" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)privacyPolicyButtonPressed
{
    NSLog(@"Privacy Policy button pressed");
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"TODO" message:@"Show Privacy policy here" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
            
        case TEXT_INVITE_A_FRIEND_INDEX:
        {
            MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
            if([MFMessageComposeViewController canSendText])
            {
                controller.body = NSLocalizedString(@"Check out this great app for doing fitness challenges. https://itunes.apple.com/us/app/id986580178",nil);
                controller.messageComposeDelegate = self;
                [self presentViewController:controller animated:YES completion:nil];
            }
        }
            break;
            
        case REQUEST_FEATURE_INDEX:
            // Launch UserVoice
            NSLog(@"feedback clicked");
            
            break;
            
        case SEND_MESSAGE_INDEX:
            if([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *mailComposeController = [[MFMailComposeViewController alloc] init];
                [mailComposeController setSubject:@"Hi There!"];
                [mailComposeController setToRecipients:[NSArray arrayWithObject:@"bombbodyfitness@gmail.com"]];
                mailComposeController.mailComposeDelegate = self;
                [self presentViewController:mailComposeController animated:YES completion:nil];
            } else {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",nil) message:NSLocalizedString(@"This device does not have the capability to send texts",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
                [alert show];
            }
            break;
            
        case RATE_US_INDEX:
            [Appirater rateApp];
            break;
            
        case RESTORE_PURCHASES_INDEX:
            {
                NSLog(@"SettingsVC Initiated transaction restore");
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.spinner];
                [self.spinner startAnimating];
                [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions){
                    if (transactions.count == 0) {
                        return;
                    }
                    PFQuery *query = [PFQuery queryWithClassName:CHALLENGE_CLASS];
                    [query whereKey:CHALLENGE_PUBLIC equalTo:[NSNumber numberWithBool:YES]];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error && objects.count) {
                            NSLog(@"Transactions restored");
                            BOOL unlockAllPurchased = NO;
                            for (SKPaymentTransaction* transaction in transactions) {
                                NSLog(@"%@", transaction.payment.productIdentifier);
                                NSString* productIdentifier = transaction.payment.productIdentifier;
                                if (![productIdentifier isEqualToString:UNLOCK_ALL_PURCHASE_IDENTIFIER]) {
                                    for (FDChallenge* challenge in objects) {
                                        if ([challenge[CHALLENGE_PURCHASE_IDENTIFIER] isEqualToString:productIdentifier]) {
                                            [challenge persistPurchase];
                                            break;
                                        }
                                    }
                                } else {
                                    unlockAllPurchased = YES;
                                }
                            }
                            if (unlockAllPurchased) {
                                NSDictionary* unlockAllKeychainDictionary = [Lockbox dictionaryForKey:UNLOCK_ALL_PURCHASE_IDENTIFIER];
                                if (!unlockAllKeychainDictionary) {
                                    [Lockbox setDictionary:@{ PURCHASE_STATUS_KEY : @YES } forKey:UNLOCK_ALL_PURCHASE_IDENTIFIER];
                                    for (FDChallenge* challenge in objects) {
                                        [challenge persistPurchase];
                                    }
                                }
                            }
                            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success",nil) message:[NSString stringWithFormat:@"%ld Challenge%@restored.", (long)[transactions count], (([transactions count] != 1) ? @"s " : @" ")] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                        } else {
                            NSLog(@"Something went wrong. error: %@", error);
                            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                        }
                        [self.spinner stopAnimating];
                    }];
                } failure:^(NSError *error) {
                    [self.spinner stopAnimating];
                    NSLog(@"Something went wrong. error: %@", error);
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }];
            }
            break;
            
        case REMINDER_INDEX:
            [self presentViewController:self.timePicker animated:YES completion:nil];
            break;
            
        default:
            break;
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    self.navigationController.navigationBarHidden = NO;
}

- (void)pushRegistrationSucceeded:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Message",nil) message:NSLocalizedString(@"Make sure you enabled banner/alert in the Notification Center.",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
    [alert show];
    NSLog(@"SettingsVC pushRegistrationSucceeded");
}

- (void)pushRegistrationFailed:(id)sender
{
    NSLog(@"SettingsVC pushRegistrationFailed");
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ShowGeneralWebview"]) {
        [segue.destinationViewController setUrlPath:sender];
    } else if ([segue.identifier isEqualToString:@"ShowLoginFromSettings"]) {
        
    }
}




- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

@end
