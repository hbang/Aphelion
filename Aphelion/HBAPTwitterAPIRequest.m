//
//  HBAPTwitterAPIRequest.m
//  Aphelion
//
//  Created by Adam D on 25/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTwitterAPIRequest.h"

@interface HBAPTwitterAPIRequest () {
	NSMutableURLRequest *_request;
	HBAPAPIRequestCompletion _completion;
}

@end

@implementation HBAPTwitterAPIRequest

+ (instancetype)requestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters account:(HBAPAccount *)account {
	return [[[self alloc] initWithURL:url parameters:parameters account:account] autorelease];
}

- (instancetype)initWithURL:(NSURL *)url parameters:(NSDictionary *)parameters account:(HBAPAccount *)account {
	self = [super init];
	
	if (self) {
		_request = [[NSMutableURLRequest alloc] initWithURL:url];
		_request.HTTPMethod = @"POST";
		
		NSString *signature = [NSString stringWithFormat:@"%@", _request.HTTPMethod];
		
		NSString *alphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
		NSMutableString *nonce = [NSMutableString stringWithString:@"hbang"];
		
		for (unsigned i = 0; i < 27; i++) {
			[nonce appendString:[alphabet substringWithRange:NSMakeRange(arc4random_uniform(alphabet.length), 1)]];
		}
		
		if (account) {
			[_request setValue:[NSString stringWithFormat:@"OAuth oauth_nonce=\"%@\" oauth_consumer_key=\"%@\" oauth_signature_method=\"HMAC_SHA1\" oauth_signature=\"%@\" oauth_token=\"%@\" oauth_timestamp=\"%d\" oauth_version=\"1.0\"", nonce, kHBAPTwitterKey, kHBAPTwitterSecret, signature, (int)((NSDate *)[NSDate date]).timeIntervalSince1970] forHTTPHeaderField:@"Authorization"]; // TODO: user key/secret
		} else {
			[_request setValue:[NSString stringWithFormat:@"OAuth oauth_nonce=\"%@\" oauth_consumer_key=\"%@\" oauth_signature_method=\"HMAC_SHA1\" oauth_signature=\"%@\" oauth_token=\"%@\" oauth_timestamp=\"%d\" oauth_version=\"1.0\"", nonce, kHBAPTwitterKey, kHBAPTwitterSecret, signature, (int)((NSDate *)[NSDate date]).timeIntervalSince1970] forHTTPHeaderField:@"Authorization"];
		}
	}
	
	return self;
}

+ (instancetype)requestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters account:(HBAPAccount *)account completion:(HBAPAPIRequestCompletion)completion {
	return [[[self alloc] initWithURL:url parameters:parameters account:account completion:completion] autorelease];
}

- (instancetype)initWithURL:(NSURL *)url parameters:(NSDictionary *)parameters account:(HBAPAccount *)account completion:(HBAPAPIRequestCompletion)completion {
	self = [self initWithURL:url parameters:parameters account:account];
	
	if (self) {
		if (completion) {
			[self performRequestWithCompletion:completion];
		}
	}
	
	return self;
}

+ (instancetype)requestWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(HBAPAccount *)account {
	return [[[self alloc] initWithPath:path parameters:parameters account:account] autorelease];	
}

- (instancetype)initWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(HBAPAccount *)account {
	self = [self initWithPath:path parameters:parameters account:account completion:nil];
	return self;
}

+ (instancetype)requestWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(HBAPAccount *)account completion:(HBAPAPIRequestCompletion)completion {
	return [[[self alloc] initWithPath:path parameters:parameters account:account completion:completion] autorelease];	
}

- (instancetype)initWithPath:(NSString *)path parameters:(NSDictionary *)parameters account:(HBAPAccount *)account completion:(HBAPAPIRequestCompletion)completion {
	self = [self initWithURL:[NSURL URLWithString:[kHBAPTwitterAPIRoot stringByAppendingString:path]] parameters:parameters account:account completion:completion];
	
	if (self) {
		if (completion) {
			[self performRequestWithCompletion:completion];
		}
	}
	
	return self;
}

- (void)performRequestWithCompletion:(HBAPAPIRequestCompletion)completion {
	_completion = completion;
	
	NSError *error;
	NSData *output = [NSURLConnection sendSynchronousRequest:_request returningResponse:nil error:&error];
		
	_completion(output, error);
}

#pragma mark - Memory management

- (void)dealloc {
	[_request release];
	
	[super dealloc];
}

@end
