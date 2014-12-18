//
//  ISReservationDayColumnHeader.m
//  iLumio Guest
//
//  Created by Michał Zaborowski on 20.09.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import "ISSectionHeader.h"

@interface ISSectionHeader ()

@end

@implementation ISSectionHeader



+ (NSDateFormatter *)sharedDayColumnHeaderDateFormatter
{
    static dispatch_once_t once;
    static NSDateFormatter *_sharedDayColumnHeaderDateFormatter;
    dispatch_once(&once, ^ { _sharedDayColumnHeaderDateFormatter = [[NSDateFormatter alloc] init];
        _sharedDayColumnHeaderDateFormatter.dateFormat = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"EEE MMM d" : @"EEEE MMMM d, YYYY");
    });
    return _sharedDayColumnHeaderDateFormatter;
}

- (void)setDay:(NSDate *)day
{


    self.dayLabel.text = [[[self class] sharedDayColumnHeaderDateFormatter] stringFromDate:day];

    [self setNeedsLayout];
}

@end
