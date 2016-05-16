//
//  KBTestViewController.m
//  
//
//  Created by 黄延 on 15/8/29.
//
//

#import "KBTestViewController.h"

#import <Masonry.h>

#import "KBEmoticonTypePanelCell.h"
#import "KBEmoticnMainCell.h"
#import "KBEmoticonDatabase.h"
#import "EmoticonType.h"

#define KB_DEFAULT_MARKER_POS (M_PI/3)

@interface KBTestViewController ()<KBEmoticonTypePanelDatasource, KBEmoticonMainPanelDataSource>

@property (nonatomic, strong) KBEmoticonDatabase *database;

@end

@implementation KBTestViewController

- (instancetype)init{
    if (self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        [self createSubviews];
        _database = [KBEmoticonDatabase sharedDatabase];
        [self.view bringSubviewToFront:_settings];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newUpdateAvailabe:) name:KB_UPDATE_FINISHED_NOTIF object:nil];
    }
    return self;
}

- (void)createSubviews{
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    CGAffineTransform initTrans = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI/2);
    
    // Initialize the setting bar
    _settings = [[KBSettingBarView alloc] init];
    [self.view addSubview:_settings];
    _settings.backgroundColor = [UIColor whiteColor];
    _settings.frame = CGRectMake(0, height - 44, width, 44);
    
    // Initialize the timeline
    _timeline = [[KBTimelineView alloc] initWithMarkerPosition:KB_DEFAULT_MARKER_POS];
    [self.view addSubview:_timeline];
    _timeline.layer.anchorPoint = CGPointMake(1, 1);
    _timeline.frame = CGRectMake(0, _settings.frame.origin.y - width, width, width);
    _timeline.transform = initTrans;
    
    // Initialize the type panel
    _panel = [[KBEmoticonTypePanelView alloc] initWithMarkerPosition:KB_DEFAULT_MARKER_POS];
    [self.view addSubview:_panel];
    _panel.backer = _timeline;
    _panel.delegate = self;
    CGFloat radius = width * 5 /6;
    _panel.layer.anchorPoint = CGPointMake(1, 1);
    _panel.frame = CGRectMake(width - radius, _settings.frame.origin.y - radius, radius, radius);
    _panel.transform = initTrans;
    
    // Initialize the emoticon display panel
    
    _main = [[KBEmoticonMainPanelView alloc] init];
    _main.backer = _panel;
    _main.delegate = self;
    [self.view addSubview:_main];
    radius = width * 4 / 6;
    _main.layer.anchorPoint = CGPointMake(1, 1);
    _main.frame = CGRectMake(width - radius, _settings.frame.origin.y - radius, radius, radius);
    _main.transform = initTrans;
    
    // Bring the setting bar to the toppest layer
    [self.view bringSubviewToFront:_settings];
}


- (void)newUpdateAvailabe:(NSNotification*)notif{
    if ([notif.name isEqualToString:KB_UPDATE_FINISHED_NOTIF]) {
        [_panel reload];
    }
}


#pragma mark delegate function for type wheel

- (NSInteger)numberOfEmoticonTypes{
    return 10;
    // return _database.allEmoticonTypes.count;
}

- (KBEmoticonTypePanelCell*)cellForIndex:(NSInteger)index{
    KBEmoticonTypePanelCell *cell = [_panel getAReusableCell];
    if (cell) {
//        [cell setTitle:[NSString stringWithFormat:@"Index:%ld",(long)index] forState:UIControlStateNormal];
    //     EmoticonType *etype = _database.allEmoticonTypes[index];
   //     cell.name.text = etype.name;
        cell.name.text = [NSString stringWithFormat:@"%ld", (long)index];
        
    }
    return cell;
}

- (void)cellSelectedForIndex:(NSInteger)index{
    
}

#pragma mark delegate function for emoticon panel

- (NSInteger)totalPageNum{
    return 4;
}

- (KBEmoticnMainCell*)cellAtPage:(NSInteger)pageNo atIndex:(NSInteger)index{
    KBEmoticnMainCell *cell = [_main getAReusableCell];
    cell.backgroundColor = [UIColor grayColor];
    return cell;
}

- (NSInteger)emoticonNumAtPage:(NSInteger)pageNum{
    return rand() % 8 + 1;
}

@end
