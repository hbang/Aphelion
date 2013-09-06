//
//  HBAPTweetTableViewself.m
//  Aphelion
//
//  Created by Adam D on 20/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTweetTableViewCell.h"
#import "HBAPTweet.h"
#import "HBAPUser.h"
#import "HBAPAvatarImageView.h"

@interface HBAPTweetTableViewCell () {
	UIView *_tweetContainerView;
	
	HBAPAvatarImageView *_avatarImageView;
	
	UILabel *_realNameLabel;
	UILabel *_screenNameLabel;
	UILabel *_timestampLabel;
	
	UIImageView *_retweetImageView;
	UILabel *_retweetedLabel;
	
	UILabel *_contentLabel;
}

@end

@implementation HBAPTweetTableViewCell

#pragma mark - UI Constants

+ (UIFont *)realNameLabelFont {
	return [UIFont boldSystemFontOfSize:19.f];
}

+ (UIFont *)screenNameLabelFont {
	return [UIFont boldSystemFontOfSize:17.f];
}

+ (UIColor *)screenNameLabelColor {
	return [UIColor colorWithWhite:0.2f alpha:1];
}

+ (UIFont *)retweetedLabelFont {
	return [UIFont italicSystemFontOfSize:14.f];
}

+ (UIColor *)retweetedLabelColor {
	return [UIColor colorWithWhite:0.17f alpha:1];
}

+ (UIFont *)contentLabelFont {
	return [UIFont systemFontOfSize:14.f];
}

#pragma mark - General

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	if (self) {
		_tweetContainerView = [[UIView alloc] initWithFrame:self.contentView.frame];
		_tweetContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview:_tweetContainerView];
		
		_avatarImageView = [[HBAPAvatarImageView alloc] initWithUser:nil size:HBAPAvatarSizeRegular];
		_avatarImageView.frame = (CGRect){{10.f, 10.f}, _avatarImageView.frame.size};
		[_tweetContainerView addSubview:_avatarImageView];
		
		float left = 10.f + _avatarImageView.frame.size.width + 10.f;
		
		_realNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, 10.f, 0, 0)];
		_realNameLabel.font = [self.class realNameLabelFont];
		_realNameLabel.backgroundColor = [UIColor clearColor];
		[_tweetContainerView addSubview:_realNameLabel];
		
		_screenNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, 10.f, 0, 0)];
		_screenNameLabel.font = [self.class screenNameLabelFont];
		_screenNameLabel.textColor = [self.class screenNameLabelColor];
		_screenNameLabel.backgroundColor = [UIColor clearColor];
		[_tweetContainerView addSubview:_screenNameLabel];
		
		_retweetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tweet_retweeted"]];
		_retweetImageView.frame = (CGRect){{10.f + _avatarImageView.frame.size.width + 10.f, 10.f}, _retweetImageView.image.size};
		_retweetImageView.hidden = YES;
		[_tweetContainerView addSubview:_retweetImageView];
		
		_retweetedLabel = [[UILabel alloc] init];
		_retweetedLabel.font = [self.class retweetedLabelFont];
		_retweetedLabel.textColor = [self.class retweetedLabelColor];
		_retweetedLabel.backgroundColor = [UIColor clearColor];
		_retweetedLabel.hidden = YES;
		[_tweetContainerView addSubview:_retweetedLabel];
		
		_contentLabel = [[UILabel alloc] init]; // TODO: TTTAttributedLabel
		_contentLabel.font = [self.class contentLabelFont];
		_contentLabel.backgroundColor = [UIColor clearColor];
		_contentLabel.numberOfLines = 0;
		[_tweetContainerView addSubview:_contentLabel];
	}
	
	return self;
}

- (HBAPTweet *)tweet {
	return _tweet;
}

- (void)setTweet:(HBAPTweet *)tweet {
	if (tweet == _tweet) {
		return;
	}
	
	_tweet = tweet;
	
	_realNameLabel.text = _tweet.isRetweet ? _tweet.originalTweet.poster.realName : _tweet.poster.realName;
	_screenNameLabel.text = [@"@" stringByAppendingString:_tweet.isRetweet ? _tweet.originalTweet.poster.screenName : _tweet.poster.screenName];
	
	if (_tweet.isRetweet) {
		_retweetImageView.hidden = NO;
		
		_retweetedLabel.hidden = NO;
		_retweetedLabel.text = _tweet.poster.realName;
	} else {
		_retweetImageView.hidden = YES;
		_retweetedLabel.hidden = YES;
	}
	
	_contentLabel.text = _tweet.isRetweet ? _tweet.originalTweet.text : _tweet.text;
	
	[self layoutSubviews];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[_realNameLabel sizeToFit];
	[_screenNameLabel sizeToFit];
	
	_screenNameLabel.frame = CGRectMake(_realNameLabel.frame.origin.x + _realNameLabel.frame.size.width + 5.f, 10.f, _tweetContainerView.frame.size.width - _realNameLabel.frame.origin.x - _realNameLabel.frame.size.width - 15.f, _realNameLabel.frame.size.height);
	
	if (_tweet.isRetweet) {
		[_retweetedLabel sizeToFit];
		
		_retweetImageView.frame = CGRectMake(_realNameLabel.frame.origin.x, _realNameLabel.frame.origin.y + _realNameLabel.frame.size.height, _retweetImageView.image.size.width, _retweetImageView.image.size.height);
		_retweetedLabel.frame = CGRectMake(_retweetImageView.frame.origin.x + _retweetImageView.frame.size.width + 5.f, _retweetImageView.frame.origin.y, _tweetContainerView.frame.size.width - _retweetImageView.frame.origin.x - _retweetImageView.frame.size.width - 15.f, _retweetedLabel.frame.size.height);
	}
	
	float width = _tweetContainerView.frame.size.width - _realNameLabel.frame.origin.x - 10.f;
	_contentLabel.frame = CGRectMake(_realNameLabel.frame.origin.x, (_tweet.isRetweet ? _retweetImageView.frame.origin.y + _retweetImageView.frame.size.height : _realNameLabel.frame.origin.y + _realNameLabel.frame.size.height) + 3.f, width, [_contentLabel.text sizeWithFont:_contentLabel.font constrainedToSize:CGSizeMake(width, 10000.f)].height);
}

#pragma mark - Memory management

- (void)dealloc {
	[_tweet release];
	
	[super dealloc];
}

@end