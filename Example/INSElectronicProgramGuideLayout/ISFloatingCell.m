//
//  ISFloatingCell.m
//  INSElectronicProgramGuideLayout
//
//  Created by Michał Zaborowski on 18.12.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import "ISFloatingCell.h"
#import <UIColor+MLPFlatColors/UIColor+MLPFlatColors.h>

@implementation ISFloatingCell

+ (NSDateFormatter *)sharedTimeRowHeaderDateFormatter
{
    static dispatch_once_t once;
    static NSDateFormatter *_sharedTimeRowHeaderDateFormatter;
    dispatch_once(&once, ^ { _sharedTimeRowHeaderDateFormatter = [[NSDateFormatter alloc] init];
        _sharedTimeRowHeaderDateFormatter.dateFormat = @"HH:mm";
    });
    return _sharedTimeRowHeaderDateFormatter;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    UIColor *randomColor = [UIColor randomFlatLightColor];
    self.topBorderView.backgroundColor = randomColor;
    self.leftBorderView.backgroundColor = randomColor;

    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.layer.shouldRasterize = YES;

    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)setDate:(NSDate *)date
{
    self.dateLabel.text = [[[self class] sharedTimeRowHeaderDateFormatter] stringFromDate:date];

    [self setNeedsLayout];
}

@end
