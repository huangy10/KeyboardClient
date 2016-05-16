//
//  KBTestViewController.h
//  
//
//  Created by 黄延 on 15/8/29.
//
//

#import <UIKit/UIKit.h>

#import "KBTimelineView.h"
#import "KBEmoticonTypePanelView.h"
#import "KBEmoticonMainPanelView.h"
#import "KBSettingBarView.h"

@interface KBTestViewController : UIViewController

@property (nonatomic, strong) KBTimelineView *timeline;
@property (nonatomic, strong) KBEmoticonTypePanelView *panel;
@property (nonatomic, strong) KBEmoticonMainPanelView *main;
@property (nonatomic, strong) KBSettingBarView *settings;


@end
