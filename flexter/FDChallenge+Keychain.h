//
//  FDChallenge+Keychain.h
//  flexter
//
//  Created by Anurag Tolety on 6/27/15.
//  Copyright (c) 2015 JMJ Innovations. All rights reserved.
//

#import "FDChallenge.h"

@interface FDChallenge (Keychain)

- (NSDictionary*)getKeychainDictionary;
- (void)setKeychainDictionary:(NSDictionary*)keychainDictionary;

@end
