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
	BOOL _touchCancelled;
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
	}
	
	return self;
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
	static CGFloat LinkPadding = 6.f;
	
	// massive <44444 to rickye for this code
	
	CGPathRef path = CGPathCreateWithRect(self.frame, nil);
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attributedString);
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, _attributedString.length), path, NULL);
	CFArrayRef lines = CTFrameGetLines(frame);
	
	CGPoint origins[CFArrayGetCount(lines)];
	CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
	
	[_linkFrames release];
	_linkFrames = [[NSMutableDictionary alloc] init];
	
	for (CFIndex i = 0; i < CFArrayGetCount(lines); i++) {
		CTLineRef line = CFArrayGetValueAtIndex((CFArrayRef)lines, i);
		
		CFArrayRef glyphRuns = CTLineGetGlyphRuns(line);
		CFIndex glyphCount = CFArrayGetCount(glyphRuns);
		
		for (NSInteger j = 0; j < glyphCount; j++) {
			CTRunRef run = CFArrayGetValueAtIndex(glyphRuns, j);
			
			NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes(run);
			if (attributes[HBAPLinkAttributeName]) {
				CGRect linkFrame;
				CGFloat ascent, descent, leading;
				
				linkFrame.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading) + LinkPadding + LinkPadding;
				linkFrame.size.height = ascent + descent + leading + LinkPadding + LinkPadding;
				linkFrame.origin.x = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL) - LinkPadding;
				linkFrame.origin.y = self.frame.size.height - origins[i].y - linkFrame.size.height + LinkPadding;
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
	if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
		return;
	}
	
	//_highlightView.hidden = YES;
	
	NSURL *url = [self URLAtPoint:_currentLinkFrame.origin];
	
	if (!url) {
		return;
	}
	
	[[HBAPLinkManager sharedInstance] openURL:url navigationController:_navigationController];
}

- (void)longPressGestureRecognizerFired:(UILongPressGestureRecognizer *)gestureRecognizer {
	static CGFloat LinkPadding = 6.f;
	
	switch (gestureRecognizer.state) {
		case UIGestureRecognizerStateBegan:
			//_highlightView.frame = CGRectInset(_currentLinkFrame, LinkPadding, LinkPadding);
			//_highlightView.hidden = NO;
			_touchCancelled = NO;
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				if (!_touchCancelled) {
					//_highlightView.hidden = YES;
					[[HBAPLinkManager sharedInstance] showActionSheetForURL:[self URLAtPoint:_currentLinkFrame.origin] navigationController:_navigationController];
				}
			});
			break;
		
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateFailed:
		case UIGestureRecognizerStateCancelled:
			_touchCancelled = YES;
			//_highlightView.hidden = YES;
			break;
		
		default:
			break;
	}
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.class != UITapGestureRecognizer.class && gestureRecognizer.class != UILongPressGestureRecognizer.class) {
		return YES;
	}
	
	if (gestureRecognizer.numberOfTouches == 0) {
		_currentLinkFrame = CGRectZero;
		return NO;
	}
	
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
