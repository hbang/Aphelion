//
//  HBAPThemeManager.m
//  Aphelion
//
//  Created by Adam D on 3/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPThemeManager.h"
#import "HBAPAppDelegate.h"

static NSString *const HBAPDefaultsThemeKey = @"theme";

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
		[names removeObject:@"Standard"];
		[names insertObject:@"Standard" atIndex:0];
		_themeNames = [names copy];
		
		_currentTheme = [[[NSUserDefaults standardUserDefaults] objectForKey:HBAPDefaultsThemeKey] ?: @"Standard" retain];
		[self _applyThemeAnimated:NO];
	}
	
	return self;
}

- (void)_applyThemeAnimated:(BOOL)animated {
	static UIColor *DefaultTintColor;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		DefaultTintColor = [[UIColor alloc] initWithRed:9.f / 255.f green:122.f / 255.f blue:1 alpha:1];
	});
	
	NSDictionary *theme = _themes[_currentTheme];
	
	_isDark = ((NSNumber *)theme[@"isDark"]).boolValue;
	_backgroundColor = [[self _colorFromArray:theme[@"backgroundColor"]] retain];
	_dimTextColor = [[self _colorFromArray:theme[@"dimTextColor"]] retain];
	_hashtagColor = [[self _colorFromArray:theme[@"hashtagColor"]] retain];
	_highlightColor = [[self _colorFromArray:theme[@"highlightColor"]] retain];
	_textColor = [[self _colorFromArray:theme[@"textColor"]] retain];
	_tintColor = [[self _colorFromArray:theme[@"tintColor"]] retain];
	
	_sidebarBackgroundColor = [[theme[@"sidebarBackgroundColor"] ? [self _colorFromArray:theme[@"sidebarBackgroundColor"]] : _backgroundColor colorWithAlphaComponent:0.4f] retain];
	_sidebarTextColor = [theme[@"sidebarTextColor"] ? [self _colorFromArray:theme[@"sidebarTextColor"]] : _dimTextColor retain];
	_linkColor = _tintColor ?: DefaultTintColor;
	
	[self _tintAllTheThings:[UIApplication sharedApplication].delegate.window];
	[UIApplication sharedApplication].delegate.window.tintColor = _tintColor;
	
	[[UINavigationBar appearance] setTintColor:_tintColor];
	[[UIToolbar appearance] setTintColor:_tintColor];
	[[UITabBar appearance] setSelectedImageTintColor:_tintColor];
	[[UISwitch appearance] setOnTintColor:_tintColor];
	
	[[UINavigationBar appearance] setBarTintColor:_backgroundColor];
	[[UIToolbar appearance] setBarTintColor:_backgroundColor];
	[[UITabBar appearance] setBarTintColor:_backgroundColor];
	[[UITableView appearance] setBackgroundColor:_backgroundColor];
	[[UITableViewCell appearance] setBackgroundColor:_backgroundColor];
	
	UIView *selectedBackgroundView = [[[UIView alloc] init] autorelease];
	selectedBackgroundView.backgroundColor = _highlightColor;
	[[UITableViewCell appearance] setSelectedBackgroundView:selectedBackgroundView];
	
	[[UITableView appearance] setSeparatorColor:_dimTextColor];
	[[UISwitch appearance] setTintColor:_dimTextColor];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	[[UITableViewCell appearance] setTextColor:_textColor];
#pragma clang diagnostic pop
	[[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: _textColor }];
	[[UITabBar appearance] setTintColor:_tintColor ? _textColor : nil];
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBAPThemeChanged object:nil]];
}

- (void)_tintAllTheThings:(UIView *)view {
	for (UIView *subview in view.subviews) {
		NSString *class = NSStringFromClass(subview.class);
		
		if (![class isEqualToString:@"UITabBar"]) {
			subview.tintColor = _tintColor;
			[self _tintAllTheThings:subview];
		}
	}
}

- (UIColor *)_colorFromArray:(NSArray *)array {
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
	
	[[NSUserDefaults standardUserDefaults] setObject:currentTheme forKey:HBAPDefaultsThemeKey];
	[self _applyThemeAnimated:YES];
}

@end
