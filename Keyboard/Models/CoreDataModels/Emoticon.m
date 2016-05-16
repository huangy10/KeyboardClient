//
//  Emoticon.m
//  
//
//  Created by 黄延 on 15/8/22.
//
//

#import "Emoticon.h"
#import "EmoticonType.h"


@implementation Emoticon

@dynamic code;
@dynamic e_description;
@dynamic icon_url;
@dynamic order_weight;
@dynamic version_no;
@dynamic type;

+ (Emoticon*)checkExistenseWithCode:(NSString *)code inContext:(NSManagedObjectContext *)context{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Emoticon" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %@", code];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil && fetchedObjects.count != 1) {
        return nil;
    }
    return [fetchedObjects firstObject];
}

- (UIImage*)iconImage{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *imagePath = [bundle pathForResource:@"pride" ofType:@"png"];
    UIImage* image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

@end
