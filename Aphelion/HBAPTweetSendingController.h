//
//  HBAPTweetSendingController.h
//  Aphelion
//
//  Created by Adam D on 8/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBAPAccount;

@interface HBAPTweetSendingController : NSObject

- (NSProgress *)sendTweet:(NSString *)tweet inReplyToTweet:(NSString *)tweetID withAttachments:(NSArray *)attachments;

@property (nonatomic, retain) HBAPAccount *account;

@end
