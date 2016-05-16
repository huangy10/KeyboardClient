//
//  KBEmoticonMainPanelView.m
//  
//
//  Created by 黄延 on 15/8/29.
//
//

#import "KBEmoticonMainPanelView.h"

#import <Masonry.h>
#import <pop/POP.h>     // Animation framework

#import "KBGlobalSetup.h"
#import "KBQuarterCircleView.h"
#import "KBEmoticnMainCell.h"
#import "KBEmoticonMainContainerView.h"
#import "KBEmoticonMainCellLayouter.h"


@interface KBEmoticonMainPanelView () <UIGestureRecognizerDelegate, POPAnimationDelegate, KBEmoticnMainCellDelegate>{
    CGPoint _pre;
    CGPoint _cur;
}

/**
 *  Background circle view
 */
@property (nonatomic, strong) KBQuarterCircleView *bg;

/**
 *  Pool to maintain the reusable cells
 */
@property (nonatomic, strong) NSMutableSet *reusablePool;

/**
 *  Visible cells
 */
@property (nonatomic, strong) NSMutableArray *underlyingVisibleCells;

/**
 *  Label to display page no. "current/total"
 */
@property (nonatomic, strong) UILabel *pageNoLabel;

/**
 *  Container for cells in current page, pervious page, and next page
 */
@property (nonatomic, strong) KBEmoticonMainContainerView *curContainer;
@property (nonatomic, strong) KBEmoticonMainContainerView *preContainer;
@property (nonatomic, strong) KBEmoticonMainContainerView *nextContainer;

@end

@implementation KBEmoticonMainPanelView

- (instancetype)init{
    if (self = [super init]) {
        // Data preparation
        _reusablePool = [NSMutableSet set];
        _underlyingVisibleCells = [NSMutableArray array];
        //
        _bg = [[KBQuarterCircleView alloc] initWithBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_bg];
        
        //
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
        pan.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:pan];
        //
        _preContainer = [[KBEmoticonMainContainerView alloc] init];
        [self addSubview:_preContainer];
        _preContainer.backgroundColor = [UIColor clearColor];
        _preContainer.backer = nil;
        
        _nextContainer = [[KBEmoticonMainContainerView alloc] init];
        [self addSubview:_nextContainer];
        _nextContainer.backgroundColor = [UIColor clearColor];
        _nextContainer.backer = nil;
        
        _curContainer = [[KBEmoticonMainContainerView alloc] init];
        [self addSubview:_curContainer];
        _curContainer.backgroundColor = [UIColor clearColor];
        _curContainer.backer = nil;
        
        _pageNoLabel = [[UILabel alloc] init];
        [self addSubview:_pageNoLabel];
        _pageNoLabel.backgroundColor = [UIColor clearColor];
        _pageNoLabel.textAlignment = NSTextAlignmentRight;
        UIFont *font = [UIFont systemFontOfSize:10];
        _pageNoLabel.font = font;
        _pageNoLabel.textColor = [UIColor grayColor];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    
    _bg.frame = self.bounds;
    
    UIFont *font = [UIFont systemFontOfSize:10];
    CGSize textSize = [@"00/00" sizeWithAttributes:@{NSFontAttributeName: font}];
    _pageNoLabel.frame = CGRectMake(self.frame.size.width - textSize.width, self.frame.size.height - textSize.height, textSize.width, textSize.height);
    
    _curContainer.frame = self.bounds;
    _preContainer.frame = self.bounds;
    [_preContainer setRotatingAngle:M_PI/2];
    _nextContainer.frame = self.bounds;
    [_nextContainer setRotatingAngle:-M_PI/2];
}

