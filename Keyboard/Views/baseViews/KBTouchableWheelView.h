//
//  KBTouchableWheelView.h
//  
//
//  Created by 黄延 on 15/8/29.
//
//

#import <UIKit/UIKit.h>

#import "KBGlobalSetup.h"
#import "KBTouchableChainedCircleView.h"

@class KBTouchableWheelView;

/**
 *  Delegate through which the angle change of the wheel is broacasted
 */
@protocol KBTouchableWheelViewDelegate <NSObject>

@required
/**
 *  Invoked when the angle of the wheel changes
 *
 *  @param wheel  the pointer the the wheel
 *  @param dAlpha the change of the angle
 */
- (void)wheel:(KBTouchableWheelView*)wheel AngleChanged:(CGFloat)dAlpha;

/**
 *  Invoked
 *
 *  @param wheel pointer to the wheel
 */
- (void)wheelDidStopped:(KBTouchableWheelView*)wheel;

@optional
/**
 *  Invoked wheel double tap happends
 *
 *  @param wheel the pointer to the wheel
 */
- (void)wheelDoubleTapped:(KBTouchableWheelView *)wheel;

@end

@interface KBTouchableWheelView : KBTouchableChainedCircleView

/**
 *  Current angle of the wheel
 */
@property (nonatomic) CGFloat angle;

/**
 *  Delegate
 */
@property (nonatomic, weak) id<KBTouchableWheelViewDelegate> delegate;

/**
 *  Double tap
 */
@property (nonatomic) BOOL doubleTapEnabled;

/**
 *  Activate the inner inertial engine to make a simulated rotation for a given angle.
 *
 *  @param angle angle;
 */
- (void)scrollForAngle:(CGFloat)angle;

@end
