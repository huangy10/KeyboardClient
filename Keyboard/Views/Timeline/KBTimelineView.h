//
//  KBTimelineView.h
//  
//
//  Created by 黄延 on 15/8/29.
//
//

#import "KBTouchableWheelView.h"

#import "KBTouchableChainedCircleView.h"

@protocol KBTimeLIneViewDelegate <NSObject>

/**
 *  Invoked when the marded time changed.
 *
 *  @param markedTime
 */
- (void)timeChanged:(NSInteger)markedTime;

@end

@interface KBTimelineView : KBTouchableChainedCircleView

/**
 *  Touchable wheel
 */
@property (nonatomic, strong) KBTouchableWheelView *wheel;

@property (nonatomic) CGFloat wheelWidth;

/**
 *  Current Selected Time
 */
@property (nonatomic) double curTime;

/**
 *  Time for 0 radian
 */
@property (nonatomic, strong) NSDate *horizontalTime;

/**
 *  in radians
 */
@property (nonatomic) CGFloat markerInterval;



/**
 *  Current Marker Postision. Notice the marker is not the
 */
@property (nonatomic) CGFloat markerAngle;

@property (nonatomic, weak) id<KBTimeLIneViewDelegate> delegate;

/**
 *  Invoke this function to initialize the view
 *
 *  @param markerAngle current angle postion of the marker of the type panel.
 *
 *  @return instance
 */
- (instancetype)initWithMarkerPosition:(CGFloat)markerAngle;

/**
 *  Initialize the scales.
 */
- (void)layoutScales;

/**
 *  Invoke this position to rotate the panel to make the marker pointing to the current time;
 */
- (void)scrollToNow;

/**
 *  Time (hour) marked by the marker
 *
 *  @return hour, (0~23)
 */
- (NSInteger)markedTime;

@end
