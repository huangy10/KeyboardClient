//
//  KBSettingEmoticonCell.h
//  
//
//  Created by 黄延 on 15/9/7.
//
//

#import <UIKit/UIKit.h>

#import "KBButton.h"

typedef enum {
    KBSettingCellOperationAdd,
    KBSettingCellOperationCancel,
    KBSettingCellOperationRemove
}KBSettingCellOperationType;

@class KBSettingEmoticonCell;

@protocol KBSettingEmoticonCellDelegate <NSObject>

- (void)cell:(KBSettingEmoticonCell*)cell RequestPerformOperation:(NSString*)operation;

@end

@interface KBSettingEmoticonCell : UITableViewCell

/**
 *  ICON of the emoticon type
 */
@property (nonatomic, strong) UIImageView *icon;

/**
 *  Name of the time
 */
@property (nonatomic, strong) UILabel *title;

/**
 *  Cooresponding time
 */
@property (nonatomic, strong) UILabel *timePeriod;

/**
 *  Operation
 */
@property (nonatomic, strong) UIButton *operation;

@property (nonatomic, strong) id<KBSettingEmoticonCellDelegate> delegate;

/**
 *  Get the reusable identifier for this cell
 *
 *  @return NSString
 */
+ (NSString*)getReusableIdentifier;

@end
