//
//  HBAPFontManager.m
//  Aphelion
//
//  Created by Adam D on 16/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPFontManager.h"
#import "HBAPThemeManager.h"
#import <CoreText/CoreText.h>

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
		
		if ([self fontNeedsDownloading:_currentFont]) {
			[self downloadFont:_currentFont withProgressCallback:nil];
		}
		
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
		
		if ([self fontNeedsDownloading:_currentFont]) {
			_currentFont = @"Helvetica Neue";
			[self _applyFont];
			return;
		}
		
		_headingFont = [[UIFont fontWithName:font[@"bold"] size:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize] retain];
		_subheadingFont = [[UIFont fontWithName:font[@"regular"] size:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline].pointSize] retain];
		_bodyFont = [[UIFont fontWithName:font[@"regular"] size:[UIFont preferredFontForTextStyle:UIFontTextStyleBody].pointSize] retain];
		_footerFont = [[UIFont fontWithName:font[@"regular"] size:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote].pointSize] retain];
	}
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBAPThemeChanged object:nil]];
}

#pragma mark - Font downloading

- (BOOL)fontNeedsDownloading:(NSString *)fontName {
	NSDictionary *fontDict = _fonts[fontName];
	
	if (((NSNumber *)fontDict[@"preinstalled"]).boolValue) {
		return NO;
	}
	
	return [self _fontNeedsDownloading:fontDict[@"regular"]] || [self _fontNeedsDownloading:fontDict[@"bold"]];
}

- (BOOL)_fontNeedsDownloading:(NSString *)fontName {
	UIFont *font = [UIFont fontWithName:fontName size:14.f];
	
	if (font && [font.fontName isEqualToString:fontName]) {
		return NO;
	}
	
	return YES;
}

- (void)downloadFont:(NSString *)fontName withProgressCallback:(void(^)(CTFontDescriptorMatchingState state, double progress))callback {
	[self _downloadFont:[UIFontDescriptor fontDescriptorWithName:_fonts[fontName][@"regular"] size:12.f] withProgressCallback:^(CTFontDescriptorMatchingState state, double progress) {
		if (callback) {
			callback(state, progress);
		}
		
		if (state == kCTFontDescriptorMatchingDidFinish) {
			[self _downloadFont:[UIFontDescriptor fontDescriptorWithName:_fonts[fontName][@"bold"] size:12.f] withProgressCallback:^(CTFontDescriptorMatchingState state, double progress) {
				if (state == kCTFontDescriptorMatchingDidFinish) {
					self.currentFont = fontName;
				}
			}];
		}
	}];
}

- (void)_downloadFont:(UIFontDescriptor *)fontDescriptor withProgressCallback:(void(^)(CTFontDescriptorMatchingState state, double progress))callback {
	CTFontDescriptorMatchFontDescriptorsWithProgressHandler((CFArrayRef)@[ fontDescriptor ], NULL, ^bool(CTFontDescriptorMatchingState state, CFDictionaryRef info) {
		double progress = ((NSNumber *)[(NSDictionary *)info objectForKey:(NSString *)kCTFontDescriptorMatchingPercentage]).doubleValue;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			callback(state, progress / 100.0);
		});
		return true;
	});
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
