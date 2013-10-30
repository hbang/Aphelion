//
//  HBAPOAuth1Client.m
//  Aphelion
//
//  Created by Adam D on 27/10/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPOAuth1Client.h"
#import "HBAPAccount.h"
#import "NSString+HBAdditions.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation HBAPOAuth1Client

+ (NSString *)generateHMACSignatureForMethod:(NSString *)method url:(NSURL *)url parameters:(NSDictionary *)parameters consumerSecret:(NSString *)consumerSecret tokenSecret:(NSString *)tokenSecret encoding:(NSStringEncoding)encoding {
	NSMutableArray *parametersArray = [NSMutableArray array];
    for (NSString *parameterName in parameters.allKeys) {
        [parametersArray addObject:[NSString stringWithFormat:@"%@=%@", parameterName.URLEncodedString, ((NSString *)parameters[parameterName]).URLEncodedString]];
    }
	
	NSArray *newParameters = [url.query ? [url.query componentsSeparatedByString:@"&"] : @[] arrayByAddingObjectsFromArray:parametersArray];
	NSString *query = [[newParameters sortedArrayUsingSelector:@selector(compare:)] componentsJoinedByString:@"&"];
    NSData *requestData = [[NSString stringWithFormat:@"%@&%@&%@", method, ((NSString *)[url.absoluteString componentsSeparatedByString:@"?"][0]).URLEncodedString, query.URLEncodedString] dataUsingEncoding:encoding];
	
	NSData *secretData = [[NSString stringWithFormat:@"%@&%@", consumerSecret.URLEncodedString, tokenSecret ? tokenSecret.URLEncodedString : @""] dataUsingEncoding:encoding];
	
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CCHmacContext cx;
    CCHmacInit(&cx, kCCHmacAlgSHA1, secretData.bytes, secretData.length);
    CCHmacUpdate(&cx, requestData.bytes, requestData.length);
    CCHmacFinal(&cx, digest);
	
    return [(NSData *)[NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH] base64EncodedStringWithOptions:kNilOptions];
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
	
	if (![method isEqualToString:@"GET"] && ![method isEqualToString:@"HEAD"] && ![method isEqualToString:@"DELETE"] && [[request valueForHTTPHeaderField:@"Content-Type"] hasPrefix:@"application/x-www-form-urlencoded"]) {
		authParameters = nil;
	}
	
	[request setValue:[self authorizationHeaderForMethod:method path:path parameters:authParameters] forHTTPHeaderField:@"Authorization"];
	
	return request;
}

- (NSString *)authorizationHeaderForMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
	NSMutableDictionary *mutableParameters = parameters ? [[parameters mutableCopy] autorelease] : [NSMutableDictionary dictionary];
	NSMutableDictionary *oauthParameters = [[@{
		@"oauth_consumer_key": _key,
		@"oauth_nonce": ((NSUUID *)[NSUUID UUID]).UUIDString,
		@"oauth_signature_method": @"HMAC-SHA1",
		@"oauth_timestamp": @(floor([NSDate date].timeIntervalSince1970)).stringValue,
		@"oauth_version": @"1.0"
	} mutableCopy] autorelease];
	
	if (_account) {
		oauthParameters[@"oauth_token"] = _account.accessToken;
	}
	
	if (parameters[@"x_auth_mode"]) {
		[mutableParameters removeObjectForKey:@"x_auth_mode"];
		oauthParameters[@"x_auth_mode"] = parameters[@"x_auth_mode"];
	}
	
	[mutableParameters addEntriesFromDictionary:oauthParameters];
		
	oauthParameters[@"oauth_signature"] = [self.class generateHMACSignatureForMethod:method url:[NSURL URLWithString:path relativeToURL:self.baseURL] parameters:mutableParameters consumerSecret:_secret tokenSecret:_account ? _account.accessSecret : nil encoding:self.stringEncoding];
	
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

@end
