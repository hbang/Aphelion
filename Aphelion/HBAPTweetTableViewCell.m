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
	return [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
}

+ (UIFont *)screenNameLabelFont {
	return [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

+ (UIColor *)screenNameLabelColor {
	return [UIColor colorWithWhite:0.2f alpha:1];
}

+ (UIFont *)timestampLabelFont {
	return [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
}

+ (UIColor *)timestampLabelColor {
	return [UIColor colorWithWhite:0.17f alpha:1];
}

+ (UIFont *)retweetedLabelFont {
	return [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

+ (UIColor *)retweetedLabelColor {
	return [UIColor colorWithWhite:0.17f alpha:1];
}

+ (UIFont *)contentLabelFont {
	return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
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
		
		_timestampLabel = [[UILabel alloc] init];
		_timestampLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		_timestampLabel.font = [self.class timestampLabelFont];
		_timestampLabel.textColor = [self.class timestampLabelColor];
		_timestampLabel.textAlignment = NSTextAlignmentRight;
		[_tweetContainerView addSubview:_timestampLabel];
		
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
		
		_contentLabel = [[UILabel alloc] init];
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
	_timestampLabel.text = [self _prettyDateStringForDate:_tweet.isRetweet ? _tweet.originalTweet.sent : _tweet.sent];
	
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
	[_timestampLabel sizeToFit];
	
	_screenNameLabel.frame = CGRectMake(_realNameLabel.frame.origin.x + _realNameLabel.frame.size.width + 5.f, 10.f, _tweetContainerView.frame.size.width - _realNameLabel.frame.origin.x - _realNameLabel.frame.size.width - 15.f - _timestampLabel.frame.size.width - 5.f, _realNameLabel.frame.size.height);
	_timestampLabel.frame = CGRectMake(_tweetContainerView.frame.size.width - 10.f - _timestampLabel.frame.size.width, 10.f, _timestampLabel.frame.size.width, _realNameLabel.frame.size.height);
	
	if (_tweet.isRetweet) {
		[_retweetedLabel sizeToFit];
		
		_retweetImageView.frame = CGRectMake(_realNameLabel.frame.origin.x, _realNameLabel.frame.origin.y + _realNameLabel.frame.size.height, _retweetImageView.image.size.width, _retweetImageView.image.size.height);
		_retweetedLabel.frame = CGRectMake(_retweetImageView.frame.origin.x + _retweetImageView.frame.size.width + 5.f, _retweetImageView.frame.origin.y, _tweetContainerView.frame.size.width - _retweetImageView.frame.origin.x - _retweetImageView.frame.size.width - 15.f, _retweetedLabel.frame.size.height);
	}
	
	float width = _tweetContainerView.frame.size.width - _realNameLabel.frame.origin.x - 10.f;
	_contentLabel.frame = CGRectMake(_realNameLabel.frame.origin.x, (_tweet.isRetweet ? _retweetImageView.frame.origin.y + _retweetImageView.frame.size.height : _realNameLabel.frame.origin.y + _realNameLabel.frame.size.height) + 3.f, width, [_contentLabel.text boundingRectWithSize:CGSizeMake(width, 10000.f) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: _contentLabel.font } context:nil].size.height);
}

- (NSString *)_prettyDateStringForDate:(NSDate *)date {
	double timeSinceNow = date.timeIntervalSinceNow;
	
	if (timeSinceNow < -31536000) { // year = 31536000s
		return [NSString stringWithFormat:@"%iy", (int)-floor(timeSinceNow / 60 / 60 / 24 / 365)];
	} else if (timeSinceNow < -2592000) { // month = 2592000s
		return [NSString stringWithFormat:@"%imo", (int)-floor(timeSinceNow / 60 / 60 / 30)];
	} else if (timeSinceNow < -86400) { // day = 86400s
		return [NSString stringWithFormat:@"%id", (int)-floor(timeSinceNow / 60 / 60 / 24)];
	} else if (timeSinceNow < -3600) { // hour = 3600s
		return [NSString stringWithFormat:@"%ih", (int)-floor(timeSinceNow / 60 / 60)];
	} else if (timeSinceNow < -60) { // min = 60s
		return [NSString stringWithFormat:@"%im", (int)-floor(timeSinceNow / 60)];
	} else if (timeSinceNow < 0) {
		return [NSString stringWithFormat:@"%is", (int)-timeSinceNow];
	} else {
		return L18N(@"Now");
	}
}

#pragma mark - Memory management

- (void)dealloc {
	[_tweet release];
	
	[super dealloc];
}

@end