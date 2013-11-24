//
//  HBAPTableViewCell.h
//  Aphelion
//
//  Created by Adam D on 24/11/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBAPTableViewCell : UITableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (BOOL)useThemeBackground;
- (void)setupTheme;

@end
