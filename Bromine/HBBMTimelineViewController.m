//
//  HBBMTimelineViewController.m
//  Bromine
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBBMTimelineViewController.h"

@interface HBBMTimelineViewController ()

@end

@implementation HBBMTimelineViewController

- (void)loadView {
	[super loadView];
	
	self.title = @"Wat.";
	
	_tweets = [[NSMutableArray alloc] init];
	_tweets[0] = [NSMutableDictionary dictionary];
	_tweets[0][@"screen_name"] = @"sweg";
}

- (void)loadTweetsFromPath:(NSString *)path {
	
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"CellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	cell.textLabel.text = [@"@" stringByAppendingString:_tweets[indexPath.row][@"screen_name"]];
	
	return cell;
}

@end
