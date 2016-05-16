//
//  KBEmoticonTypesList.m
//  
//
//  Created by 黄延 on 15/8/25.
//
//

#import "KBEmoticonTypesList.h"

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

#import <PINCache.h>
#import <AFNetworking.h>

#import "KBURLMaker.h"
#import "KBUser.h"
#import "EmoticonType.h"
#import "Emoticon.h"

@interface KBEmoticonTypesList ()

/**
 *  Cache to save the types data for offline use.
 */
@property (nonatomic, strong) PINDiskCache *cache;

/**
 *  Pointer to the managed context of maniplate the CORE DATA database.
 */
@property (nonatomic, weak) NSManagedObjectContext *managedContext;

/**
 *  An array temporally holds the types' info.
 */
@property (nonatomic, strong) NSArray *allTypes;

@end

@implementation KBEmoticonTypesList

+ (KBEmoticonTypesList*)typeListManager{
    static KBEmoticonTypesList *list;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        list = [[KBEmoticonTypesList alloc] initPrivate];
    });
    return list;
}

- (instancetype)initPrivate{
    if (self = [super init]) {
        _cache = [[PINDiskCache alloc] initWithName:@"kbemoticontypeslist"];
        _managedContext = [[[UIApplication sharedApplication] delegate] performSelector:@selector(managedObjectContext)];
    }
    return self;
}

- (void)allTypesOnComplete:(KBCompleteBlock __nonnull)complete error:(KBErrorOccuranceBlock __nullable)error{
    NSURL *requestURL = [[KBURLMaker maker] allTypes];
    NSDictionary *param = [[KBUser sharedUser] authenticatedParam:nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:requestURL.absoluteString parameters:param success:^(AFHTTPRequestOperation * operation, id responseObj) {
        NSDictionary *response = (NSDictionary*)responseObj;
        // Update the cache
        _allTypes = response[@"emoticon_types"];
        [_cache setObject:_allTypes forKey:@"kbemoticontypeslist_cache" block:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(nil, _allTypes);
        });
    } failure:^(AFHTTPRequestOperation * operation, NSError * err) {
        // If it fails to connect to the server, load from cache.
        NSArray* data = (NSArray*)[_cache objectForKey:@"kbemoticontypeslist_cache"];
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(nil, data);
        });
        WRLog(@"Error Occurs When Requesting for All Types");
    }];
}

- (NSArray* __nullable)selectedTypes{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmoticonType" inManagedObjectContext:_managedContext];
    [fetchRequest setEntity:entity];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order_weight"
                                                                   ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *types = [_managedContext executeFetchRequest:fetchRequest error:&error];
    return types;
}

- (void)removeEmoticonTypeWithID:(NSString * __nonnull)e_id{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmoticonType" inManagedObjectContext:_managedContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"e_id == %@", e_id];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [_managedContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        WRLog(@"The EmoticonType You Want To Delete Is Not Found");
    }else if (fetchedObjects.count > 1){
        WRLog(@"Multiple EmoticonType Found for Given ID");
    }
    [_managedContext deleteObject:[fetchedObjects firstObject]];
    [self saveContext];
}

- (void)addEmoticonTypeWithDict:(NSDictionary * __nonnull)dict{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmoticonType" inManagedObjectContext:_managedContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"e_id == %@", dict[@"id"]];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSError *error = nil;
    NSArray *fetchedObjects = [_managedContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil && fetchedObjects.count > 0) {
        // If the given type already exist, do nothing and return
        WRLog(@"Duplicated EmoticonTypes");
        return;
    }
    // Otherwise create a new record for the given type
    EmoticonType *newType = (EmoticonType*)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:_managedContext];
    newType.e_id = dict[@"id"];
    newType.name = dict[@"name"];
    newType.version_no = @-1;           // Note:
    newType.tm_start_h = dict[@"time_mark_start_hour"];
    newType.tm_start_m = dict[@"time_mark_start_minute"];
    newType.tm_end_h = dict[@"time_mark_end_hour"];
    newType.tm_end_m = dict[@"time_mark_end_minute"];
    newType.order_weight = dict[@"order_weight"];
    [self saveContext];
    // TODO: handles downloading the emoticons
    NSArray *versionInfo = @[@{
                                  @"emoticon_type_id": newType.e_id,
                                  @"emoticon_version_no": newType.version_no,
                                  @"emoticons": @{}}];
    NSURL *requestURL = [[KBURLMaker maker] checkUpdate];
    NSDictionary *param = [[KBUser sharedUser] authenticatedParam:@{@"version_info": versionInfo}];
    // Get the operation manager  for request.
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:requestURL.absoluteString
       parameters:param
          success:^(AFHTTPRequestOperation *operation, id responseObj) {
              // Convert response obj to a dict.
              NSDictionary *response = (NSDictionary*)responseObj;
              if ([response[@"success"] boolValue]) {
                  NSPersistentStoreCoordinator *coordinator = [[[UIApplication sharedApplication] delegate] performSelector:@selector(persistentStoreCoordinator)];
                  @synchronized(coordinator){
                      [self updateEmotions:response[@"update_list"]];
                  }
                  //
                  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:KB_UPDATE_FINISHED_NOTIF object:nil]];
              }else{
                  WRLog(@"Unknown error occurs when checking version info");
              }
          } failure:^(AFHTTPRequestOperation * operation, NSError * err) {
              // Do nothing for now.
              WRLog(@"Fail to check version info");
          }];
}



