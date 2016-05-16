//
//  KBEmoticonMainContainerView.h
//  
//
//  Created by 黄延 on 15/9/1.
//
//

#import "KBTouchableChainedCircleView.h"

/**
 *  This class is used to contain cells in the panel view.
 */
@interface KBEmoticonMainContainerView : KBTouchableChainedCircleView

/**
 *  Set the rotating angle of the view. The anchor point is automatically set to the lower-right point of the view.
 *
 *  @param alpha in radian
 */
- (void)setRotatingAngle:(CGFloat)alpha;

@end
