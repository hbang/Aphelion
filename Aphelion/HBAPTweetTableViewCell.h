//
//  HBAPTweetTableViewCell.h
//  Aphelion
//
//  Created by Adam D on 20/08/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HBAPTweet;

@interface HBAPTweetTableViewCell : UITableViewCell

@property (nonatomic, retain) HBAPTweet *tweet;

+ (UIFont *)realNameLabelFont;
+ (UIFont *)screenNameLabelFont;
+ (UIFont *)retweetedLabelFont;
+ (UIFont *)contentLabelFont;

@end
