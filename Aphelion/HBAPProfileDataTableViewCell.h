//
//  HBAPProfileTimelineTableViewCell.h
//  Aphelion
//
//  Created by Adam D on 13/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPTableViewCell.h"

@interface HBAPProfileDataTableViewCell : HBAPTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *valueLabel;

@end
