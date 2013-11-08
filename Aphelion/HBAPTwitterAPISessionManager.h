//
//  HBAPTwitterAPIClient.h
//  Aphelion
//
//  Created by Adam D on 21/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPOAuth1SessionManager.h"

@class HBAPTwitterConfiguration;

@interface HBAPTwitterAPISessionManager : HBAPOAuth1SessionManager

+ (instancetype)sharedInstance;

@property (nonatomic, retain) HBAPTwitterConfiguration *configuration;

@end
