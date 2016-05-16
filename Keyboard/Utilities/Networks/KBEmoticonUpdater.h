//
//  KBEmoticonUpdater.h
//  
//
//  Created by 黄延 on 15/8/22.
//
//

#import <Foundation/Foundation.h>

@class KBUser;

/**
 *  This class handles the update of the emoticons.
 */
@interface KBEmoticonUpdater : NSObject

/**
 *  Pointer to the current user account
 */
@property (nonatomic, weak, readonly) KBUser *account;

/**
 *  shared KBEmoticonUpdater instance
 *
 *  @return instance
 */
+ (KBEmoticonUpdater*)updater;

/**
 *  The next update check time.
 */
@property (nonatomic, strong) NSDate *scheduledUpdateDate;

/**
 *  Check update.
 *
 *  @return whether the update is successful. Invoke -errorInfo for error info
 */
- (BOOL)checkUpdate;

/**
 *  Error info for last -checkUpdate invocation
 *
 *  @return NSError instance
 */
- (NSError*)errorInfo;

@end
