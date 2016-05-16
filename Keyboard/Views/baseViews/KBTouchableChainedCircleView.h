//
//  KBTouchableChainedCircleView.h
//  
//
//  Created by 黄延 on 15/8/29.
//
//

#import <UIKit/UIKit.h>

/**
 *  This view make sure that the rect border of round touchable view won't block the touches for the view behind this view.
 */
@interface KBTouchableChainedCircleView : UIView

/**
 *  The view behind this view.
 */
@property (nonatomic, weak) UIView *backer;

@end
