//
//  ISDashedLineView.m
//  iLumio Guest
//
//  Created by Michał Zaborowski on 20.09.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import "ISDashedLineView.h"

@implementation ISDashedLineView

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;

    CAShapeLayer *shapeLayer = (CAShapeLayer *)self.layer;
    [shapeLayer setStrokeColor:[self.lineColor CGColor]];
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;

    CAShapeLayer *shapeLayer = (CAShapeLayer *)self.layer;
    [shapeLayer setBounds:self.bounds];
    [shapeLayer setPosition:self.center];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:[self.lineColor CGColor]];
    [shapeLayer setLineWidth:self.lineWidth];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:5],
      [NSNumber numberWithInt:5],nil]];

    // Setup the path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, 0, self.bounds.size.height);
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
}

@end
