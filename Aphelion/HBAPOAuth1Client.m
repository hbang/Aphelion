//
//  HBAPOAuth1Client.m
//  Aphelion
//
//  Created by Adam D on 27/10/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPOAuth1Client.h"
#import "HBAPAccount.h"

@interface HBAPOAuth1Client () {
	NSString *_key;
	NSString *_secret;
	HBAPAccount *_account;
}

@end

@implementation HBAPOAuth1Client

+ (NSString *)generateHMACSignatureForRequest:(NSURLRequest *)request consumerSecret:(NSString *)consumerSecret tokenSecret:(NSString *)tokenSecret encoding:(NSStringEncoding)encoding {
    NSString *secret = tokenSecret ? tokenSecret : @"";
    NSString *secretString = [NSString stringWithFormat:@"%@&%@", AFPercentEscapedQueryStringPairMemberFromStringWithEncoding(consumerSecret, NSUTF8StringEncoding), AFPercentEscapedQueryStringPairMemberFromStringWithEncoding(secret, encoding)];
    NSData *secretStringData = [secretString dataUsingEncoding:encoding];
	
    NSString *queryString = AFPercentEscapedQueryStringPairMemberFromStringWithEncoding([[[[[request URL] query] componentsSeparatedByString:@"&"] sortedArrayUsingSelector:@selector(compare:)] componentsJoinedByString:@"&"], encoding);
    NSString *requestString = [NSString stringWithFormat:@"%@&%@&%@", [request HTTPMethod], AFPercentEscapedQueryStringPairMemberFromStringWithEncoding([[[request URL] absoluteString] componentsSeparatedByString:@"?"][0], encoding), queryString];
    NSData *requestStringData = [requestString dataUsingEncoding:encoding];
	
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CCHmacContext cx;
    CCHmacInit(&cx, kCCHmacAlgSHA1, [secretStringData bytes], [secretStringData length]);
    CCHmacUpdate(&cx, [requestStringData bytes], [requestStringData length]);
    CCHmacFinal(&cx, digest);
	
    return [(NSData *)[NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH] base64EncodedDataWithOptions:kNilOptions];
}

- (instancetype)initWithBaseURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret {
	self = [super initWithBaseURL:url];
	
	if (self) {
		_key = key;
		_secret = secret;
	}
	
	return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
	NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
	request.HTTPShouldHandleCookies = NO;
	
	NSDictionary *authParameters = parameters;
	
	if (![method isEqualToString:@"GET"] || ![method isEqualToString:@"HEAD"] || ![method isEqualToString:@"DELETE"]) {
		authParameters = [[request valueForHTTPHeaderField:@"Content-Type"] hasPrefix:@"application/x-www-form-urlencoded"] ? parameters : nil;
	}
	
	[request setValue:[self authorizationHeaderForMethod:method path:path parameters:authParameters] forHTTPHeaderField:@"Authorization"];
	
	return request;
}

- (NSString *)authorizationHeaderForMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
	NSMutableDictionary *mutableParameters = parameters ? [parameters mutableCopy] : [NSMutableDictionary dictionary];
	NSMutableDictionary *oauthParameters = [@{
		@"oauth_consumer_key": _key,
		@"oauth_nonce": ((NSUUID *)[NSUUID UUID]).UUIDString,
		@"oauth_signature_method": @"HMAC-SHA1",
		@"oauth_timestamp": @(floor([NSDate date].timeIntervalSince1970)).stringValue,
		@"oauth_version": @"1.0"
	} mutableCopy];
	
	oauthParameters[@"oauth_token"] = _account.accessToken;
	
	if (parameters[@"x_reverse_auth"]) {
		[mutableParameters removeObjectForKey:@"x_reverse_auth"];
		oauthParameters[@"x_reverse_auth"] = parameters[@"x_reverse_auth"];
	}
	
	[mutableParameters addEntriesFromDictionary:oauthParameters];
	
	oauthParameters[@"oauth_signature"] = [self oauthSignatureForMethod:method path:path parameters:mutableParameters token:_account.accessToken];
	
	NSArray *components = [AFQueryStringFromParametersWithEncoding(oauthParameters, self.stringEncoding) componentsSeparatedByString:@"&"];
	NSMutableString *authHeader = [NSMutableString stringWithString:@"OAuth "];
	BOOL first = YES;
	
	for (NSString *component in components) {
		NSArray *subcomponents = [component componentsSeparatedByString:@"="];
		
		if (subcomponents.count == 2) {
			[authHeader appendFormat:@"%@%@=\"%@\"", first ? @"" : @", ", subcomponents[0], subcomponents[1]];
		}
		
		if (first) {
			first = NO;
		}
	}
	
	return authHeader;
}

- (NSString *)oauthSignatureForMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters token:(id)token {
	return [self.class generateHMACSignatureForRequest:[super requestWithMethod:method path:path parameters:parameters] consumerSecret:_secret tokenSecret:token ? token.secret : nil encoding:self.stringEncoding];
}

@end
