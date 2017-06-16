//
//  UserEntryView.h
//  flexter
//
//  Created by Anurag Tolety on 12/11/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ UserEntrySuccessBlock)(BOOL);

typedef NS_ENUM(NSInteger, UserInputType) {
    UserInputTypeEmail,
    UserInputTypeUserName,
    UserInputTypePassword
};

typedef NS_ENUM(NSInteger, UserEntryMode) {
    UserEntryModeSignUpEmailOnly,
    UserEntryModeSignUpAll,
    UserEntryModeLogin,
    UserEntryModeForgotPassword,
    UserEntryModeNone
};

@protocol UserEntryProtocol <NSObject>

@required
- (void)registerUserWithEmail:(NSString*)email userName:(NSString*)userName password:(NSString*)password;
- (void)prepareForRegisteringUser;
- (void)prepareForEmailEntered;
- (void)prepareForForgotPassword;
- (BOOL)validateWithString:(NSString*)input andType:(UserInputType)userInputType;
- (void)checkAvailabilityWithString:(NSString*)input andType:(UserInputType)userInputType withCompletionBlock:(UserEntrySuccessBlock)successBlock;
- (void)handleForgotPassword;

@end

@interface UserEntryView : UIView

@property (weak, nonatomic) id<UserEntryProtocol> delegate;
@property (strong, nonatomic, readonly) NSString* email;
@property (strong, nonatomic, readonly) NSString* userName;
@property (strong, nonatomic, readonly) NSString* password;
@property (nonatomic, readonly) UserEntryMode mode;

- (void)configureWithEmailVisibility:(BOOL)emailVisible userNameVisibility:(BOOL)userNameVisible passwordVisibility:(BOOL)passwordVisible;

@end
