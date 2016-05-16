//
//  KBEmoticonTypesList.h
//  
//
//  Created by 黄延 on 15/8/25.
//
//

#import <Foundation/Foundation.h>

#import "KBGlobalSetup.h"

/**
 *  This utility function handles fetching and caching emoticon type list from server
 */
@interface KBEmoticonTypesList : NSObject

/**
 *  Get the manager
 *
 *  @return instance of the utility function
 */
+ (KBEmoticonTypesList* __nullable)typeListManager;

/**
 *  Age of the cache
 */
@property (nonatomic) int cacheAge;

/**
 *  Get all avaible types from server
 *
 *  @param complete invoked when successfuly
 *  @param error    error handler
 */
- (void)allTypesOnComplete:(KBCompleteBlock __nonnull)complete error:(KBErrorOccuranceBlock __nullable)error;

/**
 *  Get the list of ids of selected types
 *
 *  @return selected types
 */
- (NSArray* __nullable)selectedTypes;

/**
 *  remove a type
 *
 *  @param e_id id of the type to be deleted
 */
- (void)removeEmoticonTypeWithID:(NSString* __nonnull)e_id;

/**
 *  Add a emoticonType, Notice that this will load the cooresponding emoticons which belong to this type.
 *
 *  @param dict information needed to constract an EmoticonType instance
 */
- (void)addEmoticonTypeWithDict:(NSDictionary* __nonnull)dict;

/**
 *  Add a emoticon type by specifying its id. Notice that you should invoke -allTypesOnComplete:error: first.
 *
 *  @param e_id id of the type
 */
- (void)addEmoticonTypeWithID:(NSString* __nonnull)e_id;

@end
