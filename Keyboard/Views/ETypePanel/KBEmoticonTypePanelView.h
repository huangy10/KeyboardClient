//
//  KBEmoticonTypePanelView.h
//  
//
//  Created by 黄延 on 15/8/29.
//
//

#import <UIKit/UIKit.h>

#import "KBTouchableWheelView.h"

#import "KBTouchableChainedCircleView.h"

@class KBEmoticonTypePanelCell;

@protocol KBEmoticonTypePanelDatasource <NSObject>

@required

/**
 *  Total Number of emoticon types
 *
 *  @return num of types
 */
- (NSInteger)numberOfEmoticonTypes;

/**
 *  Provide cell for given index
 *
 *  @param index integer
 *
 *  @return cell
 */
- (KBEmoticonTypePanelCell* __nonnull)cellForIndex:(NSInteger)index;

/**
 *  Invoked when a cell is selected
 *
 *  @param index integer
 */
- (void)cellSelectedForIndex:(NSInteger)index;

@end


@interface KBEmoticonTypePanelView : KBTouchableChainedCircleView

/**
 *  Touchable wheel to provide rotating support
 */
@property (nonatomic, strong) KBTouchableWheelView  * __nonnull wheel;

@property (nonatomic) CGFloat wheelWidth;

/**
 *  Pos, in radian.
 */
@property (nonatomic) CGFloat markerAngle;

/**
 *  Interval in radian.
 */
@property (nonatomic) CGFloat markerInterval;

/**
 *  Visible cells.
 */
@property (nonatomic, readonly) NSArray * __nonnull visibleCells;

/**
 *  Number of all cells.
 */
@property (nonatomic) NSInteger cellNum;

/**
 *  Datasource.
 */
@property (nonatomic, weak) id<KBEmoticonTypePanelDatasource> delegate;

/**
 *  Init by giving position of the marker.
 *
 *  @param markerAngle marker position, in radian.
 *
 *  @return instance
 */
- (nonnull instancetype)initWithMarkerPosition:(CGFloat)markerAngle;

/**
 *  layout the types
 */
- (void)layoutScales;

/**
 *  Like -reload of UITableView, reload data from data source.
 */
- (void)reload;

/**
 *  Get or create a reusable cell
 *
 *  @return cell.
 */
- (KBEmoticonTypePanelCell* __nonnull)getAReusableCell;

@end
