//
//  ISReservationCell.m
//  iLumio Guest
//
//  Created by Michał Zaborowski on 20.09.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import "ISEPGCell.h"
@interface ISEPGCell ()
@end

@implementation ISEPGCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
}


@end