- (void)addEmoticonTypeWithID:(NSString * __nonnull)e_id{
    if (_allTypes == nil || _allTypes.count == 0) {
        WRLog(@"Empty id or You Didn't Request For All Types");
        return;
    }
    // Scan the _allTypes to get the corresponding dict
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", e_id];
    NSArray* searchResult = [_allTypes filteredArrayUsingPredicate:predicate];
    if (searchResult == nil || searchResult.count != 1) {
        WRLog(@"No type or More Than One Types Are Found");
        return;
    }
    [self addEmoticonTypeWithDict:[searchResult firstObject]];
}

- (void)saveContext{
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(saveContext)];
}

#pragma mark Private utility function
/**
 *  This class construct a version check info for a given type. This is similar the the -contructLocalVersionInfo of KBEmoticonUpdater.
 *  
 *  @param  typeID id of the given emoticon type
 *  @return version info
 */
- (NSArray*)constructVersionDictForSingleEmoticonType:(NSString*)typeID{
    return @[@{@"emoticon_type_id": typeID, @"emoticon_version_no": @(-1), @"emoticons": @{}}];
}

- (BOOL)updateEmotions:(NSArray*)emoticons{
    for (NSDictionary* dict in emoticons) {
        NSFetchRequest *getType = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmoticonType" inManagedObjectContext:self.managedContext];
        [getType setEntity:entity];
        //
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"e_id == %@", dict[@"emoticon_type_id"]];
        //
        [getType setPredicate:filter];
        NSError *error = nil;
        NSArray *typeResult = [self.managedContext executeFetchRequest:getType error:&error];
        if (typeResult == nil || typeResult.count != 1) {
            WRLog(@"Emoticon with Given Type Not Found!");
            continue;
        }
        EmoticonType *e_type = typeResult.firstObject;
        e_type.version_no = dict[@"version_no"];
        e_type.order_weight = dict[@"order_weight"];
        e_type.name = dict[@"name"];
        e_type.tm_start_h = dict[@"time_mark_start_hour"];
        e_type.tm_start_m = dict[@"time_mark_start_min"];
        e_type.tm_end_h = dict[@"time_mark_end_hour"];
        e_type.tm_end_m = dict[@"time_mark_end_min"];
        
        // Get the emoticons to be updated
        NSArray *emoticons_update = (NSArray*)dict[@"emoticons"];
        for(NSDictionary *e_dict in emoticons_update){
            // Get current operation type: add, delete or update
            NSString *optype = e_dict[@"operation"];
            
            Emoticon *e_toManipulate = [Emoticon checkExistenseWithCode:dict[@"code"] inContext:self.managedContext];
            
            if ([optype isEqualToString:@"add"]) {
                if (e_toManipulate) {
                    WRLog(@"Invalid Add Operation");
                    continue;
                }
                NSEntityDescription *emoticonEntity = [NSEntityDescription entityForName:@"Emoticon" inManagedObjectContext:self.managedContext];
                Emoticon *newEmoticon = (Emoticon*)[[NSManagedObject alloc] initWithEntity: emoticonEntity insertIntoManagedObjectContext:self.managedContext];
                newEmoticon.code = e_dict[@"code"];
                newEmoticon.version_no = e_dict[@"version_no"];
                newEmoticon.order_weight = e_dict[@"order_weight"];
                newEmoticon.e_description = e_dict[@"description"];
                newEmoticon.type = e_type;
            }else if ([optype isEqualToString:@"delete"]){
                if (e_toManipulate) {
                    WRLog(@"Invalid Delete Operation");
                    continue;
                }
                [self.managedContext deleteObject:e_toManipulate];
            }else if ([optype isEqualToString:@"change"]){
                if (!e_toManipulate) {
                    WRLog(@"Invalid Change Operation");
                    continue;
                }
                e_toManipulate.code = e_dict[@"code"];
                e_toManipulate.version_no = e_dict[@"version_no"];
                e_toManipulate.order_weight = e_dict[@"order_weight"];
                e_toManipulate.e_description = e_dict[@"description"];
            }
        }
    }
    [self saveContext];
    return YES;
}

@end
