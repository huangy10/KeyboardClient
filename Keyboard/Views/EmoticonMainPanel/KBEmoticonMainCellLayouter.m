//
//  KBEmoticonMainCellLayouter.m
//  
//
//  Created by 黄延 on 15/9/2.
//
//

#import "KBEmoticonMainCellLayouter.h"

#import "KBGlobalSetup.h"

@implementation KBEmoticonMainCellLayouter

+ (KBEmoticonMainCellLayouter*)layouter{
    static KBEmoticonMainCellLayouter *layouter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        layouter = [[KBEmoticonMainCellLayouter alloc] init];
    });
    return layouter;
}

- (CGRect)frameForLevel:(NSInteger)level index:(NSInteger)index{
    // level ranges from 1 to 8, index is always smaller than level.
    static CGRect frame[36];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat scale = width / 375.0;
        // level 1
        frame[0] = CGRectMake(156, 109, 56, 56);
        // level 2
        frame[1] = CGRectMake(192, 158, 56, 56);
        frame[2] = CGRectMake(136, 81, 56, 56);
        // level 3
        frame[3] = CGRectMake(192, 158, 56, 56);
        frame[4] = CGRectMake(98, 130, 56, 56);
        frame[5] = CGRectMake(204, 72, 44, 44);
        // level 4
        frame[6] = CGRectMake(198, 171, 56, 56);
        frame[7] = CGRectMake(162, 106, 56, 56);
        frame[8] = CGRectMake(73.5, 179, 48, 48);
        frame[9] = CGRectMake(98, 92, 44, 44);
        // level 5
        frame[10] = CGRectMake(198, 171, 56, 56);
        frame[11] = CGRectMake(162, 106, 56, 56);
        frame[12] = CGRectMake(73.5, 179, 48, 48);
        frame[13] = CGRectMake(98, 92, 44, 44);
        frame[14] = CGRectMake(210, 48, 44, 44);
        // level 6
        frame[15] = CGRectMake(198, 171, 56, 56);
        frame[16] = CGRectMake(142, 136, 48, 48);
        frame[17] = CGRectMake(219, 99.5, 48, 48);
        frame[18] = CGRectMake(86, 105.5, 48, 48);
        frame[19] = CGRectMake(154, 72, 44, 44);
        frame[20] = CGRectMake(73.5, 178, 48, 48);
        // level 7
        frame[21] = CGRectMake(198, 171, 56, 56);
        frame[22] = CGRectMake(142, 136, 48, 48);
        frame[23] = CGRectMake(219, 99.5, 48, 48);
        frame[24] = CGRectMake(86, 105.5, 48, 48);
        frame[25] = CGRectMake(154, 72, 44, 44);
        frame[26] = CGRectMake(73.5, 178, 48, 48);
        frame[27] = CGRectMake(219, 27.5, 44, 44);
        // level 8
        frame[28] = CGRectMake(198, 176, 56, 56);
        frame[29] = CGRectMake(152, 123, 48, 48);
        frame[30] = CGRectMake(119, 190, 48, 48);
        frame[31] = CGRectMake(217, 99.5, 48, 48);
        frame[32] = CGRectMake(84, 116, 48, 48);
        frame[33] = CGRectMake(154, 55.5, 44, 44);
        frame[34] = CGRectMake(54, 182, 44, 44);
        frame[35] = CGRectMake(217, 33.5, 44, 44);
        
        // Scale to screen size.
        for (int i = 0; i < 36; i++) {
            CGRect tmp = frame[i];
            tmp.origin.x -= 20;
            tmp.origin.x *= scale;
            tmp.origin.y *= scale;
            tmp.size.width *= scale;
            tmp.size.height *= scale;
            frame[i] = tmp;
        }
    });
    NSInteger i = level * (level-1) / 2 + index;
    if (i >= 36 || i < 0) {
        WRLog(@"Invalid level and index");
    }
    return frame[i];
}

@end
