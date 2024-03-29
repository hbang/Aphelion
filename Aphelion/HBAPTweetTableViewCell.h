//
//  HBAPTweetTableViewCell.h
//  Aphelion
//
//  Created by Adam D on 20/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTableViewCell.h"

@class HBAPTweet, HBAPTweetTextView, HBAPAvatarButton, HBAPNavigationController;

@interface HBAPTweetTableViewCell : HBAPTableViewCell <UITextViewDelegate>

+ (CGFloat)heightForTweet:(HBAPTweet *)tweet tableView:(UITableView *)tableView;
+ (CGFloat)defaultHeight;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)updateTimestamp;

@property (nonatomic, retain) HBAPTweet *tweet;
@property (nonatomic, retain) HBAPNavigationController *navigationController;
@property (nonatomic, retain, readonly) UIView *tweetContainerView;
@property (nonatomic, retain, readonly) HBAPAvatarButton *avatarImageView;
@property (nonatomic, retain, readonly) UILabel *timestampLabel;
@property (nonatomic, retain, readonly) HBAPTweetTextView *tweetTextView;

@end
