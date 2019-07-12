//
//  INSElectronicProgramGuideLayout.m
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

#import "INSElectronicProgramGuideLayout.h"
#import "INSTimerWeakTarget.h"

NSString *const INSEPGLayoutElementKindSectionHeader = @"INSEPGLayoutElementKindSectionHeader";
NSString *const INSEPGLayoutElementKindHourHeader = @"INSEPGLayoutElementKindHourHeader";
NSString *const INSEPGLayoutElementKindHalfHourHeader = @"INSEPGLayoutElementKindHalfHourHeader";
NSString *const INSEPGLayoutElementKindSectionHeaderBackground = @"INSEPGLayoutElementKindSectionHeaderBackground";
NSString *const INSEPGLayoutElementKindHourHeaderBackground = @"INSEPGLayoutElementKindHourHeaderBackground";
NSString *const INSEPGLayoutElementKindCurrentTimeIndicator = @"INSEPGLayoutElementKindCurrentTimeIndicator";
NSString *const INSEPGLayoutElementKindCurrentTimeIndicatorVerticalGridline = @"INSEPGLayoutElementKindCurrentTimeIndicatorVerticalGridline";
NSString *const INSEPGLayoutElementKindVerticalGridline = @"INSEPGLayoutElementKindVerticalGridline";
NSString *const INSEPGLayoutElementKindHalfHourVerticalGridline = @"INSEPGLayoutElementKindHalfHourVerticalGridline";
NSString *const INSEPGLayoutElementKindHorizontalGridline = @"INSEPGLayoutElementKindHorizontalGridline";
NSString *const INSEPGLayoutElementKindFloatingItemOverlay = @"INSEPGLayoutElementKindFloatingItemOverlay";

NSUInteger const INSEPGLayoutMinOverlayZ = 1000.0; // Allows for 900 items in a section without z overlap issues
NSUInteger const INSEPGLayoutMinCellZ = 100.0;  // Allows for 100 items in a section's background
NSUInteger const INSEPGLayoutMinBackgroundZ = 0.0;

@interface INSElectronicProgramGuideLayout ()
@property (nonatomic, strong) NSTimer *minuteTimer;
@property (nonatomic, readonly) CGFloat minuteWidth;

// Cache
@property (nonatomic, assign) BOOL needsToPopulateAttributesForAllSections;

@property (nonatomic, strong) NSDate *cachedEarliestDate;
@property (nonatomic, strong) NSDate *cachedLatestDate;
@property (nonatomic, strong) NSDate *cachedCurrentDate;

@property (nonatomic, strong) NSMutableDictionary *cachedFloatingItemsOverlaySize;

@property (nonatomic, strong) NSMutableDictionary *cachedEarliestDates;
@property (nonatomic, strong) NSMutableDictionary *cachedLatestDates;

@property (nonatomic, strong) NSCache *cachedHours;
@property (nonatomic, strong) NSCache *cachedHalfHours;

@property (nonatomic, strong) NSCache *cachedStartTimeDate;
@property (nonatomic, strong) NSCache *cachedEndTimeDate;
@property (nonatomic, assign) CGFloat cachedMaxSectionWidth;

// Registered Decoration Classes
@property (nonatomic, strong) NSMutableDictionary *registeredDecorationClasses;

// Attributes
@property (nonatomic, strong) NSMutableArray *allAttributes;
@property (nonatomic, strong) NSMutableDictionary *itemAttributes;
@property (nonatomic, strong) NSMutableDictionary *floatingItemAttributes;
@property (nonatomic, strong) NSMutableDictionary *sectionHeaderAttributes;
@property (nonatomic, strong) NSMutableDictionary *sectionHeaderBackgroundAttributes;
@property (nonatomic, strong) NSMutableDictionary *hourHeaderAttributes;
@property (nonatomic, strong) NSMutableDictionary *halfHourHeaderAttributes;
@property (nonatomic, strong) NSMutableDictionary *hourHeaderBackgroundAttributes;
@property (nonatomic, strong) NSMutableDictionary *horizontalGridlineAttributes;
@property (nonatomic, strong) NSMutableDictionary *verticalGridlineAttributes;
@property (nonatomic, strong) NSMutableDictionary *verticalHalfHourGridlineAttributes;
@property (nonatomic, strong) NSMutableDictionary *currentTimeIndicatorAttributes;
@property (nonatomic, strong) NSMutableDictionary *currentTimeVerticalGridlineAttributes;
@end

@implementation INSElectronicProgramGuideLayout

#pragma mark - <INSElectronicProgramGuideLayoutDataSource>

- (id <INSElectronicProgramGuideLayoutDataSource>)dataSource
{
    return (id <INSElectronicProgramGuideLayoutDataSource>)self.collectionView.dataSource;
}

- (void)setDataSource:(id<INSElectronicProgramGuideLayoutDataSource>)dataSource
{
    self.collectionView.dataSource = dataSource;
}

#pragma mark - <INSElectronicProgramGuideLayoutDelegate>

- (id <INSElectronicProgramGuideLayoutDelegate>)delegate
{
    return (id <INSElectronicProgramGuideLayoutDelegate>)self.collectionView.delegate;
}

- (void)setDelegate:(id<INSElectronicProgramGuideLayoutDelegate>)delegate
{
    self.collectionView.delegate = delegate;
}

#pragma mark - Getters

- (CGFloat)minuteWidth
{
    return self.hourWidth / 60.0;
}

#pragma mark - NSObject

