//
//  ISFloatingCell.h
//  INSElectronicProgramGuideLayout
//
//  Created by Michał Zaborowski on 18.12.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISFloatingCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *topBorderView;
@property (weak, nonatomic) IBOutlet UIView *leftBorderView;

- (void)setDate:(NSDate *)date;
@end
