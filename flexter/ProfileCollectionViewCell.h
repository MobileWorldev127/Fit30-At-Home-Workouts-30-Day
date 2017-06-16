//
//  ProfileCollectionViewCell.h
//  flexter
//
//  Created by Anurag Tolety on 12/9/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileImageProtocol <NSObject>

@required
- (void)handleProfileCellSelection;

@end

@interface ProfileCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id<ProfileImageProtocol> delegate;
- (void)configureWithUserName:(NSString*)userName andWorkoutCount:(int)workoutCount andProfileImage:(UIImage*)profileImage;

@end
