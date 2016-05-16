//
//  KBSettingEmoticonCell.m
//  
//
//  Created by 黄延 on 15/9/7.
//
//

#import "KBSettingEmoticonCell.h"

#import <Masonry.h>

@implementation KBSettingEmoticonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews{
    // Create icon
    _icon = [[UIImageView alloc] init];
    [self.contentView addSubview:_icon];
    _icon.backgroundColor=  [UIColor clearColor];
    [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.height.equalTo(self.contentView).multipliedBy(0.6);
        make.width.equalTo(_icon.mas_height);
        make.leftMargin.equalTo(_icon.mas_topMargin);
    }];

    // title
    _title = [[UILabel alloc] init];
    [self.contentView addSubview:_title];
    _title.font = [UIFont systemFontOfSize:14];
    NSString *placeholder = @"表情的标题大概十个字";
    CGSize textSize = [placeholder sizeWithAttributes:@{NSFontAttributeName: _title.font}];
    [_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_icon.mas_right).with.offset(10);
        make.bottom.equalTo(_icon.mas_centerY);
        make.size.equalTo([NSValue valueWithCGSize:textSize]);
    }];
    
    _timePeriod = [[UILabel alloc] init];
    [self.contentView addSubview:_timePeriod];
    _timePeriod.font = [UIFont systemFontOfSize:10];
    _timePeriod.textAlignment = NSTextAlignmentLeft;
    _timePeriod.lineBreakMode = NSLineBreakByWordWrapping;
    _timePeriod.numberOfLines = 2;
    placeholder = @"00:00-00:00  ";
    textSize = [placeholder sizeWithAttributes:@{NSFontAttributeName: _timePeriod.font}];
    [_timePeriod mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_title).with.offset(4);
        make.top.equalTo(_title.mas_bottom);
        make.size.equalTo([NSValue valueWithCGSize:textSize]);
    }];
    
    _operation = [[UIButton alloc] init];
    [self.contentView addSubview:_operation];
    _operation.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1].CGColor;
    _operation.layer.borderWidth = 1;
    [_operation setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _operation.titleLabel.font = [UIFont systemFontOfSize:10];
    [_operation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.size.equalTo([NSValue valueWithCGSize:CGSizeMake(48, 29)]);
        make.right.equalTo(self.contentView).with.offset(-24);
    }];
    
    [_operation addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self layoutIfNeeded];
    _icon.layer.cornerRadius = self.icon.frame.size.width/2;
}

+ (NSString*)getReusableIdentifier{
    return @"kb_setting_emoticon_cell";
}

- (void)buttonPressed:(UIButton*)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(cell:RequestPerformOperation:)]) {
        [_delegate cell:self RequestPerformOperation:sender.titleLabel.text];
    }
}

@end
