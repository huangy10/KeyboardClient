//
//  KBSettingsDatabase.m
//  
//
//  Created by 黄延 on 15/9/7.
//
//

#import "KBSettingsDatabase.h"

#import <BlocksKit.h>

#import "KBEmoticonTypesList.h"
#import "KBEmoticonDatabase.h"

#import "EmoticonType.h"

@interface KBSettingsDatabase ()

@property (nonatomic, strong) KBEmoticonTypesList *typeList;

@end

@implementation KBSettingsDatabase

+ (KBSettingsDatabase*)sharedDatabase{
    static KBSettingsDatabase   *sharedDatabase;
    static dispatch_once_t      onceToken;
    dispatch_once(&onceToken, ^{
        sharedDatabase = [[KBSettingsDatabase alloc] initPrivate];
    });
    return sharedDatabase;
}

- (instancetype)initPrivate{
    if (self = [super init]) {
        _autoUpdateEnabledKey = @"kb_auto_update_enabled";
        _autoUpdateEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:_autoUpdateEnabledKey];
        _autoReportUsageKey = @"kb_auto_report_enabled";
        _autoReportUsage = [[NSUserDefaults standardUserDefaults] boolForKey:_autoReportUsageKey];
        
        _typeList = [KBEmoticonTypesList typeListManager];
    }return self;
}

- (void)reloadFromServer{
    [_typeList allTypesOnComplete:^(NSError *error, NSArray *data){
        if (_delegate && [_delegate respondsToSelector:@selector(database:allTypesListAvailable:)]) {
            _allTypes = data;
            [_delegate database:self allTypesListAvailable:data];
        }
    } error:^(NSError *error){
        if (_delegate && [_delegate respondsToSelector:@selector(database:ErrorOccurs:)]) {
            [_delegate database:self ErrorOccurs:error];
        }
    }];
}

- (void)removeTypeWithID:(NSString *)typeId{
    [_typeList removeEmoticonTypeWithID:typeId];
}

- (void)addTypeWithID:(NSString *)typeId{
    [_typeList addEmoticonTypeWithID:typeId];
}

- (NSArray*)selectedIdList{
    NSArray *selectedTypes = [_typeList selectedTypes];
    NSArray *result = [selectedTypes bk_map:^id(EmoticonType* obj) {
        return obj.e_id;
    }];
    _selectedIdList = result;
    return result;
}

@synthesize autoReportUsage = _autoReportUsage;

- (BOOL)autoReportUsage{
    _autoReportUsage = [[NSUserDefaults standardUserDefaults] boolForKey:_autoReportUsageKey];
    return _autoReportUsage;
}

- (void)setAutoReportUsage:(BOOL)autoReportUsage{
    _autoReportUsage = autoReportUsage;
    [[NSUserDefaults standardUserDefaults] setBool:autoReportUsage forKey:_autoReportUsageKey];
}

@synthesize autoUpdateEnabled = _autoUpdateEnabled;

- (BOOL)autoUpdateEnabled{
    _autoUpdateEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:_autoUpdateEnabledKey];
    return _autoUpdateEnabled;
}

- (void)setAutoUpdateEnabled:(BOOL)autoUpdateEnabled{
    _autoUpdateEnabled = autoUpdateEnabled;
    [[NSUserDefaults standardUserDefaults] setBool:autoUpdateEnabled forKey:_autoUpdateEnabledKey];
}

@end
