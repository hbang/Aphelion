//
//  HBAPImportAccountViewController.m
//  Aphelion
//
//  Created by Adam D on 25/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPImportAccountViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "HBAPAppDelegate.h"
#import "HBAPTutorialViewController.h"
#import "AFNetworking/AFNetworking.h"
#import "AFOAuth1Client/AFOAuth1Client.h"
#import "HBAPTwitterHTTPClient.h"
#import "LUKeychainAccess/LUKeychainAccess.h"

@interface HBAPImportAccountViewController () {
	ACAccountStore *_accountStore;
	NSArray *_accounts;
	NSMutableArray *_selectedAccounts;
	NSMutableArray *_accountsDefaults;
	
	NSString *_normalTitle;
	NSString *_importingTitle;
	UIProgressView *_progressView;
}

@end

@interface AFOAuth1Client (Private)

- (NSDictionary *)OAuthParameters;

@end

@implementation HBAPImportAccountViewController

- (void)loadView {
	[super loadView];
	
	_normalTitle = L18N(@"Add Accounts");
	_importingTitle = L18N(@"Adding");
	
	self.title = _normalTitle;
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:L18N(@"Add All") style:UIBarButtonItemStyleBordered target:self action:@selector(addAllTapped)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped)] autorelease];
	self.navigationItem.hidesBackButton = YES;
	
	_accountStore = [[ACAccountStore alloc] init];
	
	[self loadAccounts];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountStoreDidChange) name:ACAccountStoreDidChangeNotification object:nil];
	
	_progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	_progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	_progressView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height - _progressView.frame.size.height, self.navigationController.navigationBar.frame.size.width, _progressView.frame.size.height);
	_progressView.hidden = YES;
	[self.navigationController.navigationBar addSubview:_progressView];
}

- (void)addAllTapped {
	for (unsigned i = 0; i < _selectedAccounts.count; i++) {
		_selectedAccounts[i] = @YES;
	}
	
	[self.tableView reloadData];
	[self doneTapped];
}

- (void)doneTapped {
	unsigned numberOfAccounts = 0;
	
	for (unsigned i = 0; i < _selectedAccounts.count; i++) {
		if (((NSNumber *)_selectedAccounts[i]).boolValue) {
			numberOfAccounts++;
			
			[_accountsDefaults addObject:((ACAccount *)_accounts[i]).identifier];
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
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = nil;
	
	AFOAuth1Client *client = [HBAPTwitterHTTPClient sharedInstance].OAuthClient;
	float increments = 1.f / (_selectedAccounts.count * 2.f);
	unsigned i = 0;
	
	for (ACAccount *account in _accounts) {
		NSMutableDictionary *parameters = [client.OAuthParameters.mutableCopy autorelease];
		[parameters setObject:@"reverse_auth" forKey:@"x_auth_mode"];
		
		NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:@"/oauth/request_token" parameters:parameters];
		request.HTTPBody = [@"x_auth_mode=reverse_auth" dataUsingEncoding:NSUTF8StringEncoding];
		
		NSMutableDictionary *accountList = [((NSDictionary *)[[LUKeychainAccess standardKeychainAccess] objectForKey:@"accounts"]).mutableCopy autorelease] ?: [NSMutableDictionary dictionary];
		
		[client enqueueHTTPRequestOperation:[client HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
			[_progressView setProgress:_progressView.progress + increments animated:YES];
			
			SLRequest *stepTwoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"] parameters:@{
				@"x_reverse_auth_target": kHBAPTwitterKey,
				@"x_reverse_auth_parameters": operation.responseString
			}];
			stepTwoRequest.account = account;
			[stepTwoRequest performRequestWithHandler:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
				[_progressView setProgress:_progressView.progress + increments animated:YES];
				
				if (error) {
					UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:L18N(@"Error authenticating @%@"), account.username] message:error.localizedDescription delegate:nil cancelButtonTitle:L18N(@"OK") otherButtonTitles:nil] autorelease];
					[alertView show];
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
				
				if (i == _selectedAccounts.count - 1) {
					[_progressView removeFromSuperview];
					
					[[LUKeychainAccess standardKeychainAccess] setObject:accountList forKey:@"accounts"];
					
					HBAPTutorialViewController *tutorialViewController = [[[HBAPTutorialViewController alloc] init] autorelease];
					[self.navigationController pushViewController:tutorialViewController animated:YES];
				}
			}];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[_progressView setProgress:_progressView.progress + increments animated:YES];
			
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:L18N(@"Error requesting tokens for @%@"), account.username] message:error.localizedDescription delegate:nil cancelButtonTitle:L18N(@"OK") otherButtonTitles:nil] autorelease];
			[alertView show];
			
			if (i == _selectedAccounts.count - 1) {
				HBAPTutorialViewController *tutorialViewController = [[[HBAPTutorialViewController alloc] init] autorelease];
				[self.navigationController pushViewController:tutorialViewController animated:YES];
			}
		}]];
		
		i++;
	}
}

#pragma mark - Account store stuff

- (void)loadAccounts {
	_accountsDefaults = [[[NSUserDefaults standardUserDefaults] objectForKey:@"accounts"] mutableCopy] ?: [[NSMutableArray alloc] init];
	_selectedAccounts = [[NSMutableArray alloc] init];
	
	_accounts = [[_accountStore accountsWithAccountType:[_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]] retain];
	
	for (unsigned i = 0; i < _accounts.count; i++) {
		[_selectedAccounts addObject:@NO];
	}
}

- (void)accountStoreDidChange {
	[self loadAccounts];
	[self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsunsignedableView:(UITableView *)tableView {
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
		#ifndef THEOS
		cell.selectionStyle = UITableViewCellSelectionStyleDefault;
		#endif
	}
	
	cell.textLabel.text = [@"@" stringByAppendingString:((ACAccount *)_accounts[indexPath.row]).username];
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
	[_accountsDefaults release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

@end
