//
//  HBAPTweetSendingController.m
//  Aphelion
//
//  Created by Adam D on 8/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTweetSendingController.h"
#import "HBAPTweet.h"
#import "HBAPAccount.h"
#import "HBAPTwitterAPISessionManager.h"
#import "HBAPNavigationController.h"
#import <UIKit+AFNetworking/UIProgressView+AFNetworking.h>

@implementation HBAPTweetSendingController

- (void)sendTweet:(NSString *)tweet inReplyToTweet:(NSString *)tweetID withAttachments:(NSArray *)attachments {
	NSMutableDictionary *parameters = [[@{
		@"status": tweet
	} mutableCopy] autorelease];
	
	if (tweetID) {
		parameters[@"in_reply_to_status_id"] = tweetID;
	}
	
	_navigationController.progress = 0.05f;
	
	/*NSURLSessionDataTask *task =*/ [[HBAPTwitterAPISessionManager sharedInstance] POST:@"statuses/update.json" parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
		_navigationController.progress = 1.f;
		
		if (_successBlock) {
			_successBlock([[HBAPTweet alloc] initWithDictionary:responseObject]);
		}
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		_navigationController.progress = 1.f;
		
		if (_failureBlock) {
			_failureBlock(error);
		}
	}];
	
	// _navigationController.progressTask = task;
}

#pragma mark - Memory management

- (void)dealloc {
	[_account release];
	[_navigationController release];
	[_successBlock release];
	[_failureBlock release];
	
	[super dealloc];
}

@end
