//
//  HBAPOAuth1Client.h
//  Aphelion
//
//  Created by Adam D on 27/10/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@class HBAPAccount;

@interface HBAPOAuth1SessionManager : AFHTTPSessionManager

- (instancetype)initWithBaseURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret;

@property (nonatomic, retain) HBAPAccount *account;

@end
