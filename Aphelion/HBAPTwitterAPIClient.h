//
//  HBAPTwitterAPIClient.h
//  Aphelion
//
//  Created by Adam D on 21/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "AFHTTPClient.h"

@class AFOAuth1Client;

@interface HBAPTwitterAPIClient : AFHTTPClient {
	AFOAuth1Client *_OAuthClient;
}

+ (instancetype)sharedInstance;

@property (nonatomic, retain) AFOAuth1Client *OAuthClient;

@end
