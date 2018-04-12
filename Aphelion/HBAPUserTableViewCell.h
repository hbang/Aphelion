//
//  HBAPUserTableViewCell.h
//  Aphelion
//
//  Created by Adam D on 18/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTableViewCell.h"

@class HBAPUser, HBAPAvatarView;

@interface HBAPUserTableViewCell : HBAPTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, retain) HBAPUser *user;

@end
