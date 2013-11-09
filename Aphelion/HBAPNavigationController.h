//
//  HBAPNavigationController.h
//  Aphelion
//
//  Created by Adam D on 6/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBAPNavigationController : UINavigationController

- (void)setProgress:(float)progress animated:(BOOL)animated;

@property (nonatomic, retain) UIPanGestureRecognizer *toolbarGestureRecognizer;
@property float progress;
@property (nonatomic, retain) NSURLSessionTask *progressTask;

@end
