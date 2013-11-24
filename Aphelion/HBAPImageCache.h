//
//  HBAPImageCache.h
//  Aphelion
//
//  Created by Adam D on 13/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HBAPUser.h"

@interface HBAPImageCache : NSObject

+ (instancetype)sharedInstance;

- (UIImage *)avatarForUser:(HBAPUser *)user ofSize:(HBAPAvatarSize)size;
- (UIImage *)bannerForUser:(HBAPUser *)user ofSize:(HBAPBannerSize)size;

- (void)getAvatarForUser:(HBAPUser *)user size:(HBAPAvatarSize)size completion:(void (^)(UIImage *image, NSError *error))completion;
- (void)getBannerForUser:(HBAPUser *)user size:(HBAPBannerSize)size completion:(void (^)(UIImage *image, NSError *error))completion;

@end
