//
//  KBEmoticonUsage.h
//  
//
//  Created by 黄延 on 15/8/29.
//
//

#import <Foundation/Foundation.h>

/**
 *  Usage record which can be saved to disk cache.
 */
@interface KBEmoticonUsage : NSObject<NSCoding>

@property (nonatomic, strong) NSString *emoticonCode;
@property (nonatomic, strong) NSString *versionNo;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, readonly) BOOL alreadySent;
/**
 *  Send Usage Report To the server
 *
 *  @return error occurs when sending
 */
- (NSError*)send;

@end
