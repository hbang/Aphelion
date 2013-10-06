//
//  main.m
//  Aphelion
//
//  Created by Adam D on 22/07/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBAPAppDelegate.h"

#if DEBUG
#import <Cycript/Cycript.h>
#endif

int main(int argc, char * argv[]) {
	@autoreleasepool {
#if DEBUG
		CYListenServer(1337);
		NSLog(@"cycript: listening on port 1337");
#else
		NSLog(@"CRITICAL: CYCRIPT INCLUDED IN RELEASE BUILD");
#endif
		
		return UIApplicationMain(argc, argv, nil, NSStringFromClass(HBAPAppDelegate.class));
	}
}
