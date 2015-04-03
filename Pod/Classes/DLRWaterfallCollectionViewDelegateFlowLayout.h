//
//  DLRWaterfallCollectionViewDelegateFlowLayout.h
//  DLRWaterfallCollectionViewLayout
//
//  Created by Mark Schall on 4/3/15.
//  Copyright (c) 2015 Detroit Labs, LLC. All rights reserved.
//

typedef NS_ENUM(NSInteger, DLRWaterfallSortPattern) {
    DLRWaterfallSortPatternDefault,
    DLRWaterfallSortPatternInOrder,
    DLRWaterfallSortPatternShortestFirst = DLRWaterfallSortPatternDefault,
};

@protocol DLRWaterfallCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

@required
-(NSInteger)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
          columnsInSection:(NSInteger)section;

-(CGFloat)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
   cellHeightAtIndexPath:(NSIndexPath*)indexPath;

@optional
-(CGFloat)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
   headerHeightInSection:(NSInteger)sectionIndex;


-(CGFloat)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
   footerHeightInSection:(NSInteger)sectionIndex;

-(DLRWaterfallSortPattern)collectionView:(UICollectionView*)collectionView
                                  layout:(UICollectionViewLayout *)collectionViewLayout
                    sortPatternInSection:(NSInteger)section;

@end