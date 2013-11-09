//
//  HBAPOAuth1RequestSerializer.h
//  Aphelion
//
//  Created by Adam D on 8/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "AFURLRequestSerialization.h"

@class HBAPAccount;

@interface HBAPOAuth1RequestSerializer : AFHTTPRequestSerializer

+ (instancetype)serializerWithKey:(NSString *)key secret:(NSString *)secret;

- (instancetype)initWithKey:(NSString *)key secret:(NSString *)secret;

@property (nonatomic, retain) HBAPAccount *account;

@end
