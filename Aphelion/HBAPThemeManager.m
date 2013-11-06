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
	_isDark = ((NSNumber *)_themes[_currentTheme][@"isDark"]).boolValue;
	_backgroundColor = [[self _colorFromArray:_themes[_currentTheme][@"backgroundColor"]] retain];
	_dimTextColor = [[self _colorFromArray:_themes[_currentTheme][@"dimTextColor"]] retain];
	_hashtagColor = [[self _colorFromArray:_themes[_currentTheme][@"hashtagColor"]] retain];
	_highlightColor = [[self _colorFromArray:_themes[_currentTheme][@"highlightColor"]] retain];
	_textColor = [[self _colorFromArray:_themes[_currentTheme][@"textColor"]] retain];
	_tintColor = [[self _colorFromArray:_themes[_currentTheme][@"tintColor"]] retain];
	
	_sidebarBackgroundColor = [[_themes[_currentTheme][@"sidebarBackgroundColor"] ? [self _colorFromArray:_themes[_currentTheme][@"sidebarBackgroundColor"]] : _backgroundColor colorWithAlphaComponent:0.4f] retain];
	_sidebarTextColor = [_themes[_currentTheme][@"sidebarTextColor"] ? [self _colorFromArray:_themes[_currentTheme][@"sidebarTextColor"]] : _dimTextColor retain];
	
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
		
	[[UITableViewCell appearance] setTextColor:_textColor];
	[[UITabBar appearance] setTintColor:_textColor];
	[[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: _textColor }];
	
}

- (void)_tintAllTheThings:(UIView *)view {
	for (UIView *subview in view.subviews) {
		subview.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
		subview.tintColor = self.tintColor;
		
		NSString *class = NSStringFromClass(subview.class);
		
		if (![class isEqualToString:@"UITabBar"]) {
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
