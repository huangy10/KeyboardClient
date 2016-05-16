//
//  KBEmoticonUsage.m
//  
//
//  Created by 黄延 on 15/8/29.
//
//

#import "KBEmoticonUsage.h"

#import <AFNetworking.h>

#import "KBGlobalSetup.h"
#import "KBURLMaker.h"
#import "KBUser.h"

@implementation KBEmoticonUsage

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        _date = [aDecoder decodeObjectForKey:@"date"];
        _versionNo = [aDecoder decodeObjectForKey:@"versionNo"];
        _emoticonCode = [aDecoder decodeObjectForKey:@"code"];
    }
    return self;
}

- (instancetype)init{
    if (self = [super init]) {
        _alreadySent = NO;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_date forKey:@"date"];
    [aCoder encodeObject:_versionNo forKey:@"versionNo"];
    [aCoder encodeObject:_emoticonCode forKey:@"code"];
}

- (NSError*)send{
    if (_alreadySent) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *dateString = [formatter stringFromDate:_date];
    NSDictionary *param = @{@"emoticon_code": _emoticonCode,
                            @"version_no": _versionNo,
                            @"use_time": dateString};
    param = [[KBUser sharedUser] authenticatedParam:param];
    NSURL *requestURL = [[KBURLMaker maker] report];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    __block NSError *errorInfo = nil;
    dispatch_semaphore_t semaphere = dispatch_semaphore_create(0);
    manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    [manager POST:requestURL.absoluteString parameters:param success:^(AFHTTPRequestOperation * operation, id responseObj) {
        NSDictionary *response = (NSDictionary*)responseObj;
        if (!response[@"success"]) {
            errorInfo = [NSError errorWithDomain:@"Unknown Error" code:0 userInfo:nil];
        }else{
            _alreadySent = YES;
        }
        dispatch_semaphore_signal(semaphere);
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        WRLog(@"Error Occurs When Sending Usage Report");
        errorInfo = error;
        dispatch_semaphore_signal(semaphere);
    }];
    // [operation waitUntilFinished];
    // Wait until the account is successfully getted.
    dispatch_semaphore_wait(semaphere, DISPATCH_TIME_FOREVER);
    return errorInfo;
}

@end
