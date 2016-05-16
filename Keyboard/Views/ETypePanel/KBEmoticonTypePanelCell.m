//
//  KBEmoticonTypePanelCell.m
//  
//
//  Created by 黄延 on 15/8/30.
//
//

#import "KBEmoticonTypePanelCell.h"

#import <Masonry.h>

@implementation KBEmoticonTypePanelCell

- (instancetype)init{
    if (self = [super init]) {
        _name = [[UILabel alloc] init];
        _name.textColor = [UIColor whiteColor];
        _name.adjustsFontSizeToFitWidth = YES;
        _name.textAlignment = NSTextAlignmentCenter;
        // self.userInteractionEnabled = NO;
        [self addSubview:_name];
        [_name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

@end
