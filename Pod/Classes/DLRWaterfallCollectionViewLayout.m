//
//  DLRWaterfallCollectionViewLayout.m
//  DLRWaterfallCollectionViewLayout
//
//  Created by Mark Schall on 4/3/15.
//  Copyright (c) 2015 Detroit Labs, LLC. All rights reserved.
//

#import "DLRWaterfallCollectionViewLayout.h"
#import "DLRWaterfallCollectionViewDelegateFlowLayout.h"

@interface DLRWaterfallCollectionViewLayout()
@property NSMutableArray* sectionHeaderAttributes;
@property NSMutableArray* sectionItemAttributes;
@property NSMutableArray* sectionFooterAttributes;
@property NSMutableArray* sectionHeights;
@end

@implementation DLRWaterfallCollectionViewLayout

#pragma mark - UICollectionViewLayout Methods
#pragma mark - Methods to Override
- (void)prepareLayout {
    [super prepareLayout];
    
    NSInteger numberOfSections = self.collectionView.numberOfSections;
    
    CGFloat tableWidth = self.collectionView.frame.size.width;
    
    [self initializeArrays:numberOfSections];
    
    for (NSInteger sectionIndex = 0; sectionIndex < numberOfSections; sectionIndex++) {
        
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:sectionIndex];
        NSMutableArray* itemAttributes = [[NSMutableArray alloc] initWithCapacity:itemCount];
        [_sectionItemAttributes addObject:itemAttributes];
        
        NSInteger columnCount = [self columnCountInSection:sectionIndex];
        
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
        
        CGFloat headerHeight = [self headerHeightInSection:sectionIndex];
        
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
            
            CGFloat cellHeight = [self cellHeightAtIndexPath:indexPath];
            
            NSUInteger columnIndex = [self nextColumnIndexForIndexPath:indexPath andColumnHeights:columnHeights];
            
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
            footerHeight = [self footerHeightInSection:sectionIndex];
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

#pragma mark - Helper Methods
- (id<DLRWaterfallCollectionViewDelegateFlowLayout>)delegate {
    return (id<DLRWaterfallCollectionViewDelegateFlowLayout>)self.collectionView.delegate;
}

-(BOOL)delegateImplmentsHeaderHeight {
    return [self.delegate respondsToSelector:@selector(collectionView:layout:headerHeightInSection:)];
}

-(BOOL)delegateImplmentsFooterHeight {
    return [self.delegate respondsToSelector:@selector(collectionView:layout:footerHeightInSection:)];
}

-(BOOL)delegateImplementsInterimSpacing {
    return [self.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)];
}

-(BOOL)delegateImplementsLineSpacing {
    return [self.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)];
}

-(BOOL)delegateImplementsInset {
    return [self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:) ];
}

-(BOOL)delegateImplementsSortPattern {
    return [self.delegate respondsToSelector:@selector(collectionView:layout:sortPatternInSection:) ];
}

- (void)initializeArrays:(NSInteger)numberOfSections {
    self.sectionHeaderAttributes = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
		
	self.sectionItemAttributes = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
	
	self.sectionFooterAttributes = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
		
	self.sectionHeights = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
}

-(NSInteger)columnCountInSection:(NSInteger)sectionIndex {
    return [self.delegate collectionView:self.collectionView layout:self columnsInSection:sectionIndex];
}

-(CGFloat)interItemSpacingXInSection:(NSInteger)sectionIndex {
	CGFloat interItemSpacingX = 0.f;
	if ( [self delegateImplementsInterimSpacing] ) {
		interItemSpacingX = [self.delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:sectionIndex];
	}
	
	return interItemSpacingX;
}

-(CGFloat)interItemSpacingYInSection:(NSInteger)sectionIndex {
	CGFloat interItemSpacingY = 0.f;
	if ( [self delegateImplementsLineSpacing] ) {
		interItemSpacingY = [self.delegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:sectionIndex];
	}
	
	return interItemSpacingY;
}

-(UIEdgeInsets)sectionInsetInSection:(NSInteger)sectionIndex {
	UIEdgeInsets sectionInset = UIEdgeInsetsZero;
	if ( [self delegateImplementsInset] ) {
		sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:sectionIndex];
	}
	
	return sectionInset;
}

-(CGFloat)headerHeightInSection:(NSInteger)sectionIndex {
    CGFloat headerHeight = 0.f;
    if ( [self delegateImplmentsHeaderHeight] ) {
        headerHeight = [self.delegate collectionView:self.collectionView layout:self headerHeightInSection:sectionIndex];
    }
    return headerHeight;
}

-(CGFloat)cellHeightAtIndexPath:(NSIndexPath*)indexPath {
    return [self.delegate collectionView:self.collectionView layout:self cellHeightAtIndexPath:indexPath];
}

-(CGFloat)footerHeightInSection:(NSInteger)sectionIndex {
    CGFloat footerHeight = 0.f;
    if ( [self delegateImplmentsFooterHeight] ) {
        footerHeight = [self.delegate collectionView:self.collectionView layout:self footerHeightInSection:sectionIndex];
    }
    return footerHeight;
}

-(DLRWaterfallSortPattern)sortPatternInSection:(NSInteger)sectionIndex {
    DLRWaterfallSortPattern sortPattern = DLRWaterfallSortPatternDefault;
    if ( [self delegateImplementsSortPattern] ) {
        sortPattern = [self.delegate collectionView:self.collectionView layout:self sortPatternInSection:sectionIndex];
    }
    return sortPattern;
}

-(NSInteger)nextColumnIndexForIndexPath:(NSIndexPath*)indexPath andColumnHeights:(NSArray*)columnHeights {
    DLRWaterfallSortPattern sortPattern = [self sortPatternInSection:indexPath.section];
    NSInteger columnIndex = 0;
    switch (sortPattern) {
        case DLRWaterfallSortPatternInOrder:
            columnIndex = indexPath.item % columnHeights.count;
            break;
        case DLRWaterfallSortPatternShortestFirst:
        default:
            columnIndex = [self shortestColumnIndex:columnHeights];
            break;
    }
    
    return columnIndex;
}

-(CGFloat)longestColumnHeight:(NSArray*)columnHeights {
    __block CGFloat longestHeight = CGFLOAT_MIN;
    
    [columnHeights enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height > longestHeight) {
            longestHeight = height;
        }
    }];
    
    return longestHeight;
}

-(NSInteger)shortestColumnIndex:(NSArray*)columnHeights {
    __block NSInteger shortestColumnIndex = 0;
    __block CGFloat shortestColumnHeight = CGFLOAT_MAX;
    
    [columnHeights enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height < shortestColumnHeight) {
            shortestColumnHeight = height;
            shortestColumnIndex = idx;
        }
    }];
    
    return shortestColumnIndex;
}

@end
