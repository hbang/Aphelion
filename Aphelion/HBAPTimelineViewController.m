//
//  HBAPTimelineViewController.m
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTimelineViewController.h"
#import "HBAPAccountController.h"
#import "HBAPTweet.h"
#import "HBAPTweetTableViewCell.h"
#import "HBAPTweetDetailViewController.h"
#import "HBAPRootViewController.h"
#import "HBAPAvatarImageView.h"
#import "HBAPTwitterAPIClient.h"
#import "JSONKit/JSONKit.h"

@interface HBAPTimelineViewController () {
	BOOL _hasAppeared;
	BOOL _isLoading;
	BOOL _isComposing;
	
	NSMutableURLRequest *_request;
	
	UIBarButtonItem *_composeBarButtonItem;
	UIBarButtonItem *_sendBarButtonItem;
	UIBarButtonItem *_cancelBarButtonItem;
	
	NSMutableArray *_tweets;
	BOOL _canCompose;
}

@end

@implementation HBAPTimelineViewController

- (void)loadView {
	[super loadView];
	
	self.title = @"Wat.";
	self.tableView.estimatedRowHeight = 78.f;
	self.tableView.rowHeight = 78.f;
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(performRefresh) forControlEvents:UIControlEventValueChanged];
	
	_hasAppeared = NO;
	_isLoading = YES;
	_canCompose = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	_hasAppeared = YES;
	[self.refreshControl beginRefreshing];
}

#pragma mark - Tweet loading

- (void)loadTweetsFromPath:(NSString *)path {
	_request = [[[HBAPTwitterAPIClient sharedInstance] requestWithMethod:@"GET" path:[path stringByAppendingString:@".json"] parameters:nil] retain];
	[self performRefresh];
}

- (void)_loadTweetsFromArray:(NSArray *)tweetArray {
	_tweets = [[NSMutableArray alloc] init];
	
	for (NSDictionary *tweet in tweetArray) {
		if (tweet) {
			[_tweets addObject:[[[HBAPTweet alloc] initWithDictionary:tweet] autorelease]];
		}
	}
	
	_isLoading = NO;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.tableView reloadData];
	});
}

- (void)performRefresh {
	[[HBAPTwitterAPIClient sharedInstance] enqueueHTTPRequestOperation:[[HBAPTwitterAPIClient sharedInstance] HTTPRequestOperationWithRequest:_request success:^(AFHTTPRequestOperation *operation, NSData *responseObject) {
		[self _loadTweetsFromArray:responseObject.objectFromJSONData];
		
		static NSDateFormatter *dateFormatter;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			dateFormatter = [[NSDateFormatter alloc] init];
			dateFormatter.dateStyle = NSDateFormatterNoStyle;
			dateFormatter.timeStyle = NSDateFormatterLongStyle;
		});
		
		self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:L18N(@"Last updated: %@"), [dateFormatter stringFromDate:[NSDate date]]]];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.refreshControl endRefreshing];
		});
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		// TODO: handle error
		NSLog(@"error=%@ on %@",[operation responseString],_request.URL);
	}]];
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
	static float cellPaddingWidth;
	static float cellPaddingHeight = 38.f;
	static float titleTextHeight;
	static float retweetTextHeight;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		cellPaddingWidth = 45.f + [HBAPAvatarImageView frameForSize:HBAPAvatarSizeRegular].size.height;
		titleTextHeight = [@" " sizeWithAttributes:@{ NSFontAttributeName: [HBAPTweetTableViewCell realNameLabelFont] }].height;
		retweetTextHeight = [@" " sizeWithAttributes:@{ NSFontAttributeName: [HBAPTweetTableViewCell retweetedLabelFont] }].height + 3.f;
	});
	
	HBAPTweet *tweet = [_tweets objectAtIndex:indexPath.row];
	
	return cellPaddingHeight + titleTextHeight + [tweet.isRetweet ? tweet.originalTweet.text : tweet.text boundingRectWithSize:CGSizeMake(self.view.frame.size.width - cellPaddingWidth, 10000.f) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: [HBAPTweetTableViewCell contentLabelFont] } context:nil].size.height + (tweet.isRetweet ? retweetTextHeight : 0);
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
