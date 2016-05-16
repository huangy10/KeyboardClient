//
//  KBEmoticonUsageReporter.m
//  
//
//  Created by 黄延 on 15/8/22.
//
//

#import "KBEmoticonUsageReporter.h"

#import <PINDiskCache.h>
#import "Reachability.h"

#import "KBGlobalSetup.h"
#import "KBEmoticonUsage.h"

@interface KBEmoticonUsageReporter ()

/**
 *  Cache manager.
 *   
 *  Q: Why to use cache utilities here?
 *  A: Usually, the records which are not sent to the server yet stays in the queue named readyToSend. However, since the queue is in the memory rather than the disk, so when the app is terminated with records left to be sent, thos records are lost. As a solution to this problem, we save to queue to the disk cache every time this instance is dealloced.
 */
@property (nonatomic, strong) PINDiskCache *cache;

/**
 *  Listener for reachablity to the server.
 */
@property (nonatomic, strong) Reachability *reachable;

/**
 *  The usage records that are ready to be send.
 */
@property (nonatomic, strong) NSMutableArray *readyToSend;

/**
 *  Whether the reporter is sending data.
 */
@property BOOL sending;

@end

@implementation KBEmoticonUsageReporter

+ (KBEmoticonUsageReporter*)reporter{
    static KBEmoticonUsageReporter *reporter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reporter = [[KBEmoticonUsageReporter alloc] initPrivate];
    });
    return reporter;
}

- (instancetype)initPrivate{
    self = [super init];
    if (self) {
        _readyToSend = [NSMutableArray array];
        _sending = NO;
        // Init the disk cache manager
        _cache = [[PINDiskCache alloc] initWithName:@"updater"];
        // Check if there is already data in the cache.
        // load the data synchronously to avoid thread safety problem.
        NSArray *data = (NSArray*)[_cache objectForKey:@"usage_records"];
        if (data!=nil && data.count>0){
            // Cache data found, load the data from cache data.
            // Since it is the very begin of the initialization, thread safety is not a problem here.
            [_readyToSend addObjectsFromArray:data];
            [self setNeedsSending];
        }
        // Listener for network
        _reachable = [Reachability reachabilityWithHostName:KBHOST_NAME];
        _reachable.reachableOnWWAN = YES;
        _reachable.reachableBlock = ^(Reachability *reach){
            // This block will be invoked when the server becomes reachable again.
            // Load the records in cache to `readyToSend` queue.
            NSArray *data = (NSArray*)[_cache objectForKey:@"usage_records"];
            if (data!=nil && data.count > 0) {
                @synchronized(_readyToSend){
                    // lock the mutable array when writing to it.
                    [_readyToSend addObjectsFromArray:data];
                }
                [self setNeedsSending];
            }
        };
    }
    return self;
}

- (void)dealloc{
    [self saveQueueToCache:YES];
}

- (void)sendUsageReportForEmoticon:(NSString *)emoticonCode
                         versionNo:(NSInteger)versionNo
                                at:(NSDate *)useTime{
    KBEmoticonUsage *record = [[KBEmoticonUsage alloc] init];
    record.emoticonCode = emoticonCode;
    record.versionNo = [NSString stringWithFormat:@"%ld", (long)versionNo];
    record.date = useTime;
    @synchronized(_readyToSend){
        [_readyToSend addObject:record];
    }
    [self setNeedsSending];
}

- (void)setNeedsSending{
    // If the sending thread is not running, and the server is reachable, start sending in background.
    if (_sending == NO && !_reachable.isReachable) {
        [self performSelectorInBackground:@selector(sendAll) withObject:nil];
    }
}

/**
 *  Send all the records in the queue
 */
- (void)sendAll{
    _sending = YES;
    while (_readyToSend.count > 0 && _sending) {
        KBEmoticonUsage *record;
        @synchronized(_readyToSend){
            // fetch one record from the queue
            record = [_readyToSend firstObject];
            //
        }
        // TODO: send record to the server synchronously.
        NSError *err = [record send];
        if (err) {
            if (_reachable.isReachable) {
                // If the connection is reachable, retry.
                continue;
            }else{
                // Otherwise stop sending.
                break;
            }
        }else{
            // remove the record from the queue
            @synchronized(_readyToSend){
                [_readyToSend removeObjectAtIndex:0];
            }
        }
    }
    _sending = NO;
}

/**
 *  Save the entire queue to cache. This function is used by dealloc function. DO NOT invoke it during sending.
 *
 *  @param overwrite whether to overwrite the former data.
 */
- (void)saveQueueToCache:(BOOL)overwrite{
    // first copy an immutable version of the queue and clear the queue.
    NSArray *queue;
    @synchronized(_readyToSend){
        if (_readyToSend.count == 0) {
            return;
        }
        queue = [_readyToSend copy];
        [_readyToSend removeAllObjects];
    }
    if (!overwrite) {
        NSArray *formerData = (NSArray*)[_cache objectForKey:@"usage_records"];
        if (formerData) {
            queue = [queue arrayByAddingObjectsFromArray:formerData];
        }
    }
    [_cache setObject:queue forKey:@"usage_records"];
}

- (void)clearCachedReport{
    @synchronized(_readyToSend){
        [_readyToSend removeAllObjects];
    }
    [_cache removeAllObjects];
}

@end
