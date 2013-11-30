//
//  HBAPLinkManager.h
//  Aphelion
//
//  Created by Adam D on 30/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBAPLinkManager : NSObject

+ (instancetype)sharedInstance;

- (void)openURL:(NSURL *)url navigationController:(UINavigationController *)navigationController;
- (void)showActionSheetForURL:(NSURL *)url navigationController:(UINavigationController *)navigationController;

@end
