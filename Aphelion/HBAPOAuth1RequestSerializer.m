//
//  HBAPOAuth1RequestSerializer.m
//  Aphelion
//
//  Created by Adam D on 8/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPOAuth1RequestSerializer.h"
#import "HBAPAccount.h"
#import "NSString+HBAdditions.h"
#import <CommonCrypto/CommonHMAC.h>
#import <AFNetworking/AFNetworking.h>

extern NSString *AFQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding);

@interface HBAPOAuth1RequestSerializer () {
	NSString *_key;
	NSString *_secret;
}

@end

@implementation HBAPOAuth1RequestSerializer

+ (NSString *)generateHMACSignatureForMethod:(NSString *)method url:(NSURL *)url parameters:(NSDictionary *)parameters consumerSecret:(NSString *)consumerSecret tokenSecret:(NSString *)tokenSecret encoding:(NSStringEncoding)encoding {
	NSMutableArray *parametersArray = [NSMutableArray array];
	
	if (parameters && parameters.count) {
		for (NSString *parameterName in parameters.allKeys) {
			[parametersArray addObject:[NSString stringWithFormat:@"%@=%@", parameterName.URLEncodedString, ((NSString *)parameters[parameterName]).URLEncodedString]];
		}
	}
	
	NSArray *newParameters = [url.query ? [url.query componentsSeparatedByString:@"&"] : @[] arrayByAddingObjectsFromArray:parametersArray];
	NSString *query = [[newParameters sortedArrayUsingSelector:@selector(compare:)] componentsJoinedByString:@"&"];
    NSData *requestData = [[NSString stringWithFormat:@"%@&%@&%@", method, ((NSString *)[url.absoluteString componentsSeparatedByString:@"?"][0]).URLEncodedString, query.URLEncodedString] dataUsingEncoding:encoding];
	
	NSData *secretData = [[NSString stringWithFormat:@"%@&%@", consumerSecret.URLEncodedString, tokenSecret ? tokenSecret.URLEncodedString : @""] dataUsingEncoding:encoding];
	
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CCHmacContext context;
    CCHmacInit(&context, kCCHmacAlgSHA1, secretData.bytes, secretData.length);
    CCHmacUpdate(&context, requestData.bytes, requestData.length);
    CCHmacFinal(&context, digest);
	
    return [(NSData *)[NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH] base64EncodedStringWithOptions:kNilOptions];
}

+ (instancetype)serializerWithKey:(NSString *)key secret:(NSString *)secret {
	return [[[self alloc] initWithKey:key secret:secret] autorelease];
}

- (instancetype)initWithKey:(NSString *)key secret:(NSString *)secret {
	self = [super init];
	
	if (self) {
		_key = key;
		_secret = secret;
	}
	
	return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters error:(NSError **)error {
	NSMutableURLRequest *request = [super requestWithMethod:method URLString:URLString parameters:parameters error:error];
	request.HTTPShouldHandleCookies = NO;
	[request setValue:[self authorizationHeaderForMethod:method URLString:URLString parameters:parameters] forHTTPHeaderField:@"Authorization"];
	
	return request;
}

- (NSString *)authorizationHeaderForMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters {
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
		oauthParameters[@"x_auth_mode"] = parameters[@"x_auth_mode"];
	}
	
	[mutableParameters addEntriesFromDictionary:oauthParameters];
	
	oauthParameters[@"oauth_signature"] = [self.class generateHMACSignatureForMethod:method url:[NSURL URLWithString:URLString] parameters:mutableParameters consumerSecret:_secret tokenSecret:_account ? _account.accessSecret : nil encoding:self.stringEncoding];
	
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

#pragma mark - Memory management

- (void)dealloc {
	[_account release];
	[_key release];
	[_secret release];
	
	[super dealloc];
}

@end
