//
//  HBAPAuthorizeRequestViewController.h
//  Aphelion
//
//  Created by Adam D on 7/06/2014.
//  Copyright (c) 2014 HASHBANG Productions. All rights reserved.
//

#import "HBAPViewController.h"

@interface HBAPAuthorizeRequestViewController : HBAPViewController <UITextViewDelegate>

- (instancetype)initWithCompletion:(void(^)())completion;

@end
