//
//  KBURLMaker.h
//  
//
//  Created by 黄延 on 15/8/23.
//
//

#import <Foundation/Foundation.h>
/**
 *  This utility class handles the urls. You should fetch urls from the singleton instance rather than create them by yourself.
 */
@interface KBURLMaker : NSObject

/**
 *  Get the singleton instance
 *
 *  @return instance
 */
+ (KBURLMaker*)maker;

/**
 *  Check update
 */
@property (nonatomic, readonly, strong) NSURL* checkUpdate;

/**
 *  Send usage report to this url
 */
@property (nonatomic, readonly, strong) NSURL* report;

/**
 *  ask for a new account
 */
@property (nonatomic, readonly, strong) NSURL* ask4Account;

/**
 *  Fetch all available accounts.
 */
@property (nonatomic, readonly, strong) NSURL* allTypes;

/**
 *  Get the download url for emoticon image.
 *
 *  @param code       emoticon code
 *  @param version_no version no.
 *
 *  @return url for downloading.
 */
- (NSURL*)urlForEmoticonCode:(NSString*)code version_no:(NSInteger)version_no;

/**
 *  URL for downloading the thumbnail image of the emoticon type
 *
 *  @param typeID Type ID
 *
 *  @return NSURL
 */
- (NSURL*)urlForTypeThumbnailWithTypeID:(NSString*)typeID;

@end
