//
//  HBAPProfileTimelineTableViewCell.m
//  Aphelion
//
//  Created by Adam D on 13/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPProfileDataTableViewCell.h"
#import "HBAPThemeManager.h"

@implementation HBAPProfileDataTableViewCell

#pragma mark - Constants

+ (UIFont *)titleLabelFont {
	return [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
}

+ (UIFont *)valueLabelFont {
	return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

#pragma mark - Implementation

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	
	if (self) {
		self.backgroundColor = [[HBAPThemeManager sharedInstance].backgroundColor colorWithAlphaComponent:0.3f];
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 0, 0, self.contentView.frame.size.height)];
		_titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		_titleLabel.font = [self.class titleLabelFont];
		_titleLabel.textColor = [HBAPThemeManager sharedInstance].tintColor;
		_titleLabel.highlightedTextColor = [UIColor whiteColor];
		_titleLabel.textAlignment = NSTextAlignmentRight;
		[self.contentView addSubview:_titleLabel];
		
		_valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, self.contentView.frame.size.height)];
		_valueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_valueLabel.font = [self.class valueLabelFont];
		_valueLabel.textColor = [HBAPThemeManager sharedInstance].textColor;
		[self.contentView addSubview:_valueLabel];
	}
	
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat width = [_titleLabel.text sizeWithAttributes:@{ NSFontAttributeName: _titleLabel.font }].width;
	
	CGRect titleFrame = _titleLabel.frame;
	titleFrame.size.width = width < 70.f ? 70.f : width;
	_titleLabel.frame = titleFrame;
	
	CGRect valueFrame = _valueLabel.frame;
	valueFrame.origin.x = titleFrame.origin.x + titleFrame.size.width + 10.f;
	valueFrame.size.width = self.contentView.frame.size.width - valueFrame.origin.x - 15.f;
	_valueLabel.frame = valueFrame;
}

- (void)setTintColor:(UIColor *)tintColor {
	[super setTintColor:tintColor];
	
	_titleLabel.textColor = tintColor;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	
	_titleLabel.highlighted = highlighted;
}

@end
