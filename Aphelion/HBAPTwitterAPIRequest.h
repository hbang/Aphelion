//
//  HBAPTwitterAPIRequest.h
//  Aphelion
//
//  Created by Adam D on 25/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBAPAccount;

typedef void(^HBAPAPIRequestCompletion)(NSData *data, NSError *error);
typedef void(^HBAPAPIRequestCompletionWithDictionary)(NSDictionary *data, NSError *error);

@interface HBAPTwitterAPIRequest : NSObject

+ (instancetype)requestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters account:(HBAPAccount *)account;
+ (instancetype)requestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters account:(HBAPAccount *)account completion:(HBAPAPIRequestCompletion)completion;
+ (instancetype)requestWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(HBAPAccount *)account;
+ (instancetype)requestWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(HBAPAccount *)account completion:(HBAPAPIRequestCompletion)completion;

- (instancetype)initWithURL:(NSURL *)url parameters:(NSDictionary *)parameters account:(HBAPAccount *)account;
- (instancetype)initWithURL:(NSURL *)url parameters:(NSDictionary *)parameters account:(HBAPAccount *)account completion:(HBAPAPIRequestCompletion)completion;
- (instancetype)initWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(HBAPAccount *)account;
- (instancetype)initWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(HBAPAccount *)account completion:(HBAPAPIRequestCompletion)completion;

- (void)performRequestWithCompletion:(HBAPAPIRequestCompletion)completion;

@end
