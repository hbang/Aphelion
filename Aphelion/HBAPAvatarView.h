//
//  HBAPAvatarView.h
//  Aphelion
//
//  Created by Adam D on 18/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBAPUser.h"

@interface HBAPAvatarView : UIView

@property (nonatomic, retain) HBAPUser *user;
@property (nonatomic, retain) NSString *userID;

+ (CGSize)sizeForSize:(HBAPAvatarSize)size;

- (instancetype)initWithSize:(HBAPAvatarSize)size;
- (instancetype)initWithUser:(HBAPUser *)user size:(HBAPAvatarSize)size;
- (instancetype)initWithUserID:(NSString *)userID size:(HBAPAvatarSize)size;

@end
