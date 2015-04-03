//
//  DLRViewController.m
//  DLRWaterfallLayout
//
//  Created by Mark Schall on 04/03/2015.
//  Copyright (c) 2014 Mark Schall. All rights reserved.
//

#import "DLRViewController.h"
#import <DLRWaterfallLayout/DLRWaterfallCollectionViewLayout.h>
#import <DLRWaterfallLayout/DLRWaterfallCollectionViewDelegateFlowLayout.h>

@interface DLRViewController () <DLRWaterfallCollectionViewDelegateFlowLayout>

@end

@implementation DLRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.collectionViewLayout = [[DLRWaterfallCollectionViewLayout alloc] init];
    self.collectionView.delegate = self;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 6;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return section * 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UILabel *label = (UILabel*)[cell viewWithTag:5];
    if ( label == nil ) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(5.f, 5.f, 100.f, 20.f)];
        label.tag = 5;
        label.numberOfLines = 0;
        [cell addSubview:label];
    }
    cell.backgroundColor = [UIColor colorWithRed:(arc4random()%256)/255.f green:(arc4random()%256)/255.f blue:(arc4random()%256)/255.f alpha:1.f];
    label.text = [NSString stringWithFormat:@"item #%ld", indexPath.item];
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
          columnsInSection:(NSInteger)section {
    return section;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
   cellHeightAtIndexPath:(NSIndexPath*)indexPath {
    return arc4random() % 40 + 30;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
   headerHeightInSection:(NSInteger)sectionIndex {
    return 20;
}


-(CGFloat)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
   footerHeightInSection:(NSInteger)sectionIndex {
    return 10;
}

-(DLRWaterfallSortPattern)collectionView:(UICollectionView*)collectionView
                                  layout:(UICollectionViewLayout *)collectionViewLayout
                    sortPatternInSection:(NSInteger)section {
    return section / 2;
}

@end
