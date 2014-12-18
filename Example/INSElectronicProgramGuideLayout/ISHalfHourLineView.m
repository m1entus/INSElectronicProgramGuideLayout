//
//  ISReservationHalfHourLineView.m
//  iLumio Guest
//
//  Created by Michał Zaborowski on 20.09.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import "ISHalfHourLineView.h"
#import "ISDashedLineView.h"

@interface ISHalfHourLineView ()
@property (nonatomic, strong) ISDashedLineView *dashLine;
@end

@implementation ISHalfHourLineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.dashLine = [[ISDashedLineView alloc] initWithFrame:self.bounds];
        [self addSubview:self.dashLine];

        self.dashLine.lineColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
        self.dashLine.lineWidth = 3;
    }
    return self;
}

@end
