//
//  HBAPTimelineComposeViewController.m
//  Aphelion
//
//  Created by Adam D on 7/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTimelineComposeViewController.h"
#import "HBAPTweetComposeTableViewCell.h"

@interface HBAPTimelineComposeViewController () {
	BOOL _isComposing;
	
	UIBarButtonItem *_composeBarButtonItem;
	UIBarButtonItem *_sendBarButtonItem;
	UIBarButtonItem *_cancelBarButtonItem;
	HBAPCanCompose _canCompose;
}

@end

@implementation HBAPTimelineComposeViewController

- (void)loadView {
	[super loadView];
	
	_canCompose = HBAPCanComposeNo;
	
	self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
}

#pragma mark - UITableViewDataSource 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger originalValue = [super numberOfSectionsInTableView:tableView];
	return _canCompose != HBAPCanComposeNo ? originalValue + 1 : originalValue;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0 && _canCompose != HBAPCanComposeNo) {
		return _isComposing ? 1 : 0;
	} else {
		return [super tableView:tableView numberOfRowsInSection:section];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section != 0 || _canCompose == HBAPCanComposeNo) {
		return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	}
	
	static NSString *CellIdentifier = @"TweetComposeCell";
	
	HBAPTweetComposeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		cell = [[[HBAPTweetComposeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.navigationController = self.navigationController;
		cell.tweet = nil;
		cell.editable = YES;
	}
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && _canCompose != HBAPCanComposeNo && _isComposing) {
		return;
	}
	
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.section == 0 && _canCompose != HBAPCanComposeNo && _isComposing ? self.tableView.rowHeight + 50.f : [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - Tweet composing

- (HBAPCanCompose)canCompose {
	return _canCompose;
}

- (void)setCanCompose:(HBAPCanCompose)canCompose {
	_canCompose = canCompose;
	
	if (_canCompose != HBAPCanComposeNo) {
		_isComposing = NO;
		
		if (!_composeBarButtonItem) {
			_composeBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:_canCompose == HBAPCanComposeReply ? UIBarButtonSystemItemReply : UIBarButtonSystemItemCompose target:self action:@selector(composeTapped)];
		}
		
		if (!_sendBarButtonItem) {
			_sendBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:L18N(@"Send") style:UIBarButtonItemStyleDone target:self action:@selector(sendTapped)];
		}
		
		if (!_cancelBarButtonItem) {
			_cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped)];
		}
		
		self.navigationItem.leftBarButtonItem = nil;
		self.navigationItem.rightBarButtonItem = _composeBarButtonItem;
	} else {
		self.navigationItem.leftBarButtonItem = nil;
		self.navigationItem.rightBarButtonItem = nil;
	}
}

- (void)composeTapped {
	if (_isComposing) {
		return;
	}
	
	_isComposing = YES;
	
	[self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationBottom];
	
	[self.navigationItem setLeftBarButtonItem:_cancelBarButtonItem animated:YES];
	[self.navigationItem setRightBarButtonItem:_sendBarButtonItem animated:YES];
}

- (void)sendTapped {
	NOIMP
	
	if (!_isComposing) {
		return;
	}
	
	_isComposing = NO;
	
	[self.tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationBottom];
	
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	[self.navigationItem setRightBarButtonItem:_composeBarButtonItem animated:YES];
}

- (void)cancelTapped {
	NOIMP
	
	if (!_isComposing) {
		return;
	}
	
	_isComposing = NO;
	
	[self.tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationBottom];
	
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	[self.navigationItem setRightBarButtonItem:_composeBarButtonItem animated:YES];
}

@end
