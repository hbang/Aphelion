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
#import "HBAPAvatarButton.h"
#import "HBAPTweetEntity.h"
#import "HBAPTweetTextStorage.h"
#import "HBAPTweetTextView.h"
#import "HBAPTweetAttributedStringFactory.h"
#import "NSString+HBAdditions.h"
#import "HBAPAccount.h"
#import "HBAPAccountController.h"
#import "HBAPTwitterAPISessionManager.h"
#import "HBAPTwitterConfiguration.h"
#import "HBAPProfileViewController.h"
#import "HBAPTweetDetailViewController.h"
#import "HBAPThemeManager.h"
#import "HBAPFontManager.h"

@interface HBAPTweetTableViewCell () {
	UIView *_tweetContainerView;
	
	HBAPTweet *_tweet;
	UINavigationController *_navigationController;
}

@end

@implementation HBAPTweetTableViewCell

+ (CGFloat)heightForTweet:(HBAPTweet *)tweet tableView:(UITableView *)tableView {
	static CGFloat CellSpacingWidth = 45.f;
	static CGFloat CellSpacingHeight = 38.f;
	static CGFloat RetweetSpacingHeight = 3.f;
	
	CGFloat cellPaddingWidth = CellSpacingWidth + [HBAPAvatarView sizeForSize:HBAPAvatarSizeNormal].width;
	BOOL isRetweet = NO;
	
	if (tweet.isRetweet) {
		tweet = tweet.originalTweet;
		isRetweet = YES;
	}
	
	if (!tweet) {
		return [self.class defaultHeight];
	}
	
	[tweet createAttributedStringIfNeeded];
	
	return CellSpacingHeight + ceilf([@" " sizeWithAttributes:@{ NSFontAttributeName: [HBAPFontManager sharedInstance].headingFont }].height) + ceilf([tweet.attributedString boundingRectWithSize:CGSizeMake(tableView.frame.size.width - cellPaddingWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height) + (isRetweet ? ceilf([@" " sizeWithAttributes:@{ NSFontAttributeName: [HBAPFontManager sharedInstance].subheadingFont }].height) + RetweetSpacingHeight : 0);
}

#pragma mark - UI Constants

+ (CGFloat)defaultHeight {
	return 78.f;
}

#pragma mark - General

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithReuseIdentifier:reuseIdentifier];
	
	if (self) {
		_tweetContainerView = [[UIView alloc] initWithFrame:self.contentView.frame];
		_tweetContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview:_tweetContainerView];
		
		_avatarImageView = [[HBAPAvatarButton alloc] initWithUser:nil size:HBAPAvatarSizeNormal];
		_avatarImageView.frame = (CGRect){{15.f, 15.f}, _avatarImageView.frame.size};
		[_tweetContainerView addSubview:_avatarImageView];
		
		CGFloat left = 15.f + _avatarImageView.frame.size.width + 15.f;
		
		_realNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, 18.f, 0, 0)];
		_realNameLabel.backgroundColor = [UIColor clearColor];
		[_tweetContainerView addSubview:_realNameLabel];
		
		_screenNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, _realNameLabel.frame.origin.y, 0, 0)];
		_screenNameLabel.backgroundColor = [UIColor clearColor];
		[_tweetContainerView addSubview:_screenNameLabel];
		
		_timestampLabel = [[UILabel alloc] init];
		_timestampLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		_timestampLabel.textAlignment = NSTextAlignmentRight;
		[_tweetContainerView addSubview:_timestampLabel];
		
		_tweetTextView = [[HBAPTweetTextView alloc] init];
		_tweetTextView.backgroundColor = [UIColor clearColor];
		[_tweetContainerView addSubview:_tweetTextView];
		
		_retweetedLabel = [[UILabel alloc] init];
		_retweetedLabel.backgroundColor = [UIColor clearColor];
		_retweetedLabel.hidden = YES;
		[_tweetContainerView addSubview:_retweetedLabel];
		
		[self setupTheme];
	}
	
	return self;
}

- (void)setupTheme {
	[super setupTheme];
	
	_realNameLabel.textColor = [HBAPThemeManager sharedInstance].textColor;
	_screenNameLabel.textColor = [HBAPThemeManager sharedInstance].dimTextColor;
	_timestampLabel.textColor = [HBAPThemeManager sharedInstance].dimTextColor;
	_retweetedLabel.textColor = [HBAPThemeManager sharedInstance].dimTextColor;
	_tweetTextView.tintColor = [HBAPThemeManager sharedInstance].tintColor;
}

- (HBAPTweet *)tweet {
	return _tweet;
}

