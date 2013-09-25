//
//  HBAPTwitterAPIClient.m
//  Aphelion
//
//  Created by Adam D on 21/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTwitterAPIClient.h"
#import "HBAPAccountController.h"

@interface HBAPTwitterAPIClient () {
	NSMutableDictionary *_tokenCache;
}

@end

@implementation HBAPTwitterAPIClient

+ (instancetype)sharedInstance {
	static HBAPTwitterAPIClient *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self.class alloc] initWithBaseURL:[NSURL URLWithString:kHBAPTwitterAPIRoot] key:kHBAPTwitterKey secret:kHBAPTwitterSecret];
	});
	
	return sharedInstance;
}

- (instancetype)initWithBaseURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret {
	self = [super initWithBaseURL:url key:key secret:secret];
	
	if (self) {
		_tokenCache = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
	self.accessToken = [urlRequest.URL.pathComponents[1] isEqualToString:@"oauth"] ? nil : [[HBAPAccountController sharedInstance] accessTokenForAccount:[HBAPAccountController sharedInstance].accountForCurrentUser];
	return [super HTTPRequestOperationWithRequest:urlRequest success:success failure:failure];
}

@end
