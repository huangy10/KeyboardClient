//
//  KBEmoticonTypePanelView.m
//  
//
//  Created by 黄延 on 15/8/29.
//
//

#import "KBEmoticonTypePanelView.h"

#import <Masonry.h>

#import "KBGlobalSetup.h"
#import "KBQuarterCircleWithMarkerView.h"
#import "KBEmoticonTypePanelCell.h"

@interface KBEmoticonTypePanelView () <KBTouchableWheelViewDelegate>

/**
 *  Background view.
 */
@property (nonatomic, strong) KBQuarterCircleWithMarkerView *bg;

/**
 *  Container for reusable cells
 */
@property (nonatomic, strong) NSMutableSet *reusableCellPool;

/**
 *  Visible cells.
 */
@property (nonatomic, strong) NSMutableArray *underlyingVisibleCells;

@property (nonatomic) BOOL scrollable;

@end

@implementation KBEmoticonTypePanelView

- (instancetype)initWithMarkerPosition:(CGFloat)markerAngle{
    if (self = [super init]) {
        _markerAngle = markerAngle;
        _reusableCellPool = [NSMutableSet set];
        _underlyingVisibleCells = [NSMutableArray array];
        _markerInterval = 15 / 180.0 * M_PI;
        // Create background view
        _bg = [[KBQuarterCircleWithMarkerView alloc] initWithMarkerPos:markerAngle color:KBColorPanelRed];
        [self addSubview:_bg];
        // Create touchable wheel
        _wheel = [[KBTouchableWheelView alloc] init];
        _wheel.delegate = self;
        [self addSubview:_wheel];
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _bg.frame = self.bounds;
    _wheel.frame = self.bounds;
    [self layoutScales];
}

- (void)layoutScales{
    [_bg setNeedsDisplay];
    _scrollable = YES;
    CGFloat pos = _markerAngle;
    int i = 0;
    while(pos>=0 && i<_cellNum){
        // Ask for a cell from delegate
        KBEmoticonTypePanelCell *cell = [_delegate cellForIndex:i];
        //[self addSubview:cell];
        [_underlyingVisibleCells addObject:cell];
        cell.pos = pos;
        cell.center = [self getCenterForPos:pos];
        cell.index = i;
        if (i == 0) {
//            [cell setSelected:YES];
            [_delegate cellSelectedForIndex:i];
        }
        pos -= _markerInterval;
        i += 1;
    }
    if (i >= _cellNum) {
        _scrollable = NO;
        return;
    }
    pos = _markerAngle + _markerInterval;
    int j = 1;
    while (pos <= M_PI/2 && _cellNum-j>=i) {
        KBEmoticonTypePanelCell *cell = [_delegate cellForIndex:_cellNum-j];
        // [self addSubview:cell];
        [_underlyingVisibleCells addObject:cell];
        cell.index = _cellNum-j;
        cell.pos = pos;
        cell.center = [self getCenterForPos:pos];
        pos += _markerInterval;
        j += 1;
    }
    // If all the cells can be place in the panel at the same time. then the scroll is forbidden
    if (i+j-1 >= _cellNum) {
        _scrollable = NO;
    }
    // Make sure the list is ordered correctly
    [_underlyingVisibleCells sortUsingComparator:^NSComparisonResult(KBEmoticonTypePanelCell *cell1, KBEmoticonTypePanelCell *cell2) {
        if (cell1.pos < cell2.pos) {
            return NSOrderedAscending;
        }else if(cell1.pos > cell2.pos){
            return NSOrderedDescending;
        }else{
            return NSOrderedSame;
        }
    }];
}

- (void)reload{
    _cellNum = [_delegate numberOfEmoticonTypes];
    // Add all cell visible to the pull.
    for (KBEmoticonTypePanelCell *cell in _underlyingVisibleCells) {
        cell.center = CGPointMake(1000, 1000);
    }
    [_reusableCellPool addObjectsFromArray:_underlyingVisibleCells];
    [self layoutScales];
}

- (KBEmoticonTypePanelCell*)getAReusableCell{
    if (_reusableCellPool.count == 0) {
        KBEmoticonTypePanelCell *cell = [[KBEmoticonTypePanelCell alloc] init];
        [cell addTarget:self action:@selector(cellPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cell];
        cell.backgroundColor = [UIColor blackColor];
        cell.bounds = CGRectMake(0, 0, 30, 20);
        cell.translatesAutoresizingMaskIntoConstraints = YES;
        [cell addTarget:self action:@selector(cellPressed:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }else{
        KBEmoticonTypePanelCell* cell = [_reusableCellPool anyObject];
        [_reusableCellPool removeObject:cell];
        return cell;
    }
}

- (NSArray*)visibleCells{
    return _underlyingVisibleCells;
}

- (void)setBacker:(UIView *)backer{
    [super setBacker:backer];
    _wheel.backer = backer;
}

- (void)setDelegate:(id<KBEmoticonTypePanelDatasource>)delegate{
    _delegate = delegate;
    if (delegate) {
        _cellNum = [delegate numberOfEmoticonTypes];
    }
}

- (void)wheel:(KBTouchableWheelView *)wheel AngleChanged:(CGFloat)dAlpha{
    if (!_scrollable) {
        return;
    }
    // First, remove those cells which are out of the screen
    KBEmoticonTypePanelCell *firstCell = [_underlyingVisibleCells firstObject];
    while (firstCell.pos < - _markerInterval * 2) {
        [_underlyingVisibleCells removeObject:firstCell];
        //[firstCell removeFromSuperview];
        [_reusableCellPool addObject:firstCell];
        firstCell = [_underlyingVisibleCells firstObject];
    }
    KBEmoticonTypePanelCell *lastCell = [_underlyingVisibleCells lastObject];
    while (lastCell.pos > M_PI/2 + _markerInterval * 2) {
        [_underlyingVisibleCells removeObject:lastCell];
        //[lastCell removeFromSuperview];
        [_reusableCellPool addObject:lastCell];
        lastCell = [_underlyingVisibleCells lastObject];
    }
    // Second, load the cells appearing
    while (firstCell.pos > 0) {
        NSInteger newIndex = (firstCell.index + 1) % _cellNum;
        KBEmoticonTypePanelCell *newCell = [_delegate cellForIndex:newIndex];
        [_underlyingVisibleCells addObject:newCell];
        // [self addSubview:newCell];
        newCell.pos = firstCell.pos - _markerInterval;
        newCell.center = [self getCenterForPos:newCell.pos];
        newCell.index = newIndex;
        firstCell = newCell;
    }
    while (lastCell.pos < M_PI/2) {
        NSInteger newIndex = lastCell.index - 1;
        if (newIndex < 0) {
            newIndex += _cellNum;
        }
        KBEmoticonTypePanelCell *newCell = [_delegate cellForIndex:newIndex];
        [_underlyingVisibleCells addObject:newCell];
        // [self addSubview:newCell];
        newCell.pos = lastCell.pos + _markerInterval;
        newCell.center = [self getCenterForPos:newCell.pos];
        newCell.index = newIndex;
        lastCell = newCell;
    }
    // Make sure the list is ordered correctly
    [_underlyingVisibleCells sortUsingComparator:^NSComparisonResult(KBEmoticonTypePanelCell *cell1, KBEmoticonTypePanelCell *cell2) {
        if (cell1.pos < cell2.pos) {
            return NSOrderedAscending;
        }else if(cell1.pos > cell2.pos){
            return NSOrderedDescending;
        }else{
            return NSOrderedSame;
        }
    }];
    // update the location of the scales
    for (KBEmoticonTypePanelCell *cell in _underlyingVisibleCells) {
        CGFloat pos = cell.pos + dAlpha;
        CGPoint newCenter = [self getCenterForPos:pos];
        cell.center = newCenter;
        cell.pos = pos;
        [cell setNeedsLayout];
    }
}

- (void)wheelDidStopped:(KBTouchableWheelView *)wheel{
    // Do nothing here
}

#pragma mark cell button 

- (void)cellPressed:(KBEmoticonTypePanelCell*)sender{
    [_delegate cellSelectedForIndex:sender.index];
}

#pragma mark utilities
- (CGPoint)getCenterForPos:(CGFloat)angle{
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    _wheelWidth = width / 6 * 0.8;
    CGFloat radius = self.bounds.size.width - _wheelWidth/1.6;
    return CGPointMake(width - radius * cos(angle), height - radius * sin(angle));
}

@end
