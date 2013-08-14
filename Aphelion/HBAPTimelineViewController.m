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
	[HBAPTwitterAPIRequest requestWithPath:path parameters:nil account:[[HBAPAccountController sharedInstance] accountWithUsername:@"twitter:kirbtest"] completion:^(NSData *data, NSError *error) {
		NSLog(@"%@ %@",data,error);
		[self _loadTweetsFromArray:[data objectFromJSONData]];
	}];
}

- (void)_loadTweetsFromArray:(NSArray *)array {
	_rawTweets = [array copy];
	
	[_tweets release];
	_tweets = [[NSMutableArray alloc] init];
	
	for (NSDictionary *tweet in _rawTweets) {
		[_tweets addObject:[[HBAPTweet alloc] initWithJSON:tweet]];
	}
	
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
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.detailTextLabel.numberOfLines = 0;
		cell.detailTextLabel.font = [UIFont systemFontOfSize:14.f];
	}
	
	HBAPTweet *tweet = [_tweets objectAtIndex:indexPath.row];
	
	cell.textLabel.text = tweet.isRetweet ? [NSString stringWithFormat:@"RT @%@", tweet.originalTweet.poster.screenName] : [NSString stringWithFormat:@"@%@", tweet.poster.screenName];
	cell.detailTextLabel.text = tweet.isRetweet ? tweet.originalTweet.text : tweet.text;
	
	/*
	NSString *avatarURL = tweet.isRetweet ? tweet.originalTweet.poster.avatarURL : tweet.poster.avatarURL;
	
	if (_avatarCache[avatarURL]) {
		cell.imageView.image = _avatarCache[avatarURL];
	} else {
		NSString *user = tweet.isRetweet ? [tweet objectForKey:@"retweeted_status"][@"user"][@"screen_name"] : [tweet objectForKey:@"user"][@"screen_name"];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:tweet.isRetweet ? [tweet objectForKey:@"retweeted_status"][@"user"][@"profile_image_url_https"] : [tweet objectForKey:@"user"][@"profile_image_url_https"]]];
			_avatarCache[avatarURL] = [UIImage imageWithData:data];
			
			int i = 0;
			
			for (NSDictionary *tweet in _tweets) {
				BOOL isRetweet = !!tweet[@"retweeted_status"];
				NSMutableArray *array = [NSMutableArray array];
				
				if ([isRetweet ? [tweet objectForKey:@"retweeted_status"][@"user"][@"screen_name"] : [tweet objectForKey:@"user"][@"screen_name"] isEqualToString:user]) {
					[array addObject:[NSIndexPath indexPathForRow:i inSection:0]];
				}
				
				i++;
			}
		});
	}
	*/
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	HBAPTweet *tweet = [_tweets objectAtIndex:indexPath.row];
	
	return 20.f + [@"" sizeWithFont:[UIFont boldSystemFontOfSize:18.f]].height + [tweet.isRetweet ? tweet.originalTweet.text : tweet.text sizeWithFont:[UIFont systemFontOfSize:14.f] constrainedToSize:CGSizeMake(self.view.frame.size.width - 20.f, 10000.f)].height;
}

@end
