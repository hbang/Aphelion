//
//  HBAPTwitterAPIClient.h
//  Aphelion
//
//  Created by Adam D on 21/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPOAuth1Client.h"

@class HBAPTwitterConfiguration;

@interface HBAPTwitterAPIClient : HBAPOAuth1Client

+ (instancetype)sharedInstance;

@property (nonatomic, retain) HBAPTwitterConfiguration *configuration;

@end
