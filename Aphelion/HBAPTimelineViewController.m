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
	NSMutableArray *_rawTweets;
	NSMutableDictionary *_avatarCache;
}

@end

@implementation HBAPTimelineViewController

- (void)loadView {
	[super loadView];
	
	self.title = @"Wat.";
	
	_rawTweets = [[NSMutableArray alloc] init];
	_tweets = [[NSMutableArray alloc] init];
	_avatarCache = [[NSMutableDictionary alloc] init];
}

- (void)loadTweetsFromPath:(NSString *)path {
	[HBAPTwitterAPIRequest requestWithPath:path parameters:nil account:[[HBAPAccountController sharedInstance] accountWithUsername:@"kirbtest"] completion:^(NSData *data, NSError *error) {
		NSLog(@"%@ %@",data,error);
		[self _loadTweetsFromArray:[data objectFromJSONData]];
	}];
}

- (void)_loadTweetsFromArray:(NSArray *)array {
	_rawTweets = [array copy];
	
	[_tweets release];
	_tweets = [[NSMutableArray alloc] init];
	
	for (NSDictionary *tweet in _rawTweets) {
		[_tweets addObject:[[HBAPTweet alloc] initWithDictionary:tweet]];
	}
	
	[_rawTweets release];
	
	[self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _tweets.count;
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
	HBAPTweet *tweet = [_tweets objectAtIndex:indexPath.row];
	
	return 40.f + [@"" sizeWithFont:[UIFont boldSystemFontOfSize:18.f]].height + [tweet.isRetweet ? tweet.originalTweet.text : tweet.text sizeWithFont:[UIFont systemFontOfSize:14.f] constrainedToSize:CGSizeMake(self.view.frame.size.width - 20.f, 10000.f)].height;
}

@end
