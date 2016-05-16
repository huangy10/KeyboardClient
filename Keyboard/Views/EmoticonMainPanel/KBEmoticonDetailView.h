//
//  KBEmoticonDetailView.h
//  
//
//  Created by 黄延 on 15/9/2.
//
//

#import <UIKit/UIKit.h>

@interface KBEmoticonDetailView : UIView

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic) CGFloat contentRadius;

@property (nonatomic) CGFloat arrowPos;

@property (nonatomic) CGPoint anchorPoint;

@end
