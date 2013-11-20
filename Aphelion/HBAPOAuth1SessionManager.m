//
//  HBAPOAuth1Client.m
//  Aphelion
//
//  Created by Adam D on 27/10/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPOAuth1SessionManager.h"
#import "HBAPOAuth1RequestSerializer.h"
#import "HBAPAccountController.h"

@implementation HBAPOAuth1SessionManager

- (instancetype)initWithBaseURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret {
	self = [self initWithBaseURL:url];
	
	if (self) {
		self.requestSerializer = [HBAPOAuth1RequestSerializer serializerWithKey:key secret:secret];
	}
	
	return self;
}

- (HBAPAccount *)account {
	return ((HBAPOAuth1RequestSerializer *)self.requestSerializer).account;
}

- (void)setAccount:(HBAPAccount *)account {
	((HBAPOAuth1RequestSerializer *)self.requestSerializer).account = account;
}

@end
