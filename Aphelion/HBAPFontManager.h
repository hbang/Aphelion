//
//  HBAPFontManager.h
//  Aphelion
//
//  Created by Adam D on 16/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface HBAPFontManager : NSObject

+ (instancetype)sharedInstance;

- (void)downloadFont:(NSString *)fontName withProgressCallback:(void(^)(CTFontDescriptorMatchingState state, double progress))callback;
- (BOOL)fontNeedsDownloading:(NSString *)fontName;

@property (nonatomic, retain, readonly) NSDictionary *fonts;
@property (nonatomic, retain, readonly) NSArray *fontNames;
@property (nonatomic, retain) NSString *currentFont;

@property (nonatomic, retain) UIFont *headingFont;
@property (nonatomic, retain) UIFont *subheadingFont;
@property (nonatomic, retain) UIFont *bodyFont;
@property (nonatomic, retain) UIFont *footerFont;

@end
