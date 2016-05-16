//
//  KBSettingController.m
//  
//
//  Created by 黄延 on 15/9/7.
//
//

#import "KBSettingController.h"

#import <UIImageView+WebCache.h>

#import "KBSettingsDatabase.h"
#import "KBSettingEmoticonCell.h"
#import "KBSettingSwithCell.h"
#import "KBURLMaker.h"
#import "KBUser.h"

#import "EmoticonType.h"

@interface KBSettingController () <KBSettingsDatabaseDelegate, KBSettingEmoticonCellDelegate>

/**
 *  Pointer to the database
 */
@property (nonatomic, strong) KBSettingsDatabase *database;

@end

@implementation KBSettingController

- (instancetype)initWithStyle:(UITableViewStyle)style{
    if (self = [super initWithStyle:style]) {
        self.navigationItem.title = @"设置";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
        
        _database = [KBSettingsDatabase sharedDatabase];
        _database.delegate = self;
        
        [self.tableView registerClass:[KBSettingEmoticonCell class] forCellReuseIdentifier:[KBSettingEmoticonCell getReusableIdentifier]];
        [self.tableView registerClass:[KBSettingSwithCell class] forCellReuseIdentifier:[KBSettingSwithCell getReusableIdentifier]];
        
    }return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_database reloadFromServer];
}

- (void)dismiss{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Delegate of tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else{
        return [_database allTypes].count;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return @"表情管理";
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }else{
        return 87;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }else{
        return [super tableView:tableView heightForHeaderInSection:section];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        KBSettingSwithCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[KBSettingSwithCell getReusableIdentifier] forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.switcher.on = _database.autoUpdateEnabled;
            cell.userdefautKey = _database.autoUpdateEnabledKey;
            cell.title.text = @"是否自动更新";
        }else if (indexPath.row == 1){
            cell.switcher.on = _database.autoReportUsage;
            cell.userdefautKey = _database.autoReportUsageKey;
            cell.title.text = @"是否回报使用情况";
        }
        return cell;
    }else{
        KBSettingEmoticonCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[KBSettingEmoticonCell getReusableIdentifier] forIndexPath:indexPath];
        cell.delegate = self;
        NSDictionary *type = [_database allTypes][indexPath.row];
        cell.title.text = type[@"name"];
        cell.timePeriod.text = [NSString stringWithFormat:@"%02d:%02d-%02d:%02d", [type[@"time_mark_start_hour"] intValue], [type[@"time_mark_start_min"] intValue], [type[@"time_mark_end_hour"] intValue], [type[@"time_mark_end_min"] intValue]];
        NSURL *thumbnail = [[KBURLMaker maker] urlForTypeThumbnailWithTypeID:type[@"id"]];
        thumbnail = [[KBUser sharedUser] authenticatedURL:thumbnail];
        [cell.icon sd_setImageWithURL:thumbnail completed:nil];
        if ([_database.selectedIdList containsObject:type[@"id"]]) {
            [cell.operation setTitle:@"删除" forState:UIControlStateNormal];
            [cell.operation setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else{
            [cell.operation setTitle:@"下载" forState:UIControlStateNormal];
            [cell.operation setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        [self.tableView setNeedsLayout];
        return cell;
    }

}

#pragma mark Delegate of cell event

- (void)cell:(KBSettingEmoticonCell *)cell RequestPerformOperation:(NSString *)operation{
    if ([operation isEqualToString:@"删除"]) {
        NSIndexPath *index = [self.tableView indexPathForCell:cell];
        NSArray *allType = [_database allTypes];
        [_database removeTypeWithID:allType[index.row][@"id"]];
        [cell.operation setTitle:@"下载" forState:UIControlStateNormal];
        [cell.operation setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
    }else if ([operation isEqualToString:@"下载"]){
        NSIndexPath *index = [self.tableView indexPathForCell:cell];
        NSArray *allType = [_database allTypes];
        [_database addTypeWithID:allType[index.row][@"id"]];
        
        [cell.operation setTitle:@"删除" forState:UIControlStateNormal];
        [cell.operation setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
    }else if ([operation isEqualToString:@"取消"]){
        
    }else{
        WRLog(@"Invalid operation");
    }
}

#pragma mark Delegate of database

- (void)database:(KBSettingsDatabase *)database allTypesListAvailable:(NSArray *)allTypes{
    [self.tableView reloadData];
}

- (void)database:(KBSettingsDatabase *)database ErrorOccurs:(NSError *)error{
    WRLog(@"ERROR");
}

@end
