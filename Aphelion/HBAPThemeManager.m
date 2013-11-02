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
	_backgroundColor = [self _colorFromArray:_themes[_currentTheme][@"backgroundColor"]];
	_dimTextColor = [self _colorFromArray:_themes[_currentTheme][@"dimTextColor"]];
	_hashtagColor = [self _colorFromArray:_themes[_currentTheme][@"hashtagColor"]];
	_textColor = [self _colorFromArray:_themes[_currentTheme][@"textColor"]];
	_tintColor = [self _colorFromArray:_themes[_currentTheme][@"tintColor"]];
	
	[self _tintAllTheThings:[UIApplication sharedApplication].delegate.window];
	
	[[UINavigationBar appearance] setTintColor:self.tintColor];
	[[UIToolbar appearance] setTintColor:self.tintColor];
	[[UITabBar appearance] setSelectedImageTintColor:self.tintColor];
	
	[[UINavigationBar appearance] setBarTintColor:self.backgroundColor];
	[[UIToolbar appearance] setBarTintColor:self.backgroundColor];
	[[UITabBar appearance] setBarTintColor:self.backgroundColor];
	
	[[UITableView appearance] setBackgroundColor:self.backgroundColor];
	[[UITableViewCell appearance] setBackgroundColor:self.backgroundColor];
	
	[[UITableViewCell appearance] setTextColor:self.textColor];
	[[UITabBar appearance] setTintColor:self.textColor];
	[[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: self.textColor }];
	
	[[UITableView appearance] setSeparatorColor:self.dimTextColor];
}

- (void)_tintAllTheThings:(UIView *)view {
	for (UIView *subview in view.subviews) {
		subview.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
		subview.tintColor = self.tintColor;
		
		if (![NSStringFromClass(subview.class) isEqualToString:@"UITabBar"]) {
			[self _tintAllTheThings:subview];
		}
	}
}

- (UIColor *)_colorFromArray:(NSArray *)array {
	return [UIColor colorWithRed:((NSNumber *)array[0]).floatValue / 255.f green:((NSNumber *)array[1]).floatValue / 255.f blue:((NSNumber *)array[2]).floatValue / 255.f alpha:1];
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
