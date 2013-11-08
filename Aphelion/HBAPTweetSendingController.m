//
//  HBAPTweetSendingController.m
//  Aphelion
//
//  Created by Adam D on 8/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTweetSendingController.h"
#import "HBAPAccount.h"

@implementation HBAPTweetSendingController

- (NSProgress *)sendTweet:(NSString *)tweet inReplyToTweet:(NSString *)tweetID withAttachments:(NSArray *)attachments {
	NSProgress *progress = [[NSProgress alloc] initWithParent:nil userInfo:@{
		
	}];
	return progress;
}

@end
