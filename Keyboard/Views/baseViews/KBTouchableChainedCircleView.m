//
//  KBTouchableChainedCircleView.m
//  
//
//  Created by 黄延 on 15/8/29.
//
//

#import "KBTouchableChainedCircleView.h"

#import "KBGlobalSetup.h"

@implementation KBTouchableChainedCircleView

- (instancetype)init{
    if (self = [super init]) {
        // self.translatesAutoresizingMaskIntoConstraints = YES;
    }
    return self;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hit = [super hitTest:point withEvent:event];
    CGFloat dis = [self distance:point];
    if ([hit isEqual:self] && (dis > self.frame.size.width) && _backer) {
        return [_backer hitTest:[_backer convertPoint:point fromView:self] withEvent:event];
    }else if([hit isEqual:self] && dis > self.frame.size.width){
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
