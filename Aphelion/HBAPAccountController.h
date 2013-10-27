//
//  HBAPAccountController.h
//  Aphelion
//
//  Created by Adam D on 6/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBAPAccount;

@interface HBAPAccountController : NSObject

+ (instancetype)sharedInstance;

- (NSArray *)allAccounts;
- (HBAPAccount *)accountForCurrentUser;
- (HBAPAccount *)accountForUserID:(NSString *)userID;

@end
