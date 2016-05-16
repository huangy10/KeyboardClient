//
//  Emoticon.h
//  
//
//  Created by 黄延 on 15/8/22.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class EmoticonType;

@interface Emoticon : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * e_description;
@property (nonatomic, retain) NSString * icon_url;
@property (nonatomic, retain) NSNumber * order_weight;
@property (nonatomic, retain) NSNumber * version_no;
@property (nonatomic, retain) EmoticonType *type;

/**
 *  Utility function, check whether the emoticon with the given code has already been in the database
 *
 *  @param code    code of the emoticon
 *  @param context context, CORE DATA
 *
 *  @return if the emoticon exists, return it, otherwise return nil.
 */
+ (Emoticon*)checkExistenseWithCode:(NSString*)code inContext:(NSManagedObjectContext*)context;

/**
 *  Return the image of the emoticon
 *
 *  @return UIImage
 */
- (UIImage*)iconImage;

@end
