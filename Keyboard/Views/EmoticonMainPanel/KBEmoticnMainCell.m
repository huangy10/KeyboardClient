//
//  KBEmoticnMainCell.m
//  
//
//  Created by 黄延 on 15/9/1.
//
//

#import "KBEmoticnMainCell.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "Emoticon.h"
#import "KBURLMaker.h"
#import "KBUser.h"
#import "KBEmoticonDetailView.h"

@interface KBEmoticnMainCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) KBEmoticonDetailView *detail;

@end

@implementation KBEmoticnMainCell

- (instancetype)init{
    if (self = [super init]) {
        // self.clipsToBounds = YES;
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
        [self addGestureRecognizer:longPress];
        longPress.minimumPressDuration = 1;
        longPress.delegate = self;
    }
    return self;
}

- (void)longPressHandler:(UILongPressGestureRecognizer*)gesture{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            if (!_detail) {
                _detail = [[KBEmoticonDetailView alloc] init];
                _detail.contentRadius = self.frame.size.width * 2;
                _detail.arrowPos = M_PI / 4;
                [self addSubview:_detail];
                _detail.anchorPoint = CGPointMake(5, 5);
                _detail.backgroundColor = [UIColor clearColor];
                _detail.icon.image = self.icon.image;
                [_detail setNeedsDisplay];
            }
            [_detail setHidden:NO];
            [_delegate needToPresentDetail:self];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:
            if (_detail != nil) {
                [_detail setHidden:YES];
            }
        default:
            break;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

/**
 *  Setter for emoticon
 *
 *  @param emticon emoticon
 */
- (void)setEmticon:(Emoticon *)emticon{
    _emticon = emticon;
    NSURL *imageURL = [[KBURLMaker maker] urlForEmoticonCode:emticon.code version_no:emticon.version_no.integerValue];
    imageURL = [[KBUser sharedUser] authenticatedURL:imageURL];
    [self.icon sd_setImageWithURL:imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        // This block remains empty for now.
    }];
    // self.icon.image = [emticon iconImage];
}

- (void)setRadius:(CGFloat)radius{
    _radius = radius;
    self.bounds = CGRectMake(0, 0, radius * 2, radius * 2);
}

@end
