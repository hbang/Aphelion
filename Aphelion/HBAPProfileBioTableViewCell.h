//
//  HBAPProfileBioTableViewCell.h
//  Aphelion
//
//  Created by Adam D on 10/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTableViewCell.h"

@class HBAPUser;

@interface HBAPProfileBioTableViewCell : HBAPTableViewCell

+ (CGFloat)heightForUser:(HBAPUser *)user tableView:(UITableView *)tableView;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, retain) HBAPUser *user;

@end
