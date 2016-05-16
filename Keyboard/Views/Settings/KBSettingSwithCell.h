//
//  KBSettingSwithCell.h
//  
//
//  Created by 黄延 on 15/9/8.
//
//

#import <UIKit/UIKit.h>

@interface KBSettingSwithCell : UITableViewCell

@property (nonatomic, strong) NSString *userdefautKey;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UISwitch *switcher;

+ (NSString*)getReusableIdentifier;

@end
