//
//  HBAPTweetTableViewCell.h
//  Aphelion
//
//  Created by Adam D on 20/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HBAPTweet;

typedef NS_ENUM(NSUInteger, HBAPTweetTimestampUpdateInterval) {
	HBAPTweetTimestampUpdateIntervalSeconds,
	HBAPTweetTimestampUpdateIntervalMinutes,
};

@interface HBAPTweetTableViewCell : UITableViewCell <UITextViewDelegate>

@property (nonatomic, retain) HBAPTweet *tweet;
@property BOOL editable;
@property (nonatomic, retain) UINavigationController *navigationController;

+ (UIFont *)realNameLabelFont;
+ (UIFont *)screenNameLabelFont;
+ (UIFont *)retweetedLabelFont;
+ (UIFont *)contentTextViewFont;

@end
