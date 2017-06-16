//
//  FDChallenge+Purchase.m
//  flexter
//
//  Created by Anurag Tolety on 6/27/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#import "FDChallenge+Purchase.h"
#import "Lockbox.h"
#import "UIConstants.h"
#import "FDChallenge+Keychain.h"

@implementation FDChallenge (Purchase)

+ (BOOL)isAllPurchased {
    NSDictionary* allPurchaseDictionary = [Lockbox dictionaryForKey:UNLOCK_ALL_PURCHASE_IDENTIFIER];
    return [[allPurchaseDictionary objectForKey:PURCHASE_STATUS_KEY] boolValue];
}

+ (void)persistAllPurchase {
    [Lockbox setDictionary:@{ PURCHASE_STATUS_KEY : @YES } forKey:UNLOCK_ALL_PURCHASE_IDENTIFIER];
}

- (void)persistPurchase {
    NSMutableDictionary* keychainDictionary = [[self getKeychainDictionary] mutableCopy];
    [keychainDictionary setObject:@YES forKey:PURCHASE_STATUS_KEY];
    [self setKeychainDictionary:[keychainDictionary copy]];
}

- (BOOL)isPurchased {
    if (!self[CHALLENGE_PURCHASE_IDENTIFIER]) {
        return YES;
    }
    return [[[self getKeychainDictionary] objectForKey:PURCHASE_STATUS_KEY] boolValue];
}

@end
