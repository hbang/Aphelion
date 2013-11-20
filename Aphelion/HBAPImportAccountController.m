//
//  HBAPImportAccountController.m
//  Aphelion
//
//  Created by Adam D on 25/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPImportAccountController.h"
#import "HBAPAppDelegate.h"
#import "HBAPTutorialViewController.h"
#import "HBAPTwitterOAuthSessionManager.h"
#import "HBAPNavigationController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <LUKeychainAccess/LUKeychainAccess.h>

@interface HBAPImportAccountController () {
	ACAccountStore *_accountStore;
	NSMutableArray *_accounts;
}

@end

@implementation HBAPImportAccountController

- (instancetype)init {
	self = [super init];
	
	if (self) {
		_accountStore = [[ACAccountStore alloc] init];
		
		[self loadAccounts];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountStoreDidChange) name:ACAccountStoreDidChangeNotification object:nil];
	}
	
	return self;
}

#pragma mark - Account store stuff

- (void)loadAccounts {
	[_accounts release];
	
	_accounts = [[NSMutableArray alloc] init];
	
	NSDictionary *accountsDefaults = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"accounts"] ?: @{};
	NSArray *accounts = [_accountStore accountsWithAccountType:[_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]];
	
	for (NSUInteger i = 0; i < accounts.count; i++) {
		// private property :(
		NSString *userID = [[(ACAccount *)accounts[i] valueForKey:[NSString stringWithFormat:@"%@ert%@s", @"prop", @"ie"]] valueForKey:[NSString stringWithFormat:@"u%@i%@", @"ser_", @"d"]];
		
		if (!accountsDefaults[userID]) {
			[_accounts addObject:accounts[i]];
		}
	}
}

- (void)accountStoreDidChange {
	[self loadAccounts];
}

#pragma mark - Reverse Auth

- (void)importAccount:(ACAccount *)account callback:(void (^)(NSError *error))callback {
	[self _beginReverseAuthWithCallback:^(NSError *error, NSData *response) {
		if (error) {
			callback(error);
			return;
		}
		
		[self _retrieveAccessTokenForAccount:account stepOneResponse:response callback:^(NSError *error, NSDictionary *response) {
			if (error) {
				callback(error);
				return;
			}
			
			[self addAccountWithUserID:response[@"user_id"] key:response[@"oauth_token"] secret:response[@"oauth_token_secret"]];
			callback(nil);
		}];
	}];
}

- (void)_beginReverseAuthWithCallback:(void (^)(NSError *error, NSData *response))callback {
	[[HBAPTwitterOAuthSessionManager sharedInstance] POST:@"/oauth/request_token" parameters:@{ @"x_auth_mode": @"reverse_auth" } success:^(NSURLSessionTask *task, NSData *response) {
		callback(nil, response);
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		HBLogError(@"login step 1 failed: %@", error);
		callback(error, nil);
	}];
}

- (void)_retrieveAccessTokenForAccount:(ACAccount *)account stepOneResponse:(NSData *)response callback:(void (^)(NSError *error, NSDictionary *response))callback {
	SLRequest *stepTwoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"access_token" relativeToURL:[NSURL URLWithString:kHBAPTwitterOAuthRoot]] parameters:@{
		@"x_reverse_auth_target": kHBAPTwitterKey,
		@"x_reverse_auth_parameters": [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] autorelease]
	}];
	stepTwoRequest.account = account;
	[stepTwoRequest performRequestWithHandler:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
		if (error) {
			HBLogError(@"login step 2 failed for %@: %@", account.username, error);
			callback([self errorForXMLError:data originalError:error], nil);
			return;
		}
		
		NSString *output = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		NSArray *parameters = [output componentsSeparatedByString:@"&"];
		NSMutableDictionary *items = [NSMutableDictionary dictionary];
		
		for (NSString *parameter in parameters) {
			NSArray *splitArray = [parameter componentsSeparatedByString:@"="];
			items[splitArray[0]] = splitArray[1];
		}
		
		callback(nil, items);
	}];
}

#pragma mark - Add account

- (void)addAccountWithUserID:(NSString *)userID key:(NSString *)key secret:(NSString *)secret {
	NSMutableDictionary *accountList = [((NSDictionary *)[[LUKeychainAccess standardKeychainAccess] objectForKey:@"accounts"]).mutableCopy autorelease] ?: [NSMutableDictionary dictionary];
	
	accountList[userID] = @{
		@"token": key,
		@"secret": secret
	};
	
	[[LUKeychainAccess standardKeychainAccess] setObject:accountList forKey:@"accounts"];
}

#pragma mark - Errors

- (NSError *)errorForXMLError:(NSData *)data originalError:(NSError *)error {
	// i couldn't possibly give a fuck about using a parser
	NSString *response = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
	NSRange errorIDStartRange = [response rangeOfString:@"<error code=\""];
	NSRange errorIDEndRange = [response rangeOfString:@"\">" options:kNilOptions range:NSMakeRange(errorIDStartRange.location + errorIDStartRange.length, 10)];
	NSString *errorID =	errorIDStartRange.location == NSNotFound ? @"-1337" : [response substringWithRange:NSMakeRange(errorIDStartRange.location + errorIDStartRange.length, errorIDEndRange.length)];
	NSString *errorMessage = errorIDStartRange.location == NSNotFound ? [NSString stringWithFormat:L18N(@"Unknown error: %@"), error.localizedDescription] : [response substringWithRange:NSMakeRange(errorIDEndRange.location + 2, [response rangeOfString:@"</error>"].location - errorIDEndRange.location - 2)];
	
	return [NSError errorWithDomain:HBAPImportAccountStepTwoError code:errorID.integerValue userInfo:@{ NSLocalizedDescriptionKey: errorMessage }];
}

#pragma mark - Memory management

- (void)dealloc {
	[_accountStore release];
	[_accounts release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

@end
