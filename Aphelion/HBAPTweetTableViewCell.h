//
//  HBAPTweetTableViewCell.h
//  Aphelion
//
//  Created by Adam D on 20/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTableViewCell.h"

@class HBAPTweet, HBAPAvatarButton, HBAPNavigationController;

typedef NS_ENUM(NSUInteger, HBAPTweetTimestampUpdateInterval) {
	HBAPTweetTimestampUpdateIntervalSeconds,
	HBAPTweetTimestampUpdateIntervalMinutes,
};

@interface HBAPTweetTableViewCell : HBAPTableViewCell <UITextViewDelegate>

+ (CGFloat)heightForTweet:(HBAPTweet *)tweet tableView:(UITableView *)tableView;
+ (CGFloat)defaultHeight;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, retain) HBAPTweet *tweet;
@property (nonatomic, retain) HBAPNavigationController *navigationController;
@property (nonatomic, retain, readonly) HBAPAvatarButton *avatarImageView;
@property (nonatomic, retain, readonly) UILabel *realNameLabel;
@property (nonatomic, retain, readonly) UILabel *screenNameLabel;
@property (nonatomic, retain, readonly) UILabel *timestampLabel;
@property (nonatomic, retain, readonly) UILabel *retweetedLabel;
@property (nonatomic, retain, readonly) UITextView *contentTextView;

@end
