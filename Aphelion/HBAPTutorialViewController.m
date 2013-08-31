//
//  HBAPTutorialViewController.m
//  Aphelion
//
//  Created by Adam D on 20/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTutorialViewController.h"

@interface HBAPTutorialViewController () {
	UIScrollView *_scrollView;
}

@end

@implementation HBAPTutorialViewController
@synthesize isFirstRun = _isFirstRun;

- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	self.title = L18N(@"Tutorial");
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:L18N(@"Skip") style:UIBarButtonItemStyleBordered target:self action:@selector(doneTapped)] autorelease];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.delegate = self;
	_scrollView.pagingEnabled = YES;
	[self.view addSubview:_scrollView];
	
	UILabel *pageOne = [[[UILabel alloc] initWithFrame:_scrollView.frame] autorelease];
	pageOne.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
	pageOne.backgroundColor = [UIColor colorWithWhite:0.3f alpha:0.8f];
	pageOne.text = @"tutorial not finished yet...";
	[_scrollView addSubview:pageOne];
	
	CGRect pageTwoFrame = _scrollView.frame;
	pageTwoFrame.origin.x += pageTwoFrame.size.width;
	
	UILabel *pageTwo = [[[UILabel alloc] initWithFrame:pageTwoFrame] autorelease];
	pageTwo.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
	pageTwo.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.8f];
	pageTwo.text = @"move along...";
	[_scrollView addSubview:pageTwo];
	
	CGRect pageThreeFrame = pageTwoFrame;
	pageThreeFrame.origin.x += pageThreeFrame.size.width;
	
	UILabel *pageThree = [[[UILabel alloc] initWithFrame:pageThreeFrame] autorelease];
	pageThree.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
	pageThree.backgroundColor = [UIColor colorWithWhite:0.7f alpha:0.8f];
	pageThree.text = @"keep going...";
	[_scrollView addSubview:pageThree];
}

- (void)_setScrollViewContentSize {
	unsigned numberOfPages = 3;
	
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width * numberOfPages, self.view.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self _setScrollViewContentSize];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self _setScrollViewContentSize];
}

- (void)doneTapped {
	[self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (_scrollView.contentOffset.x >= _scrollView.contentSize.width - self.view.frame.size.width) {
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped)] autorelease];
	}
}

#pragma mark - Memory management

- (void)dealloc {
	[_scrollView release];
	
	[super dealloc];
}

@end
