//
//  KBEmoticonMainCellLayouter.h
//  
//
//  Created by 黄延 on 15/9/2.
//
//

#import <UIKit/UIKit.h>

/**
 *  This class handles the layout of cells in the container
 */
@interface KBEmoticonMainCellLayouter : NSObject

+ (KBEmoticonMainCellLayouter*)layouter;

- (CGRect)frameForLevel:(NSInteger)level index:(NSInteger)index;

@end
