//
//  KBQuarterCircleWithMarkerView.m
//  
//
//  Created by 黄延 on 15/8/30.
//
//

#import "KBQuarterCircleWithMarkerView.h"

#import "KBGlobalSetup.h"

@implementation KBQuarterCircleWithMarkerView

- (instancetype)initWithMarkerPos:(CGFloat)pos color:(UIColor *)color{
    if (self = [super initWithBackgroundColor:color]) {
        _pos = pos;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGRect frame = self.frame;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat markerSize = 15.0 / 270 * frame.size.width;
    CGFloat r = frame.size.width-1;
    CGAffineTransform  trans = CGAffineTransformTranslate(CGAffineTransformIdentity, frame.size.width - r*cos(_pos), frame.size.height - r*sin(_pos));
    trans = CGAffineTransformRotate(trans, M_PI/2 + _pos);
    CGPathMoveToPoint(path, &trans, 0, markerSize);
    CGPathAddLineToPoint(path, &trans, -markerSize/2, 0);
    CGPathAddLineToPoint(path, &trans, markerSize/2, 0);
    CGPathAddLineToPoint(path, &trans, 0, markerSize);
    
    CGContextAddPath(ctx, path);
    CGContextClosePath(ctx);
    CGContextSetFillColorWithColor(ctx, KBColorPanelRed.CGColor);
    CGContextFillPath(ctx);
    CGPathRelease(path);
    CGContextRestoreGState(ctx);
}

@end
