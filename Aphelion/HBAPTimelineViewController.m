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
#import "HBAPAvatarView.h"
#import "HBAPTwitterAPIClient.h"
#import <JSONKit/JSONKit.h>

//#define kHBAPKirbOfflineDebug

@interface HBAPTimelineViewController () {
	BOOL _hasAppeared;
	BOOL _isLoading;
	BOOL _isComposing;
	
	UIBarButtonItem *_composeBarButtonItem;
	UIBarButtonItem *_sendBarButtonItem;
	UIBarButtonItem *_cancelBarButtonItem;
	HBAPCanCompose _canCompose;
	
	NSMutableArray *_tweets;
}

@end

@implementation HBAPTimelineViewController

#pragma mark - Constants

+ (NSString *)cachePathForAPIPath:(NSString *)path {
	return [[GET_DIR(NSCachesDirectory) stringByAppendingPathComponent:@"timelines"] stringByAppendingPathComponent:[path stringByReplacingOccurrencesOfString:@"/" withString:@""]];
}

#pragma mark - UIViewController

- (void)loadView {
	[super loadView];
	
	self.title = @"Wat.";
	self.tableView.estimatedRowHeight = 78.f;
	self.tableView.rowHeight = 78.f;
	self.refreshControl = [[[UIRefreshControl alloc] init] autorelease];
	[self.refreshControl addTarget:self action:@selector(performRefresh) forControlEvents:UIControlEventValueChanged];
	
	_hasAppeared = NO;
	_isLoading = NO;
	_canCompose = HBAPCanComposeNo;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self performRefresh];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	_hasAppeared = YES;
	
	if (_isLoading) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[self.refreshControl beginRefreshing];
			[self.tableView scrollRectToVisible:CGRectMake(0, -self.refreshControl.frame.size.height, 0, 0) animated:NO];
		});
	}
}

#pragma mark - Tweet loading

- (void)loadTweetsFromArray:(NSArray *)tweetArray {
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
	if (!_apiPath) {
		return;
	}
	
	_isLoading = YES;
	
	void (^refreshDone)(void) = ^{
		_isLoading = NO;
		
		static NSDateFormatter *dateFormatter;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			dateFormatter = [[NSDateFormatter alloc] init];
			dateFormatter.dateStyle = NSDateFormatterNoStyle;
			dateFormatter.timeStyle = NSDateFormatterMediumStyle;
		});
		
		self.refreshControl.attributedTitle = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:L18N(@"Last updated: %@"), [dateFormatter stringFromDate:[NSDate date]]]] autorelease];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.refreshControl endRefreshing];
		});
	};
	
#ifdef kHBAPKirbOfflineDebug
	NSString *path = [GET_DIR(NSDocumentDirectory) stringByAppendingPathComponent:@"timelinesample.json"];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		[self loadTweetsFromArray:[[NSData dataWithContentsOfFile:path] objectFromJSONData]];
		refreshDone();
	} else {
		[[HBAPTwitterAPIClient sharedInstance] enqueueHTTPRequestOperation:[[HBAPTwitterAPIClient sharedInstance] HTTPRequestOperationWithRequest:[[HBAPTwitterAPIClient sharedInstance] requestWithMethod:@"GET" path:self.apiPath parameters:nil] success:^(AFHTTPRequestOperation *operation, NSData *responseObject) {
			[self loadTweetsFromArray:responseObject.objectFromJSONData];
			[responseObject writeToFile:path atomically:YES];
			
			refreshDone();
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			// TODO: handle error
			NSLog(@"error=%@",[operation responseString]);
		}]];
	}
#else
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self.class cachePathForAPIPath:_apiPath]]) {
		[self loadTweetsFromArray:[NSArray arrayWithContentsOfFile:[self.class cachePathForAPIPath:_apiPath]]];
		refreshDone();
		return;
	}
	
	[[HBAPTwitterAPIClient sharedInstance] enqueueHTTPRequestOperation:[[HBAPTwitterAPIClient sharedInstance] HTTPRequestOperationWithRequest:[[HBAPTwitterAPIClient sharedInstance] requestWithMethod:@"GET" path:_apiPath parameters:nil] success:^(AFHTTPRequestOperation *operation, NSData *responseObject) {
		[self loadTweetsFromArray:responseObject.objectFromJSONData];
		refreshDone();
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		// TODO: handle error
		NSLog(@"error=%@",[operation responseString]);
	}]];
#endif
}

#pragma mark - State saving

- (void)saveState {
	[_tweets writeToFile:[self.class cachePathForAPIPath:_apiPath] atomically:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return _isComposing ? 1 : 0;
	}
	
	return _isLoading ? 0 : _tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"TweetCell";
	
	HBAPTweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		cell = [[[HBAPTweetTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.navigationController = self.navigationController;
	}
	
	if (_isComposing && indexPath.section == 0) {
		cell.tweet = nil;
		cell.editable = YES;
	} else {
		cell.tweet = [_tweets objectAtIndex:indexPath.row];
		cell.editable = NO;
	}
	
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
		cellPaddingWidth = 45.f + [HBAPAvatarView frameForSize:HBAPAvatarSizeRegular].size.height;
		titleTextHeight = [@" " sizeWithAttributes:@{ NSFontAttributeName: [HBAPTweetTableViewCell realNameLabelFont] }].height;
		retweetTextHeight = [@" " sizeWithAttributes:@{ NSFontAttributeName: [HBAPTweetTableViewCell retweetedLabelFont] }].height + 3.f;
	});
	
	HBAPTweet *tweet = [_tweets objectAtIndex:indexPath.row];
	
	return cellPaddingHeight + titleTextHeight + [tweet.isRetweet ? tweet.originalTweet.text : tweet.text boundingRectWithSize:CGSizeMake(self.view.frame.size.width - cellPaddingWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: [HBAPTweetTableViewCell contentTextViewFont] } context:nil].size.height + (tweet.isRetweet ? retweetTextHeight : 0);
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

#pragma mark - Memory management

- (void)dealloc {
	[_tweets release];
	[_account release];
	
	[super dealloc];
}

@end
