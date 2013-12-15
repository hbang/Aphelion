//
//  HBAPActivityViewController.h
//  Aphelion
//
//  Created by Adam D on 4/12/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPViewController.h"

@interface HBAPActivityViewController : HBAPViewController

- (void)presentInViewController:(UIViewController *)viewController frame:(CGRect)frame;

@property (nonatomic, retain) NSDictionary *items;

@end
