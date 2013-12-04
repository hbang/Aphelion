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
	HBAPAvatarView *_avatarView;
	NSLayoutManager *_layoutManager;
	UIBarButtonItem *_remainingCharactersBarButtonItem;
	
	NSUInteger _cachedHttpLength;
	NSUInteger _cachedHttpsLength;
}

@end

@implementation HBAPTweetComposeTableViewCell

#pragma mark - Constants

+ (UIColor *)remaining15Color {
	return [UIColor colorWithRed:0.45f green:0 blue:0 alpha:1];
}

+ (UIColor *)remaining10Color {
	return [UIColor colorWithRed:0.6f green:0 blue:0 alpha:1];
}

+ (UIColor *)remaining5Color {
	return [UIColor colorWithRed:0.7f green:0 blue:0 alpha:1];
}

+ (UIColor *)remaining2Color {
	return [UIColor colorWithRed:0.75f green:0 blue:0 alpha:1];
}

+ (UIColor *)remaining0Color {
	return [UIColor redColor];
}

+ (CGFloat)cellHeight {
	return 130.f;
}

#pragma mark - Implemnetation

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithReuseIdentifier:reuseIdentifier];
	
	if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		_cachedHttpLength = [HBAPTwitterAPISessionManager sharedInstance].configuration.tcoHttpLength;
		_cachedHttpsLength = [HBAPTwitterAPISessionManager sharedInstance].configuration.tcoHttpsLength;
		
		_avatarView = [[HBAPAvatarView alloc] initWithUser:[HBAPAccountController sharedInstance].currentAccount.user size:HBAPAvatarSizeNormal];
		_avatarView.frame = CGRectMake(15.f, 15.f, _avatarView.frame.size.width, _avatarView.frame.size.height);
		[self.contentView addSubview:_avatarView];
		
		HBAPTweetTextStorage *textStorage = [[[HBAPTweetTextStorage alloc] initWithAttributes:@{
			NSFontAttributeName: [HBAPFontManager sharedInstance].bodyFont,
			NSForegroundColorAttributeName: [HBAPThemeManager sharedInstance].textColor
		}] autorelease];
		_layoutManager = [[NSLayoutManager alloc] init];
		NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithSize:CGSizeMake(0, CGFLOAT_MAX)] autorelease];
		textContainer.widthTracksTextView = YES;
		[_layoutManager addTextContainer:textContainer];
		[textStorage addLayoutManager:_layoutManager];
		
		_contentTextView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:textContainer];
		_contentTextView.editable = YES;
		_contentTextView.backgroundColor = [UIColor clearColor];
		_contentTextView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
		_contentTextView.textContainerInset = UIEdgeInsetsZero;
		_contentTextView.textContainer.lineFragmentPadding = 0;
		_contentTextView.linkTextAttributes = @{};
		_contentTextView.delegate = self;
		[self.contentView addSubview:_contentTextView];
		
		_remainingCharactersBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"140" style:UIBarButtonItemStylePlain target:Nil action:nil];
		
		UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 44.f)] autorelease];
		toolbar.items = @[
			[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:Nil action:nil] autorelease],
			[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:Nil action:nil] autorelease],
			[[[UIBarButtonItem alloc] initWithTitle:L18N(@"0 Drafts") style:UIBarButtonItemStylePlain target:Nil action:nil] autorelease],
			[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:Nil action:nil] autorelease],
			_remainingCharactersBarButtonItem
		];
		_contentTextView.inputAccessoryView = toolbar;
	}
	
	return self;
}

- (BOOL)useThemeBackground {
	return NO;
}

- (void)setupTheme {
	[super setupTheme];
	
	self.backgroundColor = [[HBAPThemeManager sharedInstance].dimTextColor colorWithAlphaComponent:0.2f];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	static CGFloat Spacing = 15.f;
	static CGFloat LeftSpacing = 78.f;
	
	_contentTextView.frame = CGRectMake(LeftSpacing, Spacing, self.contentView.frame.size.width - LeftSpacing - Spacing, self.contentView.frame.size.height - Spacing - Spacing);
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
	NSInteger tweetLength = [TwitterText remainingCharacterCount:textView.text httpURLLength:_cachedHttpLength httpsURLLength:_cachedHttpsLength];
	
	_remainingCharactersBarButtonItem.title = @(tweetLength).stringValue;
	
	UIColor *newColor = nil;
	
	if (tweetLength > 15) {
		newColor = nil;
	} else if (tweetLength > 10 && tweetLength <= 15) {
		newColor = [self.class remaining15Color];
	} else if (tweetLength > 5 && tweetLength <= 10) {
		newColor = [self.class remaining10Color];
	} else if (tweetLength > 2 && tweetLength <= 5) {
		newColor = [self.class remaining5Color];
	} else if (tweetLength > -1 && tweetLength <= 2) {
		newColor = [self.class remaining2Color];
	} else {
		newColor = [self.class remaining0Color];
	}
	
	if (newColor != _remainingCharactersBarButtonItem.tintColor) {
		[UIView animateWithDuration:0.2f animations:^{
			_remainingCharactersBarButtonItem.tintColor = newColor;
		}];
	}
}

#pragma mark - Memory management

- (void)dealloc {
	[_layoutManager release];
	[_remainingCharactersBarButtonItem release];
	
	[super dealloc];
}

@end
