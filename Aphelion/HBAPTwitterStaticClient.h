//
//  HBAPTwitterStaticClient.h
//  Aphelion
//
//  Created by Adam D on 22/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "AFHTTPClient.h"

@interface HBAPTwitterStaticClient : AFHTTPClient

+ (instancetype)sharedInstance;

@end
