//
//  HBAPTweetTableViewself.m
//  Aphelion
//
//  Created by Adam D on 20/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTweetTableViewCell.h"
#import "HBAPTweet.h"
#import "HBAPUser.h"

@implementation HBAPTweetTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	if (self) {
		// TODO: attributed label
		self.detailTextLabel.numberOfLines = 0;
		self.detailTextLabel.font = [UIFont systemFontOfSize:14.f];
		self.detailTextLabel.textColor = [UIColor blackColor];
	}
	
	return self;
}

- (HBAPTweet *)tweet {
	return _tweet;
}

- (void)setTweet:(HBAPTweet *)tweet {
	if (tweet == _tweet) {
		return;
	}
	
	_tweet = tweet;
	
	self.textLabel.text = _tweet.isRetweet ? [NSString stringWithFormat:@"RT @%@", _tweet.originalTweet.poster.screenName] : [NSString stringWithFormat:@"@%@", _tweet.poster.screenName];
	self.detailTextLabel.text = _tweet.isRetweet ? _tweet.originalTweet.text : _tweet.text;
}

@end