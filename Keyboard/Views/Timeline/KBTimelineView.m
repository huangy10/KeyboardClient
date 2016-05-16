//
//  KBTimelineView.m
//  
//
//  Created by 黄延 on 15/8/29.
//
//

#import "KBTimelineView.h"

#import "KBTimelineMarkerView.h"
#import "KBQuarterCircleView.h"
#import "UIButton+ChainedCircle.h"

@interface KBTimelineView ()<KBTouchableWheelViewDelegate>{
    int _curHour;
    int _curMin;
    int _curMarked;
    NSInteger _preMarkdedTime;
}
/**
 *  Container for time scales
 */
@property (nonatomic, strong) UIView *scaleContainer;

/**
 *  This array contains all the 24 scales.
 */
@property (nonatomic, strong) NSArray* scales;

/**
 *  This array contains the currently visible scales
 */
@property (nonatomic, strong) NSMutableArray *visibleScales;

/**
 *  Background view
 */
@property (nonatomic, strong) KBQuarterCircleView *bg;

/**
 *  NSTimer to check hour change
 */
@property (nonatomic, strong) NSTimer *hourChangeTimer;

@end

@implementation KBTimelineView

- (instancetype)initWithMarkerPosition:(CGFloat)markerAngle{
    if (self = [super init]) {
        _markerAngle = markerAngle;
        _visibleScales = [NSMutableArray array];
        // Set this interval bigger than 15 degree may cause unexpected display error.
        _markerInterval = 15 / 180.0 * M_PI;
        // Create background view
        _bg = [[KBQuarterCircleView alloc] initWithBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_bg];
        // Create the touchable wheel.
        _wheel = [[KBTouchableWheelView alloc] init];
        _wheel.delegate = self;
        _wheel.doubleTapEnabled = YES;
        [self addSubview:_wheel];

        // Create scales.
        _scaleContainer = [[UIView alloc] init];
        _scaleContainer.userInteractionEnabled = NO;
        _scaleContainer.backgroundColor = [UIColor clearColor];
        [self addSubview:_scaleContainer];
        _scaleContainer.clipsToBounds = YES;
        
        NSMutableArray *scales = [NSMutableArray array];
        for (int i=0; i < 24; i++) {
            KBTimelineMarkerView *scale = [[KBTimelineMarkerView alloc] init];
            [scales addObject:scale];
            scale.label.text = [NSString stringWithFormat:@"%02d:00", i];
            scale.time = i;
            [scale setHidden:YES];
            [_scaleContainer addSubview:scale];

        }
        _scales = scales;
        [self bringSubviewToFront:_wheel];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _bg.frame = self.bounds;
    _wheel.frame = self.bounds;
    _scaleContainer.frame = self.bounds;
    [self layoutScales];
}

/**
 *  This function handle the layout of scales.
 */
- (void)layoutScales{
    double dt = _markerAngle / _markerInterval * 60 * 60;
    _horizontalTime = [NSDate dateWithTimeInterval:-dt sinceDate:[NSDate date]];
    [self loadCurrentHourAndMin];
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *components = [calender components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:_horizontalTime];
    int hHour = (int)[components hour];
    _preMarkdedTime = hHour;
    double minute = (double)[components minute];
    // initial position for first scale
    CGFloat startingPos = (minute - minute) / 60 * _markerInterval;
    int i = hHour;
    CGFloat pos = startingPos;
    
    for (; i < hHour + 24; i++) {
        int index = i % 24;
        KBTimelineMarkerView *scale = _scales[index];
        CGPoint newCenter = [self getCenterForPos:pos];
        scale.center = newCenter;
        scale.bounds = CGRectMake(0, 0, 50, 30);
        [scale layoutLabels];
        if ( pos < M_PI * 0.667) {
            [scale setHidden:NO];
        }else{
            [scale setHidden:NO];
        }
        if (_curHour == index) {
            [scale setMarked:YES];
            _curMarked = index;
        }
        [scale setCurAngle:pos];
        [_visibleScales addObject:scale];
        pos += _markerInterval;
    }
    if (!_hourChangeTimer) {
        _hourChangeTimer =  [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(hourCheck) userInfo:nil repeats:YES];
        [_hourChangeTimer fire];
    }
}

- (void)scrollToNow{
    KBTimelineMarkerView *scale = [_visibleScales firstObject];
    CGFloat pos = scale.curAngle;
    int time = scale.time;
    [self loadCurrentHourAndMin];
    // Select to nearest direction
    int dTime = time - _curHour;
    if (dTime > 12) {
        dTime -= 24;
    }else if (dTime < -12){
        dTime += 24;
    }
    //
    CGFloat dPos = dTime * _markerInterval + _markerAngle - pos;
    [_wheel scrollForAngle:-dPos];
}

- (NSInteger)markedTime{
    KBTimelineMarkerView *scale = [_visibleScales firstObject];
    CGFloat pos=  scale.curAngle;
    return (scale.time + (int)((_markerAngle - pos)/_markerInterval)) % 24;
}

- (void)wheel:(KBTouchableWheelView *)wheel AngleChanged:(CGFloat)dAlpha{
    KBTimelineMarkerView *firstScale = [_visibleScales firstObject];
    while (firstScale.curAngle < - _markerInterval * 2) {
        [firstScale setHidden:YES];
        [_visibleScales removeObjectAtIndex:0];
        firstScale = [_visibleScales firstObject];
    }
    while(firstScale.curAngle > 0){
        int newIndex = firstScale.time - 1;
        if (newIndex < 0) {
            newIndex += 24;
        }
        KBTimelineMarkerView *newScale = _scales[newIndex];
        [_visibleScales insertObject:newScale atIndex:0];
        newScale.curAngle = firstScale.curAngle - _markerInterval;
        newScale.center = [self getCenterForPos:newScale.curAngle];
        [newScale setHidden:NO];
        firstScale = newScale;
    }
    KBTimelineMarkerView *lastScale = [_visibleScales lastObject];
    while (lastScale.curAngle > M_PI/2 + _markerInterval * 2) {
        [lastScale setHidden:YES];
        [_visibleScales removeLastObject];
        lastScale = [_visibleScales lastObject];
    }
    while (lastScale.curAngle < M_PI/2) {
        int newIndex = (lastScale.time + 1)%24;
        KBTimelineMarkerView *newScale = _scales[newIndex];
        [_visibleScales addObject:newScale];
        newScale.curAngle = lastScale.curAngle + _markerInterval;
        newScale.center = [self getCenterForPos:newScale.curAngle];
        [newScale setHidden:NO];
        lastScale = newScale;
    }
    
    [_visibleScales sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        KBTimelineMarkerView *scale1 = (KBTimelineMarkerView*)obj1;
        KBTimelineMarkerView *scale2 = (KBTimelineMarkerView*)obj2;
        if (scale1.curAngle < scale2.curAngle) {
            return NSOrderedAscending;
        }else if(scale1.curAngle > scale2.curAngle){
            return NSOrderedDescending;
        }else{
            return NSOrderedSame;
        }
    }];
    
    for (KBTimelineMarkerView *scale in _visibleScales) {
        CGFloat pos = scale.curAngle + dAlpha;
        CGPoint newCenter = [self getCenterForPos:pos];
        
        scale.center = newCenter;
        [scale setCurAngle:pos];
        [scale setNeedsLayout];
    }
}

