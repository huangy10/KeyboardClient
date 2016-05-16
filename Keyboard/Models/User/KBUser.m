//
//  KBUser.m
//  
//
//  Created by 黄延 on 15/8/22.
//
//

#import "KBUser.h"

#import <AFNetworking.h>

#import "KBGlobalSetup.h"
#import "KBURLMaker.h"

@interface KBUser (){
    BOOL _isValidAccount;   // if the current account is valid
}

@end

@implementation KBUser

@synthesize username = _username;
@synthesize passwd = _passwd;

+ (KBUser*)sharedUser{
    static KBUser *sharedUser;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUser = [[KBUser alloc] initPrivate];
    });
    return sharedUser;
}

- (void)setUsername:(NSString *)username{
    _username = username;
    [[NSUserDefaults standardUserDefaults] setObject:_username forKey:@"keyboard_username"];
}

- (void)setPasswd:(NSString *)passwd{
    _passwd = passwd;
    [[NSUserDefaults standardUserDefaults] setObject:_passwd forKey:@"keyboard_passwd"];
}

/**
 *  Private init function
 *
 *  @return instance of user
 */
- (instancetype)initPrivate{
    self = [super init];
    if (self) {
        self.username = [[NSUserDefaults standardUserDefaults] stringForKey:@"keyboard_username"];
        self.passwd = [[NSUserDefaults standardUserDefaults] stringForKey:@"keyboard_passwd"];
        if (self.username == nil) {
            _isValidAccount = NO;
            [self requestForAccount];
        }else{
            _isValidAccount = YES;
        }
        
        // send request to the server for a new account
        [self requestForAccount];
    }
    return self;
}

- (NSDictionary*)authenticatedParam:(NSDictionary *)param{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result addEntriesFromDictionary:param];
    [result addEntriesFromDictionary:@{@"username": _username, @"password": _passwd}];
    return result;
}

- (NSURL*)authenticatedURL:(NSURL *)url{
    NSURLComponents *urlComp = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    NSString *originalQuery = urlComp.query;
    NSString *newQuery;
    if (originalQuery != nil && originalQuery.length <= 0) {
        newQuery = [NSString stringWithFormat:@"%@&username=%@&passwd=%@", originalQuery, _username, _passwd];
    }else{
        newQuery = [NSString stringWithFormat:@"username=%@&passwd=%@", _username, _passwd];
    }
    urlComp.query = newQuery;
    return [urlComp URL];
}

/**
 *  Request for a account
 */
- (void)requestForAccount{
    if (_isValidAccount) {
        // When there exist a valid account, no request is permitted
        return;
    }
    NSURL *requestURL = [[KBURLMaker maker] ask4Account];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    dispatch_semaphore_t semaphere = dispatch_semaphore_create(0);
    manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    [manager GET:requestURL.absoluteString parameters:nil success:^(AFHTTPRequestOperation * operation, id responseObj) {
        NSDictionary *response = (NSDictionary*)responseObj;
        NSDictionary *data = response[@"data"];
        self.username = data[@"username"];
        self.passwd = data[@"password"];
        _isValidAccount = YES;
        dispatch_semaphore_signal(semaphere);
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        WRLog(@"Error Occurs When Requesting for a New Account");
        dispatch_semaphore_signal(semaphere);
    }];
    // [operation waitUntilFinished];
    // Wait until the account is successfully getted.
    dispatch_semaphore_wait(semaphere, DISPATCH_TIME_FOREVER);
}

- (void)resetAccount{
    _isValidAccount = NO;
}

@end
