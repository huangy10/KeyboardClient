//
//  KBEmoticonTypePanelCell.h
//  
//
//  Created by 黄延 on 15/8/30.
//
//

#import <UIKit/UIKit.h>

@interface KBEmoticonTypePanelCell : UIButton

@property (nonatomic) NSInteger index;

/**
 *  Name label
 */
@property (nonatomic, strong) UILabel *name;

/**
 *  In radian. This property is handled by the pannel view. Setting it in the controller will be ignored.
 */
@property (nonatomic) CGFloat pos;

@end
