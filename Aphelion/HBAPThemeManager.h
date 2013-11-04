//
//  HBAPThemeManager.h
//  Aphelion
//
//  Created by Adam D on 3/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBAPThemeManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, retain, readonly) NSDictionary *themes;
@property (nonatomic, retain, readonly) NSArray *themeNames;
@property (nonatomic, retain) NSString *currentTheme;

@property (readonly) BOOL isDark;
@property (nonatomic, retain, readonly) UIColor *backgroundColor;
@property (nonatomic, retain, readonly) UIColor *highlightColor;
@property (nonatomic, retain, readonly) UIColor *dimTextColor;
@property (nonatomic, retain, readonly) UIColor *hashtagColor;
@property (nonatomic, retain, readonly) UIColor *sidebarBackgroundColor;
@property (nonatomic, retain, readonly) UIColor *sidebarTextColor;
@property (nonatomic, retain, readonly) UIColor *textColor;
@property (nonatomic, retain, readonly) UIColor *tintColor;

@end
