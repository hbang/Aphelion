//
//  HBBMTwitterAPIRequest.m
//  Bromine
//
//  Created by Adam D on 25/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBBMTwitterAPIRequest.h"

@implementation HBBMTwitterAPIRequest

+ (SLRequest *)requestWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(ACAccount *)account requestMethod:(SLRequestMethod)requestMethod dataType:(HBBMAPIRequestDataType)dataType completion:(HBBMAPIRequestCompletion)completion {
	SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:[kHBBMTwitterAPIRoot stringByAppendingString:path]] parameters:parameters];
	request.account = account;
	
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		completion(responseData, error);
	}];
	
	return request;
}

+ (SLRequest *)requestWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(ACAccount *)account completion:(HBBMAPIRequestCompletion)completion {
	return [self requestWithPath:path parameters:parameters account:account requestMethod:SLRequestMethodGET dataType:HBBMAPIRequestDataTypeJSON completion:completion];
}

+ (SLRequest *)postRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(ACAccount *)account completion:(HBBMAPIRequestCompletion)completion {
	return [self requestWithPath:path parameters:parameters account:account requestMethod:SLRequestMethodPOST dataType:HBBMAPIRequestDataTypeJSON completion:completion];
}

@end
