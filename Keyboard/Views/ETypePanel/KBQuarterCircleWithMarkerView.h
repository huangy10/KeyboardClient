//
//  KBQuarterCircleWithMarkerView.h
//  
//
//  Created by 黄延 on 15/8/30.
//
//

#import "KBQuarterCircleView.h"

@interface KBQuarterCircleWithMarkerView : KBQuarterCircleView

@property (nonatomic) CGFloat pos;

- (instancetype)initWithMarkerPos:(CGFloat)pos color:(UIColor*)color;

@end
