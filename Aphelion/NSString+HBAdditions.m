//
//  NSString+HBAdditions.m
//  Aphelion
//
//  Created by Adam D on 27/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "NSString+HBAdditions.h"

@implementation NSString (HBAdditions)

- (NSString *)stringByDecodingXMLEntities {
	if ([self rangeOfString:@"&" options:NSLiteralSearch].location == NSNotFound) {
		return self;
	}
	
	NSMutableString *result = [NSMutableString stringWithCapacity:self.length * 1.25];
	NSScanner *scanner = [NSScanner scannerWithString:self];
	scanner.charactersToBeSkipped = nil;
	
	NSCharacterSet *boundaryCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r;"];
	
	do {
		NSString *nonEntityString;
		
		if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
			[result appendString:nonEntityString];
		}
		
		if (scanner.isAtEnd) {
			break;
		}
		
		if ([scanner scanString:@"&amp;" intoString:NULL]) {
			[result appendString:@"&"];
		} else if ([scanner scanString:@"&apos;" intoString:NULL]) {
			[result appendString:@"'"];
		} else if ([scanner scanString:@"&quot;" intoString:NULL]) {
			[result appendString:@"\""];
		} else if ([scanner scanString:@"&lt;" intoString:NULL]) {
			[result appendString:@"<"];
		} else if ([scanner scanString:@"&gt;" intoString:NULL]) {
			[result appendString:@">"];
		} else if ([scanner scanString:@"&#" intoString:NULL]) {
			BOOL gotNumber;
			NSUInteger charCode;
			NSString *xForHex = @"";
			
			// Is it hex or decimal?
			if ([scanner scanString:@"x" intoString:&xForHex]) {
				gotNumber = [scanner scanHexInt:&charCode];
			} else {
				gotNumber = [scanner scanInt:(int *)&charCode];
			}
			
			if (gotNumber) {
				[result appendFormat:@"%C", (unichar)charCode];
				
				[scanner scanString:@";" intoString:NULL];
			} else {
				NSString *unknownEntity = @"";
				
				[scanner scanUpToCharactersFromSet:boundaryCharacterSet intoString:&unknownEntity];
				[result appendFormat:@"&#%@%@", xForHex, unknownEntity];
			}
		} else {
			NSString *amp;
			
			[scanner scanString:@"&" intoString:&amp];
			[result appendString:amp];
		}
	} while (!scanner.isAtEnd);
	
	return result;
}

- (NSString *)URLEncodedString {
	return [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(":/=,!$& '()*+;[]@#?"), kCFStringEncodingUTF8) autorelease];
}

@end
