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
	
	self.title = L18N(@"Settings");
	
	[self _parseSpecifiers:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PrefsRoot" ofType:@"plist"]]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}

- (void)_parseSpecifiers:(NSDictionary *)specifiers {
	NSMutableArray *newSections = [NSMutableArray array];
	NSMutableArray *currentSection;
	
	for (NSDictionary *specifier in specifiers) {
		if ([specifier[@"type"] isEqualToString:@"section"]) {
			if (currentSection && currentSection.count) {
				[newSections addObject:currentSection];
				
				currentSection = [NSMutableArray array];
			}
			
			[currentSection addObject:specifier];
		}
	}
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((NSArray *)_sections[section]).count - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *specifier = _sections[indexPath.section][indexPath.row + 1];
	
	if ([specifier[@"type"] isEqualToString:@"link"]) {
		static NSString *CellIdentifier = @"LinkCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if (!cell) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellStyleDefault;
		}
		
		cell.textLabel.text = L18N(specifier[@"label"]);
		
		return cell;
	} else if ([specifier[@"type"] isEqualToString:@"option"]) {
		static NSString *CellIdentifier = @"OptionCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if (!cell) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellStyleDefault;
			cell.accessoryType = UITableViewCellAccessoryDetailButton;
		}
		
		NSInteger currentPreference = [[NSUserDefaults standardUserDefaults] objectForKey:specifier[@"key"]] ? ((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:specifier[@"key"]]).intValue : ((NSNumber *)specifier[@"default"]).intValue;
		
		cell.textLabel.text = L18N(specifier[@"label"]);
		cell.detailTextLabel.text = L18N(specifier[@"validTitles"][currentPreference]);
		
		return cell;
	}

	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return _sections[section][0][@"title"] ?: nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return _sections[section][0][@"footerText"] ?: nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSDictionary *specifier = _sections[indexPath.section][indexPath.row + 1];

	if (specifier[@"viewController"]) {
		Class viewClass = NSClassFromString(specifier[@"viewController"]);
		
		if (viewClass && [viewClass isKindOfClass:UIViewController.class]) {
			UIViewController *viewController = [[[viewClass alloc] init] autorelease];
			[self.navigationController pushViewController:viewController animated:YES];
		}
	}
}

@end