- (void)setTweet:(HBAPTweet *)tweet {
	if (tweet == _tweet) {
		return;
	}
	
	_tweet = tweet;
	
	HBAPTweet *shownTweet = _tweet.isRetweet ? _tweet.originalTweet : _tweet;
	
	if (_tweet) {
		self.selectionStyle = UITableViewCellSelectionStyleDefault;
		
		_avatarImageView.user = shownTweet.poster;
		_realNameLabel.text = shownTweet.poster.realName;
		_screenNameLabel.text = [@"@" stringByAppendingString:shownTweet.poster.screenName];
		_timestampLabel.hidden = NO;
		[self updateTimestamp];
		
		if (_tweet.isRetweet) {
			_retweetedLabel.hidden = NO;
			_retweetedLabel.text = [NSString stringWithFormat:L18N(@"Retweeted by %@"), _tweet.poster.realName];
		} else {
			_retweetedLabel.hidden = YES;
		}
		
		_tweetTextView.attributedString = shownTweet.attributedString;
		[_tweetTextView setNeedsDisplay];
	}
	
	[self layoutSubviews];
}

- (UINavigationController *)navigationController {
	return _navigationController;
}

- (void)setNavigationController:(UINavigationController *)navigationController {
	_navigationController = navigationController;
	_avatarImageView.navigationController = navigationController;
	_tweetTextView.navigationController = _navigationController;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	_realNameLabel.font = [HBAPFontManager sharedInstance].headingFont;
	_screenNameLabel.font = [HBAPFontManager sharedInstance].subheadingFont;
	_timestampLabel.font = [HBAPFontManager sharedInstance].footerFont;
	_retweetedLabel.font = [HBAPFontManager sharedInstance].subheadingFont;
		
	[_realNameLabel sizeToFit];
	[_screenNameLabel sizeToFit];
	[_timestampLabel sizeToFit];
	[_retweetedLabel sizeToFit];
	
	CGFloat width = _tweetContainerView.frame.size.width - _realNameLabel.frame.origin.x - 15.f;
	
	_screenNameLabel.frame = CGRectMake(_realNameLabel.frame.origin.x + _realNameLabel.frame.size.width + 5.f, _screenNameLabel.frame.origin.y, _tweetContainerView.frame.size.width - _realNameLabel.frame.origin.x - _realNameLabel.frame.size.width - 15.f - _timestampLabel.frame.size.width - 5.f, _realNameLabel.frame.size.height);
	_timestampLabel.frame = CGRectMake(_tweetContainerView.frame.size.width - 15.f - _timestampLabel.frame.size.width, _screenNameLabel.frame.origin.y, _timestampLabel.frame.size.width, _realNameLabel.frame.size.height);
	_tweetTextView.frame = CGRectMake(_realNameLabel.frame.origin.x, _realNameLabel.frame.origin.y + _realNameLabel.frame.size.height + 1.f, width, ceilf([_tweetTextView.attributedString boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height) + 3.f);
	_retweetedLabel.frame = CGRectMake(_realNameLabel.frame.origin.x, _tweetTextView.frame.origin.y + _tweetTextView.frame.size.height, width, _retweetedLabel.frame.size.height);
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
		return [NSString stringWithFormat:@"%imo", (int)floor(timeSinceNow / 60 / 24 / 30)];
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

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)url inRange:(NSRange)characterRange {
	HBAPTweet *tweet = _tweet.isRetweet ? _tweet.originalTweet : _tweet;
	
	if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
		if (([url.host isEqualToString:@"twitter.com"] || [url.host isEqualToString:@"www.twitter.com"] || [url.host isEqualToString:@"mobile.twitter.com"]) && url.pathComponents.count > 1) {
			if (url.pathComponents.count == 2 && [url.pathComponents[1] isEqualToString:@"search"] && url.query) {
				HBLogInfo(@"textView:shouldInteractWithURL:inRange: opening search vc not implemented");
				
				return YES;//NO
			} else if (url.pathComponents.count == 2 && ![[HBAPTwitterAPISessionManager sharedInstance].configuration.nonUsernamePaths containsObject:url.pathComponents[1]]) {
				NSString *userID = nil;
				
				for (HBAPTweetEntity *entity in tweet.entities) {
					if (entity.range.location == characterRange.location && entity.range.length == characterRange.length) {
						userID = entity.userID;
						break;
					}
				}
				
				HBAPProfileViewController *viewController = [[[HBAPProfileViewController alloc] initWithUserID:userID] autorelease];
				[_navigationController pushViewController:viewController animated:YES];
				
				return NO;
			} else if (url.pathComponents.count == 4 && ([url.pathComponents[2] isEqualToString:@"status"] || [url.pathComponents[2] isEqualToString:@"statuses"])) {
				HBAPTweetDetailViewController *viewController = [[[HBAPTweetDetailViewController alloc] init] autorelease];
				[_navigationController pushViewController:viewController animated:YES];
				
				return NO;
			}
		}
	}
	
	return YES;
}

#pragma mark - Memory management

/*
- (void)dealloc {
	[_tweet release];
	[_navigationController release];
	[_avatarImageView release];
	[_screenNameLabel release];
	[_realNameLabel release];
	[_timestampLabel release];
	[_retweetedLabel release];
	[_tweetTextView release];
	[_tweetContainerView release];
	
	[super dealloc];
}
*/

@end
