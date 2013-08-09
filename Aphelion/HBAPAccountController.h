//
//  HBAPAccountController.h
//  Aphelion
//
//  Created by Adam D on 6/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

@interface HBAPAccountController : NSObject

+ (instancetype)sharedInstance;
- (ACAccount *)accountWithUsername:(NSString *)username;

@end
