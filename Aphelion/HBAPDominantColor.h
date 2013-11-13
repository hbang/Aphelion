//
//  HBAPDominantColor.h
//  Aphelion
//
//  Created by Adam D on 13/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBAPDominantColor : NSObject

+ (UIColor *)dominantColorForImage:(UIImage *)image;
+ (BOOL)isDarkColor:(UIColor *)color;

@end