- (void)dealloc
{
    [self invalidateLayoutCache];
    [self.minuteTimer invalidate];
    self.minuteTimer = nil;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.needsToPopulateAttributesForAllSections = YES;

    self.cachedStartTimeDate = [NSCache new];
    self.cachedEndTimeDate = [NSCache new];
    self.cachedHours = [NSCache new];
    self.cachedHalfHours = [NSCache new];
    self.cachedMaxSectionWidth = CGFLOAT_MIN;
    self.cachedFloatingItemsOverlaySize = [NSMutableDictionary new];

    self.registeredDecorationClasses = [NSMutableDictionary new];

    self.allAttributes = [NSMutableArray new];
    self.itemAttributes = [NSMutableDictionary new];
    self.floatingItemAttributes = [NSMutableDictionary new];
    self.sectionHeaderAttributes = [NSMutableDictionary new];
    self.sectionHeaderBackgroundAttributes = [NSMutableDictionary new];
    self.hourHeaderAttributes = [NSMutableDictionary new];
    self.halfHourHeaderAttributes = [NSMutableDictionary new];
    self.hourHeaderBackgroundAttributes = [NSMutableDictionary new];
    self.verticalGridlineAttributes = [NSMutableDictionary new];
    self.horizontalGridlineAttributes = [NSMutableDictionary new];
    self.currentTimeIndicatorAttributes = [NSMutableDictionary new];
    self.currentTimeVerticalGridlineAttributes = [NSMutableDictionary new];
    self.verticalHalfHourGridlineAttributes = [NSMutableDictionary new];

    self.shouldUseFloatingItemOverlay = YES;
    self.contentMargin = UIEdgeInsetsMake(0, 0, 0, 0);
    self.cellMargin = UIEdgeInsetsMake(0, 0, 0, 10);
    self.sectionHeight = 60;
    self.sectionHeaderWidth = 100;
    self.hourHeaderHeight = 50;
    self.hourWidth = 600;
    self.currentTimeIndicatorSize = CGSizeMake(self.sectionHeaderWidth, 10.0);
    self.currentTimeVerticalGridlineWidth = 1.0;
    self.verticalGridlineWidth = (([[UIScreen mainScreen] scale] == 2.0) ? 0.5 : 1.0);
    self.horizontalGridlineHeight = (([[UIScreen mainScreen] scale] == 2.0) ? 0.5 : 1.0);
    self.sectionGap = 10;
    self.floatingItemOverlaySize = CGSizeMake(0, self.sectionHeight);
    self.floatingItemOffsetFromSection = 10.0;
    self.shouldResizeStickyHeaders = NO;

    // Set CurrentTime Behind cell
    self.currentTimeIndicatorShouldBeBehind = YES;

    self.headerLayoutType = INSElectronicProgramGuideLayoutTypeTimeRowAboveDayColumn;

    // Invalidate layout on minute ticks (to update the position of the current time indicator)
    NSDate *oneMinuteInFuture = [[NSDate date] dateByAddingTimeInterval:60];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:oneMinuteInFuture];
    NSDate *nextMinuteBoundary = [[NSCalendar currentCalendar] dateFromComponents:components];

    // This needs to be a weak reference, otherwise we get a retain cycle
    INSTimerWeakTarget *timerWeakTarget = [[INSTimerWeakTarget alloc] initWithTarget:self selector:@selector(minuteTick:)];
    self.minuteTimer = [[NSTimer alloc] initWithFireDate:nextMinuteBoundary interval:60 target:timerWeakTarget selector:timerWeakTarget.fireSelector userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.minuteTimer forMode:NSDefaultRunLoopMode];
}

#pragma mark - Public

- (NSDate *)dateForHourHeaderAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.cachedHours objectForKey:indexPath];
}

- (NSDate *)dateForHalfHourHeaderAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.cachedHalfHours objectForKey:indexPath];
}

- (void)scrollToCurrentTimeAnimated:(BOOL)animated
{
    if (self.collectionView.numberOfSections > 0) {
        CGRect currentTimeHorizontalGridlineattributesFrame = [self.currentTimeVerticalGridlineAttributes[[NSIndexPath indexPathForItem:0 inSection:0]] frame];
        CGFloat xOffset;
        if (!CGRectEqualToRect(currentTimeHorizontalGridlineattributesFrame, CGRectZero)) {
            xOffset = nearbyintf(CGRectGetMinX(currentTimeHorizontalGridlineattributesFrame) - (CGRectGetWidth(self.collectionView.frame) / 2.0));
        } else {
            xOffset = 0.0;
        }
        CGPoint contentOffset = CGPointMake(xOffset, self.collectionView.contentOffset.y - self.collectionView.contentInset.top);

        // Prevent the content offset from forcing the scroll view content off its bounds
        if (contentOffset.y > (self.collectionView.contentSize.height - self.collectionView.frame.size.height)) {
            contentOffset.y = (self.collectionView.contentSize.height - self.collectionView.frame.size.height);
        }
        if (contentOffset.y < -self.collectionView.contentInset.top) {
            contentOffset.y = -self.collectionView.contentInset.top;
        }
        if (contentOffset.x > (self.collectionView.contentSize.width - self.collectionView.frame.size.width)) {
            contentOffset.x = (self.collectionView.contentSize.width - self.collectionView.frame.size.width);
        }
        if (contentOffset.x < 0.0) {
            contentOffset.x = 0.0;
        }

        [self.collectionView setContentOffset:contentOffset animated:animated];
    }
}

- (void)invalidateLayoutCache
{
    self.needsToPopulateAttributesForAllSections = YES;

    // Invalidate cached Components
    self.cachedEarliestDate = nil;
    self.cachedLatestDate = nil;
    self.cachedCurrentDate = nil;

    [self.cachedEarliestDates removeAllObjects];
    [self.cachedLatestDates removeAllObjects];

    [self.cachedFloatingItemsOverlaySize removeAllObjects];

    [self.cachedHours removeAllObjects];
    [self.cachedHalfHours removeAllObjects];

    [self.cachedStartTimeDate removeAllObjects];
    [self.cachedEndTimeDate removeAllObjects];
    self.cachedMaxSectionWidth = CGFLOAT_MIN;

    [self.verticalGridlineAttributes removeAllObjects];
    [self.itemAttributes removeAllObjects];
    [self.floatingItemAttributes removeAllObjects];
    [self.sectionHeaderAttributes removeAllObjects];
    [self.sectionHeaderBackgroundAttributes removeAllObjects];
    [self.hourHeaderAttributes removeAllObjects];
    [self.halfHourHeaderAttributes removeAllObjects];
    [self.hourHeaderBackgroundAttributes removeAllObjects];
    [self.horizontalGridlineAttributes removeAllObjects];
    [self.currentTimeIndicatorAttributes removeAllObjects];
    [self.currentTimeVerticalGridlineAttributes removeAllObjects];
    [self.verticalHalfHourGridlineAttributes removeAllObjects];
    [self.allAttributes removeAllObjects];
}


#pragma mark Minute Updates

