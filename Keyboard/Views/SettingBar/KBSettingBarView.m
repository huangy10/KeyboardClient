//
//  KBSettingBarView.m
//  
//
//  Created by 黄延 on 15/8/30.
//
//

#import "KBSettingBarView.h"

#import <Masonry.h>

@implementation KBSettingBarView

- (instancetype)init{
    if (self = [super init]) {
        _setting = [[KBButton alloc] init];
        _setting.icon.image = [UIImage imageNamed:@"setting_button"];
        [self addSubview:_setting];
        [_setting mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).with.offset(-10);
            make.height.equalTo(self).multipliedBy(0.6);
            make.width.equalTo(_setting.mas_height);
        }];
        [_setting.icon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_setting);
            make.size.equalTo(_setting).multipliedBy(0.7);
        }];
        _quit = [[KBButton alloc] init];
        _quit.icon.image = [UIImage imageNamed:@"quit_button"];
        [self addSubview:_quit];
        [_quit mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).with.offset(10);
            make.height.equalTo(self).multipliedBy(0.6);
            make.width.equalTo(_quit.mas_height);
        }];
        [_quit.icon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_quit);
            make.size.equalTo(_quit).multipliedBy(0.7);
        }];
//        UIView *border = [[UIView alloc] init];
//        border.backgroundColor = [UIColor grayColor];
//        [self addSubview:border];
//        [border mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.height.equalTo(@1);
//            make.width.equalTo(self);
//            make.top.equalTo(self);
//            make.centerX.equalTo(self);
//        }];
    }
    return self;
}

@end
