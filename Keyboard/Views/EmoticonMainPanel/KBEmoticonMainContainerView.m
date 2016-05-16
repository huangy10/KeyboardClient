//
//  KBEmoticonMainContainerView.m
//  
//
//  Created by 黄延 on 15/9/1.
//
//

#import "KBEmoticonMainContainerView.h"

@implementation KBEmoticonMainContainerView

- (instancetype)init{
    if (self = [super init]) {
        // Change the rotating anchor point to the lower-right point
        self.layer.anchorPoint = CGPointMake(1, 1);
        // self.clipsToBounds = YES;
    }
    return self;
}

- (void)setRotatingAngle:(CGFloat)alpha{
    CGAffineTransform trans = CGAffineTransformRotate(CGAffineTransformIdentity, alpha);
    self.transform = trans;
}

@end