- (void)minuteTick:(id)sender
{
    // Invalidate cached current date componets (since the minute's changed!)
    self.cachedCurrentDate = nil;
    [self invalidateLayout];
}

#pragma mark - UICollectionViewLayout


- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewAtIndexPath:(NSIndexPath *)indexPath ofKind:(NSString *)kind withItemCache:(NSMutableDictionary *)itemCache
{
    NSIndexPath *indexPathKey = [self keyForIndexPath:indexPath];
    UICollectionViewLayoutAttributes *layoutAttributes;
    if (self.registeredDecorationClasses[kind] && !(layoutAttributes = itemCache[indexPathKey])) {
        layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kind withIndexPath:indexPathKey];
        itemCache[indexPathKey] = layoutAttributes;
    }
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath ofKind:(NSString *)kind withItemCache:(NSMutableDictionary *)itemCache
{
    NSIndexPath *indexPathKey = [self keyForIndexPath:indexPath];
    UICollectionViewLayoutAttributes *layoutAttributes;
    if (!(layoutAttributes = itemCache[indexPathKey])) {
        layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPathKey];
        itemCache[indexPathKey] = layoutAttributes;
    }
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForCellAtIndexPath:(NSIndexPath *)indexPath withItemCache:(NSMutableDictionary *)itemCache
{
    NSIndexPath *indexPathKey = [self keyForIndexPath:indexPath];
    UICollectionViewLayoutAttributes *layoutAttributes;
    if (!(layoutAttributes = itemCache[indexPathKey])) {
        layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPathKey];
        itemCache[indexPathKey] = layoutAttributes;
    }
    return layoutAttributes;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [self invalidateLayoutCache];

    // Update the layout with the new items
    [self prepareLayout];

    [super prepareForCollectionViewUpdates:updateItems];
}

- (void)finalizeCollectionViewUpdates
{
    // This is a hack to prevent the error detailed in :
    // http://stackoverflow.com/questions/12857301/uicollectionview-decoration-and-supplementary-views-can-not-be-moved
    // If this doesn't happen, whenever the collection view has batch updates performed on it, we get multiple instantiations of decoration classes
    for (UIView *subview in self.collectionView.subviews) {
        for (Class decorationViewClass in self.registeredDecorationClasses.allValues) {
            if ([subview isKindOfClass:decorationViewClass]) {
                [subview removeFromSuperview];
            }
        }
    }
    [self.collectionView reloadData];
}

- (void)registerClass:(Class)viewClass forDecorationViewOfKind:(NSString *)decorationViewKind
{
    [super registerClass:viewClass forDecorationViewOfKind:decorationViewKind];
    self.registeredDecorationClasses[decorationViewKind] = viewClass;
}

- (void)registerNib:(UINib *)nib forDecorationViewOfKind:(NSString *)elementKind
{
    [super registerNib:nib forDecorationViewOfKind:elementKind];

    NSArray *topLevelObjects = [nib instantiateWithOwner:nil options:nil];

    NSAssert(topLevelObjects.count == 1 && [[topLevelObjects firstObject] isKindOfClass:UICollectionReusableView.class], @"must contain exactly 1 top level object which is a UICollectionReusableView");

    self.registeredDecorationClasses[elementKind] = [[topLevelObjects firstObject] class];
}

- (void)prepareLayout
{
    [super prepareLayout];

    if (self.needsToPopulateAttributesForAllSections) {
        [self prepareSectionLayoutForSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collectionView.numberOfSections)]];
        self.needsToPopulateAttributesForAllSections = NO;
    }

    BOOL needsToPopulateAllAttribtues = (self.allAttributes.count == 0);
    if (needsToPopulateAllAttribtues) {
        [self.allAttributes addObjectsFromArray:[self.itemAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.sectionHeaderAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.sectionHeaderBackgroundAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.hourHeaderBackgroundAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.hourHeaderAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.halfHourHeaderAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.verticalGridlineAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.horizontalGridlineAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.currentTimeIndicatorAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.verticalHalfHourGridlineAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.currentTimeVerticalGridlineAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.floatingItemAttributes allValues]];
    }
}

#pragma mark - Preparing Layout Helpers

- (CGFloat)maximumSectionWidth
{
    if (self.cachedMaxSectionWidth != CGFLOAT_MIN) {
        return self.cachedMaxSectionWidth;
    }

    CGFloat maxSectionWidth = self.sectionHeaderWidth + ([self latestDate].timeIntervalSince1970 - [self earliestDate].timeIntervalSince1970) / 60.0 * self.minuteWidth + self.contentMargin.left + self.contentMargin.right;

    self.cachedMaxSectionWidth = maxSectionWidth;

    return maxSectionWidth;
}

- (CGFloat)xCoordinateForDate:(NSDate *)date
{
    return nearbyintf(self.collectionViewContentSize.width - ((fabs([self latestDate].timeIntervalSince1970 - date.timeIntervalSince1970)) / 60 * self.minuteWidth) - self.contentMargin.right);
}

- (NSDate *)dateForXCoordinate:(CGFloat)position
{
    if (position > self.collectionViewContentSize.width || position < 0) {
        return nil;
    }

    NSDate *earliestDate = [self earliestDate];

    CGFloat timeInSeconds = position / self.minuteWidth * 60;
    return [earliestDate dateByAddingTimeInterval:timeInSeconds];
}

- (CGFloat)minimumGridX
{
    return self.sectionHeaderWidth + self.contentMargin.left;
}

- (CGFloat)minimumGridY
{
    return self.hourHeaderHeight + self.contentMargin.top + self.collectionView.contentInset.top;
}

#pragma mark - Preparing Layout

- (void)prepareSectionLayoutForSections:(NSIndexSet *)sectionIndexes
{
    if (self.collectionView.numberOfSections == 0) {
        return;
    }

    BOOL needsToPopulateItemAttributes = (self.itemAttributes.count == 0);
    BOOL needsToPopulateHorizontalGridlineAttributes = (self.horizontalGridlineAttributes.count == 0);

    [self prepareSectionHeaderBackgroundAttributes];
    [self prepareHourHeaderBackgroundAttributes];

    [self prepareCurrentIndicatorAttributes];

    [self prepareVerticalGridlineAttributes];

    [sectionIndexes enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
        [self prepareSectionAttributes:section needsToPopulateItemAttributes:needsToPopulateItemAttributes];

        if (needsToPopulateHorizontalGridlineAttributes) {
            [self prepareHorizontalGridlineAttributesForSection:section];
        }
    }];
}

