//
//  HBAPTweetTextView.m
//  Aphelion
//
//  Created by Adam D on 28/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTweetTextView.h"
#import "HBAPTweetAttributedStringFactory.h"
#import <CoreText/CoreText.h>

@interface HBAPTweetTextView () {
	BOOL _framesNeedUpdating;
	NSMutableDictionary *_linkFrames;
}

@end

@implementation HBAPTweetTextView

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	[_attributedString drawInRect:rect];
	
	if (_framesNeedUpdating) {
		_framesNeedUpdating = NO;
		
		[self _updateLinkFrames];
	}
}

- (void)setAttributedString:(NSAttributedString *)attributedString {
	if (_attributedString == attributedString) {
		return;
	}
	
	_attributedString = attributedString;
	_framesNeedUpdating = YES;
}

/*
 Sample usage:
 self.linkedLabel.content = @"Hi, it's me\nhello\nHi";
 self.linkedLabel.links = @{@"http://google.com" : @"Hi"}; // It's an NSDictionary, the link is the key, the value is the string it belongs to
 // For example here it will link 'Hi' to google.
 // You can change fonts, colors, etc. in the drawRect:
 */

- (void)_updateLinkFrames {
	// massive <44444 to rickye for this code
	
	/*for (NSString *key in self.links.allKeys) {
		[self addLink:key forString:[self.links objectForKey:key] inString:attString];
	}*/
	
	CGPathRef path = CGPathCreateWithRect(self.frame, nil);
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attributedString);
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, _attributedString.length), path, NULL);
	NSArray* lines = (NSArray *)CTFrameGetLines(frame);
	
	CGPoint origins[lines.count];
	CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
	
	[_linkFrames release];
	_linkFrames = [[NSMutableDictionary alloc] init];
	
	for (CFIndex i = 0; i < lines.count; i++) {
		CTLineRef line = CFArrayGetValueAtIndex((CFArrayRef)lines, i);
		
		CFArrayRef glyphRuns = CTLineGetGlyphRuns(line);
		CFIndex glyphCount = CFArrayGetCount(glyphRuns);
		
		for (NSInteger j = 0; j < glyphCount; j++) {
			CTRunRef run = CFArrayGetValueAtIndex(glyphRuns, j);
			
			NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes(run);
			if ([attributes objectForKey:HBAPLinkAttributeName]) {
				CGRect linkFrame;
				
				CGFloat ascent;
				CGFloat descent;
				
				linkFrame.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
				linkFrame.size.height = ascent + descent;
				linkFrame.origin.x = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
				linkFrame.origin.y = self.frame.size.height - origins[i].y - linkFrame.size.height;
				[_linkFrames setObject:attributes[HBAPLinkAttributeName] forKey:[NSValue valueWithCGRect:linkFrame]];
			}
		}
	}
	
	CFRelease(frame);
	CFRelease(path);
	CFRelease(framesetter);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint touchLocation = [event.allTouches.anyObject locationInView:self];
	
	for (NSValue *value in _linkFrames.allKeys) {
		if (CGRectContainsPoint(value.CGRectValue, touchLocation)) {
			[[UIApplication sharedApplication] openURL:_linkFrames[value]];
			//[[HBAPLinkManager sharedInstance] openURL:nil];
			break;
		}
	}
}

@end
