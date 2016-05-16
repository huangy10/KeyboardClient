//
//  KBButton.h
//  
//
//  Created by 黄延 on 15/8/30.
//
//

#import <UIKit/UIKit.h>

/**
 *  A button combining a UIButton and a separate UIImageView, which separate the display area size and the icon display area size.
 */
@interface KBButton : UIButton

@property (nonatomic, strong, readonly) UIImageView *icon;

@end
