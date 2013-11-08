//
//  HBAPImportAccountViewController.m
//  Aphelion
//
//  Created by Adam D on 25/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPImportAccountViewController.h"
#import "HBAPAppDelegate.h"
#import "HBAPTutorialViewController.h"
#import "HBAPTwitterAPISessionManager.h"
#import "HBAPNavigationController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <LUKeychainAccess/LUKeychainAccess.h>
#import <AFNetworking/AFHTTPRequestOperation.h>

@interface HBAPImportAccountViewController () {
	ACAccountStore *_accountStore;
	NSMutableArray *_accounts;
	NSMutableArray *_selectedAccounts;
	
	NSString *_normalTitle;
	NSString *_importingTitle;
	UIBarButtonItem *_addAllBarButtonItem;
	UIBarButtonItem *_doneBarButtonItem;
	UIProgressView *_progressView;
}

@end

@implementation HBAPImportAccountViewController

- (void)loadView {
	[super loadView];
	
	_normalTitle = L18N(@"Add Accounts");
	_importingTitle = L18N(@"Adding…");
	
	self.title = _normalTitle;
	self.navigationItem.hidesBackButton = YES;
	
	_addAllBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:L18N(@"Add All") style:UIBarButtonItemStyleBordered target:self action:@selector(addAllTapped)];
	_doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped)];
	self.navigationItem.leftBarButtonItem = _addAllBarButtonItem;
	self.navigationItem.rightBarButtonItem = _doneBarButtonItem;
	
	_accountStore = [[ACAccountStore alloc] init];
	
	[self loadAccounts];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountStoreDidChange) name:ACAccountStoreDidChangeNotification object:nil];
}

- (void)addAllTapped {
	for (NSUInteger i = 0; i < _selectedAccounts.count; i++) {
		_selectedAccounts[i] = @YES;
	}
	
	[self.tableView reloadData];
	[self doneTapped];
}

- (void)doneTapped {
	NSUInteger numberOfAccounts = 0;
	
	for (NSUInteger i = 0; i < _selectedAccounts.count; i++) {
		if (((NSNumber *)_selectedAccounts[i]).boolValue) {
			numberOfAccounts++;
		}
	}
	
	if (numberOfAccounts == 0) {
		UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:L18N(@"No accounts selected.") message:L18N(@"At least one of your Twitter accounts must be imported to use Aphelion.\n\nDon’t have any Twitter accounts set up on your device? Tap the “Settings” icon on your home screen, followed by “Twitter”.") delegate:nil cancelButtonTitle:L18N(@"OK") otherButtonTitles:nil] autorelease];
		[alertView show];
		
		return;
	}
	
	self.title = _importingTitle;
	_progressView.hidden = NO;
	self.tableView.userInteractionEnabled = NO;
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	[self.navigationItem setRightBarButtonItem:nil animated:YES];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		CGFloat increments = 1.f / (numberOfAccounts * 2.f);
		NSUInteger i = 0;
		__block NSUInteger failures = 0;
		NSMutableDictionary *accountList = [((NSDictionary *)[[LUKeychainAccess standardKeychainAccess] objectForKey:@"accounts"]).mutableCopy autorelease] ?: [NSMutableDictionary dictionary];
		
		for (ACAccount *account in _accounts) {
			if (!((NSNumber *)_selectedAccounts[i]).boolValue) {
				continue;
			}
			
			dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
			
			[[HBAPTwitterAPISessionManager sharedInstance] POST:@"/oauth/request_token" parameters:@{ @"x_auth_mode": @"reverse_auth" } success:^(NSURLSessionTask *task, NSData *response) {
				((HBAPNavigationController *)self.navigationController).progress += increments;
				
				NSDictionary *params = @{
					@"x_reverse_auth_target": kHBAPTwitterKey,
					@"x_reverse_auth_parameters": [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] autorelease]
				};
				
				SLRequest *stepTwoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"access_token" relativeToURL:[NSURL URLWithString:kHBAPTwitterOAuthRoot]] parameters:params];
				stepTwoRequest.account = account;
				[stepTwoRequest performRequestWithHandler:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
					((HBAPNavigationController *)self.navigationController).progress += increments;
					
					if (error) {
						failures++;
						
						// i couldn't possibly give a fuck about using a parser
						NSString *response = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
						
						NSRange errorIDStartRange = [response rangeOfString:@"<error code=\""];
						NSRange errorIDEndRange = [response rangeOfString:@"\">" options:kNilOptions range:NSMakeRange(errorIDStartRange.location + errorIDStartRange.length, 10)];
						NSString *errorID =	errorIDStartRange.location == NSNotFound ? @"-1337" : [response substringWithRange:NSMakeRange(errorIDStartRange.location + errorIDStartRange.length, errorIDEndRange.length)];
						NSString *errorMessage = errorIDStartRange.location == NSNotFound ? [NSString stringWithFormat:L18N(@"Unknown error: %@"), error.localizedDescription] : [response substringWithRange:NSMakeRange(errorIDEndRange.location + 2, [response rangeOfString:@"</error>"].location - errorIDEndRange.location - 2)];
						
						dispatch_async(dispatch_get_main_queue(), ^{
							UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:L18N(@"Error authenticating @%@"), account.username] message:[NSString stringWithFormat:L18N(@"%@: %@\nEnsure that your account password is correct in the iOS Settings app."), errorID, errorMessage] delegate:nil cancelButtonTitle:L18N(@"OK") otherButtonTitles:nil] autorelease];
							[alertView show];
						});
					} else {
						NSString *response = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
						NSArray *parameters = [response componentsSeparatedByString:@"&"];
						NSMutableDictionary *data = [NSMutableDictionary dictionary];
						
						for (NSString *parameter in parameters) {
							NSArray *splitArray = [parameter componentsSeparatedByString:@"="];
							data[splitArray[0]] = splitArray[1];
						}
						
						accountList[data[@"user_id"]] = @{
							@"token": data[@"oauth_token"],
							@"secret": data[@"oauth_token_secret"]
						};
					}
					
					dispatch_semaphore_signal(semaphore);
					
					if (_progressView.progress == 1.f) {
						[[LUKeychainAccess standardKeychainAccess] setObject:accountList forKey:@"accounts"];
						[self _importingCompletedWithFailures:failures];
					}
				}];
			} failure:^(NSURLSessionTask *task, NSError *error) {
				failures++;
				
				[_progressView setProgress:_progressView.progress + increments animated:YES];
				
				dispatch_async(dispatch_get_main_queue(), ^{
					UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:L18N(@"Error requesting tokens for @%@"), account.username] message:error.localizedDescription delegate:nil cancelButtonTitle:L18N(@"OK") otherButtonTitles:nil] autorelease];
					[alertView show];
				});
				
				dispatch_semaphore_signal(semaphore);
				
				if (i == numberOfAccounts - 1) {
					[self _importingCompletedWithFailures:failures];
				}
			}];
			
			dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
			dispatch_release(semaphore);
			
			i++;
		}
	});
}

