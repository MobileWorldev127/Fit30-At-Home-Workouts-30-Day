//
//  PurchaseAllChallengesVC.m
//  flexter
//
//  Created by Anurag Tolety on 6/25/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#import "PurchaseAllChallengesVC.h"
#import "RMStore.h"
#import "Lockbox.h"
#import "UIConstants.h"
#import "FDChallenge+Purchase.h"

@interface PurchaseAllChallengesVC () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *purchaseAllButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PurchaseAllChallengesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.purchaseAllButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.purchaseAllButton setTitle:@"Fetching price..." forState:UIControlStateNormal];
    self.purchaseAllButton.enabled = NO;
    if (UNLOCK_ALL_PURCHASE_IDENTIFIER) {
        NSSet *products = [NSSet setWithArray:@[UNLOCK_ALL_PURCHASE_IDENTIFIER]];
        [[RMStore defaultStore] requestProducts:products success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
            if (products.count) {
                for (SKProduct* product in products) {
                    NSLog(@"%@, %@, %0.02f", product.productIdentifier, product.localizedTitle, product.price.floatValue);
                    if ([product.productIdentifier isEqualToString:UNLOCK_ALL_PURCHASE_IDENTIFIER] && [SKPaymentQueue canMakePayments]) {
                        [self.purchaseAllButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Buy for $%0.02f",nil), product.price.floatValue] forState:UIControlStateNormal];
                        self.purchaseAllButton.enabled = YES;
                    }
                }
            } else {
                [self.purchaseAllButton setTitle:@"Error!" forState:UIControlStateNormal];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",nil) message:NSLocalizedString(@"Unable to retrieve the price for buy all.",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
                [alert show];
            }
        } failure:^(NSError *error) {
            NSLog(@"Something went wrong: %@", error);
            [self.purchaseAllButton setTitle:NSLocalizedString(@"Error!",nil) forState:UIControlStateNormal];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",nil) message:NSLocalizedString(@"Unable to retrieve price for all from Apple's Servers. Please try again.",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
            [alert show];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)purchaseAllButtonPressed:(id)sender {
    [[RMStore defaultStore] addPayment:UNLOCK_ALL_PURCHASE_IDENTIFIER success:^(SKPaymentTransaction *transaction) {
        [FDChallenge persistAllPurchase];
        for (FDChallenge* challenge in self.challenges) {
            [challenge persistPurchase];
        }
        NSLog(@"Product unlock all purchased");
		[PFAnalytics trackEvent:@"boughtIAP" dimensions:@{@"product": UNLOCK_ALL_PURCHASE_IDENTIFIER}];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Hurray!",nil) message:NSLocalizedString(@"Thank you for purchasing All Challenges!",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [alert show];
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        NSLog(@"Something went wrong %@", [error localizedDescription]);
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [alert show];
    }];
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PurchaseAllPromptCell"];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%ld professionally designed challenges to tone and maximize fat loss.",nil), (long)self.challenges.count - 1];
            break;
            
        case 1:
            cell.textLabel.text = NSLocalizedString(@"All in one spot, anytime, on the go.",nil);
            break;
            
        case 2:
            cell.textLabel.text = NSLocalizedString(@"For beginners & intermediates.",nil);
            break;
            
        case 3:
            cell.textLabel.text = NSLocalizedString(@"No equipment needed.",nil);
            break;
            
        case 4:
            cell.textLabel.text = NSLocalizedString(@"OVER 50% OFF!",nil);
            break;
            
        default:
            break;
    }
    return cell;
}
@end
