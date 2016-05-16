//
//  KBKeyboardController.m
//  
//
//  Created by 黄延 on 15/9/2.
//
//

#import "KBKeyboardController.h"

#import <pop/POP.h>

#import "KBSettingBarView.h"
#import "KBTimelineView.h"
#import "KBEmoticonTypePanelView.h"
#import "KBEmoticonMainPanelView.h"
#import "KBEmoticonDatabase.h"
#import "KBSettingsDatabase.h"
#import "KBEmoticonUsageReporter.h"

#import "KBEmoticonTypePanelCell.h"
#import "KBEmoticnMainCell.h"

#import "Emoticon.h"
#import "EmoticonType.h"

#import "KBSettingController.h"

#define KB_DEFAULT_MARKER_POS (M_PI/3)

@interface KBKeyboardController ()<KBEmoticonTypePanelDatasource, KBEmoticonMainPanelDataSource, POPAnimationDelegate, KBTimeLIneViewDelegate> {
    CGRect _initRect;           // init postion of the setting bar which is invisible
    CGRect _settingRect;        // target position of the animation of the setting bar, which is visible.
    BOOL _needReload;
}

#pragma mark Subviews

/**
 *  Time line marker layer.
 */
@property (nonatomic, strong) KBTimelineView *timeline;

/**
 *  Type display board
 */
@property (nonatomic, strong) KBEmoticonTypePanelView *panel;

/**
 *  This is where we display the emoticon-icons
 */
@property (nonatomic, strong) KBEmoticonMainPanelView *main;

/**
 *  Setting bar
 */
@property (nonatomic, strong) KBSettingBarView *settings;

#pragma mark Data maintaining

/**
 *  A pointer to the shared database. Do not create a database yourself.
 */
@property (nonatomic, strong) KBEmoticonDatabase *database;

/**
 *  Currently selected type
 */
@property (nonatomic, strong) EmoticonType *curType;

/**
 *  Selected emoticon
 */
@property (nonatomic, strong) Emoticon *selectedEmoticon;

/**
 *  This array tell you how the pages are divided
 */
@property (nonatomic, strong) NSArray *pageDivision;

/**
 *  The array of emoticons belonging to curType
 */
@property (nonatomic, strong) NSArray *curEmoticons;

@property (nonatomic, strong) NSArray *curETypeList;


@property (nonatomic, strong) UIButton *debug;

@end

@implementation KBKeyboardController

+ (void)environmentConfig:(NSDictionary *)option{
    
}

- (instancetype)init{
    if (self = [super init]) {
        // Local variables
        _needReload  = YES;
        //
        self.view.backgroundColor = [UIColor whiteColor];
        // Get the pointer to the database
        _database = [KBEmoticonDatabase sharedDatabase];
        // create subviews
        [self createSubviews];
        
        _debug = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        [self.view addSubview:_debug];
        [_debug addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
        
        // Add observer to listen to the emoticon updater
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newUpdateAvailabe:) name:KB_UPDATE_FINISHED_NOTIF object:nil];
    }
    return self;
}

- (void)test:(UIButton*)sender{
    [self launchAnimated:YES];
    sender.selected = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_curETypeList.count > 0) {
        [self cellSelectedForIndex:0];        
    }
    if (_needReload) {
        [_panel reload];
        [_main reload];
    }
    _needReload = NO;
}

