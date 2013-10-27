//
//  HBAPOAuth1Client.h
//  Aphelion
//
//  Created by Adam D on 27/10/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "AFHTTPClient.h"

@class HBAPAccount;

@interface HBAPOAuth1Client : AFHTTPClient

- (instancetype)initWithBaseURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret;

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *secret;
@property (nonatomic, retain) HBAPAccount *account;

@end
