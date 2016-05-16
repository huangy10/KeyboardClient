//
//  KBEmoticonDetailView.m
//  
//
//  Created by 黄延 on 15/9/2.
//
//

#import "KBEmoticonDetailView.h"

#import <Masonry.h>

@implementation KBEmoticonDetailView

- (instancetype) init{
    if (self = [super init]) {
        _title = [[UILabel alloc] init];
        [self addSubview:_title];
        _title.backgroundColor = [UIColor clearColor];
        _title.font = [UIFont systemFontOfSize:10];
        _title.textColor = [UIColor blackColor];
        _title.textAlignment = NSTextAlignmentCenter;
        [_title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(self).multipliedBy(0.2);
        }];
        
        _icon = [[UIImageView alloc] init];
        [self addSubview:_icon];
        [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_title.mas_top);
            make.top.equalTo(self);
            make.centerX.equalTo(self);
            make.width.equalTo(_icon.mas_height);
        }];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextAddEllipseInRect(ctx, CGRectMake(0, 0, _contentRadius * 2, _contentRadius * 2));
    CGContextFillPath(ctx);
    CGMutablePathRef path = CGPathCreateMutable();
    CGAffineTransform trans = CGAffineTransformTranslate(CGAffineTransformIdentity, _contentRadius* 0.98 * (1+cos(_arrowPos)), _contentRadius* 0.98 * (1+sin(_arrowPos)));
    trans = CGAffineTransformRotate(trans,  _arrowPos - M_PI/2);
    CGFloat arrowSize = _contentRadius / 5;
    CGPathMoveToPoint(path, &trans, 0, arrowSize);
    CGPathAddLineToPoint(path, &trans, arrowSize, 0);
    CGPathAddLineToPoint(path, &trans, -arrowSize, 0);
    CGPathCloseSubpath(path);
    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    
    CGContextRestoreGState(ctx);
}

- (void)setAnchorPoint:(CGPoint)anchorPoint{
    CGPoint center = CGPointMake(anchorPoint.x - _contentRadius*cos(_arrowPos), _anchorPoint.y - _contentRadius * sin(_arrowPos));
    self.center = center;
}

- (void)setContentRadius:(CGFloat)contentRadius{
    _contentRadius = contentRadius;
    self.bounds = CGRectMake(0, 0, _contentRadius*2, _contentRadius*2);
}

@end
