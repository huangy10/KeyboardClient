//
//  KBTimelineMarkerView.h
//  
//
//  Created by 黄延 on 15/8/29.
//
//

#import <UIKit/UIKit.h>

@interface KBTimelineMarkerView : UIView

/**
 *  Label to display time
 */
@property (nonatomic, strong) UILabel *label;

/**
 *  Label to display 'now' mark
 */
@property (nonatomic, strong) UILabel *now;

/**
 *  time represented, in hours
 */
@property (nonatomic) int time;

/**
 *  Whether the marker is marked as selected
 */
@property (nonatomic) BOOL marked;

/**
 *  Current angle position
 */
@property (nonatomic) double curAngle;


- (void)layoutLabels;


@end