- (void)prepareFloatingItemAttributesOverlayForSection:(NSUInteger)section sectionFrame:(CGRect)rect
{
    CGFloat floatingGridMinX = fmaxf(self.collectionView.contentOffset.x, 0.0) + self.sectionHeaderWidth + self.floatingItemOffsetFromSection;

    for (NSUInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {

        NSIndexPath *floatingItemIndexPath = [NSIndexPath indexPathForRow:item inSection:section];
        
        NSDate *itemEndTime = [self endDateForIndexPath:floatingItemIndexPath];
        
        if ([itemEndTime ins_isLaterThan:[self latestDate]] || [itemEndTime ins_isEarlierThan:[self earliestDate]]) {
            continue;
        }
        
        UICollectionViewLayoutAttributes *itemAttributes = [self.itemAttributes objectForKey:floatingItemIndexPath];
        CGRect itemAttributesFrame = itemAttributes.frame;
        itemAttributesFrame.origin.y -= self.cellMargin.top;

        UICollectionViewLayoutAttributes *floatingItemAttributes = [self layoutAttributesForSupplementaryViewAtIndexPath:floatingItemIndexPath ofKind:INSEPGLayoutElementKindFloatingItemOverlay withItemCache:self.floatingItemAttributes];

        CGSize floatingItemSize = [self floatingItemOverlaySizeForIndexPath:floatingItemIndexPath];

        if (floatingItemSize.width >= itemAttributesFrame.size.width) {
            floatingItemAttributes.frame = itemAttributesFrame;
        } else {
            // Items on the right side of sections
            if (itemAttributesFrame.origin.x >= floatingGridMinX) {
                floatingItemAttributes.frame = (CGRect){ itemAttributesFrame.origin, floatingItemSize };
            } else {
                CGFloat floatingSpace = itemAttributesFrame.size.width - floatingItemSize.width;

                floatingItemAttributes.frame = (CGRect){ {itemAttributesFrame.origin.x + floatingSpace, itemAttributesFrame.origin.y} , floatingItemSize};

                //Floating
                if (floatingGridMinX <= floatingItemAttributes.frame.origin.x && floatingGridMinX >= itemAttributesFrame.origin.x) {
                    floatingItemAttributes.frame = (CGRect){ {floatingGridMinX, floatingItemAttributes.frame.origin.y} , floatingItemSize};
                }

            }
        }
        floatingItemAttributes.zIndex = [self zIndexForElementKind:INSEPGLayoutElementKindFloatingItemOverlay floating:YES];
    }
}

- (void)prepareItemAttributesForSection:(NSUInteger)section sectionFrame:(CGRect)rect
{
    for (NSUInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
        NSIndexPath *itemIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        
        NSDate *itemEndTime = [self endDateForIndexPath:itemIndexPath];
        
        if ([itemEndTime ins_isLaterThan:[self latestDate]] || [itemEndTime ins_isEarlierThan:[self earliestDate]]) {
            continue;
        }
        
        NSDate *itemStartTime = [self startDateForIndexPath:itemIndexPath];
        
        CGFloat itemStartTimePositionX = [self xCoordinateForDate:itemStartTime];
        CGFloat itemEndTimePositionX = [self xCoordinateForDate:itemEndTime];
        CGFloat itemWidth = itemEndTimePositionX - itemStartTimePositionX;
        
        UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForCellAtIndexPath:itemIndexPath withItemCache:self.itemAttributes];
        itemAttributes.frame = CGRectMake(itemStartTimePositionX + self.cellMargin.left, rect.origin.y + self.cellMargin.top, itemWidth - self.cellMargin.left - self.cellMargin.right, rect.size.height - self.cellMargin.top - self.cellMargin.bottom);
        itemAttributes.zIndex = [self zIndexForElementKind:nil];

    }
}

- (void)prepareSectionAttributes:(NSUInteger)section needsToPopulateItemAttributes:(BOOL)needsToPopulateItemAttributes
{
    CGFloat sectionMinY = self.hourHeaderHeight + self.contentMargin.top;

    CGFloat sectionMinX = self.shouldResizeStickyHeaders ? fmaxf(self.collectionView.contentOffset.x, 0.0) : self.collectionView.contentOffset.x;

    CGFloat sectionY = sectionMinY + ((self.sectionHeight + self.sectionGap) * section);
    NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    UICollectionViewLayoutAttributes *sectionAttributes = [self layoutAttributesForSupplementaryViewAtIndexPath:sectionIndexPath ofKind:INSEPGLayoutElementKindSectionHeader withItemCache:self.sectionHeaderAttributes];
    sectionAttributes.frame = CGRectMake(sectionMinX, sectionY, self.sectionHeaderWidth, self.sectionHeight);
    sectionAttributes.zIndex = [self zIndexForElementKind:INSEPGLayoutElementKindSectionHeader floating:YES];

    if (needsToPopulateItemAttributes) {
        [self prepareItemAttributesForSection:section sectionFrame:sectionAttributes.frame];
    }
    if (self.shouldUseFloatingItemOverlay) {
        [self prepareFloatingItemAttributesOverlayForSection:section sectionFrame:sectionAttributes.frame];
    }
}

- (void)prepareHorizontalGridlineAttributesForSection:(NSUInteger)section
{
    CGFloat gridMinY = self.hourHeaderHeight + self.contentMargin.top;
    CGFloat gridWidth = self.collectionViewContentSize.width - self.contentMargin.right;

    CGFloat horizontalGridlineMinX = (fmaxf(self.collectionView.contentOffset.x, 0.0) - self.collectionView.frame.size.width + self.sectionHeaderWidth);

    CGFloat horizontalGridlineMinY = gridMinY + ((self.sectionHeight + self.sectionGap) * section) - nearbyintf(self.sectionGap/2);

    if (section <= 0) {
        return;
    }

    horizontalGridlineMinY -= self.horizontalGridlineHeight/2;

    NSIndexPath *horizontalGridlineIndexPath = [NSIndexPath indexPathForItem:section inSection:0];
    UICollectionViewLayoutAttributes *horizontalGridlineAttributes = [self layoutAttributesForDecorationViewAtIndexPath:horizontalGridlineIndexPath ofKind:INSEPGLayoutElementKindHorizontalGridline withItemCache:self.horizontalGridlineAttributes];
    horizontalGridlineAttributes.frame = CGRectMake(horizontalGridlineMinX, horizontalGridlineMinY, gridWidth + fabs(horizontalGridlineMinX), self.horizontalGridlineHeight);
    horizontalGridlineAttributes.zIndex = [self zIndexForElementKind:INSEPGLayoutElementKindHorizontalGridline];
}

