//
//  ISReservationTimeRowHeader.m
//  iLumio Guest
//
//  Created by Michał Zaborowski on 20.09.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import "ISHourHeader.h"

@interface ISHourHeader ()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end

@implementation ISHourHeader

+ (NSDateFormatter *)sharedTimeRowHeaderDateFormatter
{
    static dispatch_once_t once;
    static NSDateFormatter *_sharedTimeRowHeaderDateFormatter;
    dispatch_once(&once, ^ { _sharedTimeRowHeaderDateFormatter = [[NSDateFormatter alloc] init];
        _sharedTimeRowHeaderDateFormatter.dateFormat = @"HH:mm";
    });
    return _sharedTimeRowHeaderDateFormatter;
}

- (void)setTime:(NSDate *)time
{
    _time = time;

    self.timeLabel.text = [[[self class] sharedTimeRowHeaderDateFormatter] stringFromDate:time];

    [self setNeedsLayout];
}

@end
