//
//  HBAPTweetSendingController.h
//  Aphelion
//
//  Created by Adam D on 8/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBAPAccount, HBAPTweet, HBAPNavigationController;

@interface HBAPTweetSendingController : NSObject

- (void)sendTweet:(NSString *)tweet inReplyToTweet:(NSString *)tweetID withAttachments:(NSArray *)attachments;

@property (nonatomic, retain) HBAPAccount *account;
@property (nonatomic, retain) HBAPNavigationController *navigationController;
@property (nonatomic, copy) void (^successBlock)(HBAPTweet *tweet);
@property (nonatomic, copy) void (^failureBlock)(NSError *error);

@end
