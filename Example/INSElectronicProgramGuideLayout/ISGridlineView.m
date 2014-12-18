//
//  ISReservationGridlineView.m
//  iLumio Guest
//
//  Created by Michał Zaborowski on 20.09.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import "ISGridlineView.h"

@implementation ISGridlineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =  [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    }
    return self;
}

@end
