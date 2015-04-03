//
//  DPZCouponFlowLayout~iPad.h
//  Dominos
//
//  Created by Mark Schall on 12/9/13.
//  Copyright (c) 2013 Domino's Pizza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPZCouponLayout_iPad : UICollectionViewLayout

@end

@protocol DPZCouponLayoutDelegate <UICollectionViewDelegateFlowLayout>

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

@end