//
//  HBAPTweetComposeTableViewCell.m
//  Aphelion
//
//  Created by Adam D on 16/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTweetComposeTableViewCell.h"
#import "HBAPAccountController.h"
#import "HBAPAccount.h"
#import "HBAPUser.h"
#import "HBAPAvatarButton.h"
#import "HBAPTweetTextStorage.h"
#import "HBAPTwitterAPISessionManager.h"
#import "HBAPTwitterConfiguration.h"
#import "HBAPThemeManager.h"
#import "HBAPFontManager.h"
#import <twitter-text-objc/TwitterText.h>

@interface HBAPTweetComposeTableViewCell () {
	NSLayoutManager *_layoutManager;
	UIBarButtonItem *_remainingCharactersBarButtonItem;
	
	NSUInteger _cachedHttpLength;
	NSUInteger _cachedHttpsLength;
}

@end

@implementation HBAPTweetComposeTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithReuseIdentifier:reuseIdentifier];
	
	if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.backgroundColor = [HBAPThemeManager sharedInstance].highlightColor;
		
		self.timestampLabel.hidden = YES;
		self.retweetedLabel.hidden = YES;
		self.contentTextView.editable = YES;
		
		_remainingCharactersBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"140" style:UIBarButtonItemStylePlain target:Nil action:nil];
		_remainingCharactersBarButtonItem.tintColor = [HBAPThemeManager sharedInstance].textColor;
		
		UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 44.f)] autorelease];
		toolbar.items = @[
			[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:Nil action:nil] autorelease],
			[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:Nil action:nil] autorelease],
			[[[UIBarButtonItem alloc] initWithTitle:L18N(@"0 Drafts") style:UIBarButtonItemStylePlain target:Nil action:nil] autorelease],
			[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:Nil action:nil] autorelease],
			_remainingCharactersBarButtonItem
		];
		self.contentTextView.inputAccessoryView = toolbar;
		
		_cachedHttpLength = [HBAPTwitterAPISessionManager sharedInstance].configuration.tcoHttpLength;
		_cachedHttpsLength = [HBAPTwitterAPISessionManager sharedInstance].configuration.tcoHttpsLength;
		
		self.avatarImageView.user = [HBAPAccountController sharedInstance].currentAccount.user;
	}
	
	return self;
}

- (UITextView *)_newContentTextView {
	HBAPTweetTextStorage *textStorage = [[[HBAPTweetTextStorage alloc] initWithAttributes:@{
		NSFontAttributeName: [HBAPFontManager sharedInstance].bodyFont,
		NSForegroundColorAttributeName: [HBAPThemeManager sharedInstance].textColor
	}] autorelease];
	_layoutManager = [[NSLayoutManager alloc] init];
	NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithSize:CGSizeMake(0, CGFLOAT_MAX)] autorelease];
	textContainer.widthTracksTextView = YES;
	[_layoutManager addTextContainer:textContainer];
	[textStorage addLayoutManager:_layoutManager];
	
	return [[UITextView alloc] initWithFrame:CGRectZero textContainer:textContainer];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	static CGFloat BottomSpacing = 15.f;
	
	CGRect textViewFrame = self.contentTextView.frame;
	textViewFrame.size.height = self.contentView.frame.size.height - textViewFrame.origin.y - BottomSpacing;
	self.contentTextView.frame = textViewFrame;
}

#pragma mark - UITextView

- (void)textViewDidChange:(UITextView *)textView {
	NSInteger tweetLength = [TwitterText remainingCharacterCount:textView.text httpURLLength:_cachedHttpLength httpsURLLength:_cachedHttpsLength];
	
	_remainingCharactersBarButtonItem.title = @(tweetLength).stringValue;
	
	if (tweetLength > 15) {
		_remainingCharactersBarButtonItem.tintColor = [HBAPThemeManager sharedInstance].textColor;
	} else if (tweetLength > 10 && tweetLength <= 15) {
		_remainingCharactersBarButtonItem.tintColor = [UIColor colorWithRed:0.45f green:0 blue:0 alpha:1];
	} else if (tweetLength > 5 && tweetLength <= 10) {
		_remainingCharactersBarButtonItem.tintColor = [UIColor colorWithRed:0.6f green:0 blue:0 alpha:1];
	} else if (tweetLength > 2 && tweetLength <= 5) {
		_remainingCharactersBarButtonItem.tintColor = [UIColor colorWithRed:0.7f green:0 blue:0 alpha:1];
	} else if (tweetLength > -1 && tweetLength <= 2) {
		_remainingCharactersBarButtonItem.tintColor = [UIColor colorWithRed:0.75f green:0 blue:0 alpha:1];
	} else {
		_remainingCharactersBarButtonItem.tintColor = [UIColor redColor];
	}
}

#pragma mark - Memory management

- (void)dealloc {
	[_layoutManager release];
	[_remainingCharactersBarButtonItem release];
	
	[super dealloc];
}

@end
