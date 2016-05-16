//
//  KBTimelineMarkerView.m
//  
//
//  Created by 黄延 on 15/8/29.
//
//

#import "KBTimelineMarkerView.h"

#import "KBGlobalSetup.h"

#import <Masonry.h>

@implementation KBTimelineMarkerView

- (instancetype)init{
    if (self = [super init]) {
        _now = [[UILabel alloc] init];
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
        _now.textAlignment = NSTextAlignmentCenter;
        _now.text = @"now";
        _now.textColor = KBColorPanelRed;
        [_now setHidden:YES];
        [self addSubview:_now];
        [self addSubview:_label];
//        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.mas_centerX).priorityHigh();
//            make.centerY.equalTo(self.mas_centerY).priorityHigh();
//            make.left.equalTo(self.mas_left);
//            make.right.equalTo(self.mas_right);
//            make.height.equalTo(self.mas_height).multipliedBy(0.3);
//
//        }];
//        [_now mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(_label.mas_centerX).priorityLow();
//            make.top.equalTo(self.mas_top).priorityLow();
//            make.height.lessThanOrEqualTo(self.mas_height).multipliedBy(0.3);
//            // make.bottom.equalTo(_label.mas_top).priorityLow();
//        }];
        
    }
    return self;
}

- (void)setMarked:(BOOL)marked{
    _marked = marked;
    if (marked) {
        [_now setHidden:NO];
        [_label setTextColor:KBColorPanelRed];
    }else{
        [_now setHidden:YES];
        [_label setTextColor:KBColorPanelGray];
    }
}

- (void)setCurAngle:(double)curAngle{
    _curAngle = curAngle;
//    CGAffineTransform trans = CGAffineTransformIdentity;
//    trans = CGAffineTransformRotate(trans, -M_PI/2+curAngle);
    // self.transform = trans;
    CATransform3D trans = CATransform3DIdentity;
    trans = CATransform3DRotate(trans, -M_PI/2+curAngle, 0, 0, 1);
    self.layer.transform = trans;
    }

- (void)layoutLabels{
    _label.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    _label.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height * 0.4);
    _label.font = [UIFont systemFontOfSize:self.frame.size.height * 0.35];
    _now.center = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.15);
    _now.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height * 0.3);
    _now.font = [UIFont systemFontOfSize:self.frame.size.height * 0.2];

}

@end
