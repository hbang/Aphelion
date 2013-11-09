//
//  HBAPNavigationController.m
//  Aphelion
//
//  Created by Adam D on 6/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPNavigationController.h"
#import "HBAPThemeManager.h"

@interface HBAPNavigationController () {
	UIProgressView *_progressView;
}

@end

@implementation HBAPNavigationController

- (void)loadView {
	[super loadView];
	
	_progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
	_progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	[self.navigationBar addSubview:_progressView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if (IS_IPAD) {
		self.toolbarHidden = NO;
		
		UIImageView *grabberImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grabber"]] autorelease];
		grabberImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
		grabberImageView.center = CGPointMake(self.toolbar.frame.size.width / 2, self.toolbar.frame.size.height / 2);
		[self.toolbar addSubview:grabberImageView];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	_progressView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height - _progressView.frame.size.height, self.navigationController.navigationBar.frame.size.width, _progressView.frame.size.height);
	
	if (_toolbarGestureRecognizer) {
		[self.toolbar addGestureRecognizer:_toolbarGestureRecognizer];
	}
}

- (float)progress {
	return _progressView.progress;
}

- (void)setProgress:(float)progress {
	if (_progressView.progress == progress) {
		return;
	}
	
	[_progressView setProgress:progress animated:progress != 0];
	
	if (progress == 1.f) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			self.progress = 0;
		});
	}
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
	if (_progressView.progress == progress) {
		return;
	}
	
	[_progressView setProgress:progress animated:animated];
}

@end
