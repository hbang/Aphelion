//
//  HBAPTwitterAPIClient.h
//  Aphelion
//
//  Created by Adam D on 21/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <AFOAuth1Client/AFOAuth1Client.h>

@interface HBAPTwitterAPIClient : AFHTTPClient

+ (instancetype)sharedInstance;

@end
