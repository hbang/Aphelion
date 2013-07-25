//
//  HBBMTwitterAPIRequest.h
//  Bromine
//
//  Created by Adam D on 25/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>

typedef void(^HBBMAPIRequestCompletion)(NSData *data, NSError *error);
typedef void(^HBBMAPIRequestCompletionWithDictionary)(NSDictionary *data, NSError *error);

typedef enum {
	HBBMAPIRequestDataTypeRaw,
	HBBMAPIRequestDataTypeJSON,
} HBBMAPIRequestDataType;

@interface HBBMTwitterAPIRequest : NSObject

+ (SLRequest *)requestWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(ACAccount *)account requestMethod:(SLRequestMethod)requestMethod dataType:(HBBMAPIRequestDataType)dataType completion:(HBBMAPIRequestCompletion)completion;
+ (SLRequest *)requestWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(ACAccount *)account completion:(HBBMAPIRequestCompletion)completion;
+ (SLRequest *)postRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(ACAccount *)account completion:(HBBMAPIRequestCompletion)completion;

@end
