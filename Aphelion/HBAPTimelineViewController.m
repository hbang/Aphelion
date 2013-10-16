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
#import "NSData+HBAdditions.h"

//#define kHBAPKirbOfflineDebug

@interface HBAPTimelineViewController () {
	BOOL _hasAppeared;
	BOOL _isLoading;
	
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
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _isLoading ? 0 : _tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"TweetCell";
	
	HBAPTweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		cell = [[[HBAPTweetTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.navigationController = self.navigationController;
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	cell.tweet = _tweets.count > indexPath.row ? [_tweets objectAtIndex:indexPath.row] : nil;
	cell.editable = NO;
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	HBAPTweetDetailViewController *detailViewController = [[[HBAPTweetDetailViewController alloc] initWithTweet:[_tweets objectAtIndex:indexPath.row]] autorelease];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	static CGFloat CellSpacingWidth = 45.f;
	static CGFloat CellSpacingHeight = 38.f;
	static CGFloat RetweetSpacingHeight = 3.f;
	
	CGFloat cellPaddingWidth = CellSpacingWidth + [HBAPAvatarView frameForSize:HBAPAvatarSizeRegular].size.width;

	HBAPTweet *tweet = [_tweets objectAtIndex:indexPath.row];
	
	return CellSpacingHeight + [@" " sizeWithAttributes:@{ NSFontAttributeName: [HBAPTweetTableViewCell realNameLabelFont] }].height + [tweet.isRetweet ? tweet.originalTweet.text : tweet.text boundingRectWithSize:CGSizeMake(self.view.frame.size.width - cellPaddingWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: [HBAPTweetTableViewCell contentTextViewFont] } context:nil].size.height + (tweet.isRetweet ? [@" " sizeWithAttributes:@{ NSFontAttributeName: [HBAPTweetTableViewCell retweetedLabelFont] }].height + RetweetSpacingHeight : 0);
}

#pragma mark - Memory management

- (void)dealloc {
	[_tweets release];
	[_account release];
	
	[super dealloc];
}

@end
