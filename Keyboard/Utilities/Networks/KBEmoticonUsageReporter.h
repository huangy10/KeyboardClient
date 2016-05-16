//
//  KBEmoticonUsageReporter.h
//  
//
//  Created by 黄延 on 15/8/22.
//
//

#import <Foundation/Foundation.h>

/**
 *  This utility class handles reporting the usage of emoticons.
 *  
 *  Feel free to send report even when no connection to the server is available.
 */
@interface KBEmoticonUsageReporter : NSObject

+ (KBEmoticonUsageReporter*)reporter;
/**
 *  Send a usage report to the server. If no network available for now, the report will be cached
 *
 *  @param emoticonCode code of Emoticon that was used
 *  @param versionNo version No.
 *  @param useTime  When the emotion was used
 */
- (void)sendUsageReportForEmoticon:(NSString*)emoticonCode
                         versionNo:(NSInteger)versionNo
                                at:(NSDate*)useTime;

#pragma mark For debug

/**
 *  Clear current disk cache as well as sending queue.
 *  
 *  This is a dangerour function, only for debugging. DO NOT use it in production.
 */
- (void)clearCachedReport;

@end
