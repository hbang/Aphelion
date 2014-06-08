//
//  UIColor+HBAdditions.m
//  Aphelion
//
//  Created by Adam D on 9/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "UIColor+HBAdditions.h"

@implementation UIColor (HBAdditions)

- (instancetype)initWithHexString:(NSString *)hexString {
	unsigned int hexInteger = 0;
	NSScanner *scanner = [NSScanner scannerWithString:hexString];
	scanner.charactersToBeSkipped = [NSCharacterSet characterSetWithCharactersInString:@"#"];
	[scanner scanHexInt:&hexInteger];
	
	return [[UIColor alloc] initWithRed:((hexInteger & 0xFF0000) >> 16) / 255.f green:((hexInteger & 0xFF00) >> 8) / 255.f blue:(hexInteger & 0xFF) / 255.f alpha:1];
}

@end
