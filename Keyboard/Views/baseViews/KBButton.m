//
//  KBButton.m
//  
//
//  Created by 黄延 on 15/8/30.
//
//

#import "KBButton.h"

#import <Masonry.h>

@implementation KBButton

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        _icon = [[UIImageView alloc] init];
        _icon.backgroundColor = [UIColor clearColor];
        [self addSubview:_icon];
        [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

@end
