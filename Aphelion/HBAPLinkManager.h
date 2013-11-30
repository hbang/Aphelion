//
//  HBAPLinkManager.h
//  Aphelion
//
//  Created by Adam D on 30/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const HBAPFallback = @"browser";

static NSString *const HBAPBrowserSafari = @"safari";
static NSString *const HBAPBrowserChrome = @"chrome";
static NSString *const HBAPBrowserProcyon = @"procyon";

static NSString *const HBAPYouTubeApp = @"youtube";
static NSString *const HBAPYouTubeJasmine = @"jasmine";

static NSString *const HBAPMapsApple = @"apple";
static NSString *const HBAPMapsGoogle = @"googlemaps";

static NSString *const HBAPGitHubIOctocat = @"ioctocat";
static NSString *const HBAPIMDBApp = @"imdb";
static NSString *const HBAPEBayApp = @"ebay";

@interface HBAPLinkManager : NSObject

+ (instancetype)sharedInstance;

- (void)reloadPreferences;

- (void)openURL:(NSURL *)url navigationController:(UINavigationController *)navigationController;
- (void)showActionSheetForURL:(NSURL *)url navigationController:(UINavigationController *)navigationController;

@property (nonatomic, retain) NSString *browserApp;
@property (nonatomic, retain) NSString *youTubeApp;
@property (nonatomic, retain) NSString *mapsApp;
@property (nonatomic, retain) NSString *gitHubApp;
@property (nonatomic, retain) NSString *imdbApp;
@property (nonatomic, retain) NSString *ebayApp;

@end
