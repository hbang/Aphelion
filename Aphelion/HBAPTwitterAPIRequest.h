//
//  HBAPTwitterAPIRequest.h
//  Aphelion
//
//  Created by Adam D on 25/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>

typedef void(^HBAPAPIRequestCompletion)(NSData *data, NSError *error);
typedef void(^HBAPAPIRequestCompletionWithDictionary)(NSDictionary *data, NSError *error);

typedef enum {
	HBAPAPIRequestDataTypeRaw,
	HBAPAPIRequestDataTypeJSON,
} HBAPAPIRequestDataType;

@interface HBAPTwitterAPIRequest : NSObject

+ (SLRequest *)requestWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(ACAccount *)account requestMethod:(SLRequestMethod)requestMethod dataType:(HBAPAPIRequestDataType)dataType completion:(HBAPAPIRequestCompletion)completion;
+ (SLRequest *)requestWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(ACAccount *)account completion:(HBAPAPIRequestCompletion)completion;
+ (SLRequest *)postRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(ACAccount *)account completion:(HBAPAPIRequestCompletion)completion;

@end
