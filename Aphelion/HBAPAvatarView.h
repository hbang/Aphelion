//
//  HBAPAvatarView.h
//  Aphelion
//
//  Created by Adam D on 18/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HBAPUser;

typedef NS_ENUM(NSUInteger, HBAPAvatarSize) {
	HBAPAvatarSizeSmall,
	HBAPAvatarSizeRegular,
	HBAPAvatarSizeBig,
	HBAPAvatarSizeOriginal,
};

@interface HBAPAvatarView : UIView

@property (nonatomic, retain) HBAPUser *user;
@property (nonatomic, retain) NSString *userID;

+ (CGRect)frameForSize:(HBAPAvatarSize)size;

- (instancetype)initWithSize:(HBAPAvatarSize)size;
- (instancetype)initWithUser:(HBAPUser *)user size:(HBAPAvatarSize)size;
- (instancetype)initWithUserID:(NSString *)userID size:(HBAPAvatarSize)size;

@end