- (void)prepareVerticalGridlineAttributes
{
    CGFloat gridMinX = [self minimumGridX];
    CGFloat gridMaxWidth = [self maximumSectionWidth] - gridMinX;
    CGFloat hourWidth = [self hourWidth];

    CGFloat hourMinY = (self.shouldResizeStickyHeaders ? fmaxf(self.collectionView.contentOffset.y + self.collectionView.contentInset.top, 0.0) : self.collectionView.contentOffset.y + self.collectionView.contentInset.top);

    CGFloat currentTimeVerticalGridlineMinY = (self.shouldResizeStickyHeaders ? fmaxf(self.hourHeaderHeight, self.collectionView.contentOffset.y + [self minimumGridY]) : self.collectionView.contentOffset.y + [self minimumGridY] - self.contentMargin.top);
    CGFloat gridHeight = self.collectionViewContentSize.height - currentTimeVerticalGridlineMinY - self.contentMargin.bottom + self.collectionView.contentOffset.y;

    NSDate *startDate = [[self earliestDate] ins_dateWithoutMinutesAndSeconds];
    CGFloat startDatePosition = [self xCoordinateForDate:startDate];

    NSUInteger verticalGridlineIndex = 0;
    for (CGFloat hourX = startDatePosition; hourX <= gridMaxWidth; hourX += hourWidth) {
        NSIndexPath *verticalGridlineIndexPath = [NSIndexPath indexPathForItem:verticalGridlineIndex inSection:0];
        UICollectionViewLayoutAttributes *verticalGridlineAttributes = [self layoutAttributesForDecorationViewAtIndexPath:verticalGridlineIndexPath ofKind:INSEPGLayoutElementKindVerticalGridline withItemCache:self.verticalGridlineAttributes];

        verticalGridlineAttributes.frame = CGRectMake(hourX, currentTimeVerticalGridlineMinY, self.verticalGridlineWidth, gridHeight);
        verticalGridlineAttributes.zIndex = [self zIndexForElementKind:INSEPGLayoutElementKindVerticalGridline];

        NSIndexPath *hourHeaderIndexPath = [NSIndexPath indexPathForItem:verticalGridlineIndex inSection:0];

        CGFloat hourTimeInterval = 3600;
        if (![self.cachedHours objectForKey:hourHeaderIndexPath]) {
            [self.cachedHours setObject:[startDate dateByAddingTimeInterval: hourTimeInterval * verticalGridlineIndex] forKey:hourHeaderIndexPath];
        }

        UICollectionViewLayoutAttributes *hourHeaderAttributes = [self layoutAttributesForSupplementaryViewAtIndexPath:hourHeaderIndexPath ofKind:INSEPGLayoutElementKindHourHeader withItemCache:self.hourHeaderAttributes];
        CGFloat hourHeaderMinX = hourX - nearbyintf(self.hourWidth / 2.0);

        hourHeaderAttributes.frame = (CGRect){ {hourHeaderMinX, hourMinY}, {self.hourWidth, self.hourHeaderHeight} };
        hourHeaderAttributes.zIndex = [self zIndexForElementKind:INSEPGLayoutElementKindHourHeader floating:YES];

        verticalGridlineIndex++;
    }

    NSInteger verticalHalfHourGridlineIndex = 0;
    for (CGFloat halfHourX = startDatePosition + hourWidth/2; halfHourX <= gridMaxWidth + hourWidth/2; halfHourX += hourWidth) {
        NSIndexPath *verticalHalfHourGridlineIndexPath = [NSIndexPath indexPathForItem:verticalHalfHourGridlineIndex inSection:0];
        UICollectionViewLayoutAttributes *verticalHalfHourGridlineAttributes = [self layoutAttributesForDecorationViewAtIndexPath:verticalHalfHourGridlineIndexPath ofKind:INSEPGLayoutElementKindHalfHourVerticalGridline withItemCache:self.verticalHalfHourGridlineAttributes];

        verticalHalfHourGridlineAttributes.frame = CGRectMake(halfHourX, currentTimeVerticalGridlineMinY, self.verticalGridlineWidth, gridHeight);
        verticalHalfHourGridlineAttributes.zIndex = [self zIndexForElementKind:INSEPGLayoutElementKindHalfHourVerticalGridline];

        NSIndexPath *halfHourHeaderIndexPath = [NSIndexPath indexPathForItem:verticalHalfHourGridlineIndex inSection:0];

        CGFloat hourTimeInterval = 3600;
        if (![self.cachedHalfHours objectForKey:halfHourHeaderIndexPath]) {
            [self.cachedHalfHours setObject:[startDate dateByAddingTimeInterval:hourTimeInterval * verticalHalfHourGridlineIndex + hourTimeInterval/2] forKey:halfHourHeaderIndexPath];
        }

        UICollectionViewLayoutAttributes *halfHourHeaderAttributes = [self layoutAttributesForSupplementaryViewAtIndexPath:halfHourHeaderIndexPath ofKind:INSEPGLayoutElementKindHalfHourHeader withItemCache:self.halfHourHeaderAttributes];
        CGFloat hourHeaderMinX = halfHourX - nearbyintf(self.hourWidth / 2.0);
        halfHourHeaderAttributes.frame = (CGRect){ {hourHeaderMinX, hourMinY}, {self.hourWidth, self.hourHeaderHeight} };
        halfHourHeaderAttributes.zIndex = [self zIndexForElementKind:INSEPGLayoutElementKindHalfHourHeader floating:YES];

        verticalHalfHourGridlineIndex++;
    }
}

