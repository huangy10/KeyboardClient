//
//  KBSettingBarView.h
//  
//
//  Created by 黄延 on 15/8/30.
//
//

#import <UIKit/UIKit.h>

#import "KBButton.h"

@interface KBSettingBarView : UIView

/**
 *  Pop settings.
 */
@property (nonatomic, strong) KBButton *setting;

/**
 *  Quit the keyboard.
 */
@property (nonatomic, strong) KBButton *quit;

@end
