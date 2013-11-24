//
//  HBAPPreferencesTableViewCell.h
//  Aphelion
//
//  Created by Adam D on 15/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTableViewCell.h"

@interface HBAPPreferencesTableViewCell : HBAPTableViewCell

+ (CGFloat)cellHeight;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)cellTapped;

@property (nonatomic, retain) NSDictionary *specifier;

@end
