//
//  KBSettingsDatabase.h
//  
//
//  Created by 黄延 on 15/9/7.
//
//

#import <Foundation/Foundation.h>

#import "KBGlobalSetup.h"

@class KBSettingsDatabase;

@protocol KBSettingsDatabaseDelegate <NSObject>

@required
/**
 *  Invoked when allTypes are available, notice that the array here contains nsdictionary other than EmoticonType
 */
- (void)database:(KBSettingsDatabase*)database allTypesListAvailable:(NSArray*)allTypes;

@optional
/**
 *  Invoked when error occusr when loading type info
 */
- (void)database:(KBSettingsDatabase *)database ErrorOccurs:(NSError*)error;

@end

@interface KBSettingsDatabase : NSObject

+ (KBSettingsDatabase*)sharedDatabase;

@property (nonatomic, strong, readonly) NSString *autoUpdateEnabledKey;

@property (nonatomic) BOOL autoUpdateEnabled;

@property (nonatomic, strong, readonly) NSString *autoReportUsageKey;

@property (nonatomic) BOOL autoReportUsage;

@property (nonatomic, strong) NSArray *allTypes;

@property (nonatomic, strong) NSArray *selectedIdList;

@property (nonatomic, weak) id<KBSettingsDatabaseDelegate>delegate;

/**
 *  Reload type info from the server.
 */
- (void)reloadFromServer;

/**
 *  Remove an emoticon type which has been installed
 *
 *  @param typeId type id
 */
- (void)removeTypeWithID:(NSString*)typeId;

- (void)addTypeWithID:(NSString*)typeId;

@end
