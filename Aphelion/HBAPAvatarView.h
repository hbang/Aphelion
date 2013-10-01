//
//  HBAPAvatarView.h
//  Aphelion
//
//  Created by Adam D on 30/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HBAPUser;

typedef enum {
	HBAPAvatarSizeRegular,
	HBAPAvatarSizeBig,
	HBAPAvatarSizeOriginal,
} HBAPAvatarSize;

@interface HBAPAvatarView : UIButton

@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) HBAPUser *user;
@property (nonatomic, retain) UIImageView *avatarImageView;

+ (CGRect)frameForSize:(HBAPAvatarSize)size;

- (instancetype)initWithScreenName:(NSString *)screenName size:(HBAPAvatarSize)size;
- (instancetype)initWithUser:(HBAPUser *)user size:(HBAPAvatarSize)size;

@end
