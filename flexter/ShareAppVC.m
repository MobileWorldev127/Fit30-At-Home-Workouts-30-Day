//
//  ShareAppVC.m
//  flexter
//
//  Created by Anurag Tolety on 9/24/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "ShareAppVC.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "FDConstants.h"
#import "FDCustomKeyValuePairs.h"
#import <Crashlytics/Crashlytics.h>

@interface ShareAppVC () <MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *shareAppLabel;
@property (weak, nonatomic) IBOutlet UILabel *lbl_sharedetail;
@property (weak, nonatomic) IBOutlet UILabel *lbl_contact;

@end

@implementation ShareAppVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.shareAppLabel.text = @"";
    self.lbl_sharedetail.text = @"Sharing your progress with your friends will help \n you stay in the habit of working out. Give it a try!";
    self.lbl_contact.text = @"Contact Support / Give Feedback";

	
    PFQuery* query = [PFQuery queryWithClassName:CUSTOM_KEY_VALUE_CLASS];
    [query whereKey:CUSTOM_KEY_VALUE_KEY equalTo:CUSTOM_KEY_SHARE_LABEL_TEXTS];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        BOOL customMessageRetrieved = NO;
        if ([error code] == 0) {
            FDCustomKeyValuePairs* customMessages = (FDCustomKeyValuePairs*)[objects lastObject];
            if (customMessages) {
                NSArray* shareLabelStrings = customMessages[CUSTOM_KEY_VALUE_VALUE];
                if ([shareLabelStrings count]) {
                    customMessageRetrieved = YES;
                    NSUserDefaults* defaults = [[NSUserDefaults alloc] init];
                    NSNumber* lastMessageIndexNumber = [defaults objectForKey:CUSTOM_KEY_SHARE_LABEL_TEXTS];
                    int newMessageIndex = 0;
                    if (lastMessageIndexNumber && ([lastMessageIndexNumber intValue] < ([shareLabelStrings count] - 1))) {
                        newMessageIndex = lastMessageIndexNumber.intValue + 1;
                    }
                    self.shareAppLabel.text = [shareLabelStrings objectAtIndex:newMessageIndex];
                    [defaults setObject:[NSNumber numberWithInt:newMessageIndex] forKey:CUSTOM_KEY_SHARE_LABEL_TEXTS];
                }
            }
        } else {
            NSLog(@"Error: %@", error);
        }
        if (!customMessageRetrieved) {
            self.shareAppLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Woohoo! Day %d \n is done!",nil), self.day];
        }
    }];
	[self requestReview];
}


- (void) requestReview {
	NSLog(@"day: %d",self.day);
	Boolean reviewedApp = [[NSUserDefaults standardUserDefaults] boolForKey:@"reviewedApp"];
	if (!reviewedApp && (self.day % 3) == 0) {
		NSString *message = [NSString stringWithFormat:NSLocalizedString(@"I hope Fit30 has helped you get in better shape! If so, we'd really appreciate a review in the App Store. Thank you so much!\n-Jay",nil)];
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please help us out!",nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:NSLocalizedString(@"Sure!",nil), nil] show];
	}
	
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if([alertView.title isEqualToString:NSLocalizedString(@"Please help us out!",nil)])
	{
		if (buttonIndex == 0) {
			NSLog(@"NO");
			[PFAnalytics trackEvent:@"askedForReview" dimensions:@{@"reponsce": @"no"}];
		} else if (buttonIndex == 1) {
			NSLog(@"review clicked");
			[PFAnalytics trackEvent:@"askedForReview" dimensions:@{@"reponsce": @"yes"}];
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			
			[userDefaults setBool:YES forKey:@"reviewedApp"];
			[userDefaults synchronize];
			
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=986580178&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
			//http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=483983989&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8
		}
	}
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareThroughTextMessage:(id)sender {
    if([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.body = NSLocalizedString(@"Hey! Check this amazing app for fitness challenges. https://itunes.apple.com/us/app/id986580178?mt=8",nil);
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",nil) message:NSLocalizedString(@"This device does not have the capability to send texts",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [alert show];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}



- (IBAction)onclickedShareButton:(id)sender {

    NSString * message = [NSString stringWithFormat:NSLocalizedString(@"Just completed day %d/30 of my 30-day workout challenge on Fit30 for iPhone! http://app2.it/fit30",nil), self.day];
    NSArray *array = @[message];
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
    
    [self presentViewController:avc animated:YES completion:nil];
    
    [Answers logCustomEventWithName:@"Workout Shared" customAttributes:@{@"App Share to":@"",
                                                                         @"":@""}];
}


@end
