//
//  ISReservationCurrentTimeIndicatorView.m
//  iLumio Guest
//
//  Created by Michał Zaborowski on 20.09.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import "ISCurrentTimeIndicatorView.h"

@interface ISCurrentTimeIndicatorView ()
@property (nonatomic, weak) IBOutlet UILabel *currentTimeLabel;
@property (nonatomic, retain) NSTimer *minuteTimer;
@end

@implementation ISCurrentTimeIndicatorView

- (void)awakeFromNib
{
    [super awakeFromNib];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *oneMinuteInFuture = [[NSDate date] dateByAddingTimeInterval:60];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:oneMinuteInFuture];
    NSDate *nextMinuteBoundary = [calendar dateFromComponents:components];

    self.minuteTimer = [[NSTimer alloc] initWithFireDate:nextMinuteBoundary interval:60 target:self selector:@selector(minuteTick:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.minuteTimer forMode:NSDefaultRunLoopMode];

    [self updateTime];

}

#pragma mark - MSCurrentTimeIndicator

- (void)minuteTick:(id)sender
{
    [self updateTime];
}

- (void)updateTime
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"HH:mm"];
    self.currentTimeLabel.text = [dateFormatter stringFromDate:[NSDate date]];
}


@end
