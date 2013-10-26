//
//  HBAPPreferencesViewController.m
//  Aphelion
//
//  Created by Adam D on 18/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPPreferencesViewController.h"

@interface HBAPPreferencesViewController ()

@end

@implementation HBAPPreferencesViewController

- (void)loadView {
	[super loadView];

	// ...
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning numberOfSectionsInTableView: not implemented.
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning tableView:numberOfRowsInSection: not implemented.
	// Return the number of rows in the section.
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
		{
			static NSString *CellIdentifier = @"<#CellIdentifier#>";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

			if (!cell) {
				//cell = [[[UITableViewCell alloc] initWithStyle:<#UITableViewCellStyle#> reuseIdentifier:CellIdentifier] autorelease];

				// ...
			}

			// ...

			return cell;
			break;
		}
	}

	return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	/*
	<#DetailViewController#> *detailViewController = [[[<#DetailViewController#> alloc] init] autorelease];
	[self.navigationController pushViewController:detailViewController animated:YES];
	*/
}

@end