- (void)wheelDidStopped:(KBTouchableWheelView *)wheel{
    if (_delegate && [_delegate respondsToSelector:@selector(timeChanged:)]) {
        NSInteger markedTime = [self markedTime];
        if (markedTime != _preMarkdedTime) {
            _preMarkdedTime = markedTime;
            [_delegate timeChanged:[self markedTime]];
        }
    }
}

- (void)wheelDoubleTapped:(KBTouchableWheelView *)wheel{
    [self scrollToNow];
}

/**
 *  Override the default hit checker to forward the touches of this view to the touchable wheel
 */
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hit = [super hitTest:point withEvent:event];
    if ([hit isEqual:self]) {
        return _wheel;
    }else{
        return hit;
    }
}


#pragma mark utility function

- (void)hourCheck{
    NSDate *now = [NSDate date];
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *components = [calender components:NSCalendarUnitHour fromDate:now];
    int curHour = (int)[components hour];
    if (curHour != _curMarked) {
        [_scales[_curMarked] setMarked:NO];
        [_scales[curHour] setMarked:YES];
        _curMarked = curHour;
    }
}

- (void)loadCurrentHourAndMin{
    NSDate *now = [NSDate date];
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *components = [calender components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:now];
    _curHour = (int)[components hour];
    _curMin = (int)[components minute];
}

- (CGPoint)getCenterForPos:(CGFloat)angle{
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    _wheelWidth = width / 6 * 0.8;
    CGFloat radius = self.bounds.size.width - _wheelWidth/1.8;
    return CGPointMake(width - radius * cos(angle), height - radius * sin(angle));
}

@end
