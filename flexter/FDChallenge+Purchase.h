//
//  FDChallenge+Purchase.h
//  flexter
//
//  Created by Anurag Tolety on 6/27/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#import "FDChallenge.h"

@interface FDChallenge (Purchase)

+ (void)persistAllPurchase;
// Do not use this to find out if all the existing challenges were purchased. New challenges may have been added since the user purchased all from the PurchaseAllVC.
+ (BOOL)isAllPurchased;

- (void)persistPurchase;
- (BOOL)isPurchased;

@end
