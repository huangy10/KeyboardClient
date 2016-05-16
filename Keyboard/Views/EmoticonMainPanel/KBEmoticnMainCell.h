//
//  KBEmoticnMainCell.h
//  
//
//  Created by 黄延 on 15/9/1.
//
//

#import "KBButton.h"

@class Emoticon;
@class KBEmoticnMainCell;

@protocol KBEmoticnMainCellDelegate <NSObject>

- (void)needToPresentDetail:(KBEmoticnMainCell*)cell;

@end

@interface KBEmoticnMainCell : KBButton

/**
 *  Emoticon displayed by this cell
 */
@property (nonatomic, strong) Emoticon *emticon;

/**
 *  Radius of the icon
 */
@property (nonatomic) CGFloat radius;

@property (nonatomic, weak) id<KBEmoticnMainCellDelegate>delegate;

@end
