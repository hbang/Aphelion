//
//  NSString+HBAdditions.h
//  Aphelion
//
//  Created by Adam D on 27/09/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HBAdditions)

- (NSString *)stringByDecodingXMLEntities;
- (NSString *)URLEncodedString;

@end
