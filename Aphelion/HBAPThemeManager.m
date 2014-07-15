//
//  HBAPThemeManager.m
//  Aphelion
//
//  Created by Adam D on 3/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPThemeManager.h"
#import "HBAPAppDelegate.h"

static NSString *const kHBAPDefaultsThemeKey = @"theme";
static NSString *const kHBAPDefaultTheme = @"White";

@interface HBAPThemeManager () {
	NSString *_currentTheme;
}

@end

@implementation HBAPThemeManager

+ (instancetype)sharedInstance {
	static HBAPThemeManager *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	
	return sharedInstance;
}

- (instancetype)init {
	self = [super init];
	
	if (self) {
		_themes = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"themes" ofType:@"plist"]];
		
		NSMutableArray *names = [[[_themes.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] mutableCopy] autorelease];
		[names removeObject:kHBAPDefaultTheme];
		[names insertObject:kHBAPDefaultTheme atIndex:0];
		_themeNames = [names copy];
		
		NSString *currentTheme = [[NSUserDefaults standardUserDefaults] objectForKey:kHBAPDefaultsThemeKey] ?: kHBAPDefaultTheme;
		
		if (!_themes[currentTheme]) {
			currentTheme = kHBAPDefaultTheme;
		}
		
		_currentTheme = [currentTheme copy];
		
		[self _applyThemeAnimated:NO];
	}
	
	return self;
}

- (void)_applyThemeAnimated:(BOOL)animated {
	static UIColor *DefaultTintColor;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		DefaultTintColor = [[UIColor alloc] initWithRed:0 green:0.478431f blue:1 alpha:1];
	});
	
	NSDictionary *theme = _themes[_currentTheme];
	
	_isDark = ((NSNumber *)theme[@"isDark"]).boolValue;
	_blurEffectStyle = _isDark ? UIBlurEffectStyleDark : UIBlurEffectStyleLight;
	_tintColor = theme[@"tintColor"] ? [[self colorFromArray:theme[@"tintColor"]] retain] : DefaultTintColor;
	
	CGFloat hue, saturation, brightness;
	[_tintColor ?: [UIColor whiteColor] getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
	
	_backgroundColor = theme[@"backgroundColor"] ? [[self colorFromArray:theme[@"backgroundColor"]] retain] : [[UIColor alloc] initWithHue:hue saturation:saturation - 0.3f brightness:brightness + 0.38f alpha:1];
	_groupedBackgroundColor = theme[@"groupedBackgroundColor"] ? [[self colorFromArray:theme[@"groupedBackgroundColor"]] retain] : [[UIColor alloc] initWithHue:hue saturation:saturation - 0.35f brightness:brightness + 0.3f alpha:1];
	
	_dimTextColor = [[self colorFromArray:theme[@"dimTextColor"]] retain];
	_hashtagColor = [[self colorFromArray:theme[@"hashtagColor"]] retain];
	_textColor = [[self colorFromArray:theme[@"textColor"]] retain];

	_highlightColor = theme[@"highlightColor"] ? [[self colorFromArray:theme[@"highlightColor"]] retain] : [[_dimTextColor colorWithAlphaComponent:0.3f] retain];
	_sideBackgroundColor = [[theme[@"sideBackgroundColor"] ? [self colorFromArray:theme[@"sideBackgroundColor"]] : _backgroundColor colorWithAlphaComponent:0.4f] retain];
	_sideTextColor = theme[@"sideTextColor"] ? [[self colorFromArray:theme[@"sideTextColor"]] retain] : _dimTextColor;
	_linkColor = _tintColor ?: DefaultTintColor;
	
	[UIApplication sharedApplication].delegate.window.tintColor = _tintColor;
	
	[[UIToolbar appearance] setTintColor:_tintColor];
	[[UITabBar appearance] setSelectedImageTintColor:_tintColor];
	[[UISwitch appearance] setOnTintColor:_tintColor];
	
	[[UIToolbar appearance] setBarTintColor:_backgroundColor];
	[[UITabBar appearance] setBarTintColor:_backgroundColor];
	[[UISwitch appearance] setTintColor:_dimTextColor];
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBAPThemeChanged object:nil]];
}

- (UIColor *)colorFromArray:(NSArray *)array {
	return array && array.count == 3 ? [UIColor colorWithRed:((NSNumber *)array[0]).floatValue / 255.f green:((NSNumber *)array[1]).floatValue / 255.f blue:((NSNumber *)array[2]).floatValue / 255.f alpha:1] : nil;
}

#pragma mark - Properties

- (NSString *)currentTheme {
	return _currentTheme;
}

- (void)setCurrentTheme:(NSString *)currentTheme {
	if ([_currentTheme isEqualToString:currentTheme]) {
		return;
	}
	
	_currentTheme = [currentTheme copy];
	
	[[NSUserDefaults standardUserDefaults] setObject:currentTheme forKey:kHBAPDefaultsThemeKey];
	[self _applyThemeAnimated:YES];
}

#pragma mark - Memory management

/*
- (void)dealloc {
	[_themes release];
	[_themeNames release];
	[_currentTheme release];
	[_backgroundColor release];
	[_dimTextColor release];
	[_groupedBackgroundColor release];
	[_hashtagColor release];
	[_highlightColor release];
	[_linkColor release];
	[_sidebarBackgroundColor release];
	[_sidebarTextColor release];
	[_textColor release];
	[_tintColor release];
	
	[super dealloc];
}
*/

@end
