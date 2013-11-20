//
//  HBAPAccountController.h
//  Aphelion
//
//  Created by Adam D on 6/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBAPAccount;

static NSString *const HBAPAccountControllerDidReloadUsers = @"HBAPAccountControllerDidReloadUsers";

@interface HBAPAccountController : NSObject

+ (instancetype)sharedInstance;

- (HBAPAccount *)currentAccount;
- (void)updateAccounts;

@property (nonatomic, retain) NSDictionary *accounts;

@end
