//
//  HBAPSearchTimelineViewController.m
//  Aphelion
//
//  Created by Adam D on 1/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPSearchTimelineViewController.h"

@interface HBAPSearchTimelineViewController () {
	UIBarButtonItem *_trendsBarButtonItem;
}

@end

@implementation HBAPSearchTimelineViewController

- (void)loadView {
	[super loadView];
	
	_trendsBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:L18N(@"Trends") style:UIBarButtonItemStyleBordered target:self action:@selector(trendsTapped)];
	
	UISearchDisplayController *searchController = [[[UISearchDisplayController alloc] initWithSearchBar:[[[UISearchBar alloc] init] autorelease] contentsController:self] autorelease];
	searchController.delegate = self;
	searchController.searchResultsDataSource = self;
	searchController.searchResultsDelegate = self;
	searchController.displaysSearchBarInNavigationBar = YES;
	searchController.searchBar.delegate = self;
	searchController.searchBar.showsScopeBar = YES;
	searchController.searchBar.scopeButtonTitles = @[ L18N(@"Tweets"), L18N(@"People") ];
	
	self.navigationItem.rightBarButtonItem = _trendsBarButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([self.searchDisplayController.searchBar.text isEqualToString:@""]) {
		[self.searchDisplayController.searchBar becomeFirstResponder];
	}
}

- (void)trendsTapped NOIMP

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	return NO;
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	[self.searchDisplayController.navigationItem setRightBarButtonItem:nil animated:YES];
	[searchBar setShowsCancelButton:YES animated:YES];
	searchBar.showsScopeBar = YES;
	searchBar.showsBookmarkButton = YES;
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
	[self.navigationItem setRightBarButtonItem:_trendsBarButtonItem animated:YES];
	[searchBar setShowsCancelButton:NO animated:YES];
	searchBar.showsScopeBar = NO;
	searchBar.showsBookmarkButton = NO;
	return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar NOIMP
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar NOIMP
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope NOIMP

@end
