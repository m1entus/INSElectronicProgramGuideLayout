//
//  INSElectronicProgramGuideLayout.h
//  INSElectronicProgramGuideLayout
//
//  Created by Michał Zaborowski on 29.09.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <UIKit/UIKit.h>
#import "NSDate+INSUtils.h"

extern NSString *const INSEPGLayoutElementKindSectionHeader;
extern NSString *const INSEPGLayoutElementKindHourHeader;
extern NSString *const INSEPGLayoutElementKindHalfHourHeader;

extern NSString *const INSEPGLayoutElementKindSectionHeaderBackground;
extern NSString *const INSEPGLayoutElementKindHourHeaderBackground;

extern NSString *const INSEPGLayoutElementKindCurrentTimeIndicator;
extern NSString *const INSEPGLayoutElementKindCurrentTimeIndicatorVerticalGridline;

extern NSString *const INSEPGLayoutElementKindVerticalGridline;
extern NSString *const INSEPGLayoutElementKindHalfHourVerticalGridline;
extern NSString *const INSEPGLayoutElementKindHorizontalGridline;

extern NSString *const INSEPGLayoutElementKindFloatingItemOverlay;

extern NSUInteger const INSEPGLayoutMinOverlayZ;
extern NSUInteger const INSEPGLayoutMinCellZ;
extern NSUInteger const INSEPGLayoutMinBackgroundZ;

@protocol INSElectronicProgramGuideLayoutDataSource;
@protocol INSElectronicProgramGuideLayoutDelegate;

typedef NS_ENUM(NSUInteger, INSElectronicProgramGuideLayoutType) {
    INSElectronicProgramGuideLayoutTypeTimeRowAboveDayColumn,
    INSElectronicProgramGuideLayoutTypeDayColumnAboveTimeRow
};

@interface INSElectronicProgramGuideLayout : UICollectionViewLayout
@property (nonatomic, assign) CGFloat sectionGap;
@property (nonatomic, assign) CGFloat sectionHeight;
@property (nonatomic, assign) CGFloat sectionHeaderWidth;

@property (nonatomic, assign) CGSize currentTimeIndicatorSize;
@property (nonatomic, assign) CGFloat currentTimeVerticalGridlineWidth;

@property (nonatomic, assign) CGFloat horizontalGridlineHeight;
@property (nonatomic, assign) CGFloat verticalGridlineWidth;

@property (nonatomic, assign) CGFloat hourWidth;
@property (nonatomic, assign) CGFloat hourHeaderHeight;

@property (nonatomic, assign) CGSize floatingItemOverlaySize;
@property (nonatomic, assign) CGFloat floatingItemOffsetFromSection;

@property (nonatomic, assign) UIEdgeInsets contentMargin;
@property (nonatomic, assign) UIEdgeInsets cellMargin;

@property (nonatomic, assign) INSElectronicProgramGuideLayoutType headerLayoutType;

@property (nonatomic, assign) BOOL shouldResizeStickyHeaders;
@property (nonatomic, assign) BOOL shouldUseFloatingItemOverlay;

@property (nonatomic, weak) id <INSElectronicProgramGuideLayoutDataSource> dataSource;
@property (nonatomic, weak) id <INSElectronicProgramGuideLayoutDelegate> delegate;

- (CGFloat)xCoordinateForDate:(NSDate *)date;
- (NSDate *)dateForXCoordinate:(CGFloat)position;

- (NSDate *)dateForHourHeaderAtIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)dateForHalfHourHeaderAtIndexPath:(NSIndexPath *)indexPath;

- (void)scrollToCurrentTimeAnimated:(BOOL)animated;

// Since a "reloadData" on the UICollectionView doesn't call "prepareForCollectionViewUpdates:", this method must be called first to flush the internal caches
- (void)invalidateLayoutCache;

@end


@protocol INSElectronicProgramGuideLayoutDataSource <UICollectionViewDataSource>
@required
- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(INSElectronicProgramGuideLayout *)electronicProgramGuideLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(INSElectronicProgramGuideLayout *)electronicProgramGuideLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSDate *)currentTimeForCollectionView:(UICollectionView *)collectionView layout:(INSElectronicProgramGuideLayout *)collectionViewLayout;
@end

@protocol INSElectronicProgramGuideLayoutDelegate <UICollectionViewDelegate>
@optional
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(INSElectronicProgramGuideLayout *)electronicProgramGuideLayout sizeForFloatingItemOverlayAtIndexPath:(NSIndexPath *)indexPath;
@end
