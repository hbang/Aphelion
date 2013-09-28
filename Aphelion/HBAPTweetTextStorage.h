//
//  HBAPTweetTextStorage.h
//  Aphelion
//
//  Created by Adam D on 27/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBAPTweetTextStorage : NSTextStorage

@property (nonatomic, retain, readonly) NSString *string;
@property (nonatomic, retain) NSArray *entities;

@end