- (void)createSubviews{
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
//    CGAffineTransform initTrans = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI/2);
    CATransform3D initTrans = CATransform3DMakeRotation(-M_PI, 0, 0, 1);
    
    
    // Initialize the setting bar
    _settings = [[KBSettingBarView alloc] init];
    [self.view addSubview:_settings];
    _settings.backgroundColor = [UIColor whiteColor];
    _settingRect = CGRectMake(0, height - 44, width, 44);
    _initRect = _settingRect;
    _initRect.origin.y = height;
    _settings.frame = _initRect;
    
    [_settings.quit addTarget:self action:@selector(quitTheKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [_settings.setting addTarget:self action:@selector(toggleSettings) forControlEvents:UIControlEventTouchUpInside];
    
    // Initialize the timeline
    _timeline = [[KBTimelineView alloc] initWithMarkerPosition:KB_DEFAULT_MARKER_POS];
    [self.view addSubview:_timeline];
    _timeline.layer.anchorPoint = CGPointMake(1, 1);
    _timeline.frame = CGRectMake(0, _settingRect.origin.y - width, width, width);
    _timeline.layer.transform = initTrans;
    _timeline.delegate = self;
    
    _curETypeList = [_database allEmoticonTypesAt:[_timeline markedTime]];
    
    // Initialize the type panel
    _panel = [[KBEmoticonTypePanelView alloc] initWithMarkerPosition:KB_DEFAULT_MARKER_POS];
    [self.view addSubview:_panel];
    _panel.backer = _timeline;
    _panel.delegate = self;
    CGFloat radius = width * 5 /6;
    _panel.layer.anchorPoint = CGPointMake(1, 1);
    _panel.frame = CGRectMake(width - radius, _settingRect.origin.y - radius, radius, radius);
    _panel.layer.transform = initTrans;
    
    // Initialize the emoticon display panel

    _main = [[KBEmoticonMainPanelView alloc] init];
    _main.backer = _panel;
    _main.delegate = self;
    [self.view addSubview:_main];
    radius = width * 4 / 6;
    _main.layer.anchorPoint = CGPointMake(1, 1);
    _main.frame = CGRectMake(width - radius, _settingRect.origin.y - radius, radius, radius);
    _main.layer.transform = initTrans;
    
    // Bring the setting bar to the toppest layer
    [self.view bringSubviewToFront:_settings];
    
    // Set all the subviews to invisible, you need to invoke -launchAnimated: to make them visible
    [_settings setHidden:YES];
    [_timeline setHidden:YES];
    [_panel setHidden:YES];
    [_main setHidden:YES];
}

- (void)launchAnimated:(BOOL)animated{
    if (_delegate && [_delegate respondsToSelector:@selector(keyboardWillStartLaunching:)]) {
        [_delegate keyboardWillStartLaunching:self];
    }
    
    if (_needReload) {
        [_panel reload];
        [_main reload];
    }
    
    if (animated) {
        POPSpringAnimation *animMain = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
        animMain.fromValue = @(-M_PI);
        animMain.toValue = @(0);
        animMain.beginTime = 0;
        animMain.springBounciness = 10;
        [_main.layer pop_addAnimation:animMain forKey:@"kb_launch"];
        
        POPSpringAnimation *animType = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
        animType.fromValue = @(-M_PI);
        animType.toValue = @(0);
        animType.beginTime = 0.2;
        animType.springBounciness = 6;
        [_panel.layer pop_addAnimation:animType forKey:@"kb_launch"];
        
        POPSpringAnimation *animTime = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
        animTime.fromValue = @(-M_PI);
        animTime.toValue = @(0);
        animTime.beginTime = 0.4 ;
        animTime.springBounciness = 4;
        animTime.name = @"kb_lauch";
        animTime.delegate = self;
        [_timeline.layer pop_addAnimation:animTime forKey:@"kb_launch"];
        
        POPBasicAnimation *animSetting = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
        
        animSetting.fromValue = [NSValue valueWithCGRect:_initRect];
        animSetting.toValue = [NSValue valueWithCGRect:_settingRect];
        [_settings.layer pop_addAnimation:animSetting forKey:@"kb_launch"];
        [_settings setHidden:NO];
        [_timeline setHidden:NO];
        [_panel setHidden:NO];
        [_main setHidden:NO];
    }else{
        _main.layer.transform = CATransform3DIdentity;
        _panel.layer.transform = CATransform3DIdentity;
        _timeline.layer.transform = CATransform3DIdentity;
        _settings.frame = _settingRect;
        [_settings setHidden:NO];
        [_timeline setHidden:NO];
        [_panel setHidden:NO];
        [_main setHidden:NO];
        if (_delegate && [_delegate respondsToSelector:@selector(keyboardDidFinishLaunching:)]) {
            [_delegate keyboardDidFinishLaunching:self];
        }
    }
    
    _needReload = NO;
}

- (void)dismissKeyboardAnimated:(BOOL)animated{
    if (_delegate && [_delegate respondsToSelector:@selector(keyboardWillStartDismissing:)]) {
        [_delegate keyboardWillStartDismissing:self];
    }
    if (animated) {
        POPSpringAnimation *animMain = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
        animMain.fromValue = @(0);
        animMain.toValue = @(-M_PI);
        animMain.beginTime = 0;
        animMain.springBounciness = 10;
        [_main.layer pop_addAnimation:animMain forKey:@"kb_dismiss"];
        
        POPSpringAnimation *animType = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
        animType.fromValue = @(0);
        animType.toValue = @(-M_PI);
        animType.beginTime = 0.2;
        animType.springBounciness = 6;
        [_panel.layer pop_addAnimation:animType forKey:@"kb_dismiss"];
        
        POPSpringAnimation *animTime = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
        animTime.fromValue = @(0);
        animTime.toValue = @(-M_PI);
        animTime.beginTime = 0.4 ;
        animTime.springBounciness = 4;
        animTime.delegate = self;
        animTime.name = @"kb_dismiss";
        [_timeline.layer pop_addAnimation:animTime forKey:@"kb_dismiss"];
        
        POPBasicAnimation *animSetting = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
        animSetting.fromValue = [NSValue valueWithCGRect:_settingRect];
        animSetting.toValue = [NSValue valueWithCGRect:_initRect];
        [_settings.layer pop_addAnimation:animSetting forKey:@"kb_dismiss"];
    }else{
        CATransform3D initTrans = CATransform3DMakeRotation(-M_PI/2, 0, 0, 1);
        _main.layer.transform= initTrans;
        _timeline.layer.transform = initTrans;
        _panel.layer.transform = initTrans;
        _settings.frame = _initRect;
        [_settings setHidden:YES];
        [_timeline setHidden:YES];
        [_panel setHidden:YES];
        [_main setHidden:YES];
        if (_delegate && [_delegate respondsToSelector:@selector(keyboardDidEndDismissing:)]) {
            [_delegate keyboardDidEndDismissing:self];
        }
    }
}

#pragma mark Setting bar button handler

- (void)toggleSettings{
    KBSettingController *settings = [[KBSettingController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settings];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)quitTheKeyboard{
    [self dismissKeyboardAnimated:YES];
}

#pragma mark timeline delegate

- (void)timeChanged:(NSInteger)markedTime{
    // NSLog(@"%ld", markedTime);
    _curETypeList = [_database allEmoticonTypesAt:markedTime];
    [_panel reload];
}

#pragma mark Delegate of animation

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished{
    if (finished) {
        if ([anim.name isEqualToString:@"kb_launch"]){
            if (_delegate && [_delegate respondsToSelector:@selector(keyboardDidFinishLaunching:)]) {
                [_delegate keyboardDidFinishLaunching:self];
            }
        }else if ([anim.name isEqualToString:@"kb_dismiss"]){
            [_settings setHidden:YES];
            [_timeline setHidden:YES];
            [_panel setHidden:YES];
            [_main setHidden:YES];
            if (_delegate && [_delegate respondsToSelector:@selector(keyboardDidEndDismissing:)]) {
                [_delegate keyboardDidEndDismissing:self];
            }
        }
    }
}

#pragma mark notification from the data source

- (void)newUpdateAvailabe:(NSNotification*)notif{
    if ([notif.name isEqualToString:KB_UPDATE_FINISHED_NOTIF]) {
        // [_panel reload];
        _needReload = YES;
    }
}

#pragma mark Delegate to provide date to the type panel

- (NSInteger)numberOfEmoticonTypes{
    return _curETypeList.count;
}

- (KBEmoticonTypePanelCell*)cellForIndex:(NSInteger)index{
    KBEmoticonTypePanelCell *cell = [_panel getAReusableCell];
    if (cell) {
        EmoticonType *etype = _curETypeList[index];
        cell.name.text = etype.name;
    }
    return cell;
}

- (void)cellSelectedForIndex:(NSInteger)index{
    _curType = _curETypeList[index];
    _curEmoticons = [_database emoticonsForType:_curType];
    NSInteger total = _curEmoticons.count;
    if (total <= 8) {
        _pageDivision = @[@(total)];
    }else{
        NSMutableArray *result = [NSMutableArray array];
        NSInteger min = total;
        
        NSInteger level = 2;
        while (min > 8) {
            min = total / level;
            level ++ ;
        }

        for (int i = 0; i < level-1; i++) {
            [result addObject:@(min)];
        }
        if(total - min * (level-1) > 0){
            [result addObject:@(total - min * (level-1))];
        }
        _pageDivision = result;
    }
    
    //
    [_main reload];
}

#pragma - mark Delegate to provide data to the emoticon panel

- (NSInteger)totalPageNum{
    return _pageDivision.count;
}


- (NSInteger)emoticonNumAtPage:(NSInteger)pageNum{
    return ((NSNumber*)_pageDivision[pageNum-1]).integerValue;
}

/**
 *  Provide cell info for the emoticon panel
 *
 *  @param pageNo start from 1
 *  @param index  start from 0
 *
 *  @return cell
 */
- (KBEmoticnMainCell*)cellAtPage:(NSInteger)pageNo atIndex:(NSInteger)index{
    NSInteger globalIndex = 0;
    for (int i = 0; i<pageNo-1; i++) {
        globalIndex += ((NSNumber*)_pageDivision[i]).integerValue;
    }
    globalIndex += index;
    KBEmoticnMainCell *cell = [_main getAReusableCell];
    cell.emticon = _curEmoticons[globalIndex];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)emoticonCellSelected:(KBEmoticnMainCell *)cell icon:(UIImage *)image{
    if (cell) {
        _selectedEmoticon = cell.emticon;
        if ([KBSettingsDatabase sharedDatabase].autoReportUsage) {
            KBEmoticonUsageReporter *reporter = [KBEmoticonUsageReporter reporter];
            [reporter sendUsageReportForEmoticon:_selectedEmoticon.code versionNo:_selectedEmoticon.version_no.integerValue at:[NSDate date]];
        }
        [_debug setImage:image forState:UIControlStateNormal];
        [_delegate keyboard:self didPickEmoticon:image];
    }else{
        _selectedEmoticon = nil;
    }
}

@end
