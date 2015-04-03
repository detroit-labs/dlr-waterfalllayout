//
//  DPZCouponFlowLayout~iPad.m
//  Dominos
//
//  Created by Mark Schall on 12/9/13.
//  Copyright (c) 2013 Domino's Pizza. All rights reserved.
//

#import "DPZCouponLayout~iPad.h"

@implementation DPZCouponLayout_iPad {
	NSMutableArray* _sectionHeaderAttributes;
	NSMutableArray* _sectionItemAttributes;
	NSMutableArray* _sectionFooterAttributes;
	NSMutableArray* _sectionHeights;
}

#pragma mark - Life cycle
- (void)dealloc {
	[_sectionHeaderAttributes removeAllObjects];
	_sectionHeaderAttributes = nil;
	
	[_sectionItemAttributes removeAllObjects];
	_sectionItemAttributes = nil;
	
	[_sectionFooterAttributes removeAllObjects];
	_sectionFooterAttributes = nil;
	
	[_sectionHeights removeAllObjects];
	_sectionHeights = nil;
}

#pragma mark - Helper Methods
-(BOOL)delegateImplmentsHeaderHeight {
	return [self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:headerHeightInSection:)];
}

-(BOOL)delegateImplmentsFooterHeight {
	return [self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:footerHeightInSection:)];
}

- (void)initializeArrays:(NSInteger)numberOfSections {
	_sectionHeaderAttributes = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
		
	_sectionItemAttributes = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
	
	_sectionFooterAttributes = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
		
	_sectionHeights = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
}

-(CGFloat)interItemSpacingXInSection:(NSInteger)sectionIndex {
	id<DPZCouponLayoutDelegate> delegate = (id<DPZCouponLayoutDelegate>)self.collectionView.delegate;
	BOOL implementsInterimSpacingDelegate = [delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)];
	
	CGFloat interItemSpacingX = 0.f;
	if ( implementsInterimSpacingDelegate ) {
		interItemSpacingX = [delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:sectionIndex];
	}
	
	return interItemSpacingX;
}

-(CGFloat)interItemSpacingYInSection:(NSInteger)sectionIndex {
	id<DPZCouponLayoutDelegate> delegate = (id<DPZCouponLayoutDelegate>)self.collectionView.delegate;
	BOOL implementsLineSpacingDelegate = [delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)];
	
	CGFloat interItemSpacingY = 0.f;
	if ( implementsLineSpacingDelegate ) {
		interItemSpacingY = [delegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:sectionIndex];
	}
	
	return interItemSpacingY;
}

-(UIEdgeInsets)sectionInsetInSection:(NSInteger)sectionIndex {
	id<DPZCouponLayoutDelegate> delegate = (id<DPZCouponLayoutDelegate>)self.collectionView.delegate;
	BOOL implementsInsetDelegate = [delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:) ];
	
	UIEdgeInsets sectionInset = UIEdgeInsetsZero;
	if ( implementsInsetDelegate ) {
		sectionInset = [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:sectionIndex];
	}
	
	return sectionInset;
}