- (void)panHandler:(UIPanGestureRecognizer*)gesture{
    if (_totalPages <= 1) {
        // If the total number of pages no more than 2, there is no need to handle paging functionality.
        return;
    }
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            _pre = [gesture locationInView:self];
        case UIGestureRecognizerStateChanged:
            _cur = [gesture locationInView:self];
            CGFloat dx = _cur.x - _pre.x;
            CGFloat dy = _cur.y - _pre.y;
            if ((dx - dy) > 20 && ![_curContainer.layer pop_animationForKey:@"rotate"]) {
                // Animate current page
                NSLog(@"Start Animating");
                POPSpringAnimation *anim = [POPSpringAnimation animation];
                anim.delegate = self;
                anim.name = @"to_next_page";
                anim.property = [POPAnimatableProperty propertyWithName:kPOPLayerRotation];
                anim.fromValue = @0;
                anim.toValue =  @(M_PI/2);
                [_curContainer.layer pop_addAnimation:anim forKey:@"rotate"];
                POPSpringAnimation *animNext = [POPSpringAnimation animation];
                animNext.property = [POPAnimatableProperty propertyWithName:kPOPLayerRotation];
                animNext.fromValue = @(-M_PI/2);
                animNext.toValue = @0;
                animNext.springBounciness = 10;
                [self bringSubviewToFront:_nextContainer];
                [_nextContainer.layer pop_addAnimation:animNext forKey:@"rotate"];
            }else if((dx - dy) < -20  && ![_curContainer.layer pop_animationForKey:@"rotate"]){
                POPSpringAnimation *anim = [POPSpringAnimation animation];
                anim.delegate = self;
                anim.property = [POPAnimatableProperty propertyWithName:kPOPLayerRotation];
                anim.name = @"to_previous_page";
                anim.fromValue = @0;
                anim.toValue =  @(-M_PI/2);
                [_curContainer.layer pop_addAnimation:anim forKey:@"rotate"];
                
                POPSpringAnimation *animPre = [POPSpringAnimation animation];
                animPre.property = [POPAnimatableProperty propertyWithName:kPOPLayerRotation];
                animPre.fromValue = @(M_PI/2);
                animPre.toValue = @0;
                animPre.springBounciness = 10;
                [self bringSubviewToFront:_preContainer];
                [_preContainer.layer pop_addAnimation:animPre forKey:@"rotate"];
            }
            _pre = _cur;
            break;
        default:
            break;
    }
}

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished{
    if (finished) {
        NSString *anim_name = anim.name;
        if ([anim_name isEqualToString:@"to_next_page"]) {
            KBEmoticonMainContainerView *tmp = _preContainer;
            _preContainer = _curContainer;
            _curContainer = _nextContainer;
            _nextContainer = tmp;
            
            _pageNo ++;
            if (_pageNo > _totalPages) {
                _pageNo -= _totalPages;
            }
            _pageNoLabel.text = [NSString stringWithFormat:@"%ld/%ld", _pageNo, _totalPages];
            NSInteger next = _pageNo + 1;
            if (next > _totalPages) {
                next -= _totalPages;
            }
            [self resetCellsInContainer:_nextContainer forPageNo:next];
        }else if ([anim_name isEqualToString:@"to_previous_page"]){
            KBEmoticonMainContainerView *tmp = _nextContainer;
            _nextContainer = _curContainer;
            _curContainer = _preContainer;
            _preContainer = tmp;
            _pageNo -= 1;
            if (_pageNo <= 0) {
                _pageNo += _totalPages;
            }
            _pageNoLabel.text = [NSString stringWithFormat:@"%ld/%ld", _pageNo, _totalPages];
            NSInteger pre = _pageNo - 1;
            if (pre <= 0) {
                pre += _totalPages;
            }
            [self resetCellsInContainer:_preContainer forPageNo:pre];
        }
    }
}

/**
 *  Use this function to reset the content of the container
 *
 *  @param container container: _curContainer, _preContainer, or _nextContainer
 */
- (void)resetCellsInContainer:(KBEmoticonMainContainerView*)container forPageNo:(NSInteger)pageNo{
    // First remove all current cells in the container. Remember to put them back to the reusable pool.
    NSArray *subCells = container.subviews;     // This is a copy of the actual subviews array in the container, so it is safe to remove those subviews during iteration.
    for (UIView* cell in subCells) {
        if ([cell isKindOfClass:[KBEmoticnMainCell class]]) {
            [_reusablePool addObject:cell];
            [cell removeFromSuperview];
        }
    }
    //
    NSInteger newCellNum = [_delegate emoticonNumAtPage:pageNo];
    for (int i=0; i<newCellNum; i++) {
        KBEmoticnMainCell *cell = [_delegate cellAtPage:pageNo atIndex:i];
        [container addSubview:cell];
        cell.frame = [[KBEmoticonMainCellLayouter layouter] frameForLevel:newCellNum index:i];
        cell.layer.cornerRadius = cell.frame.size.width / 2;
    
    }
    
}

- (void)needToPresentDetail:(KBEmoticnMainCell *)cell{
    [_curContainer bringSubviewToFront:cell];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)reload{
    if (_delegate == nil) {
        return;
    }
    _pageNo = 1;
    _totalPages = [_delegate totalPageNum];
    if (_totalPages <= 0) {
        return;
    }
    _pageNoLabel.text = [NSString stringWithFormat:@"%ld/%ld", _pageNo, _totalPages];
    // Start display the first page
    [self resetCellsInContainer:_curContainer forPageNo:1];
    if (_totalPages > 1) {
        [self resetCellsInContainer:_preContainer forPageNo:_totalPages];
        [self resetCellsInContainer:_nextContainer forPageNo:MIN(2, _totalPages)];
    }
}

/**
 *  Handler of the buttons event of the cells
 */
- (void)emoticonSelected: (KBEmoticnMainCell*)sender{
    [_delegate emoticonCellSelected:sender icon:sender.icon.image];
}


#pragma mark setters and getters

- (void)setDelegate:(id<KBEmoticonMainPanelDataSource>)delegate{
    _delegate = delegate;
    [self reload];
}

- (NSArray*)visibleCells{
    return _underlyingVisibleCells;
}

- (KBEmoticnMainCell*)getAReusableCell{
    if (_reusablePool.count == 0) {
        KBEmoticnMainCell *cell = [[KBEmoticnMainCell alloc] init];
        [cell addTarget:self action:@selector(emoticonSelected:) forControlEvents:UIControlEventTouchUpInside];
        cell.delegate = self;
        return cell;
    }else{
        KBEmoticnMainCell *cell = [_reusablePool anyObject];
        [_reusablePool removeObject:cell];
        return cell;
    }
}

@end
