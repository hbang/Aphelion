//
//  HBAPComposeTweetViewController.m
//  Aphelion
//
//  Created by Adam D on 30/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPComposeTweetViewController.h"
#import "HBAPAvatarSwitchButton.h"

@interface HBAPComposeTweetViewController ()

@end

@implementation HBAPComposeTweetViewController

- (void)loadView {
	[super loadView];
	
	self.title = L18N(@"New Tweet");
	self.canCompose = HBAPCanComposeAlways;	
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

@end