#pragma mark - Methods to Override
- (void)prepareLayout {
	[super prepareLayout];
	
	NSInteger numberOfSections = self.collectionView.numberOfSections;
	
	CGFloat tableWidth = self.collectionView.frame.size.width;
	
	id<DPZCouponLayoutDelegate> delegate = (id<DPZCouponLayoutDelegate>)self.collectionView.delegate;
	
	[self initializeArrays:numberOfSections];
	
	for (NSInteger sectionIndex = 0; sectionIndex < numberOfSections; sectionIndex++) {
		
		NSInteger itemCount = [self.collectionView numberOfItemsInSection:sectionIndex];
		NSMutableArray* itemAttributes = [[NSMutableArray alloc] initWithCapacity:itemCount];
		[_sectionItemAttributes addObject:itemAttributes];
		
		NSInteger columnCount = [delegate collectionView:self.collectionView layout:self columnsInSection:sectionIndex];
		
		CGFloat interItemSpacingX = [self interItemSpacingXInSection:sectionIndex];
		
		CGFloat interItemSpacingY = [self interItemSpacingYInSection:sectionIndex];
		
		UIEdgeInsets sectionInset = [self sectionInsetInSection:sectionIndex];
		
		CGFloat sectionWidth = tableWidth - sectionInset.left - sectionInset.right;
		CGFloat cellWidth = (sectionWidth - interItemSpacingX * (columnCount - 1 )) / columnCount;
		
		CGFloat previousSectionHeight = 0.f;
		if ( sectionIndex > 0 ) {
			previousSectionHeight = [_sectionHeights[sectionIndex-1] floatValue];
		}
		CGFloat startYOfSection = previousSectionHeight + sectionInset.top;
		
		CGFloat headerHeight = 0.f;
		if ( [self delegateImplmentsHeaderHeight] ) {
			headerHeight = [delegate collectionView:self.collectionView layout:self headerHeightInSection:sectionIndex];
		}
		
		if ( headerHeight > 0.f ) {
			UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:sectionIndex]];
			headerAttributes.frame = CGRectMake(sectionInset.right, startYOfSection, sectionWidth, headerHeight);
			[_sectionHeaderAttributes addObject:headerAttributes];
		} else {
			[_sectionHeaderAttributes addObject:[NSNull null]];
		}
		
		CGFloat startYOfCells = startYOfSection + headerHeight;
		
		NSMutableArray* columnHeights = [[NSMutableArray alloc] initWithCapacity:columnCount];
		for (NSInteger columnIndex = 0; columnIndex < columnCount; columnIndex++) {
			[columnHeights addObject:@(startYOfCells)];
		}
		
		for (NSInteger i = 0; i < itemCount; i++) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:sectionIndex];
			
			CGFloat cellHeight = [delegate collectionView:self.collectionView layout:self cellHeightAtIndexPath:indexPath];
			
			NSUInteger columnIndex = indexPath.item % columnCount;
			CGFloat xOffset = sectionInset.left + (cellWidth + interItemSpacingX) * columnIndex;
			CGFloat columnHeightInSection = [columnHeights[columnIndex] floatValue];
			
			CGFloat yOffset = (indexPath.item / columnCount) > 0 ? columnHeightInSection + interItemSpacingY : startYOfCells;
			
			UICollectionViewLayoutAttributes *attributes =
			[UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
			
			attributes.frame = CGRectMake(xOffset, yOffset, cellWidth, cellHeight);
			[itemAttributes addObject:attributes];
			columnHeights[columnIndex] = @(yOffset + cellHeight);
		}
		
		CGFloat endYOfCells = [self longestColumnHeight:columnHeights];
		
		CGFloat footerHeight = 0.f;
		if ( [self delegateImplmentsFooterHeight] ) {
			footerHeight = [delegate collectionView:self.collectionView layout:self footerHeightInSection:sectionIndex];
		}
		
		if ( footerHeight > 0 ) {
			UICollectionViewLayoutAttributes *footerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:sectionIndex]];
			footerAttributes.frame = CGRectMake(sectionInset.right, endYOfCells, sectionWidth, footerHeight);
			[_sectionFooterAttributes addObject:footerAttributes];
		} else {
			[_sectionFooterAttributes addObject:[NSNull null]];
		}
		
		CGFloat endYOfSection = endYOfCells + footerHeight;
			
		[_sectionHeights addObject:@(endYOfSection + sectionInset.bottom)];
	}
}

- (CGSize)collectionViewContentSize {
	CGSize contentSize = self.collectionView.frame.size;
	CGFloat height = 0.f;
	for ( NSNumber* sectionHeight in _sectionHeights) {
		height += [sectionHeight floatValue];
	}
	contentSize.height = height;
	return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path {
	return _sectionItemAttributes[path.section][path.item];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	
	UICollectionViewLayoutAttributes* attribute = nil;
	
	if ( kind == UICollectionElementKindSectionHeader ) {
		id headerAttribute = _sectionHeaderAttributes[indexPath.section];
		if ( headerAttribute != [NSNull null] ) {
			attribute = headerAttribute;
		}
	}
	
	if ( kind == UICollectionElementKindSectionFooter ) {
		id footerAttribute = _sectionFooterAttributes[indexPath.section];
		if ( footerAttribute != [NSNull null] ) {
			attribute = footerAttribute;
		}
	}
	
	return attribute;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	
	NSMutableArray *attrs = [NSMutableArray array];
	
	for ( id headerAttributes in _sectionHeaderAttributes ) {
		if ( headerAttributes != [NSNull null] && CGRectIntersectsRect(rect, [headerAttributes frame]))
		{
			[attrs addObject:headerAttributes];
		}
	}
	
	for ( NSMutableArray* sectionLayoutAttributes in _sectionItemAttributes ) {
		for ( UICollectionViewLayoutAttributes* attributes in sectionLayoutAttributes ) {
			if (CGRectIntersectsRect(rect, attributes.frame)) {
				[attrs addObject:attributes];
			}
		}
	}
	
	for ( id footerAttributes in _sectionFooterAttributes ) {
		if (footerAttributes != [NSNull null] &&  CGRectIntersectsRect(rect, [footerAttributes frame]))
		{
			[attrs addObject:footerAttributes];
		}
	}
	
	return [attrs copy];
}

-(CGFloat)longestColumnHeight:(NSArray*)columnHeights {
	__block CGFloat longestHeight = 0;
	
	[columnHeights enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
		CGFloat height = [obj floatValue];
		if (height > longestHeight) {
			longestHeight = height;
		}
	}];
	
	return longestHeight;
}

@end
