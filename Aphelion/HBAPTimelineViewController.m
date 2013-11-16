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
#import "HBAPAvatarButton.h"
#import "HBAPTwitterAPISessionManager.h"
#import "HBAPThemeManager.h"

//#define kHBAPKirbOfflineDebug

@interface HBAPTimelineViewController () {
	BOOL _hasAppeared;
	BOOL _isLoading;
	
	NSMutableArray *_tweets;
	NSDate *_lastUpdated;
}

@end

@implementation HBAPTimelineViewController

#pragma mark - Constants

+ (NSString *)cachePathForAPIPath:(NSString *)path {
	return [[[GET_DIR(NSCachesDirectory) stringByAppendingPathComponent:@"timelines"] stringByAppendingPathComponent:[path stringByReplacingOccurrencesOfString:@"/" withString:@""]] stringByAppendingPathExtension:@"plist"];
}

#pragma mark - UIViewController

- (void)loadView {
	[super loadView];
	
	self.title = @"Wat.";
	self.tableView.estimatedRowHeight = [HBAPTweetTableViewCell defaultHeight];
	self.tableView.rowHeight = [HBAPTweetTableViewCell defaultHeight];
	self.refreshControl = [[[UIRefreshControl alloc] init] autorelease];
	self.refreshControl.tintColor = [HBAPThemeManager sharedInstance].tintColor;
	[self.refreshControl addTarget:self action:@selector(performRefresh) forControlEvents:UIControlEventValueChanged];
	
	_hasAppeared = NO;
	_isLoading = NO;
	_tweets = [[NSMutableArray alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveState) name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveState) name:UIApplicationWillTerminateNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged) name:HBAPThemeChanged object:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self.class cachePathForAPIPath:_apiPath]]) {
		NSDictionary *timeline = [NSKeyedUnarchiver unarchiveObjectWithFile:[self.class cachePathForAPIPath:_apiPath]];
		_lastUpdated = [timeline[@"updated"] copy];
		_tweets = [timeline[@"tweets"] mutableCopy];
		[self _updateLastUpdated];
	}
	
	[self performRefresh];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	_hasAppeared = YES;
	
	if (_isLoading) {
		[self.refreshControl beginRefreshing];
		
		if (!_tweets || _tweets.count == 0) {
			self.tableView.contentOffset = CGPointMake(0, -200.f); // ugh
		}
	}
}

#pragma mark - Tweet loading

- (void)loadTweetsFromArray:(NSArray *)array {
	[_tweets release];
	_tweets = [[NSMutableArray alloc] init];
	
	[self insertTweetsFromArray:array atIndex:0];
}

- (void)insertRawTweetsFromArray:(NSArray *)array atIndex:(NSUInteger)index {
	[self insertRawTweetsFromArray:array atIndex:index completion:NULL];
}

- (void)insertRawTweetsFromArray:(NSArray *)array atIndex:(NSUInteger)index completion:(void (^)(void))completion {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSMutableArray *newTweets = [NSMutableArray array];
		
		for (NSDictionary *tweet in array) {
			if (tweet) {
				[newTweets addObject:[[[HBAPTweet alloc] initWithDictionary:tweet] autorelease]];
			}
		}
		
		[self insertTweetsFromArray:newTweets atIndex:index];
		
		if (completion) {
			dispatch_async(dispatch_get_main_queue(), completion);
		}
	});
}

- (void)insertTweetsFromArray:(NSArray *)array atIndex:(NSUInteger)index {
	if (array.count == 0) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self _showNoNewTweets];
		});
		
		return;
	}
	
	[_tweets insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, array.count)]];
	
	_isLoading = NO;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.tableView reloadData];
	});
}

- (void)_showNoNewTweets {
	self.navigationItem.prompt = L18N(@"No new tweets");
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		self.navigationItem.prompt = nil;
	});
}

- (void)_updateLastUpdated {
	static NSDateFormatter *dateFormatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateStyle = NSDateFormatterNoStyle;
		dateFormatter.timeStyle = NSDateFormatterMediumStyle;
	});
	
	self.refreshControl.attributedTitle = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:L18N(@"Last updated: %@"), [dateFormatter stringFromDate:_lastUpdated]] attributes:@{ NSForegroundColorAttributeName: [HBAPThemeManager sharedInstance].textColor }] autorelease];
}

