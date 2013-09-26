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
#import "HBAPTweetEntity.h"

@interface HBAPTweetTableViewCell () {
	UIView *_tweetContainerView;
	
	HBAPAvatarImageView *_avatarImageView;
	
	UILabel *_realNameLabel;
	UILabel *_screenNameLabel;
	UILabel *_timestampLabel;
	UILabel *_contentLabel;
	UILabel *_retweetedLabel;
	
	HBAPTweet *_tweet;
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
	return [UIColor colorWithWhite:0.6666666667f alpha:1];
}

+ (UIFont *)timestampLabelFont {
	return [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
}

+ (UIColor *)timestampLabelColor {
	return [UIColor colorWithWhite:0.6666666667f alpha:1];
}

+ (UIFont *)retweetedLabelFont {
	return [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

+ (UIColor *)retweetedLabelColor {
	return [UIColor colorWithWhite:0.6666666667f alpha:1];
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
		_avatarImageView.frame = (CGRect){{15.f, 15.f}, _avatarImageView.frame.size};
		[_tweetContainerView addSubview:_avatarImageView];
		
		float left = 15.f + _avatarImageView.frame.size.width + 15.f;
		
		_realNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, 18.f, 0, 0)];
		_realNameLabel.font = [self.class realNameLabelFont];
		_realNameLabel.backgroundColor = [UIColor clearColor];
		[_tweetContainerView addSubview:_realNameLabel];
		
		_screenNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, _realNameLabel.frame.origin.y, 0, 0)];
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
		
		_contentLabel = [[UILabel alloc] init];
		_contentLabel.font = [self.class contentLabelFont];
		_contentLabel.backgroundColor = [UIColor clearColor];
		_contentLabel.numberOfLines = 0;
		[_tweetContainerView addSubview:_contentLabel];
		
		_retweetedLabel = [[UILabel alloc] init];
		_retweetedLabel.font = [self.class retweetedLabelFont];
		_retweetedLabel.textColor = [self.class retweetedLabelColor];
		_retweetedLabel.backgroundColor = [UIColor clearColor];
		_retweetedLabel.hidden = YES;
		[_tweetContainerView addSubview:_retweetedLabel];
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
	
	_avatarImageView.user = _tweet.isRetweet ? _tweet.originalTweet.poster : _tweet.poster;
	_realNameLabel.text = _tweet.isRetweet ? _tweet.originalTweet.poster.realName : _tweet.poster.realName;
	_screenNameLabel.text = [@"@" stringByAppendingString:_tweet.isRetweet ? _tweet.originalTweet.poster.screenName : _tweet.poster.screenName];
	_timestampLabel.text = [self _prettyDateStringForDate:_tweet.isRetweet ? _tweet.originalTweet.sent : _tweet.sent];
	
	if (_tweet.isRetweet) {
		_retweetedLabel.hidden = NO;
		_retweetedLabel.text = [NSString stringWithFormat:L18N(@"Retweeted by %@"), _tweet.poster.realName];
	} else {
		_retweetedLabel.hidden = YES;
	}
	
	NSMutableString *text = [_tweet.isRetweet ? _tweet.originalTweet.text : _tweet.text mutableCopy];
	
	for (HBAPTweetEntity *entity in tweet.entities) {
		if (entity.range.location + entity.range.length >= text.length - 1) {
			continue;
		}
		
		[text replaceCharactersInRange:entity.range withString:entity.replacement];
	}
	
	_contentLabel.text = text;
	
	[self layoutSubviews];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[_realNameLabel sizeToFit];
	[_screenNameLabel sizeToFit];
	[_timestampLabel sizeToFit];
	[_retweetedLabel sizeToFit];
	
	float width = _tweetContainerView.frame.size.width - _realNameLabel.frame.origin.x - 15.f;
	
	_screenNameLabel.frame = CGRectMake(_realNameLabel.frame.origin.x + _realNameLabel.frame.size.width + 5.f, _screenNameLabel.frame.origin.y, _tweetContainerView.frame.size.width - _realNameLabel.frame.origin.x - _realNameLabel.frame.size.width - 15.f - _timestampLabel.frame.size.width - 5.f, _realNameLabel.frame.size.height);
	_timestampLabel.frame = CGRectMake(_tweetContainerView.frame.size.width - 15.f - _timestampLabel.frame.size.width, _screenNameLabel.frame.origin.y, _timestampLabel.frame.size.width, _realNameLabel.frame.size.height);
	_contentLabel.frame = CGRectMake(_realNameLabel.frame.origin.x, _realNameLabel.frame.origin.y + _realNameLabel.frame.size.height + 1.f, width, [_contentLabel.text boundingRectWithSize:CGSizeMake(width, 10000.f) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: _contentLabel.font } context:nil].size.height);
	_retweetedLabel.frame = CGRectMake(_realNameLabel.frame.origin.x, _contentLabel.frame.origin.y + _contentLabel.frame.size.height, width, _retweetedLabel.frame.size.height + 6.f);
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