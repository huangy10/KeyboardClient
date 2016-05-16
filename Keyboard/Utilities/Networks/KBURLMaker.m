//
//  KBURLMaker.m
//  
//
//  Created by 黄延 on 15/8/23.
//
//

#import "KBURLMaker.h"

#import "KBGlobalSetup.h"

@implementation KBURLMaker

+ (KBURLMaker*)maker{
    static KBURLMaker *maker;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        maker = [[KBURLMaker alloc] initPrivate];
    });
    return maker;
}

- (instancetype)initPrivate{
    self = [super init];
    if (self) {
        _allTypes = [NSURL URLWithString:[KBHOST_NAME stringByAppendingString:@"/emoticons/all"]];
        _report = [NSURL URLWithString:[KBHOST_NAME stringByAppendingString:@"/emoticons/report"]];
        _checkUpdate = [NSURL URLWithString:[KBHOST_NAME stringByAppendingString:@"/emoticons/check_update"]];
        _ask4Account  = [NSURL URLWithString:[KBHOST_NAME stringByAppendingString:@"/accounts/new"]];
    }
    return self;
}

- (NSURL*)urlForEmoticonCode:(NSString *)code version_no:(NSInteger)version_no{
    NSString *template = @"/emoticons/download/%@/%ld";
    return [NSURL URLWithString:[KBHOST_NAME stringByAppendingString:[NSString stringWithFormat:template, code, version_no]]];
}

- (NSURL*)urlForTypeThumbnailWithTypeID:(NSString *)typeID{
    NSString *template = @"/emoticons/thumbnail/%@";
    return [NSURL URLWithString:[KBHOST_NAME stringByAppendingString:[NSString stringWithFormat:template, typeID]]];
}

@end
