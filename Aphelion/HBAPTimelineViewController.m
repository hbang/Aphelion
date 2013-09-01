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
}

@end

@implementation HBAPTimelineViewController

- (void)loadView {
	[super loadView];
	
	self.title = @"Wat.";
	
	_hasAppeared = NO;
	_isLoading = YES;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	_hasAppeared = YES;
}

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
	[ROOT_VC pushViewController:detailViewController animated:YES removingViewControllersAfter:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	static float titleTextHeight;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		titleTextHeight = [@"" sizeWithFont:[UIFont boldSystemFontOfSize:18.f]].height;
	});
	
	HBAPTweet *tweet = [_tweets objectAtIndex:indexPath.row];
	
	return 40.f + titleTextHeight + [tweet.isRetweet ? tweet.originalTweet.text : tweet.text sizeWithFont:[UIFont systemFontOfSize:14.f] constrainedToSize:CGSizeMake(self.view.frame.size.width - 20.f, 10000.f)].height;
}

#pragma mark - Memory management

- (void)dealloc {
	[_tweets release];
	[_account release];
	
	[super dealloc];
}

@end
