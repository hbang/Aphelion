//
//  HBAPActivitySectionView.m
//  Aphelion
//
//  Created by Adam D on 16/12/2013.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "HBAPActivitySectionView.h"
#import "HBAPActivityCollectionViewCell.h"
#import "HBAPActivity.h"
#import "HBAPThemeManager.h"
#import "HBAPFontManager.h"

@interface HBAPActivitySectionView () {
	UICollectionView *_collectionView;
}

@end

static NSString *ActivityCellIdentifier = @"ActivityCell";

@implementation HBAPActivitySectionView

#pragma mark - Constants

+ (CGFloat)height {
	return 15.f + [@" " sizeWithAttributes:@{ NSFontAttributeName: [HBAPFontManager sharedInstance].footerFont }].height + 100.f;
}

#pragma mark - Implementation

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title items:(NSArray *)items {
	self = [self initWithFrame:frame];

	if (self) {
		_items = [items copy];
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 15.f, 0, 0)];
		titleLabel.text = title.uppercaseString;
		titleLabel.font = [HBAPFontManager sharedInstance].footerFont;
		titleLabel.textColor = [HBAPThemeManager sharedInstance].dimTextColor;
		[titleLabel sizeToFit];
		[self addSubview:titleLabel];
		
		UICollectionViewFlowLayout *layout = [[[UICollectionViewFlowLayout alloc] init] autorelease];
		layout.minimumLineSpacing = 0;
		layout.minimumInteritemSpacing = 0;
		layout.itemSize = CGSizeMake(75.f, 100.f);
		layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		layout.sectionInset = UIEdgeInsetsMake(0, 2.f, 0, 2.f);
		
		_collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 4.f, frame.size.width, layout.itemSize.height) collectionViewLayout:layout];
		_collectionView.backgroundColor = nil;
		_collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_collectionView.delegate = self;
		_collectionView.dataSource = self;
		_collectionView.alwaysBounceVertical = NO;
		_collectionView.showsHorizontalScrollIndicator = NO;
		_collectionView.showsVerticalScrollIndicator = NO;
		[_collectionView registerClass:HBAPActivityCollectionViewCell.class forCellWithReuseIdentifier:ActivityCellIdentifier];
		[self addSubview:_collectionView];
	}

	return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return _items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	HBAPActivityCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ActivityCellIdentifier forIndexPath:indexPath];
	cell.activity = _items[indexPath.row];
	return cell;
}

#pragma mark - Memory management

- (void)dealloc {
	[_collectionView release];
	[_items release];
	
	[super dealloc];
}

@end