- (void)prepareCurrentIndicatorAttributes
{
    NSIndexPath *currentTimeIndicatorIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UICollectionViewLayoutAttributes *currentTimeIndicatorAttributes = [self layoutAttributesForDecorationViewAtIndexPath:currentTimeIndicatorIndexPath ofKind:INSEPGLayoutElementKindCurrentTimeIndicator withItemCache:self.currentTimeIndicatorAttributes];

    NSIndexPath *currentTimeHorizontalGridlineIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UICollectionViewLayoutAttributes *currentTimeHorizontalGridlineAttributes = [self layoutAttributesForDecorationViewAtIndexPath:currentTimeHorizontalGridlineIndexPath ofKind:INSEPGLayoutElementKindCurrentTimeIndicatorVerticalGridline withItemCache:self.currentTimeVerticalGridlineAttributes];

    NSDate *currentDate = [self currentDate];
    BOOL currentTimeIndicatorVisible = ([currentDate ins_isLaterThanOrEqualTo:[self earliestDate]] && [currentDate ins_isEarlierThan:[self latestDate]]);
    currentTimeIndicatorAttributes.hidden = !currentTimeIndicatorVisible;
    currentTimeHorizontalGridlineAttributes.hidden = !currentTimeIndicatorVisible;

    if (currentTimeIndicatorVisible) {

        CGFloat xPositionToCurrentDate = [self xCoordinateForDate:currentDate];

        CGFloat currentTimeIndicatorMinX = xPositionToCurrentDate - nearbyintf(self.currentTimeIndicatorSize.width / 2.0);
        CGFloat currentTimeIndicatorMinY = ( self.shouldResizeStickyHeaders ? fmaxf(self.collectionView.contentOffset.y, 0.0) : self.collectionView.contentOffset.y + (self.hourHeaderHeight - self.currentTimeIndicatorSize.height)) + self.collectionView.contentInset.top;
        currentTimeIndicatorAttributes.frame = (CGRect){ {currentTimeIndicatorMinX, currentTimeIndicatorMinY}, self.currentTimeIndicatorSize };
        currentTimeIndicatorAttributes.zIndex = [self zIndexForElementKind:INSEPGLayoutElementKindCurrentTimeIndicator floating:YES];

        CGFloat currentTimeVerticalGridlineMinY = (self.shouldResizeStickyHeaders ? fmaxf(self.hourHeaderHeight, self.collectionView.contentOffset.y + [self minimumGridY]) : self.collectionView.contentOffset.y + [self minimumGridY]);

        CGFloat gridHeight = (self.collectionViewContentSize.height + currentTimeVerticalGridlineMinY);

        currentTimeHorizontalGridlineAttributes.frame = (CGRect){ {xPositionToCurrentDate - self.currentTimeVerticalGridlineWidth/2, currentTimeVerticalGridlineMinY}, {self.currentTimeVerticalGridlineWidth, gridHeight} };
        currentTimeHorizontalGridlineAttributes.zIndex = [self zIndexForElementKind:INSEPGLayoutElementKindCurrentTimeIndicatorVerticalGridline];
    }
}

- (void)prepareSectionHeaderBackgroundAttributes
{
    CGFloat sectionHeaderMinX = self.shouldResizeStickyHeaders ? fmaxf(self.collectionView.contentOffset.x, 0.0) : self.collectionView.contentOffset.x;

    NSIndexPath *sectionHeaderBackgroundIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UICollectionViewLayoutAttributes *sectionHeaderBackgroundAttributes = [self layoutAttributesForDecorationViewAtIndexPath:sectionHeaderBackgroundIndexPath ofKind:INSEPGLayoutElementKindSectionHeaderBackground withItemCache:self.sectionHeaderBackgroundAttributes];

    CGFloat sectionHeaderBackgroundHeight = self.collectionView.frame.size.height - self.collectionView.contentInset.top;
    CGFloat sectionHeaderBackgroundWidth = self.collectionView.frame.size.width;
    CGFloat sectionHeaderBackgroundMinX = (sectionHeaderMinX - sectionHeaderBackgroundWidth + self.sectionHeaderWidth);

    CGFloat sectionHeaderBackgroundMinY = self.collectionView.contentOffset.y + self.collectionView.contentInset.top;
    sectionHeaderBackgroundAttributes.frame = CGRectMake(sectionHeaderBackgroundMinX, sectionHeaderBackgroundMinY, sectionHeaderBackgroundWidth, sectionHeaderBackgroundHeight);

    sectionHeaderBackgroundAttributes.hidden = NO;
    sectionHeaderBackgroundAttributes.zIndex = [self zIndexForElementKind:INSEPGLayoutElementKindSectionHeaderBackground floating:YES];
}

- (void)prepareHourHeaderBackgroundAttributes
{
    NSIndexPath *hourHeaderBackgroundIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UICollectionViewLayoutAttributes *hourHeaderBackgroundAttributes = [self layoutAttributesForDecorationViewAtIndexPath:hourHeaderBackgroundIndexPath ofKind:INSEPGLayoutElementKindHourHeaderBackground withItemCache:self.hourHeaderBackgroundAttributes];
    // Frame
    CGFloat hourHeaderBackgroundHeight = (self.hourHeaderHeight + ((self.collectionView.contentOffset.y < 0.0) ? fabs(self.collectionView.contentOffset.y) : 0.0)) - self.collectionView.contentInset.top;

    if (!self.shouldResizeStickyHeaders || self.hourHeaderHeight >= hourHeaderBackgroundHeight) {
        hourHeaderBackgroundHeight = self.hourHeaderHeight;
    }

    hourHeaderBackgroundAttributes.frame = (CGRect){{self.collectionView.contentOffset.x, self.collectionView.contentOffset.y + self.collectionView.contentInset.top}, {self.collectionView.frame.size.width, hourHeaderBackgroundHeight}};

    hourHeaderBackgroundAttributes.hidden = NO;
    hourHeaderBackgroundAttributes.zIndex = [self zIndexForElementKind:INSEPGLayoutElementKindHourHeaderBackground floating:YES];
}

