//
//  HBAPTweetTextView.h
//  Aphelion
//
//  Created by Adam D on 28/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBAPTweetTextView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, retain) NSAttributedString *attributedString;
@property (nonatomic, retain) NSMutableArray *linkRanges;
@property (nonatomic, retain) UINavigationController *navigationController;

@end
