//
//  KBUser.h
//  
//
//  Created by 黄延 on 15/8/22.
//
//

#import <Foundation/Foundation.h>

@protocol KBUserDelegate <NSObject>

/**
 *  Invoked when the request for account.
 *
 *  @param error the error occurs during the request.
 */
- (void)accountRequestFinished:(NSError*)error;

@end

/**
 *  Account provided by the server.
 */
@interface KBUser : NSObject

/**
 *  Get the global user instance.
 *
 *  @return the user instance.
 */
+ (KBUser*)sharedUser;

/**
 *  Add authentication param to the given dict
 *
 *  @param param A NSDictionary
 *
 *  @return New dict with authentciation data.
 */
- (NSDictionary*)authenticatedParam:(NSDictionary*)param;

/**
 *  Attach the username and passwd as GET params
 *
 *  @param url unauthenicatable url
 *
 *  @return authenicated url
 */
- (NSURL*)authenticatedURL:(NSURL*)url;

/**
 *  Username.
 */
@property (nonatomic, strong) NSString* username;

/**
 *  Password.
 */
@property (nonatomic, strong) NSString* passwd;

/**
 *  Clear account. This will cause new request to be sent for a new account.
 *  The usage records which have not been sent yet will be deleted at the same time.
 */
- (void)resetAccount;

@end
