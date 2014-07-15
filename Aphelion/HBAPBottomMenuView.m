//
//  HBAPMenuButtonView.m
//  Aphelion
//
//  Created by Adam D on 20/04/2014.
//  Copyright (c) 2014 HASHBANG Productions. All rights reserved.
//

#import "HBAPBottomMenuView.h"
#import "HBAPThemeManager.h"
#import "HBAPBottomMenuButtonView.h"

@interface HBAPBottomMenuView () {
	UIDynamicAnimator *_animator;
	
	HBAPBottomMenuButtonView *_menuButton;
	
	HBAPBottomMenuButtonView *_homeButton;
	HBAPBottomMenuButtonView *_mentionsButton;
	HBAPBottomMenuButtonView *_messagesButton;
	HBAPBottomMenuButtonView *_profileButton;
	HBAPBottomMenuButtonView *_searchButton;
	HBAPBottomMenuButtonView *_settingsButton;
}

@end

@implementation HBAPBottomMenuView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		CGFloat menuButtonSize = 62.f;
		
		_animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
		_animator.delegate = self;
		
		_homeButton = [[HBAPBottomMenuButtonView alloc] init];
		_homeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
		_homeButton.alpha = 0;
		_homeButton.image = [UIImage imageNamed:@"sidebar_home_selected"];
		_homeButton.selected = YES;
		[self addSubview:_homeButton];
		
		_mentionsButton = [[HBAPBottomMenuButtonView alloc] init];
		_mentionsButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
		_mentionsButton.alpha = 0;
		_mentionsButton.image = [UIImage imageNamed:@"sidebar_mentions"];
		[self addSubview:_mentionsButton];
		
		_messagesButton = [[HBAPBottomMenuButtonView alloc] init];
		_messagesButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
		_messagesButton.alpha = 0;
		_messagesButton.image = [UIImage imageNamed:@"sidebar_messages"];
		[self addSubview:_messagesButton];
		
		_messagesButton = [[HBAPBottomMenuButtonView alloc] init];
		_messagesButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
		_messagesButton.alpha = 0;
		_messagesButton.image = [UIImage imageNamed:@"sidebar_messages"];
		[self addSubview:_messagesButton];
		
		_profileButton = [[HBAPBottomMenuButtonView alloc] init];
		_profileButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
		_profileButton.alpha = 0;
		_profileButton.image = [UIImage imageNamed:@"sidebar_user"];
		[self addSubview:_profileButton];
		
		_searchButton = [[HBAPBottomMenuButtonView alloc] init];
		_searchButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
		_searchButton.alpha = 0;
		_searchButton.image = [UIImage imageNamed:@"sidebar_search"];
		[self addSubview:_searchButton];
		
		_settingsButton = [[HBAPBottomMenuButtonView alloc] init];
		_settingsButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
		_settingsButton.alpha = 0;
		_settingsButton.image = [UIImage imageNamed:@"sidebar_settings"];
		[self addSubview:_settingsButton];
		
		_menuButton = [[HBAPBottomMenuButtonView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - menuButtonSize - 10.f, menuButtonSize, menuButtonSize)];
		_menuButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		_menuButton.center = CGPointMake(self.frame.size.width / 2, _menuButton.center.y);
		_menuButton.image = [UIImage imageNamed:@"menu_button"];
		_menuButton.selected = YES;
		[_menuButton addGestureRecognizer:[[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(menuButtonGestureRecognizerFired:)] autorelease]];
		[self addSubview:_menuButton];
	}
	
	return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	UIView *view = [super hitTest:point withEvent:event];
	return [view isKindOfClass:HBAPBottomMenuButtonView.class] ? view : nil;
}

#pragma mark - Animations

- (void)_openMenu {
	CGFloat buttonSize = 48.f, padding = 10.f;
	
	_homeButton.frame = _menuButton.frame;
	_mentionsButton.frame = _menuButton.frame;
	_messagesButton.frame = _menuButton.frame;
	_profileButton.frame = _menuButton.frame;
	_searchButton.frame = _menuButton.frame;
	_settingsButton.frame = _menuButton.frame;
	
	UISnapBehavior *homeBehavior = [[[UISnapBehavior alloc] initWithItem:_homeButton snapToPoint:CGPointMake(_menuButton.frame.origin.x - padding - buttonSize, _menuButton.frame.origin.y + (_menuButton.frame.size.height - buttonSize))] autorelease];
	[_animator addBehavior:homeBehavior];
	
	UISnapBehavior *mentionsBehavior = [[[UISnapBehavior alloc] initWithItem:_mentionsButton snapToPoint:CGPointMake(_menuButton.frame.origin.x - buttonSize, _menuButton.frame.origin.y - (buttonSize / 6) * 5)] autorelease];
	[_animator addBehavior:mentionsBehavior];
	
	UISnapBehavior *profileBehavior = [[[UISnapBehavior alloc] initWithItem:_profileButton snapToPoint:CGPointMake(self.frame.size.width / 2 - buttonSize / 2, _menuButton.frame.origin.y - buttonSize - padding)] autorelease];
	[_animator addBehavior:profileBehavior];
	
	UISnapBehavior *searchBehavior = [[[UISnapBehavior alloc] initWithItem:_searchButton snapToPoint:CGPointMake(_menuButton.frame.origin.x + _menuButton.frame.size.width, _menuButton.frame.origin.y - (buttonSize / 12) * 11)] autorelease];
	[_animator addBehavior:searchBehavior];
	
	UISnapBehavior *settingsBehavior = [[[UISnapBehavior alloc] initWithItem:_settingsButton snapToPoint:CGPointMake(_menuButton.frame.origin.x + _menuButton.frame.size.width + padding, _homeButton.frame.origin.y)] autorelease];
	[_animator addBehavior:settingsBehavior];
	
	[UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1.f initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		_homeButton.alpha = 1;
		_mentionsButton.alpha = 1;
		//_messagesButton.alpha = 1;
		_profileButton.alpha = 1;
		_searchButton.alpha = 1;
		_settingsButton.alpha = 1;
	} completion:nil];
}

#pragma mark - Gesture recognizers

- (void)menuButtonGestureRecognizerFired:(UIPanGestureRecognizer *)gestureRecognizer {
	switch (gestureRecognizer.state) {
		case UIGestureRecognizerStateBegan:
			[self _openMenu];
			break;
		
		default:
			break;
	}
}

#pragma mark - UIDynamicAnimatorDelegate



#pragma mark - Memory management

- (void)dealloc {
	[_animator release];
	[_menuButton release];
	[_homeButton release];
	[_mentionsButton release];
	[_messagesButton release];
	[_profileButton release];
	[_searchButton release];
	[_settingsButton release];
	
	[super dealloc];
}

@end
