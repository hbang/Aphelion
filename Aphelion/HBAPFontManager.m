//
//  HBAPFontManager.m
//  Aphelion
//
//  Created by Adam D on 16/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPFontManager.h"
#import "HBAPThemeManager.h"

static NSString *const HBAPDefaultsFontKey = @"font";

@interface HBAPFontManager () {
	NSString *_currentFont;
}

@end

@implementation HBAPFontManager

+ (instancetype)sharedInstance {
	static HBAPFontManager *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self.class alloc] init];
	});
	
	return sharedInstance;
}

- (instancetype)init {
	self = [super init];
	
	if (self) {
		_fonts = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fonts" ofType:@"plist"]];
		_fontNames = [[_fonts.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] retain];
		_currentFont = [[[NSUserDefaults standardUserDefaults] objectForKey:HBAPDefaultsFontKey] ?: @"Helvetica Neue" retain];
		[self _applyFont];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applyFont) name:UIContentSizeCategoryDidChangeNotification object:nil];
	}
	
	return self;
}

- (void)_applyFont {
	[_headingFont release];
	[_subheadingFont release];
	[_bodyFont release];
	[_footerFont release];
	
	if ([_currentFont isEqualToString:@"Helvetica Neue"]) {
		_headingFont = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] retain];
		_subheadingFont = [[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] retain];
		_bodyFont = [[UIFont preferredFontForTextStyle:UIFontTextStyleBody] retain];
		_footerFont = [[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] retain];
	} else {
		NSDictionary *font = _fonts[_currentFont];
		UIFont *testFont = [UIFont fontWithName:font[@"regular"] size:14.f];
		
		if (!testFont || ![testFont.fontName isEqualToString:font[@"regular"]]) {
			HBLogWarn(@"font not installed. reverting to helvetica neue");
			_currentFont = @"Helvetica Neue";
			[self _applyFont];
			return;
		}
		
		_headingFont = [[UIFont fontWithName:font[@"bold"] size:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize] retain];
		_subheadingFont = [[UIFont fontWithName:font[@"bold"] size:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline].pointSize] retain];
		_bodyFont = [[UIFont fontWithName:font[@"regular"] size:[UIFont preferredFontForTextStyle:UIFontTextStyleBody].pointSize] retain];
		_footerFont = [[UIFont fontWithName:font[@"regular"] size:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote].pointSize] retain];
	}
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBAPThemeChanged object:nil]];
}

#pragma mark - Properties

- (NSString *)currentFont {
	return _currentFont;
}

- (void)setCurrentFont:(NSString *)currentFont {
	if ([_currentFont isEqualToString:currentFont]) {
		return;
	}
	
	_currentFont = [currentFont copy];
	
	[[NSUserDefaults standardUserDefaults] setObject:currentFont forKey:HBAPDefaultsFontKey];
	[self _applyFont];
}

#pragma mark - Memory management

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

@end
