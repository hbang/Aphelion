//
//  NSData+HBAdditions.m
//  Aphelion
//
//  Created by Adam D on 7/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "NSData+HBAdditions.h"

@implementation NSData (HBAdditions)

- (id)objectFromJSONData {
	return [NSJSONSerialization JSONObjectWithData:self options:kNilOptions error:nil];
}

@end
