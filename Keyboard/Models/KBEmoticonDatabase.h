//
//  KBEmoticonDatabase.h
//  
//
//  Created by 黄延 on 15/8/22.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Emoticon;
@class EmoticonType;

/**
 *  This class is responsible to handle loading neccessary data from the CORE DATA database.
 *  Notice that it is not the responsibility of this class to handle the update of emoticons. Check Utilities->Networks->KBEmoticonUpdater for more information.
 */
@interface KBEmoticonDatabase : NSObject

/**
 *  Get the shared database instance
 *
 *  @return the singleton instance
 */
+ (KBEmoticonDatabase*)sharedDatabase;

/**
 *  Get all emoticonTypes currently selected by the user
 *
 *  Notice that this is not the entire available emoticon-type-list
 *
 *  @return the array of EmoticonType
 */
- (NSArray*)allEmoticonTypes;

/**
 *  Return all emoticons available for given time (hour)
 *
 *  @param time hour
 *
 *  @return the array of EmoticonType
 */
- (NSArray*)allEmoticonTypesAt:(NSInteger)time;

/**
 *  Get all emoticon for the given type
 *
 *  @param e_type Emoticon type
 *
 *  @return the array of Emoticon
 */
- (NSArray*)emoticonsForType:(EmoticonType *)e_type;

@end
