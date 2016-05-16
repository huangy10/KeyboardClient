//
//  KBEmoticonUpdater.m
//  
//
//  Created by 黄延 on 15/8/22.
//
//

#import "KBEmoticonUpdater.h"

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

#import <AFNetworking.h>
#import "NSTimer+AbsoluteFireDate.h"

#import "KBGlobalSetup.h"
#import "KBURLMaker.h"
#import "Emoticon.h"
#import "EmoticonType.h"
#import "KBUser.h"

@interface KBEmoticonUpdater ()

/**
 *  Where error info is stored.
 */
@property (nonatomic, strong, getter=errorInfo) NSError *error;

/**
 *  Timer to schedule the update check request.
 */
@property (nonatomic, strong) NSTimer *updateScheduler;

/**
 *  Context hold by this class
 */
@property (nonatomic, strong) NSManagedObjectContext *managedContext;

/**
 *  Persistent Store Coordinator hold by this class
 */
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 *  Working thread.
 */
@property (nonatomic, strong) NSThread *workingThread;

@end

@implementation KBEmoticonUpdater

+ (KBEmoticonUpdater*)updater{
    static KBEmoticonUpdater *updater;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        updater = [[KBEmoticonUpdater alloc] initPrivate];
    });
    return updater;
}

- (instancetype)initPrivate{
    self = [super init];
    if (self) {
        // Start the update-checking thread on start.
        [self performSelectorInBackground:@selector(checkUpdate) withObject:nil];
    }
    return self;
}

- (BOOL)checkUpdate{
    NSArray *versionInfo = [self constructLocalVersionInfo];

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
            @synchronized(_persistentStoreCoordinator){
                [self updateEmotions:response[@"update_list"]];
                [self deleteEmoticonTypes:response[@"deleted_types"]];
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
    // Check update again after 24 hours.
    NSDate *next = [NSDate dateWithTimeInterval:60*60*24 sinceDate:[NSDate date]];
    [self setScheduledUpdateDate:next];
    return YES;
}

/**
 *  This utility function load the version info of all emoticons and emoticon types.
 *
 *  @return result array.
 */
- (NSArray*)constructLocalVersionInfo{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmoticonType" inManagedObjectContext:self.managedContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSError *error = nil;
    NSArray *e_types = [self.managedContext executeFetchRequest:fetchRequest error:&error];
    if (e_types == nil) {
        WRLog(@"Fail to load EmoticonType data from core data.");
        return nil;
    }
    // Initialize the result array.
    NSMutableArray *result = [NSMutableArray array];
    for (EmoticonType *e_type in e_types) {
        // Fetch all emoticons for given type
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Emoticon" inManagedObjectContext:self.managedContext];
        [fetchRequest setEntity:entity];
        // Specify criteria for filtering which objects to fetch
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@", e_type];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *emoticons = [self.managedContext executeFetchRequest:fetchRequest error:&error];
        if (emoticons == nil) {
            WRLog(@"Fail to load EmoticonType data from core data.");
            return nil;
        }
        NSMutableDictionary *e_versions = [NSMutableDictionary dictionary];
        for (Emoticon *e in emoticons) {
            e_versions[e.code] = e.version_no;
        }
        // NSNumber *a = e_type.e_id;
        [result addObject:@{
                            @"emoticon_type_id": e_type.e_id,
                            @"emoticon_version_no": e_type.version_no,
                            @"emoticons": e_versions}];
    }
    return result;
}

/**
 *  This utility function handles type deletion according to response from check update
 *
 *  @param emoticonTypes emoticons to be deleted
 */
- (BOOL)deleteEmoticonTypes:(NSArray*)emoticonTypes{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmoticonType" inManagedObjectContext:self.managedContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"e_id IN %@", emoticonTypes];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil) {
        for (EmoticonType *etype in fetchedObjects) {
            [self.managedContext deleteObject:etype];
        }
    }else{
        WRLog(@"Emoticon Types to Be Deleted Are Not Found!");
        return NO;
    }
    [self saveContext];
    return YES;
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

- (NSError*)errorInfo{
    return _error;
}

- (void)setScheduledUpdateDate:(NSDate *)scheduledUpdateDate{
    // Setting new scheduled update date earlier than the former value is not acceptable.
    if (_scheduledUpdateDate != nil){
        switch ([_scheduledUpdateDate compare:scheduledUpdateDate]) {
            case NSOrderedDescending:
            case NSOrderedSame:
                WRLog(@"Error Occurs When Setting the Scheduled Update Date.");
                break;
                
            default:
                break;
        }
    }
    _scheduledUpdateDate = scheduledUpdateDate;
    //
    [_updateScheduler invalidate];
    _updateScheduler = [[NSTimer alloc] initWithFireDate:scheduledUpdateDate
                                                interval:0
                                                  target:self
                                                selector:@selector(checkUpdate) userInfo:nil
                                                 repeats:NO];
    _updateScheduler = [[NSTimer alloc] initWithAbsoluteFireDate:scheduledUpdateDate target:self selector:@selector(checkUpdate) userInfo:nil];
    // Note: A timer created with initWithFireDate must be added to a run loop manually

    [[NSRunLoop currentRunLoop] addTimer:_updateScheduler forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeInterval:10 sinceDate:_scheduledUpdateDate]];
}

#pragma mark Utility functions

/**
 *  This utility function check whether the two given dates are in the same day.
 *
 *  @param date1 data1 to be checked
 *  @param date2 date2 to be checked
 *
 *  @return BOOL response
 */
+ (BOOL)isDate:(NSDate*)date1 inTheSameDayAs:(NSDate*)date2{
    // For compatibiliy, use NSDateComponent to compare
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit| NSDayCalendarUnit;
    NSDateComponents *comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents *comp2 = [calendar components:unitFlags fromDate:date2];
    
    return  [comp1 year] == [comp2 year] &&
            [comp1 month] == [comp2 month] &&
            [comp1 day] == [comp2 day];
}

/**
 *  Create a new managed context for background usage
 *
 *  @return context
 */
- (NSManagedObjectContext*)managedContext{
    if (_managedContext != nil){
        return _managedContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (!coordinator) {
        return nil;
    }
    _managedContext = [[NSManagedObjectContext alloc] init];
    [_managedContext setPersistentStoreCoordinator:coordinator];
    _managedContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    return _managedContext;
}

- (void)saveContext{
    NSManagedObjectContext *managedObjectContext = self.managedContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator{
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    _persistentStoreCoordinator = [[[UIApplication sharedApplication] delegate] performSelector:@selector(persistentStoreCoordinator)];
//    // Create the coordinator and store
//    NSManagedObjectModel *managedObjectModel = [[[UIApplication sharedApplication] delegate] performSelector:@selector(managedObjectModel)];
//    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
//    
//    NSURL *applicationDocumententsDirectory = [[[UIApplication sharedApplication] delegate] performSelector:@selector(applicationDocumentsDirectory)];
//    NSURL *storeURL = [applicationDocumententsDirectory URLByAppendingPathComponent:@"Keyboard.sqlite"];
//    NSError *error = nil;
//    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
//    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
//        // Report any error we got.
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
//        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
//        dict[NSUnderlyingErrorKey] = error;
//        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
//        // Replace this with code to handle the error appropriately.
//        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
    
    return _persistentStoreCoordinator;
}
@end
