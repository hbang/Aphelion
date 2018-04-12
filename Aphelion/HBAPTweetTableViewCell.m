//
//  HBAPTweetTableViewCell.m
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
#import "HBAPTweetActivityViewController.h"
#import "HBAPThemeManager.h"
#import "HBAPFontManager.h"

@interface HBAPTweetTableViewCell () {
	HBAPTweet *_tweet;
	UILabel *_titleLabel;
	UINavigationController *_navigationController;
}

@end

@implementation HBAPTweetTableViewCell

+ (CGFloat)heightForTweet:(HBAPTweet *)tweet tableView:(UITableView *)tableView {
	static CGFloat CellSpacingWidth = 45.f;
	static CGFloat CellSpacingHeight = 36.f;
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
		UILongPressGestureRecognizer *longPressGestureRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerFired:)] autorelease];
		longPressGestureRecognizer.minimumPressDuration = 1.0;
		[self.contentView addGestureRecognizer:longPressGestureRecognizer];
		
		_tweetContainerView = [[UIView alloc] initWithFrame:self.contentView.frame];
		_tweetContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview:_tweetContainerView];
		
		_avatarImageView = [[HBAPAvatarButton alloc] initWithUser:nil size:HBAPAvatarSizeNormal];
		_avatarImageView.frame = (CGRect){{15.f, 15.f}, _avatarImageView.frame.size};
		[_tweetContainerView addSubview:_avatarImageView];
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f + _avatarImageView.frame.size.width + 15.f, 16.f, 0, 0)];
		_titleLabel.numberOfLines = 0;
		[_tweetContainerView addSubview:_titleLabel];
		
		_timestampLabel = [[UILabel alloc] init];
		_timestampLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		_timestampLabel.textAlignment = NSTextAlignmentRight;
		[_tweetContainerView addSubview:_timestampLabel];
		
		_tweetTextView = [[HBAPTweetTextView alloc] init];
		[_tweetContainerView addSubview:_tweetTextView];
		
		[self setupTheme];
	}
	
	return self;
}

- (void)setupTheme {
	[super setupTheme];
	
	_timestampLabel.textColor = [HBAPThemeManager sharedInstance].dimTextColor;
	_tweetTextView.tintColor = [HBAPThemeManager sharedInstance].tintColor;
	_timestampLabel.font = [HBAPFontManager sharedInstance].footerFont;
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
		
		NSString *retweeted = _tweet.isRetweet ? [NSString stringWithFormat:[L18N(@"Retweeted by %@") stringByAppendingString:@"\n"], _tweet.poster.realName] : @"";
		
		NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
		paragraphStyle.lineSpacing = 0.f;
		paragraphStyle.maximumLineHeight = [HBAPFontManager sharedInstance].subheadingFont.pointSize + 2.f;
		
		NSMutableParagraphStyle *realNameParagraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
		realNameParagraphStyle.lineSpacing = 0.f;
		realNameParagraphStyle.maximumLineHeight = [HBAPFontManager sharedInstance].headingFont.pointSize + 2.f;
		
		NSMutableAttributedString *titleAttributedString = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@ @%@", retweeted, shownTweet.poster.realName, shownTweet.poster.screenName] attributes:@{
			NSFontAttributeName: [HBAPFontManager sharedInstance].subheadingFont,
			NSForegroundColorAttributeName: [HBAPThemeManager sharedInstance].dimTextColor,
			NSParagraphStyleAttributeName: paragraphStyle
		}] autorelease];
		[titleAttributedString addAttributes:@{
			NSFontAttributeName: [HBAPFontManager sharedInstance].headingFont,
			NSForegroundColorAttributeName: [HBAPThemeManager sharedInstance].textColor,
			NSParagraphStyleAttributeName: realNameParagraphStyle
		} range:NSMakeRange(retweeted.length, shownTweet.poster.realName.length)];
		
		_titleLabel.attributedText = titleAttributedString;
		
		_tweetTextView.attributedString = shownTweet.attributedString;
		[_tweetTextView setNeedsDisplay];
	}
	
	[self updateTimestamp];
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
	
	HBAPTweet *tweet = _tweet.isRetweet ? _tweet.originalTweet : _tweet;
	CGFloat width = _tweetContainerView.frame.size.width - _titleLabel.frame.origin.x - 15.f;
	
	CGRect titleFrame = _titleLabel.frame;
	titleFrame.size.height = ceilf([_titleLabel.attributedText boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height) + 3.f;
	_titleLabel.frame = titleFrame;
	
	_tweetTextView.frame = CGRectMake(titleFrame.origin.x, titleFrame.origin.y + titleFrame.size.height + 1.f, width, ceilf([tweet.attributedString boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height) + 3.f);
}

#pragma mark - Date

- (void)updateTimestamp {
	_timestampLabel.text = [self _prettyDateStringForDate:_tweet.isRetweet ? _tweet.originalTweet.sent : _tweet.sent];
	
	CGFloat width = _tweetContainerView.frame.size.width - _titleLabel.frame.origin.x - 15.f;
	CGSize size = [_timestampLabel sizeThatFits:_tweetContainerView.frame.size];
	
	CGRect titleFrame = _titleLabel.frame;
	titleFrame.size.width = width - size.width - 5.f;
	_titleLabel.frame = titleFrame;
	
	CGSize titleSize = [@"X" sizeWithAttributes:@{ NSFontAttributeName: [HBAPFontManager sharedInstance].subheadingFont }];
	
	_timestampLabel.frame = CGRectMake(_tweetContainerView.frame.size.width - 15.f - size.width, titleFrame.origin.y + 2.f + (titleSize.height / 2) - (size.height / 2), size.width, size.height);
}

- (NSString *)_prettyDateStringForDate:(NSDate *)date {
	double timeSinceNow = -date.timeIntervalSinceNow;
	
	if (timeSinceNow > 31536000) { // year = 31536000s
		return [NSString stringWithFormat:@"%iy", (int)round(timeSinceNow / 60 / 60 / 24 / 365)];
	} else if (timeSinceNow > 2592000) { // month = 2592000s
		return [NSString stringWithFormat:@"%imo", (int)round(timeSinceNow / 60 / 60 / 24 / 30)];
	} else if (timeSinceNow > 86400) { // day = 86400s
		return [NSString stringWithFormat:@"%id", (int)round(timeSinceNow / 60 / 60 / 24)];
	} else if (timeSinceNow > 3600) { // hour = 3600s
		return [NSString stringWithFormat:@"%ih", (int)round(timeSinceNow / 60 / 60)];
	} else if (timeSinceNow > 60) { // min = 60s
		return [NSString stringWithFormat:@"%im", (int)round(timeSinceNow / 60)];
	} else if (timeSinceNow > 0) {
		return [NSString stringWithFormat:@"%is", (int)timeSinceNow];
	} else {
		return L18N(@"Now");
	}
}

#pragma mark - Action sheet

- (void)longPressGestureRecognizerFired:(UILongPressGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
		return;
	}
	
	HBAPTweetActivityViewController *activityViewController = [[[HBAPTweetActivityViewController alloc] initWithTweet:_tweet] autorelease];
	[activityViewController presentInViewController:_navigationController frame:self.frame];
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
