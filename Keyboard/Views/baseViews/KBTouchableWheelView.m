//
//  KBTouchableWheelView.m
//  
//
//  Created by 黄延 on 15/8/29.
//
//

#import "KBTouchableWheelView.h"

#define KBSCROLL_MULITPIER 300

@interface KBTouchableWheelView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>{
    CGPoint _pre;
    CGPoint _cur;
    // We have some problem when using setContentOffset:Animated:, so by setting this variable to YES to disable the angle change tracking during scrolling。
    BOOL _scrollTracingDisabled;
}

/**
 *  Use UIScrollView for inertial effects.
 */
@property (nonatomic, strong) UIScrollView *inertial;

/**
 *  double tap gesture
 */
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@property (nonatomic, strong) CADisplayLink *link;

@end

@implementation KBTouchableWheelView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        _inertial = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, M_PI/2*KBSCROLL_MULITPIER, M_PI/2*KBSCROLL_MULITPIER)];
        _inertial.contentSize = CGSizeMake(M_PI*2*KBSCROLL_MULITPIER, M_PI*2*KBSCROLL_MULITPIER);
        [_inertial setContentOffset:CGPointMake(M_PI*0.75*KBSCROLL_MULITPIER, M_PI*0.75*KBSCROLL_MULITPIER)];
        _inertial.delegate = self;
        UIView *tinyContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];

        [self addSubview:tinyContainer];
        [tinyContainer addSubview:_inertial];
        _scrollTracingDisabled = NO;
    }
    return self;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hit = [super hitTest:point withEvent:event];
    if (hit == self) {
        hit =  [_inertial hitTest:CGPointMake(_inertial.frame.size.width/2 + _inertial.contentOffset.x, _inertial.frame.size.height/2 + _inertial.contentOffset.y) withEvent:event];
    }
    return hit;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_scrollTracingDisabled) {
        return;
    }
    // _preA  = scrollView.contentOffset.y / 10;
    _pre = scrollView.contentOffset;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_scrollTracingDisabled) {
        _cur = scrollView.contentOffset;
        _pre = _cur;
        return;
    }
    CGPoint offset = scrollView.contentOffset;
    CGSize contentSize = scrollView.contentSize;
    CGSize frameSize = scrollView.frame.size;
    if (offset.x >= contentSize.width / 2 - frameSize.width &&
        offset.y >= contentSize.height / 2 - frameSize.height &&
        offset.x <= contentSize.width / 2 + frameSize.width &&
        offset.y <= contentSize.height / 2 + frameSize.height) {
        _cur = offset;
        CGFloat width = self.frame.size.width;
        CGFloat a1 = _cur.x - _pre.x;
        CGFloat a2 = _cur.y - _pre.y;
        CGFloat dAngle = sqrt(a1*a1 + a2*a2)/width;
        if (a1 < 0) {
            dAngle = -dAngle;
        }
    // NSLog(@"%lf", dAngle);
        [self changeangle:-dAngle];
        _pre = _cur;
    }else{
        if (offset.x < contentSize.width / 2 - frameSize.width + 10) {
            offset.x += frameSize.width;
            _pre.x += frameSize.width;
        }
        if (offset.y < contentSize.height / 2 - frameSize.height + 10) {
            offset.y += frameSize.height;
            _pre.y += frameSize.height;
        }
        if (offset.x > contentSize.width / 2 + frameSize.width - 10) {
            offset.x -= frameSize.width;
            _pre.x -= frameSize.width;
        }
        if (offset.y > contentSize.height / 2 + frameSize.height - 10) {
            offset.y -= frameSize.height;
            _pre.y -= frameSize.height;
        }
        scrollView.contentOffset = offset;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (_delegate && [_delegate respondsToSelector:@selector(wheelDidStopped:)]) {
        [_delegate wheelDidStopped:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        if (_delegate && [_delegate respondsToSelector:@selector(wheelDidStopped:)]) {
            [_delegate wheelDidStopped:self];
        }
    }
}
- (void)scrollForAngle:(CGFloat)angle{
    CGFloat distance = angle * self.frame.size.width;
    // Adjust the size of the scroll view
    if (_inertial.contentSize.width < fabs(distance)) {
        WRLog(@"Error");
        CGSize size = _inertial.contentSize;
        size.width = fabs(distance);
        _inertial.contentSize = size;
    }
    _scrollTracingDisabled = YES;
//    [_link invalidate];
//    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayTracker)];
//    [_link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    if(distance < 0){
        [_inertial setContentOffset:CGPointMake(_inertial.contentSize.width/2 + _inertial.frame.size.width, _inertial.contentSize.height/2 - _inertial.frame.size.height)];
//        [UIView animateWithDuration:3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//           [_inertial setContentOffset:CGPointMake(_inertial.contentSize.width/2 + _inertial.frame.size.width + distance, _inertial.contentSize.height/2 - _inertial.frame.size.height) animated:NO];
//        } completion:^(BOOL finished){
//            if (finished) {
//                DMLog(@"finished");
//                [_link invalidate];
//                _scrollTracingDisabled = NO;
//            }
//            
//        }];
        _scrollTracingDisabled = NO;
        [_inertial setContentOffset:CGPointMake(_inertial.contentSize.width/2 + _inertial.frame.size.width + distance, _inertial.contentSize.height/2 - _inertial.frame.size.height) animated:YES];
    }else{
        [_inertial setContentOffset:CGPointMake(_inertial.contentSize.width/2 - _inertial.frame.size.width, _inertial.contentSize.width/2)];
//        [UIView animateWithDuration:3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            [_inertial setContentOffset:CGPointMake(_inertial.contentSize.width/2 - _inertial.frame.size.width + distance, _inertial.contentSize.width/2) animated:YES];
//        } completion:^(BOOL finished){
//            if (finished) {
//                DMLog(@"finished");
//                [_link invalidate];
//                _scrollTracingDisabled = NO;
//            }
//        }];
        _scrollTracingDisabled = NO;
        [_inertial setContentOffset:CGPointMake(_inertial.contentSize.width/2 - _inertial.frame.size.width + distance, _inertial.contentSize.width/2) animated:YES];

    }
}

- (void)displayTracker{
    DMLog(@"duang");
}

- (void)setDoubleTapEnabled:(BOOL)doubleTapEnabled{
    _doubleTapEnabled = doubleTapEnabled;
    if (_doubleTapEnabled) {
        [_inertial addGestureRecognizer:self.tap];
    }else if (!_doubleTapEnabled && _tap){
        [_inertial removeGestureRecognizer:_tap];
    }
}

- (UITapGestureRecognizer*)tap{
    if (_tap != nil) {
        return _tap;
    }
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHandler:)];
    _tap.numberOfTapsRequired = 2;
    return _tap;
}


- (void)doubleTapHandler:(UITapGestureRecognizer*)gesture{
    
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (_delegate && [_delegate respondsToSelector:@selector(wheelDoubleTapped:)]) {
            [_delegate wheelDoubleTapped:self];
        }
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)changeangle:(CGFloat)dAngle{
    _angle += dAngle;
    while (_angle > M_2_PI) {
        _angle -= M_2_PI;
    }
    while (_angle < 0) {
        _angle += M_2_PI;
    }
    if (self.delegate != nil) {
        [_delegate wheel:self AngleChanged:dAngle];
    }
}



@end
