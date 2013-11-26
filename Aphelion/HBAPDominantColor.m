//
//  HBAPDominantColor.m
//  Aphelion
//
//  Created by Adam D on 13/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPDominantColor.h"

struct pixel {
	unsigned char r, g, b, a;
};

@implementation HBAPDominantColor

+ (UIColor *)dominantColorForImage:(UIImage *)image {
	NSUInteger red = 0, green = 0, blue = 0;
	CGSize newSize = CGSizeMake(image.size.width / 4, image.size.height / 4);
	struct pixel *pixels = (struct pixel *)calloc(1, newSize.width * newSize.height * sizeof(struct pixel));
	
	if (pixels) {
		CGContextRef context = CGBitmapContextCreate((void *)pixels, newSize.width, newSize.height, 8, newSize.width * 4, CGImageGetColorSpace(image.CGImage), (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
		
		if (context) {
			CGContextDrawImage(context, CGRectMake(0, 0, newSize.width, newSize.height), image.CGImage);
			
			NSUInteger numberOfPixels = newSize.width * newSize.height;
			
			if (numberOfPixels == 0) {
				CGContextRelease(context);
				return nil;
			}
			
			for (unsigned i = 0; i < numberOfPixels; i++) {
				red += pixels[i].r;
				green += pixels[i].g;
				blue += pixels[i].b;
			}
			
			red /= numberOfPixels;
			green /= numberOfPixels;
			blue /= numberOfPixels;
			
			CGContextRelease(context);
		}
		
		free(pixels);
	}
	
	return [UIColor colorWithRed:red / 255.f green:green / 255.f blue:blue / 255.f alpha:1];
}

+ (BOOL)isDarkColor:(UIColor *)color {
	CGFloat brightness;
	[color getHue:Nil saturation:nil brightness:&brightness alpha:nil];
	
	return brightness < 0.5f;
}

@end
