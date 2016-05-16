//
//  KBEmoticonMainPanelView.h
//  
//
//  Created by 黄延 on 15/8/29.
//
//

#import <UIKit/UIKit.h>

@class KBEmoticnMainCell;

@protocol KBEmoticonMainPanelDataSource <NSObject>

@required

/**
 *  Total page number
 *
 *  @return NSInteger
 */
- (NSInteger)totalPageNum;

/**
 *  Get emoticon number for given page
 *
 *  @param pageNum page index
 *
 *  @return NSInteger
 */
- (NSInteger)emoticonNumAtPage:(NSInteger)pageNum;

/**
 *  provide cell for given position.
 *
 *  @param pageNo page no.
 *  @param index  index in the given page
 *
 *  @return cell
 */
- (KBEmoticnMainCell*)cellAtPage:(NSInteger)pageNo atIndex:(NSInteger)index;

/**
 *  Invoked when a cell is selected
 *
 *  @param cell cell
 */
- (void)emoticonCellSelected:(KBEmoticnMainCell* )cell icon:(UIImage*)image;

@end

#import "KBTouchableChainedCircleView.h"

@interface KBEmoticonMainPanelView : KBTouchableChainedCircleView

/**
 *  Current Page No.
 */
@property (nonatomic) NSInteger pageNo;

/**
 *  Total pages
 */
@property (nonatomic) NSInteger totalPages;

/**
 *  Delegate which provide data for this view, notice that reset this delegate will cause the view to reload automatically.
 */
@property (nonatomic, weak) id<KBEmoticonMainPanelDataSource> delegate;

/**
 *  Array of all visible cells
 */
@property (nonatomic, strong, readonly) NSArray* visibleCells;

/**
 *  Get a reusable cell from the pool
 *
 *  @return KBEmotionCell
 */
- (KBEmoticnMainCell*)getAReusableCell;

/**
 *  Reload data from delegate
 */
- (void)reload;


@end
