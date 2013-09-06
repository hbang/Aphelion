//
//  HBAPTimelineViewController.m
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTimelineViewController.h"
#import "HBAPTwitterAPIRequest.h"
#import "HBAPAccountController.h"
#import "HBAPTweet.h"
#import "HBAPTweetTableViewCell.h"
#import "HBAPTweetDetailViewController.h"
#import "HBAPRootViewController.h"

#ifdef THEOS
#import "../JSONKit/JSONKit.h"
#else
#import "JSONKit.h"
#endif

@interface HBAPTimelineViewController () {
	BOOL _hasAppeared;
	BOOL _isLoading;
	BOOL _isComposing;
	
	UIBarButtonItem *_composeBarButtonItem;
	UIBarButtonItem *_sendBarButtonItem;
	UIBarButtonItem *_cancelBarButtonItem;
}

@end

@implementation HBAPTimelineViewController

@synthesize composeInReplyToTweet = _composeInReplyToTweet, composeInReplyToUser = _composeInReplyToUser;

- (void)loadView {
	[super loadView];
	
	self.title = @"Wat.";
	
	_hasAppeared = NO;
	_isLoading = YES;
	_canCompose = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	_hasAppeared = YES;
}

#pragma mark - Tweet loading

- (void)loadTweetsFromPath:(NSString *)path {
	[HBAPTwitterAPIRequest requestWithPath:path parameters:nil account:[[HBAPAccountController sharedInstance] accountWithUsername:@"kirbtest"] completion:^(NSData *data, NSError *error) {
		NSLog(@"%@ %@",data,error);
		if (error) {
			// TODO: handle error
		} else {
			[self _loadTweetsFromArray:data.objectFromJSONData];
		}
	}];
}

- (void)_loadTweetsFromArray:(NSArray *)tweetArray {
	_tweets = [[NSMutableArray alloc] init];
	
	for (NSDictionary *tweet in tweetArray) {
		if (tweet) {
			[_tweets addObject:[[HBAPTweet alloc] initWithDictionary:tweet]];
		}
	}
	
	_isLoading = NO;

	dispatch_async(dispatch_get_main_queue(), ^{
		[self.tableView reloadData];
	});
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _isLoading ? 0 : _tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"TweetCell";
	
	HBAPTweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		cell = [[[HBAPTweetTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	cell.tweet = [_tweets objectAtIndex:indexPath.row];
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	HBAPTweetDetailViewController *detailViewController = [[[HBAPTweetDetailViewController alloc] initWithTweet:[_tweets objectAtIndex:indexPath.row]] autorelease];
	[ROOT_VC pushViewController:detailViewController animated:YES removingViewControllersAfter:self.navigationController];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	static float titleTextHeight;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		titleTextHeight = [@" " sizeWithFont:[UIFont boldSystemFontOfSize:18.f]].height;
	});
	
	HBAPTweet *tweet = [_tweets objectAtIndex:indexPath.row];
	
	return 40.f + titleTextHeight + [tweet.isRetweet ? tweet.originalTweet.text : tweet.text sizeWithFont:[UIFont systemFontOfSize:14.f] constrainedToSize:CGSizeMake(self.view.frame.size.width - 20.f, 10000.f)].height;
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
			_composeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:L18N(_canCompose == HBAPCanComposeReply ? @"Reply" : @"Tweet") style:UIBarButtonItemStyleBordered target:self action:@selector(composeTapped)];
		}
		
		if (!_sendBarButtonItem) {
			_sendBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:L18N(@"Send") style:UIBarButtonItemStyleBordered target:self action:@selector(sendTapped)];
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
	NSLog(@"composeTapped kinda not implemented");
	
	if (_isComposing) {
		return;
	}
	
	_isComposing = YES;
	
	[self.navigationItem setLeftBarButtonItem:_cancelBarButtonItem animated:YES];
	[self.navigationItem setRightBarButtonItem:_sendBarButtonItem animated:YES];
}

- (void)sendTapped {
	NSLog(@"sendTapped kinda not implemented");
	
	if (!_isComposing) {
		return;
	}
	
	_isComposing = NO;
	
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	[self.navigationItem setRightBarButtonItem:_composeBarButtonItem animated:YES];
}

- (void)cancelTapped {
	NSLog(@"cancelTapped kinda not implemented");
	
	/*
	if (!_isComposing) {
		return;
	}
	
	_isComposing = NO;
	*/
	
	[self sendTapped];
}

#pragma mark - Memory management

- (void)dealloc {
	[_tweets release];
	[_account release];
	
	[super dealloc];
}

@end
