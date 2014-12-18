//
//  ViewController.m
//  INSElectronicProgramGuideLayout
//
//  Created by Michał Zaborowski on 29.09.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import "INSEPGViewController.h"
#import "INSElectronicProgramGuideLayout.h"
#import "ISHourHeader.h"
#import "ISEPGCell.h"
#import "ISSectionHeader.h"
#import "ISCurrentTimeIndicatorView.h"
#import "ISGridlineView.h"
#import "ISHeaderBackgroundView.h"
#import "ISCurrentTimeGridlineView.h"
#import "ISHalfHourLineView.h"
#import "ISFloatingCell.h"
#import "Channel.h"
#import "ISHourHeaderBackgroundView.h"
#import "Entry.h"

@interface INSEPGViewController () <INSElectronicProgramGuideLayoutDataSource, INSElectronicProgramGuideLayoutDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, weak) INSElectronicProgramGuideLayout *collectionViewEPGLayout;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation INSEPGViewController

- (INSElectronicProgramGuideLayout *)collectionViewEPGLayout
{
    return (INSElectronicProgramGuideLayout *)self.collectionViewLayout;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundImage.image = [UIImage imageNamed:@"backgroundImage"];
    self.collectionView.backgroundView = backgroundImage;

    self.fetchedResultsController = [Entry MR_fetchAllGroupedBy:@"channel.iD" withPredicate:nil sortedBy:@"channel.iD,channel.name" ascending:YES delegate:self];

    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.
    self.collectionViewEPGLayout.dataSource = self;
    self.collectionViewEPGLayout.delegate = self;

    self.collectionViewEPGLayout.shouldResizeStickyHeaders = YES;
    self.collectionViewEPGLayout.shouldUseFloatingItemOverlay = NO;
    self.collectionViewEPGLayout.floatingItemOffsetFromSection = 10.0;
    self.collectionViewEPGLayout.currentTimeVerticalGridlineWidth = 4;
    self.collectionViewEPGLayout.sectionHeight = 60;
    self.collectionViewEPGLayout.sectionHeaderWidth = 110;

    NSString *timeRowHeaderStringClass = NSStringFromClass([ISHourHeader class]);
    [self.collectionView registerNib:[UINib nibWithNibName:timeRowHeaderStringClass bundle:nil] forSupplementaryViewOfKind:INSEPGLayoutElementKindHourHeader withReuseIdentifier:timeRowHeaderStringClass];
    [self.collectionView registerNib:[UINib nibWithNibName:timeRowHeaderStringClass bundle:nil] forSupplementaryViewOfKind:INSEPGLayoutElementKindHalfHourHeader withReuseIdentifier:timeRowHeaderStringClass];

    NSString *cellStringClass = NSStringFromClass([ISFloatingCell class]);
    [self.collectionView registerNib:[UINib nibWithNibName:cellStringClass bundle:nil] forCellWithReuseIdentifier:cellStringClass];

    NSString *dayColumnHeaderStringClass = NSStringFromClass([ISSectionHeader class]);
    [self.collectionView registerNib:[UINib nibWithNibName:dayColumnHeaderStringClass bundle:nil] forSupplementaryViewOfKind:INSEPGLayoutElementKindSectionHeader withReuseIdentifier:dayColumnHeaderStringClass];

    [self.collectionViewEPGLayout registerClass:ISCurrentTimeGridlineView.class forDecorationViewOfKind:INSEPGLayoutElementKindCurrentTimeIndicatorVerticalGridline];
    [self.collectionViewEPGLayout registerClass:ISGridlineView.class forDecorationViewOfKind:INSEPGLayoutElementKindVerticalGridline];
    [self.collectionViewEPGLayout registerClass:ISHalfHourLineView.class forDecorationViewOfKind:INSEPGLayoutElementKindHalfHourVerticalGridline];

    [self.collectionViewEPGLayout registerClass:ISHeaderBackgroundView.class forDecorationViewOfKind:INSEPGLayoutElementKindSectionHeaderBackground];
    [self.collectionViewEPGLayout registerClass:ISHourHeaderBackgroundView.class forDecorationViewOfKind:INSEPGLayoutElementKindHourHeaderBackground];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionViewEPGLayout scrollToCurrentTimeAnimated:YES];
    });
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(INSElectronicProgramGuideLayout *)electronicProgramGuideLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Entry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return entry.startDate;
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(INSElectronicProgramGuideLayout *)electronicProgramGuideLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Entry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return entry.endDate;
}

- (NSDate *)currentTimeForCollectionView:(UICollectionView *)collectionView layout:(INSElectronicProgramGuideLayout *)collectionViewLayout
{
    return [NSDate date];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view;
    if (kind == INSEPGLayoutElementKindSectionHeader) {
        ISSectionHeader *dayColumnHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([ISSectionHeader class]) forIndexPath:indexPath];
        Entry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];

        dayColumnHeader.dayLabel.text = entry.channel.name;
        view = dayColumnHeader;
    } else if (kind == INSEPGLayoutElementKindHourHeader) {
        ISHourHeader *timeRowHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([ISHourHeader class]) forIndexPath:indexPath];
        timeRowHeader.time = [self.collectionViewEPGLayout dateForHourHeaderAtIndexPath:indexPath];
        view = timeRowHeader;
    } else if (kind == INSEPGLayoutElementKindHalfHourHeader) {
        ISHourHeader *timeRowHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([ISHourHeader class]) forIndexPath:indexPath];
        timeRowHeader.time = [self.collectionViewEPGLayout dateForHalfHourHeaderAtIndexPath:indexPath];
        view = timeRowHeader;
    } 

    return view;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ISFloatingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ISFloatingCell class]) forIndexPath:indexPath];
    Entry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.titleLabel.text = entry.title;
    [cell setDate:entry.startDate];

    return cell;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionViewEPGLayout invalidateLayoutCache];
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
@end
