//
//  EmoticonType.h
//  
//
//  Created by 黄延 on 15/8/22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface EmoticonType : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order_weight;
@property (nonatomic, retain) NSNumber * tm_end_h;
@property (nonatomic, retain) NSNumber * tm_end_m;
@property (nonatomic, retain) NSNumber * tm_start_h;
@property (nonatomic, retain) NSNumber * tm_start_m;
@property (nonatomic, retain) NSNumber * version_no;
@property (nonatomic, retain) NSString * e_id;
@property (nonatomic, retain) NSSet *emticons;
@property (nonatomic, retain) NSNumber *ready;

@end