- (void)performRefresh {
	if (!_apiPath) {
		HBLogError(@"no api path set for %@", self.class);
		return;
	}
	
	if (_isLoading) {
		return;
	}
	
	_isLoading = YES;
	
	void (^refreshDone)(void) = ^{
		_isLoading = NO;
		_lastUpdated = [[NSDate alloc] init];
		
		[self _updateLastUpdated];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.refreshControl endRefreshing];
		});
	};
	
#ifdef kHBAPKirbOfflineDebug
	NSString *path = [GET_DIR(NSDocumentDirectory) stringByAppendingPathComponent:@"timelinesample.json"];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		[self loadRawTweetsFromArray:[[NSData dataWithContentsOfFile:path] objectFromJSONData]];
		refreshDone();
	} else {
		[[HBAPTwitterAPISessionManager sharedInstance] getPath:_apiPath parameters:@{ @"count": @(200).stringValue } success:^(NSURLSessionTask *task, NSArray *responseObject) {
			[self loadRawTweetsFromArray:responseObject];
			[responseObject writeToFile:path atomically:YES];
			
			refreshDone();
		} failure:^(NSURLSessionTask *task, NSError *error) {
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:L18N(@"Couldn’t load timeline.") message:error.localizedDescription delegate:nil cancelButtonTitle:L18N(@"OK") otherButtonTitles:nil] autorelease];
			[alertView show];
			
			refreshDone();
		}];
	}
#else
	NSMutableDictionary *parameters = [[@{ @"count": @(200).stringValue } mutableCopy] autorelease];
	
	if (_tweets.count) {
		parameters[@"since_id"] = ((HBAPTweet *)_tweets[0]).tweetID;
	}
	
	[[HBAPTwitterAPISessionManager sharedInstance] GET:_apiPath parameters:parameters success:^(NSURLSessionTask *task, NSArray *responseObject) {
		[self insertRawTweetsFromArray:responseObject atIndex:0 completion:refreshDone];
	} failure:^(NSURLSessionTask *task, NSError *error) {
		if ([HBAPTwitterAPISessionManager sharedInstance].reachabilityManager.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable) {
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:L18N(@"Couldn’t load timeline.") message:error.localizedDescription delegate:nil cancelButtonTitle:L18N(@"OK") otherButtonTitles:nil] autorelease];
			[alertView show];
		}
		
		refreshDone();
	}];
#endif
}

#pragma mark - State saving

- (void)saveState {
	if (!_tweets || _tweets.count == 0 || !_lastUpdated) {
		return;
	}
	
	if (![NSKeyedArchiver archiveRootObject:@{
			@"version": [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"],
			@"updated": _lastUpdated,
			@"tweets": _tweets
		} toFile:[self.class cachePathForAPIPath:_apiPath]]) {
		HBLogWarn(@"couldn't save timeline %@ to %@", _apiPath, [self.class cachePathForAPIPath:_apiPath]);
	}
}

#pragma mark - Theme changing

- (void)themeChanged {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		for (HBAPTweet *tweet in _tweets) {
			[tweet resetAttributedString];
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.tableView reloadData];
		});
	});
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _tweets ? _tweets.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"TweetCell";
	
	HBAPTweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		cell = [[[HBAPTweetTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
		cell.navigationController = (HBAPNavigationController *)self.navigationController;
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	cell.tweet = _tweets.count > indexPath.row ? [_tweets objectAtIndex:indexPath.row] : nil;
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	HBAPTweetDetailViewController *detailViewController = [[[HBAPTweetDetailViewController alloc] initWithTweet:[_tweets objectAtIndex:indexPath.row]] autorelease];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [HBAPTweetTableViewCell heightForTweet:_tweets[indexPath.row] tableView:self.tableView];
}

#pragma mark - Memory management

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_tweets release];
	[_account release];
	
	[super dealloc];
}

@end
