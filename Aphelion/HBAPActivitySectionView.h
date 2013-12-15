//
//  HBAPActivitySectionView.h
//  Aphelion
//
//  Created by Adam D on 16/12/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBAPActivitySectionView : UIView <UICollectionViewDataSource, UICollectionViewDelegate>

+ (CGFloat)height;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title items:(NSArray *)items;

@property (nonatomic, retain) NSArray *items;

@end
