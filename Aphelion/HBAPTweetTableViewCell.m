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
#import "HBAPTweetTextStorage.h"
#import "NSString+HBAdditions.h"

@interface HBAPTweetTableViewCell () {
	UIView *_tweetContainerView;
	
	HBAPAvatarImageView *_avatarImageView;
	
	UILabel *_realNameLabel;
	UILabel *_screenNameLabel;
	UILabel *_timestampLabel;
	UITextView *_contentTextView;
	UILabel *_retweetedLabel;
	
	HBAPTweet *_tweet;
	HBAPTweetTextStorage *_textStorage;
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

+ (UIFont *)contentTextViewFont {
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
		
		_textStorage = [[HBAPTweetTextStorage alloc] init];
		NSLayoutManager *layoutManager = [[[NSLayoutManager alloc] init] autorelease];
		NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithSize:CGSizeMake(_tweetContainerView.frame.size.width, CGFLOAT_MAX)] autorelease];
		textContainer.widthTracksTextView = YES;
		[layoutManager addTextContainer:textContainer];
		[_textStorage addLayoutManager:layoutManager];
		
		_contentTextView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:textContainer];
		_contentTextView.font = [self.class contentTextViewFont];
		_contentTextView.backgroundColor = [UIColor clearColor];
		_contentTextView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
		_contentTextView.textContainerInset = UIEdgeInsetsZero;
		_contentTextView.textContainer.lineFragmentPadding = 0;
		_contentTextView.dataDetectorTypes = UIDataDetectorTypeAll;
		_contentTextView.editable = _editable;
		_contentTextView.scrollEnabled = _editable;
		[_tweetContainerView addSubview:_contentTextView];
		
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
	[self updateTimestamp];
	
	if (_tweet.isRetweet) {
		_retweetedLabel.hidden = NO;
		_retweetedLabel.text = [NSString stringWithFormat:L18N(@"Retweeted by %@"), _tweet.poster.realName];
	} else {
		_retweetedLabel.hidden = YES;
	}
	
	NSMutableString *text = [[_tweet.isRetweet ? _tweet.originalTweet.text.stringByDecodingXMLEntities : _tweet.text.stringByDecodingXMLEntities mutableCopy] autorelease];
	
	for (HBAPTweetEntity *entity in _tweet.isRetweet ? _tweet.originalTweet.entities : _tweet.entities) {
		if (entity.range.location + entity.range.length >= text.length - 1) {
			continue;
		}
		
		[text replaceCharactersInRange:entity.range withString:entity.replacement];
	}
	
	_tweetText = [text copy];
	_contentTextView.text = text;
	_textStorage.entities = _tweet.entities;
	
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
	_contentTextView.frame = CGRectMake(_realNameLabel.frame.origin.x, _realNameLabel.frame.origin.y + _realNameLabel.frame.size.height + 1.f, width, [_contentTextView.text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: _contentTextView.font } context:nil].size.height + 3.f);
	_retweetedLabel.frame = CGRectMake(_realNameLabel.frame.origin.x, _contentTextView.frame.origin.y + _contentTextView.frame.size.height, width, _retweetedLabel.frame.size.height);
}

- (HBAPTweetTimestampUpdateInterval)updateTimestamp {
	NSDate *date = _tweet.isRetweet ? _tweet.originalTweet.sent : _tweet.sent;
	_timestampLabel.text = [self _prettyDateStringForDate:date];
	return date.timeIntervalSinceNow < -60 ? HBAPTweetTimestampUpdateIntervalSeconds : HBAPTweetTimestampUpdateIntervalMinutes;
}

- (NSString *)_prettyDateStringForDate:(NSDate *)date {
	double timeSinceNow = -date.timeIntervalSinceNow;
	
	if (timeSinceNow > 31536000) { // year = 31536000s
		return [NSString stringWithFormat:@"%iy", (int)floor(timeSinceNow / 60 / 60 / 24 / 365)];
	} else if (timeSinceNow > 2592000) { // month = 2592000s
		return [NSString stringWithFormat:@"%imo", (int)floor(timeSinceNow / 60 / 60 / 30)];
	} else if (timeSinceNow > 86400) { // day = 86400s
		return [NSString stringWithFormat:@"%id", (int)floor(timeSinceNow / 60 / 60 / 24)];
	} else if (timeSinceNow > 3600) { // hour = 3600s
		return [NSString stringWithFormat:@"%ih", (int)floor(timeSinceNow / 60 / 60)];
	} else if (timeSinceNow > 60) { // min = 60s
		return [NSString stringWithFormat:@"%im", (int)floor(timeSinceNow / 60)];
	} else if (timeSinceNow > 0) {
		return [NSString stringWithFormat:@"%is", (int)timeSinceNow];
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