#pragma mark - Layout


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *indexPathKey = [self keyForIndexPath:indexPath];
    return self.itemAttributes[indexPathKey];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *indexPathKey = [self keyForIndexPath:indexPath];

    if (kind == INSEPGLayoutElementKindSectionHeader) {
        return self.sectionHeaderAttributes[indexPathKey];

    }else if (kind == INSEPGLayoutElementKindHourHeader) {
        return self.hourHeaderAttributes[indexPathKey];

    } else if (kind == INSEPGLayoutElementKindHalfHourHeader) {
        return self.halfHourHeaderAttributes[indexPathKey];

    } else if (kind == INSEPGLayoutElementKindFloatingItemOverlay) {
        return self.floatingItemAttributes[indexPathKey];
    }

    return nil;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *indexPathKey = [self keyForIndexPath:indexPath];

    if (decorationViewKind == INSEPGLayoutElementKindCurrentTimeIndicator) {
        return self.currentTimeIndicatorAttributes[indexPathKey];
    }
    else if (decorationViewKind == INSEPGLayoutElementKindCurrentTimeIndicatorVerticalGridline) {
        return self.currentTimeVerticalGridlineAttributes[indexPathKey];
    }
    else if (decorationViewKind == INSEPGLayoutElementKindVerticalGridline) {
        return self.verticalGridlineAttributes[indexPathKey];
    }
    else if (decorationViewKind == INSEPGLayoutElementKindHorizontalGridline) {
        return self.horizontalGridlineAttributes[indexPathKey];
    }
    else if (decorationViewKind == INSEPGLayoutElementKindHourHeaderBackground) {
        return self.hourHeaderBackgroundAttributes[indexPathKey];
    }
    else if (decorationViewKind == INSEPGLayoutElementKindSectionHeaderBackground) {
        return self.hourHeaderBackgroundAttributes[indexPathKey];

    } else if (decorationViewKind == INSEPGLayoutElementKindHalfHourVerticalGridline) {
        return self.verticalHalfHourGridlineAttributes[indexPathKey];
    }
    return nil;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableIndexSet *visibleSections = [NSMutableIndexSet indexSet];
    [[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collectionView.numberOfSections)] enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
        CGRect sectionRect = [self rectForSection:section];
        if (CGRectIntersectsRect(sectionRect, rect)) {
            [visibleSections addIndex:section];
        }
    }];

    // Update layout for only the visible sections
    [self prepareSectionLayoutForSections:visibleSections];

    // Return the visible attributes (rect intersection)
    return [self.allAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *layoutAttributes, NSDictionary *bindings) {
        return CGRectIntersectsRect(layoutAttributes.frame,rect);
    }]];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    // Required for sticky headers
    return YES;
}

- (CGSize)collectionViewContentSize
{
    CGFloat width = [self maximumSectionWidth];
    CGFloat height = self.hourHeaderHeight + (((self.sectionHeight + self.sectionGap) * self.collectionView.numberOfSections)) + self.contentMargin.top + self.contentMargin.bottom - self.sectionGap;

    return CGSizeMake(width >= self.collectionView.frame.size.width ? width : self.collectionView.frame.size.width, height >= self.collectionView.frame.size.height ? height : self.collectionView.frame.size.height);
}

#pragma mark Section Sizing

- (CGRect)rectForSection:(NSInteger)section
{
    CGFloat sectionHeight = self.sectionHeight;
    CGFloat sectionY = self.contentMargin.top + self.hourHeaderHeight + ((sectionHeight + self.sectionGap) * section);
    return CGRectMake(0.0, sectionY, self.collectionViewContentSize.width, sectionHeight);
}

#pragma mark Z Index

- (CGFloat)zIndexForElementKind:(NSString *)elementKind
{
    return [self zIndexForElementKind:elementKind floating:NO];
}

- (CGFloat)zIndexForElementKind:(NSString *)elementKind floating:(BOOL)floating
{
    if (elementKind == INSEPGLayoutElementKindCurrentTimeIndicator) {
        return (INSEPGLayoutMinOverlayZ + ((self.headerLayoutType == INSElectronicProgramGuideLayoutTypeTimeRowAboveDayColumn) ? (floating ? 9.0 : 4.0) : (floating ? 7.0 : 2.0)));
    }
    else if (elementKind == INSEPGLayoutElementKindHourHeader || elementKind == INSEPGLayoutElementKindHalfHourHeader) {
        return (INSEPGLayoutMinOverlayZ + ((self.headerLayoutType == INSElectronicProgramGuideLayoutTypeTimeRowAboveDayColumn) ? (floating ? 8.0 : 3.0) : (floating ? 6.0 : 1.0)));
    }
    else if (elementKind == INSEPGLayoutElementKindHourHeaderBackground) {
        return (INSEPGLayoutMinOverlayZ + ((self.headerLayoutType == INSElectronicProgramGuideLayoutTypeTimeRowAboveDayColumn) ? (floating ? 7.0 : 2.0) : (floating ? 5.0 : 0.0)));
    }
    else if (elementKind == INSEPGLayoutElementKindSectionHeader) {
        return (INSEPGLayoutMinOverlayZ + ((self.headerLayoutType == INSElectronicProgramGuideLayoutTypeTimeRowAboveDayColumn) ? (floating ? 6.0 : 1.0) : (floating ? 9.0 : 4.0)));
    }
    else if (elementKind == INSEPGLayoutElementKindSectionHeaderBackground) {
        return (INSEPGLayoutMinOverlayZ + ((self.headerLayoutType == INSElectronicProgramGuideLayoutTypeTimeRowAboveDayColumn) ? (floating ? 5.0 : 0.0) : (floating ? 8.0 : 3.0)));
    }
    // Cell
    else if (elementKind == nil) {
        return INSEPGLayoutMinCellZ;
    }
    // Floating Cell Overlay
    else if (elementKind == INSEPGLayoutElementKindFloatingItemOverlay) {
        return INSEPGLayoutMinCellZ + 1.0;
    }
    // Current Time Horizontal Gridline
    else if (elementKind == INSEPGLayoutElementKindCurrentTimeIndicatorVerticalGridline) {
        if (self.currentTimeIndicatorShouldBeBehind) {
            return (INSEPGLayoutMinBackgroundZ + 2.0);
        }
        // Place currentTimeGridLine juste behind Section Header and above cell
        return (INSEPGLayoutMinOverlayZ + ((self.headerLayoutType == INSElectronicProgramGuideLayoutTypeTimeRowAboveDayColumn) ? (floating ? 5.9 : 0.9) : (floating ? 8.9 : 3.9)));
    }
    // Vertical Gridline
    else if (elementKind == INSEPGLayoutElementKindVerticalGridline || elementKind == INSEPGLayoutElementKindHalfHourVerticalGridline) {
        return (INSEPGLayoutMinBackgroundZ + 1.0);
    }
    // Horizontal Gridline
    else if (elementKind == INSEPGLayoutElementKindHorizontalGridline) {
        return INSEPGLayoutMinBackgroundZ;
    }

    return CGFLOAT_MIN;
}

