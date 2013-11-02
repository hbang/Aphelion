//
//  HBAPPreferencesViewController.m
//  Aphelion
//
//  Created by Adam D on 18/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPPreferencesViewController.h"

@interface HBAPPreferencesViewController () {
	NSArray *_sections;
}

@end

@implementation HBAPPreferencesViewController

- (void)loadView {
	[super loadView];
	[self _parseSpecifiers:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PrefsRoot" ofType:@"plist"]]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}

- (void)_parseSpecifiers:(NSDictionary *)specifiers {
	NSMutableArray *newSections = [NSMutableArray array];
	NSMutableArray *currentSection = [NSMutableArray array];
	
	self.title = L18N(specifiers[@"title"]);
	
	for (NSDictionary *specifier in specifiers[@"items"]) {
		if ([specifier[@"cell"] isEqualToString:@"group"]) {
			if (currentSection.count) {
				[newSections addObject:currentSection];
				currentSection = [NSMutableArray array];
			}
		}
		
		[currentSection addObject:specifier];
	}
	
	[newSections addObject:currentSection];
	
	_sections = [newSections copy];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _sections ? _sections.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((NSArray *)_sections[section]).count - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *specifier = _sections[indexPath.section][indexPath.row + 1];
	
	if ([specifier[@"cell"] isEqualToString:@"link"]) {
		static NSString *CellIdentifier = @"LinkCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if (!cell) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleDefault;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		cell.textLabel.text = L18N(specifier[@"label"]);
		
		return cell;
	} else if ([specifier[@"cell"] isEqualToString:@"option"]) {
		static NSString *CellIdentifier = @"OptionCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if (!cell) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleDefault;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		NSInteger currentPreference = [[NSUserDefaults standardUserDefaults] objectForKey:specifier[@"key"]] ? ((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:specifier[@"key"]]).intValue : ((NSNumber *)specifier[@"default"]).intValue;
		
		cell.textLabel.text = L18N(specifier[@"label"]);
		cell.detailTextLabel.text = L18N(specifier[@"validTitles"][currentPreference]);
		
		return cell;
	}

	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return _sections[section][0][@"label"] ?: nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return _sections[section][0][@"footerText"] ?: nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSDictionary *specifier = _sections[indexPath.section][indexPath.row + 1];
	UIViewController *viewController = nil;
	
	if ([specifier[@"cell"] isEqualToString:@"link"] && specifier[@"detail"]) {
		Class viewClass = NSClassFromString(specifier[@"detail"]);
		
		if ([viewClass isSubclassOfClass:UIViewController.class]) {
			viewController = [[[viewClass alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
		} else if (viewClass != Nil) {
			HBLogError(@"class %@ is not a UIViewController", specifier[@"detail"]);
		} else {
			HBLogError(@"class %@ does not exist", specifier[@"detail"]);
		}
	} else if ([specifier[@"cell"] isEqualToString:@"linklist"]) {
		NOIMP
		//viewController = [[[HBAPPreferencesLinkListViewController alloc] initWithSpecifier:specifier] autorelease];
	} else {
		HBLogWarn(@"no action for cell %i:%i", indexPath.section, indexPath.row);
	}
	
	if (viewController) {
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

@end
