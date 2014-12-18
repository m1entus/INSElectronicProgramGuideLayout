//
//  ISDashedLineView.h
//  iLumio Guest
//
//  Created by Michał Zaborowski on 20.09.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISDashedLineView : UIView
@property (nonatomic, assign) IBInspectable CGFloat lineWidth;
@property (nonatomic, strong) IBInspectable UIColor *lineColor;
@end
