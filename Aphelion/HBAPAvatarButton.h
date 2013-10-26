//
//  HBAPAvatarButton.h
//  Aphelion
//
//  Created by Adam D on 30/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBAPAvatarView.h"

@interface HBAPAvatarButton : UIButton

@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) HBAPUser *user;
@property (nonatomic, retain) NSString *userID;

- (instancetype)initWithSize:(HBAPAvatarSize)size;
- (instancetype)initWithUser:(HBAPUser *)user size:(HBAPAvatarSize)size;
- (instancetype)initWithUserID:(NSString *)userID size:(HBAPAvatarSize)size;

@end
