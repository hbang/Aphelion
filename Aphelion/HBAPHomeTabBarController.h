//
//  HBAPHomeTabBarController.h
//  Aphelion
//
//  Created by Adam D on 6/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HBAPAccount;

@interface HBAPHomeTabBarController : UITabBarController

- (instancetype)initWithAccount:(HBAPAccount *)account;

@end
