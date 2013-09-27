//
//  HBAPTweetTableViewCell.h
//  Aphelion
//
//  Created by Adam D on 20/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HBAPTweet;

typedef enum {
	HBAPTweetTimestampUpdateIntervalSeconds,
	HBAPTweetTimestampUpdateIntervalMinutes,
} HBAPTweetTimestampUpdateInterval;

@interface HBAPTweetTableViewCell : UITableViewCell

@property (nonatomic, retain) HBAPTweet *tweet;
@property (nonatomic, retain, readonly) NSString *tweetText;
@property BOOL editable;

+ (UIFont *)realNameLabelFont;
+ (UIFont *)screenNameLabelFont;
+ (UIFont *)retweetedLabelFont;
+ (UIFont *)contentTextViewFont;

@end
