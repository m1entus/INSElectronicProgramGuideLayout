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

#import "NSDate+INSUtils.h"

@implementation NSDate (INSUtils)

- (BOOL)ins_isLaterThan:(NSDate *)date
{
    if (self.timeIntervalSince1970 > date.timeIntervalSince1970) {
        return YES;
    }
    return NO;
}
- (BOOL)ins_isEarlierThan:(NSDate *)date
{
    if (self.timeIntervalSince1970 < date.timeIntervalSince1970) {
        return YES;
    }
    return NO;
}
- (BOOL)ins_isLaterThanOrEqualTo:(NSDate *)date
{
    if (self.timeIntervalSince1970 >= date.timeIntervalSince1970) {
        return YES;
    }
    return NO;
}
- (BOOL)ins_isEarlierThanOrEqualTo:(NSDate *)date
{
    if (self.timeIntervalSince1970 <= date.timeIntervalSince1970) {
        return YES;
    }
    return NO;
}

- (NSDate *)ins_dateByAddingHours:(NSInteger)hour
{
    return [self dateByAddingTimeInterval:(hour * 3600)];
}

- (NSDate *)ins_dateWithoutMinutesAndSeconds
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone defaultTimeZone]];

    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit
                                                   fromDate:self];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];

    return [calendar dateFromComponents:dateComponents];
}

@end
