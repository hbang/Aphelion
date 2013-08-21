//
//  main.m
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UI7Kit/UI7Kit.h"
#import "HBAPAppDelegate.h"

int main(int argc, char * argv[]) {
	@autoreleasepool {
		[UI7Kit patchIfNeeded];
		return UIApplicationMain(argc, argv, nil, NSStringFromClass(HBAPAppDelegate.class));
	}
}
