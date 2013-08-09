//
//  HBAPTwitterAPIRequest.m
//  Aphelion
//
//  Created by Adam D on 25/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTwitterAPIRequest.h"

@implementation HBAPTwitterAPIRequest

+ (SLRequest *)requestWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(ACAccount *)account requestMethod:(SLRequestMethod)requestMethod dataType:(HBAPAPIRequestDataType)dataType completion:(HBAPAPIRequestCompletion)completion {
	SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:[kHBAPTwitterAPIRoot stringByAppendingString:path]] parameters:parameters];
	request.account = account;
	
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		completion(responseData, error);
	}];
	
	return request;
}

+ (SLRequest *)requestWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(ACAccount *)account completion:(HBAPAPIRequestCompletion)completion {
	return [self requestWithPath:path parameters:parameters account:account requestMethod:SLRequestMethodGET dataType:HBAPAPIRequestDataTypeJSON completion:completion];
}

+ (SLRequest *)postRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(ACAccount *)account completion:(HBAPAPIRequestCompletion)completion {
	return [self requestWithPath:path parameters:parameters account:account requestMethod:SLRequestMethodPOST dataType:HBAPAPIRequestDataTypeJSON completion:completion];
}

@end
