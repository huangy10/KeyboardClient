//
//  UIButton++ChainedCircle.m
//  
//
//  Created by 黄延 on 15/9/3.
//
//

#import "UIButton+ChainedCircle.h"

@implementation UIButton (ChainedCircle)

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hit = [super hitTest:point withEvent:event];
    CGFloat dis = [self distance:point];
    if([hit isEqual:self] && dis > self.frame.size.width){
        return nil;
    }else{
        return hit;
    }
}

- (CGFloat)distance:(CGPoint)pt{
    CGFloat dx = self.frame.size.width - pt.x;
    CGFloat dy = self.frame.size.height - pt.y;
    CGFloat dis = sqrt(dx * dx + dy * dy);
    return dis;
}

@end