- (void)_importingCompletedWithFailures:(NSUInteger)failures {
	dispatch_async(dispatch_get_main_queue(), ^{
		((HBAPNavigationController *)self.navigationController).progress = 0;
		
		if (failures == 0) {
			HBAPTutorialViewController *tutorialViewController = [[[HBAPTutorialViewController alloc] init] autorelease];
			[self.navigationController pushViewController:tutorialViewController animated:YES];
		} else {
			self.title = _normalTitle;
			self.tableView.userInteractionEnabled = YES;
			[self.navigationItem setLeftBarButtonItem:_addAllBarButtonItem animated:YES];
			[self.navigationItem setRightBarButtonItem:_doneBarButtonItem animated:YES];
			[self loadAccounts];
			[self.tableView reloadData];
		}
	});
}

#pragma mark - Account store stuff

- (void)loadAccounts {
	[_accounts release];
	[_selectedAccounts release];
	
	_accounts = [[NSMutableArray alloc] init];
	_selectedAccounts = [[NSMutableArray alloc] init];
	
	NSDictionary *accountsDefaults = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"accounts"] ?: [NSDictionary dictionary];
	NSArray *accounts = [_accountStore accountsWithAccountType:[_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]];
	
	for (NSUInteger i = 0; i < accounts.count; i++) {
		// private property :(
		NSString *userID = [[(ACAccount *)accounts[i] valueForKey:[NSString stringWithFormat:@"%@ert%@s", @"prop", @"ie"]] valueForKey:[NSString stringWithFormat:@"u%@i%@", @"ser_", @"d"]];
		
		if (![accountsDefaults objectForKey:userID]) {
			[_accounts addObject:accounts[i]];
			[_selectedAccounts addObject:@NO];
		}
	}
}

- (void)accountStoreDidChange {
	[self loadAccounts];
	[self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"AccountCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	}
	
	cell.textLabel.text = ((ACAccount *)_accounts[indexPath.row]).accountDescription;
	cell.accessoryType = ((NSNumber *)[_selectedAccounts objectAtIndex:indexPath.row]).boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	_selectedAccounts[indexPath.row] = @(!((NSNumber *)_selectedAccounts[indexPath.row]).boolValue);
	cell.accessoryType = ((NSNumber *)[_selectedAccounts objectAtIndex:indexPath.row]).boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return L18N(@"Use the iOS Settings app to add more Twitter accounts.");
}

#pragma mark - Memory management

- (void)dealloc {
	[_accountStore release];
	[_accounts release];
	[_selectedAccounts release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

@end
