//
//  KBSettingSwithCell.m
//  
//
//  Created by 黄延 on 15/9/8.
//
//

#import "KBSettingSwithCell.h"

#import <Masonry.h>

#import "KBSettingsDatabase.h"

@implementation KBSettingSwithCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _title = [[UILabel alloc] init];
        [self.contentView addSubview:_title];
        _title.font  = [UIFont systemFontOfSize:14];
        NSString *container = @"是否回报使用情况";
        CGSize textSize = [container sizeWithAttributes:@{NSFontAttributeName: _title.font}];
        [_title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@24);
            make.centerY.equalTo(self.contentView);
            make.size.equalTo([NSValue valueWithCGSize:textSize]);
        }];
        
        _switcher = [[UISwitch alloc] init];
        [self.contentView addSubview:_switcher];
        [_switcher mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            // make.height.equalTo(_title);
            make.width.lessThanOrEqualTo(@44);
            make.right.equalTo(self.contentView).with.offset(-24);
        }];
        
        [_switcher addTarget:self action:@selector(switchHanler:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

+ (NSString*)getReusableIdentifier{
    return @"kb_setting_switch_cell";
}

- (void)switchHanler:(UISwitch*)sender{
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:_userdefautKey];
}

@end
