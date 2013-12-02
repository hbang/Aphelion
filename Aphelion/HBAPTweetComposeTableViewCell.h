//
//  HBAPTweetComposeTableViewCell.h
//  Aphelion
//
//  Created by Adam D on 16/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTableViewCell.h"

@interface HBAPTweetComposeTableViewCell : HBAPTableViewCell <UITextViewDelegate>

@property (nonatomic, retain) UITextView *contentTextView;

@end
