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
		DefaultTintColor = [[UIColor alloc] initWithRed:0.03529411765f green:0.4784313725f blue:1 alpha:1];
	});
	
	NSDictionary *theme = _themes[_currentTheme];
	
	_isDark = ((NSNumber *)theme[@"isDark"]).boolValue;
	_tintColor = [[self colorFromArray:theme[@"tintColor"]] retain];
	
	CGFloat hue, saturation, brightness;
	[_tintColor getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
	
	_backgroundColor = theme[@"backgroundColor"] ? [[self colorFromArray:theme[@"backgroundColor"]] retain] : [[UIColor alloc] initWithHue:hue saturation:saturation - 0.3f brightness:brightness + 0.38f alpha:1];
	_groupedBackgroundColor = theme[@"groupedBackgroundColor"] ? [[self colorFromArray:theme[@"groupedBackgroundColor"]] retain] : [[UIColor alloc] initWithHue:hue saturation:saturation - 0.35f brightness:brightness + 0.3f alpha:1];
	
	_dimTextColor = [[self colorFromArray:theme[@"dimTextColor"]] retain];
	_hashtagColor = [[self colorFromArray:theme[@"hashtagColor"]] retain];
	_textColor = [[self colorFromArray:theme[@"textColor"]] retain];

	_highlightColor = theme[@"highlightColor"] ? [[self colorFromArray:theme[@"highlightColor"]] retain] : [[_dimTextColor colorWithAlphaComponent:0.3f] retain];
	_sidebarBackgroundColor = [[theme[@"sidebarBackgroundColor"] ? [self colorFromArray:theme[@"sidebarBackgroundColor"]] : _backgroundColor colorWithAlphaComponent:0.4f] retain];
	_sidebarTextColor = theme[@"sidebarTextColor"] ? [[self colorFromArray:theme[@"sidebarTextColor"]] retain] : _dimTextColor;
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

@end
