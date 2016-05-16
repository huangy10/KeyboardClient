//
//  KBQuarterCircleView.m
//  
//
//  Created by 黄延 on 15/8/29.
//
//

#import "KBQuarterCircleView.h"

@implementation KBQuarterCircleView

- (instancetype)initWithBackgroundColor:(UIColor *)color{
    if (self = [super init]) {
        _bg = color;
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        // self.layer.shadowOffset = CGSizeMake(0, -5);
        self.layer.shadowRadius = 8;
        self.layer.shadowOpacity = 0.3;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGRect frame = self.frame;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, _bg.CGColor);
    CGContextAddEllipseInRect(ctx, CGRectMake(0, 0, frame.size.width*2, frame.size.height*2));
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);
}

@end
