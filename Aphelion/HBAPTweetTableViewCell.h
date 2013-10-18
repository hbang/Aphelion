//
//  HBAPTweetTableViewCell.h
//  Aphelion
//
//  Created by Adam D on 20/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HBAPTweet, HBAPAvatarButton;

typedef NS_ENUM(NSUInteger, HBAPTweetTimestampUpdateInterval) {
	HBAPTweetTimestampUpdateIntervalSeconds,
	HBAPTweetTimestampUpdateIntervalMinutes,
};

@interface HBAPTweetTableViewCell : UITableViewCell <UITextViewDelegate>

@property (nonatomic, retain) HBAPTweet *tweet;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain, readonly) HBAPAvatarButton *avatarImageView;
@property (nonatomic, retain, readonly) UILabel *realNameLabel;
@property (nonatomic, retain, readonly) UILabel *screenNameLabel;
@property (nonatomic, retain, readonly) UILabel *timestampLabel;
@property (nonatomic, retain, readonly) UILabel *retweetedLabel;
@property (nonatomic, retain, readonly) UITextView *contentTextView;

+ (UIFont *)realNameLabelFont;
+ (UIFont *)screenNameLabelFont;
+ (UIFont *)retweetedLabelFont;
+ (UIFont *)contentTextViewFont;

@end
