//
//  HBAPDebug.m
//  Aphelion
//
//  Created by Adam D on 6/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#if DEBUG
#import <Cycript/Cycript.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

const short cycriptPort = 1337;

void HBAPDebugStart() {
	CYListenServer(cycriptPort);
	
	struct ifaddrs *interfaces;
	char *ip = "127.0.0.1";
	
	if (getifaddrs(&interfaces) == 0) {
		struct ifaddrs *currentInterface = interfaces;
		
		while (currentInterface) {
			if (currentInterface->ifa_addr->sa_family == AF_INET && strcmp(currentInterface->ifa_name, "en0") == 0) {
				ip = inet_ntoa(((struct sockaddr_in *)currentInterface->ifa_addr)->sin_addr);
				break;
			}
			
			currentInterface = currentInterface->ifa_next;
		}
		
		freeifaddrs(interfaces);
	}
	
	NSLog(@"cycript -r %s:%hd", ip, cycriptPort);
}
#endif