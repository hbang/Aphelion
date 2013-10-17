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
#import "HBAPAvatarView.h"
#import "HBAPTweetTextStorage.h"

@interface HBAPTweetComposeTableViewCell () {
	NSLayoutManager *_layoutManager;
}

@end

@implementation HBAPTweetComposeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1];
		
		HBAPUser *user = [HBAPAccountController sharedInstance].accountForCurrentUser.user;
		self.avatarImageView.user = user;
		self.realNameLabel.text = user.realName;
		self.screenNameLabel.text = [@"@" stringByAppendingString:@"thekirbylover"];//user.screenName];
		self.timestampLabel.hidden = YES;
		self.retweetedLabel.hidden = YES;
		self.contentTextView.editable = YES;
		
		[self.contentTextView.textStorage beginEditing];
		self.contentTextView.attributedText = [[[NSAttributedString alloc] initWithString:@"" attributes:@{ NSFontAttributeName: [self.class contentTextViewFont] }] autorelease];
		[self.contentTextView.textStorage endEditing];
	}
	
	return self;
}

- (UITextView *)_newContentTextView {
	HBAPTweetTextStorage *textStorage = [[[HBAPTweetTextStorage alloc] initWithFont:[self.class contentTextViewFont]] autorelease];
	_layoutManager = [[NSLayoutManager alloc] init];
	NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithSize:CGSizeMake(0, CGFLOAT_MAX)] autorelease];
	textContainer.widthTracksTextView = YES;
	[_layoutManager addTextContainer:textContainer];
	[textStorage addLayoutManager:_layoutManager];
	
	UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:textContainer];
	UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 44.f)] autorelease];
	toolbar.items = @[
					  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:Nil action:nil] autorelease],
					  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:Nil action:nil] autorelease],
					  [[[UIBarButtonItem alloc] initWithTitle:@"0 Drafts" style:UIBarButtonItemStylePlain target:Nil action:nil] autorelease],
					  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:Nil action:nil] autorelease],
					  [[[UIBarButtonItem alloc] initWithTitle:@"140" style:UIBarButtonItemStylePlain target:Nil action:nil] autorelease],
	];
	((UIBarButtonItem *)toolbar.items[4]).tintColor = [UIColor blackColor];
	textView.inputAccessoryView = toolbar;
	
	return textView;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	static CGFloat BottomSpacing = 15.f;
	
	CGRect textViewFrame = self.contentTextView.frame;
	textViewFrame.size.height = self.contentView.frame.size.height - textViewFrame.origin.y - BottomSpacing;
	self.contentTextView.frame = textViewFrame;
}

@end
