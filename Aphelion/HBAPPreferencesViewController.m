//
//  HBAPPreferencesViewController.m
//  Aphelion
//
//  Created by Adam D on 18/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPPreferencesViewController.h"
#import "HBAPPreferencesTableViewCell.h"
#import "HBAPPreferencesHeaderFooterView.h"

@interface HBAPPreferencesViewController () {
	NSArray *_sections;
	NSDictionary *_headers;
	NSString *_plistName;
}

@end

@implementation HBAPPreferencesViewController

#pragma mark - Constants

+ (NSString *)specifierPlist {
	return @"PrefsRoot";
}

+ (CGFloat)headerPadding {
	return 35.f;
}

#pragma mark - Implementation

- (instancetype)initWithPlistName:(NSString *)name {
	self = [super initWithStyle:UITableViewStyleGrouped];
	
	if (self) {
		_plistName = [name copy];
	}
	
	return self;
}

- (void)loadView {
	[super loadView];
	[self _parseSpecifiers:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:_plistName ?: [self.class specifierPlist] ofType:@"plist"]]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}

#pragma mark - Specifiers

- (void)_parseSpecifiers:(NSDictionary *)specifiers {
	if (!specifiers || !specifiers.count) {
		HBLogError(@"%@: failed to load specifiers", self.class);
		return;
	}
	
	NSMutableArray *newSections = [NSMutableArray array];
	NSMutableArray *currentSection = [NSMutableArray array];
	NSMutableDictionary *newHeaders = [NSMutableDictionary dictionary];
	
	self.title = L18N(specifiers[@"title"]);
	
	NSInteger i = 0;
	
	for (NSDictionary *specifier in specifiers[@"items"]) {
		if ([specifier[@"cell"] isEqualToString:@"group"]) {
			if (currentSection.count) {
				[newSections addObject:currentSection];
				currentSection = [NSMutableArray array];
			}
			
			BOOL failed = YES;
			HBAPPreferencesHeaderFooterView *headerView = nil;
			
			if (specifier[@"headerClass"]) {
				Class headerClass = NSClassFromString(specifier[@"headerClass"]);
				
				if (headerClass) {
					failed = NO;
					
					headerView = [[[headerClass alloc] initWithFrame:CGRectZero] autorelease];
					headerView.autoresizingMask |= UIViewAutoresizingFlexibleWidth;
				} else {
					HBLogWarn(@"bad header class: %@", specifier[@"headerClass"]);
				}
			}
			
			if (!failed) {
				[newHeaders setObject:headerView forKey:@(i)];
			}
		}
		
		[currentSection addObject:specifier];
		
		i++;
	}
	
	[newSections addObject:currentSection];
	
	_sections = [newSections copy];
	_headers = [newHeaders copy];
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
		HBAPPreferencesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if (!cell) {
			cell = [[[HBAPPreferencesTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleDefault;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		cell.textLabel.text = L18N(specifier[@"label"]);
		
		return cell;
	} else if ([specifier[@"cell"] isEqualToString:@"option"]) {
		static NSString *CellIdentifier = @"OptionCell";
		HBAPPreferencesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if (!cell) {
			cell = [[[HBAPPreferencesTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleDefault;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		NSInteger currentPreference = [[NSUserDefaults standardUserDefaults] objectForKey:specifier[@"key"]] ? ((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:specifier[@"key"]]).intValue : ((NSNumber *)specifier[@"default"]).intValue;
		
		cell.textLabel.text = L18N(specifier[@"label"]);
		cell.detailTextLabel.text = L18N(specifier[@"validTitles"][currentPreference]);
		
		return cell;
	} else if ([specifier[@"cell"] isEqualToString:@"custom"]) {
		NSString *cellIdentifier = [@"CustomCell_" stringByAppendingString:specifier[@"cellClass"]];
		HBAPPreferencesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		
		if (!cell) {
			cell = [[[NSClassFromString(specifier[@"cellClass"]) alloc] initWithReuseIdentifier:cellIdentifier] autorelease];
		}
		
		if ([cell respondsToSelector:@selector(setSpecifier:)]) {
			cell.specifier = specifier;
		}
		
		return cell;
	}

	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *specifier = _sections[indexPath.section][indexPath.row + 1];
	Class cellClass = specifier[@"cellClass"] ? NSClassFromString(specifier[@"cellClass"]) : HBAPPreferencesTableViewCell.class;
	return [cellClass respondsToSelector:@selector(cellHeight)] ? [cellClass cellHeight] : 44.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return _headers[@(section)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	HBAPPreferencesHeaderFooterView *view = _headers[@(section)];
	return view ? [view.class cellHeight] : -1.f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return _sections[section][0][@"label"];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return _sections[section][0][@"footerText"];
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
	} else if ([specifier[@"cell"] isEqualToString:@"link"] && specifier[@"specifier"]) {
		viewController = [[[HBAPPreferencesViewController alloc] initWithPlistName:specifier[@"specifier"]] autorelease];
	} else if ([specifier[@"cell"] isEqualToString:@"linklist"]) {
		NOIMP
		//viewController = [[[HBAPPreferencesLinkListViewController alloc] initWithSpecifier:specifier] autorelease];
	} else if ([specifier[@"cell"] isEqualToString:@"custom"]) {
		Class cellClass = specifier[@"cellClass"] ? NSClassFromString(specifier[@"cellClass"]) : HBAPPreferencesTableViewCell.class;
		
		if ([cellClass instancesRespondToSelector:@selector(cellTapped)]) {
			[(HBAPPreferencesTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] cellTapped];
		}
	} else {
		// HBLogWarn(@"no action for cell %i:%i", indexPath.section, indexPath.row);
	}
	
	if (viewController) {
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

#pragma mark - Memory management

- (void)dealloc {
	[_sections release];
	
	[super dealloc];
}

@end
