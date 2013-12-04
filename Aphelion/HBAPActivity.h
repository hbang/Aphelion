//
//  HBAPActivity.h
//  Aphelion
//
//  Created by Adam D on 4/12/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBAPActivity : NSObject

- (BOOL)shouldShow;
- (void)activityTapped;

@property (nonatomic, retain, readonly) NSString *title;
@property (nonatomic, retain, readonly) UIImage *icon;

@end