#pragma mark - Dates

- (NSDate *)earliestDate
{
    if (self.cachedEarliestDate) {
        return self.cachedEarliestDate;
    }
    NSDate *earliestDate = nil;
    
    if ([self.dataSource respondsToSelector:@selector(collectionView:startTimeForLayout:)]) {
        earliestDate = [self.dataSource collectionView:self.collectionView startTimeForLayout:self];
    } else {
        for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
            NSDate *earliestDateForSection = [self earliestDateForSection:section];
            if ((earliestDateForSection && [earliestDateForSection ins_isEarlierThan:earliestDate]) || !earliestDate) {
                earliestDate = earliestDateForSection;
            }
        }
    }

    if (earliestDate) {
        self.cachedEarliestDate = earliestDate;
        return self.cachedEarliestDate;
    }

    return [NSDate date];
}

- (NSDate *)earliestDateForSection:(NSInteger)section
{
    if (self.cachedEarliestDates[@(section)]) {
        return self.cachedEarliestDates[@(section)];
    }

    NSDate *earliestDate = nil;

    if ([self.dataSource respondsToSelector:@selector(collectionView:startTimeForLayout:)]) {
        earliestDate = [self.dataSource collectionView:self.collectionView startTimeForLayout:self];
    } else {
        for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            NSDate *itemStartDate = [self startDateForIndexPath:indexPath];
            if ((itemStartDate && [itemStartDate ins_isEarlierThan:earliestDate]) || !earliestDate) {
                earliestDate = itemStartDate;
            }
        }
    }

    if (earliestDate) {
        self.cachedEarliestDates[@(section)] = earliestDate;
        return earliestDate;
    }
    
    return nil;
}

- (NSDate *)latestDate
{
    if (self.cachedLatestDate) {
        return self.cachedLatestDate;
    }
    NSDate *latestDate = nil;

    if ([self.dataSource respondsToSelector:@selector(collectionView:endTimeForlayout:)]) {
        latestDate = [self.dataSource collectionView:self.collectionView endTimeForlayout:self];
    } else {
        for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
            NSDate *latestDateForSection = [self latestDateForSection:section];
            if ((latestDateForSection && [latestDateForSection ins_isLaterThan:latestDate]) || !latestDate) {
                latestDate = latestDateForSection;
            }
        }
    }

    if (latestDate) {
        self.cachedLatestDate = latestDate;
        return self.cachedLatestDate;
    }

    return [NSDate date];
}

- (NSDate *)latestDateForSection:(NSInteger)section
{
    if (self.cachedLatestDates[@(section)]) {
        return self.cachedLatestDates[@(section)];
    }

    NSDate *latestDate = nil;

    if ([self.dataSource respondsToSelector:@selector(collectionView:endTimeForlayout:)]) {
        latestDate = [self.dataSource collectionView:self.collectionView endTimeForlayout:self];
    } else {
        for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            NSDate *itemEndDate = [self endDateForIndexPath:indexPath];
            if ((itemEndDate && [itemEndDate ins_isLaterThan:latestDate]) || !latestDate) {
                latestDate = itemEndDate;
            }
        }
    }

    if (latestDate) {
        self.cachedLatestDates[@(section)] = latestDate;
        return latestDate;
    }

    return nil;
}

#pragma mark Delegate Wrappers

- (NSDate *)startDateForIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *indexPathKey = [self keyForIndexPath:indexPath];

    if ([self.cachedStartTimeDate objectForKey:indexPathKey]) {
        return [self.cachedStartTimeDate objectForKey:indexPathKey];
    }

    NSDate *date = [self.dataSource collectionView:self.collectionView layout:self startTimeForItemAtIndexPath:indexPathKey];

    [self.cachedStartTimeDate setObject:date forKey:indexPathKey];
    return date;
}

- (NSDate *)endDateForIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *indexPathKey = [self keyForIndexPath:indexPath];

    if ([self.cachedEndTimeDate objectForKey:indexPathKey]) {
        return [self.cachedEndTimeDate objectForKey:indexPathKey];
    }

    NSDate *date = [self.dataSource collectionView:self.collectionView layout:self endTimeForItemAtIndexPath:indexPathKey];

    [self.cachedEndTimeDate setObject:date forKey:indexPathKey];
    return date;
}

- (NSDate *)currentDate
{
    if (self.cachedCurrentDate) {
        return self.cachedCurrentDate;
    }

    NSDate *date = [self.dataSource currentTimeForCollectionView:self.collectionView layout:self];

    self.cachedCurrentDate = date;
    return date;
}

#pragma mark - Helpers
// Issues using NSIndexPath as key in NSMutableDictionary
// http://stackoverflow.com/questions/19613927/issues-using-nsindexpath-as-key-in-nsmutabledictionary

- (NSIndexPath *)keyForIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath class] == [NSIndexPath class]) {
        return indexPath;
    }
    return [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
}

#pragma mark - Size Delegate Wrapper

- (CGSize)floatingItemOverlaySizeForIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *indexPathKey = [self keyForIndexPath:indexPath];

    if ([self.cachedFloatingItemsOverlaySize objectForKey:indexPathKey]) {
        return [[self.cachedFloatingItemsOverlaySize objectForKey:indexPathKey] CGSizeValue];
    }
    CGSize floatingItemSize = self.floatingItemOverlaySize;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForFloatingItemOverlayAtIndexPath:)]) {
        floatingItemSize = [self.delegate collectionView:self.collectionView layout:self sizeForFloatingItemOverlayAtIndexPath:indexPathKey];
    }
    [self.cachedFloatingItemsOverlaySize setObject:[NSValue valueWithCGSize:floatingItemSize] forKey:indexPathKey];
    return floatingItemSize;
}

@end
