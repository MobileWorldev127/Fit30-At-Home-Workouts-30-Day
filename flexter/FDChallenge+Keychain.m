//
//  FDChallenge+Keychain.m
//  flexter
//
//  Created by Anurag Tolety on 6/27/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#import "FDChallenge+Keychain.h"
#import "Lockbox.h"
#import "UIConstants.h"

@implementation FDChallenge (Keychain)

- (NSString*)getKeychainDictionaryKey {
    return self[CHALLENGE_PURCHASE_IDENTIFIER] ? self[CHALLENGE_PURCHASE_IDENTIFIER] : self.objectId;
}

- (NSDictionary*)getKeychainDictionary {
    NSDictionary* keychainDictionary = [Lockbox dictionaryForKey:[self getKeychainDictionaryKey]];
    if (!keychainDictionary) {
        keychainDictionary = @{ PURCHASE_STATUS_KEY : @NO, IN_PROGRESS_DAY_INDEX : @0};
        [self setKeychainDictionary:keychainDictionary];
    }
    return keychainDictionary;
}

- (void)setKeychainDictionary:(NSDictionary*)keychainDictionary {
    if (keychainDictionary) {
        [Lockbox setDictionary:keychainDictionary forKey:[self getKeychainDictionaryKey]];
    }
}

@end
