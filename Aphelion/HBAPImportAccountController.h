//
//  HBAPImportAccountController.h
//  Aphelion
//
//  Created by Adam D on 25/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTableViewController.h"

@class ACAccount;

static NSString *const HBAPImportAccountStepTwoError = @"HBAPImportAccountStepTwoError";

@interface HBAPImportAccountController : NSObject

- (void)importAccount:(ACAccount *)account callback:(void (^)(NSError *error))callback;

@property (nonatomic, retain) NSArray *accounts;

@end
