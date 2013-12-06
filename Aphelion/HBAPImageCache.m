//
//  HBAPImageCache.m
//  Aphelion
//
//  Created by Adam D on 13/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPImageCache.h"
#import "HBAPImageSessionManager.h"

@interface HBAPImageCache () {
	NSMutableDictionary *_imageCacheCache;
}

@end

@implementation HBAPImageCache

#pragma mark - Constants

+ (HBAPAvatarSize)avatarSizeURLForSize:(HBAPAvatarSize)size {
	switch (size) {
		case HBAPAvatarSizeMini:
			return HBAPAvatarSizeNormal;
			break;
			
		case HBAPAvatarSizeNavBar:
			return HBAPAvatarSizeNormal;
			break;
			
		case HBAPAvatarSizeNormal:
			return HBAPAvatarSizeBigger;
			break;
			
		case HBAPAvatarSizeBigger:
			return HBAPAvatarSizeReasonablySmall;
			break;
			
		case HBAPAvatarSizeReasonablySmall:
			return HBAPAvatarSizeReasonablySmall;
			break;
			
		case HBAPAvatarSizeOriginal:
			return HBAPAvatarSizeOriginal;
			break;
	}
}

+ (NSString *)cachedAvatarPathForUserID:(NSString *)userID url:(NSURL *)url {
	return [[GET_DIR(NSCachesDirectory) stringByAppendingPathComponent:@"avatars"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@", userID, url.lastPathComponent]];
}

+ (NSString *)cachedBannerPathForUserID:(NSString *)userID url:(NSURL *)url {
	return [[GET_DIR(NSCachesDirectory) stringByAppendingPathComponent:@"banners"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@", userID, url.pathComponents[url.pathComponents.count - 2], url.lastPathComponent]];
}

#pragma mark - Implementation

+ (instancetype)sharedInstance {
	static HBAPImageCache *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self.class alloc] init];
	});
	
	return sharedInstance;
}

- (instancetype)init {
	self = [super init];
	
	if (self) {
		_imageCacheCache = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

#pragma mark - Cache getters

- (UIImage *)avatarForUser:(HBAPUser *)user ofSize:(HBAPAvatarSize)size {
	NSURL *url = [user URLForAvatarSize:[self.class avatarSizeURLForSize:size]];
	return [self _cachedImageWithUserID:user.userID url:url cachePath:[self.class cachedAvatarPathForUserID:user.userID url:url]];
}

- (UIImage *)bannerForUser:(HBAPUser *)user ofSize:(HBAPBannerSize)size {
	NSURL *url = [user URLForBannerSize:size];
	return [self _cachedImageWithUserID:user.userID url:url cachePath:[self.class cachedBannerPathForUserID:user.userID url:url]];
}

- (UIImage *)_cachedImageWithUserID:(NSString *)userID url:(NSURL *)url cachePath:(NSString *)cachePath {
	if (_imageCacheCache[url.absoluteString]) {
		return _imageCacheCache[url.absoluteString];
	} else if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
		UIImage *image = [UIImage imageWithContentsOfFile:cachePath];
		_imageCacheCache[url.absoluteString] = image;
		return image;
	}
	
	return nil;
}

#pragma mark - Downloaders

- (void)getAvatarForUser:(HBAPUser *)user size:(HBAPAvatarSize)size completion:(void (^)(UIImage *image, NSError *error))completion {
	NSURL *url = [user URLForAvatarSize:[self.class avatarSizeURLForSize:size]];
	[self _getImageWithURL:url cachePath:[self.class cachedAvatarPathForUserID:user.userID url:url] completion:completion];
}

- (void)getBannerForUser:(HBAPUser *)user size:(HBAPBannerSize)size completion:(void (^)(UIImage *image, NSError *error))completion {
	NSURL *url = [user URLForBannerSize:size];
	[self _getImageWithURL:url cachePath:[self.class cachedBannerPathForUserID:user.userID url:url] completion:completion];
}

- (void)_getImageWithURL:(NSURL *)url cachePath:(NSString *)cachePath completion:(void (^)(UIImage *image, NSError *error))completion {
	if (!url) {
		return;
	}
	
	[[HBAPImageSessionManager sharedInstance] GET:url.absoluteString parameters:nil success:^(NSURLSessionDataTask *task, UIImage *responseObject) {
		[UIImagePNGRepresentation(responseObject) writeToFile:cachePath atomically:NO];
		_imageCacheCache[url.absoluteString] = responseObject;
		completion(responseObject, nil);
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		completion(nil, error);
	}];
}

#pragma mark - Memory management

- (void)dealloc {
	[_imageCacheCache release];
	
	[super dealloc];
}

@end
