//
//  HBAPTweetTextView.m
//  Aphelion
//
//  Created by Adam D on 28/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTweetTextView.h"
#import "HBAPTweetAttributedStringFactory.h"
#import "HBAPLinkManager.h"
#import <CoreText/CoreText.h>

@interface HBAPTweetTextView () {
	BOOL _framesNeedUpdating;
	NSMutableDictionary *_linkFrames;
	CGRect _currentLinkFrame;
	
	UIView *_highlightView;
}

@end

@implementation HBAPTweetTextView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		UILongPressGestureRecognizer *longPressGestureRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerFired:)] autorelease];
		longPressGestureRecognizer.delegate = self;
		[self addGestureRecognizer:longPressGestureRecognizer];
		
		UITapGestureRecognizer *tapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerFired:)] autorelease];
		tapGestureRecognizer.delegate = self;
		[self addGestureRecognizer:tapGestureRecognizer];
		
		_highlightView = [[UIView alloc] init];
		_highlightView.alpha = 0.4f;
		_highlightView.backgroundColor = self.tintColor;
		_highlightView.layer.cornerRadius = 6.f;
		[self addSubview:_highlightView];
	}
	
	return self;
}

#pragma mark - Highlight view

- (void)setTintColor:(UIColor *)tintColor {
	[super setTintColor:tintColor];
	_highlightView.backgroundColor = tintColor;
}

#pragma mark - Attributed string

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

- (void)_updateLinkFrames {
	// massive <44444 to rickye for this code
	
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

#pragma mark - URLs

- (NSURL *)URLAtPoint:(CGPoint)point {
	for (NSValue *value in _linkFrames.allKeys) {
		if (CGRectContainsPoint(value.CGRectValue, point)) {
			return _linkFrames[value];
		}
	}
	
	return nil;
}

- (void)tapGestureRecognizerFired:(UITapGestureRecognizer *)gestureRecognizer {
	switch (gestureRecognizer.state) {
		case UIGestureRecognizerStateBegan:
			_highlightView.frame = _currentLinkFrame;
			_highlightView.hidden = NO;
			break;
		
		case UIGestureRecognizerStateEnded:
		{
			_highlightView.hidden = YES;
			
			NSURL *url = [self URLAtPoint:_currentLinkFrame.origin];
			
			if (!url) {
				return;
			}
			
			[[HBAPLinkManager sharedInstance] openURL:url navigationController:_navigationController];
			break;
		}
		
		default:
			break;
	}
}

- (void)longPressGestureRecognizerFired:(UILongPressGestureRecognizer *)gestureRecognizer {
	switch (gestureRecognizer.state) {
		case UIGestureRecognizerStateFailed:
		case UIGestureRecognizerStateCancelled:
			NSLog(@"long fail");
			_highlightView.hidden = YES;
			break;
		
		case UIGestureRecognizerStateEnded:
			_highlightView.hidden = YES;
			[[HBAPLinkManager sharedInstance] showActionSheetForURL:[self URLAtPoint:_currentLinkFrame.origin] navigationController:_navigationController];
			break;
		
		default:
			break;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (_currentLinkFrame.size.width == 0 && _currentLinkFrame.size.height == 0) {
		[super touchesEnded:touches withEvent:event];;
	}
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	CGPoint touchPoint = [gestureRecognizer locationOfTouch:0 inView:self];
	
	for (NSValue *value in _linkFrames.allKeys) {
		if (CGRectContainsPoint(value.CGRectValue, touchPoint)) {
			_currentLinkFrame = value.CGRectValue;
			return YES;
		}
	}
	
	_currentLinkFrame = CGRectZero;
	return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
