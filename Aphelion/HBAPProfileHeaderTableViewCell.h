//
//  HBAPProfileHeaderTableViewCell.h
//  Aphelion
//
//  Created by Adam D on 9/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPUserTableViewCell.h"

@class HBAPUser;

@interface HBAPProfileHeaderTableViewCell : UITableViewCell

+ (CGFloat)cellHeight;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, retain) HBAPUser *user;

@end
