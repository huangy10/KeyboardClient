//
//  KBEmoticonDatabase.m
//  
//
//  Created by 黄延 on 15/8/22.
//
//

// header file of current class
#import "KBEmoticonDatabase.h"
// packages from sys
#import <CoreData/CoreData.h>
// packages from 3rd party
// header files for other classes in this proj
#import "KBGlobalSetup.h"

#import "EmoticonType.h"

@interface KBEmoticonDatabase (){
    NSArray *_cachedTypes;
}

@property (nonatomic, weak) NSManagedObjectContext *managedContext;

@end

@implementation KBEmoticonDatabase

+ (KBEmoticonDatabase*)sharedDatabase{
    static KBEmoticonDatabase *sharedDatabase;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDatabase = [[KBEmoticonDatabase alloc] initPrivate];
    });
    return sharedDatabase;
}

- (instancetype)initPrivate{
    self = [super init];
    if (self) {
        // Get a pointer to the context defined in appdelegate
        _managedContext = [[[UIApplication sharedApplication] delegate] performSelector:@selector(managedObjectContext)];
        // Listen to the notification posted by the updater
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newUpdateAvailable:) name:KB_UPDATE_FINISHED_NOTIF object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray*)allEmoticonTypes{
    if (_cachedTypes != nil) {
        return _cachedTypes;
    }
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmoticonType" inManagedObjectContext:_managedContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order_weight"
                                                                   ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [_managedContext executeFetchRequest:fetchRequest error:&error];
    _cachedTypes = fetchedObjects;
    return _cachedTypes;
}

- (NSArray*)allEmoticonTypesAt:(NSInteger)time{
    NSArray *all = [self allEmoticonTypes];
    NSMutableArray *result = [NSMutableArray array];
    for (EmoticonType *e_type in all) {
        NSInteger start = e_type.tm_start_h.integerValue;
        NSInteger end = e_type.tm_end_h.integerValue;
        if (end > start) {
            if (time >= start && time <= end) {
                [result addObject:e_type];
            }else{
                continue;
            }
        }else if (end < start){
            if (time >= end || time <= start) {
                [result addObject:e_type];
            }else{
                continue;
            }
        }else{
            [result addObject:e_type];
        }
    }
    return result;
}

- (NSArray*)emoticonsForType:(EmoticonType *)e_type{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Emoticon" inManagedObjectContext:_managedContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@", e_type];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order_weight"
                                                                   ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [_managedContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        return nil;
    }else{
        return fetchedObjects;
    }
}

- (void)newUpdateAvailable:(NSNotification*)notif{
    _cachedTypes = nil;
}

@end
