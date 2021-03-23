//
//  TUIConversationListController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/17.
//

#import "TUIConversationListController.h"
#import "TUIConversationCell.h"
#import "TUIConversationTableHeaderView.h"
#import "THeader.h"
#import "TUIKit.h"
#import "TUILocalStorage.h"
#import "TIMUserProfile+DataProvider.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "UIColor+TUIDarkMode.h"
#import "NSBundle+TUIKIT.h"
@import ImSDK;

static NSString *kConversationCell_ReuseId = @"TConversationCell";

@interface TUIConversationListController () <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate>
@end

@implementation TUIConversationListController

-(void)setTableHeaderView{
    if (self.viewModel.dataList.count > 0 && self.GuanJiaTop){
        TUIConversationCellData *data = self.GuanJiaTop;
        TUIConversationTableHeaderView *cell = [[TUIConversationTableHeaderView alloc] init];
        [cell setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 132)];
//        cell.contentView.backgroundColor= UIColor.whiteColor;
        if (!data.cselector) {
            data.cselector = @selector(didSelectConversation:);
        }
        [cell fillWithData:data];

        //可以在此处修改，也可以在对应cell的初始化中进行修改。用户可以灵活的根据自己的使用需求进行设置。
        cell.changeColorWhenTouched = YES;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 132)];
        [headerView addSubview:cell];
        headerView.backgroundColor = UIColor.whiteColor;
//        [UIColor colorWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1];
        
        self.tableView.tableHeaderView = headerView;
        CGRect frame = self.tableView.tableHeaderView.frame;
        frame.size.height = 132;
        self.tableView.tableHeaderView.frame = frame;
    }else{
        self.tableView.tableHeaderView = nil;
    }
}


-(NSMutableArray<TUIConversationCellData*> *)viewModelPerson{
    
    NSMutableArray<TUIConversationCellData*> *list = [NSMutableArray array];
    
    for (int _loc1 = 0; _loc1 < self.viewModel.dataList.count; _loc1 ++) {
        if (self.viewModel.dataList[_loc1].userID != nil ){
            if ([self.viewModel.dataList[_loc1].userID isEqualToString:@"u18600663714"]){
                self.GuanJiaTop = self.viewModel.dataList[_loc1];
                self.GuanJiaTop.yinxingData = [NSMutableDictionary dictionaryWithObject:@"18600663714" forKey:@"phone"];
                [self.GuanJiaTop.yinxingData setValue:@"在线时间：8:00 - 20:00" forKey:@"time"];
                [self.GuanJiaTop.yinxingData setValue:@"  金牌管家666  " forKey:@"position"];
            }else{
                NSLog(@"userID:%@",self.viewModel.dataList[_loc1].userID);
                [list addObject:self.viewModel.dataList[_loc1]];
            }
            
        }
    }
    
    return list;
}

-(NSMutableArray<TUIConversationCellData*> *)viewModelGroup{
    
    NSMutableArray<TUIConversationCellData*> *list = [NSMutableArray array];
    
    for (int _loc1 = 0; _loc1 < self.viewModel.dataList.count; _loc1 ++) {
        if (self.viewModel.dataList[_loc1].groupID != nil){
            NSLog(@"userID:%@",self.viewModel.dataList[_loc1].userID);
            [list addObject:self.viewModel.dataList[_loc1]];
        }
    }
    
    return list;
}

//- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//
//    if (section == 0){
//        return nil;
//    }else{
//        return @"我的服务群";
//    }
//
//}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section

{
    view.tintColor = [[UIColor alloc] initWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    CGRect rect = self.view.frame;
    rect.size.height = 37;
    UIView *sView = [[UIView alloc] initWithFrame:rect];
    
    
    rect = CGRectMake(15, 11, 200, 15);
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.font = [UIFont fontWithName:@"SourceHanSansCN-Regular" size:14.0];
    [sView addSubview:label];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    if (section == 1){
        label.text = @"我的服务群";
    }else{
        label.text = @"";
    }
    
    return sView;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0){
        if (self.GuanJiaTop == nil ){
            return 0;
        }else{
            return 15;
        }
        
    }else{
        return 37;
    }
    
}

//by vince


- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupViews];

    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    [_tableView registerClass:[TUIConversationCell class] forCellReuseIdentifier:kConversationCell_ReuseId];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self setTableHeaderView];
    [self.view addSubview:_tableView];

    @weakify(self)
    [RACObserve(self.viewModel, dataList) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.tableView reloadData];
        [self setTableHeaderView];
    }];
//    [RACObserve(self.viewModelGroup, dataList) subscribeNext:^(id  _Nullable x) {
//        @strongify(self)
//        [self.tableView reloadData];
//    }];
}

- (TConversationListViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [TConversationListViewModel new];
    }
    return _viewModel;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.viewModelGroup != nil && self.viewModelGroup.count > 0){
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.viewModelPerson.count;
    }else {
//        section == 1
        return self.viewModelGroup.count;
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray<TUIConversationCellData*> *sectionModel = indexPath.section == 0 ? self.viewModelPerson : self.viewModelGroup;
    
    return [sectionModel[indexPath.row] heightOfWidth:Screen_Width];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TUILocalizableString(Delete);
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

//关闭了删除功能
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        TUIConversationCellData *conv = self.viewModel.dataList[indexPath.row];
        [self.viewModel removeData:conv];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }
}

- (void)didSelectConversation:(TUIConversationCell *)cell
{
    if(_delegate && [_delegate respondsToSelector:@selector(conversationListController:didSelectConversation:)]){
        [_delegate conversationListController:self didSelectConversation:cell];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray<TUIConversationCellData*> *sectionModel = indexPath.section == 0 ? self.viewModelPerson : self.viewModelGroup;
    
    
    TUIConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:kConversationCell_ReuseId forIndexPath:indexPath];
    TUIConversationCellData *data = [sectionModel objectAtIndex:indexPath.row];
    
    if (!data.cselector) {
        data.cselector = @selector(didSelectConversation:);
    }
    [cell fillWithData:data];

    //可以在此处修改，也可以在对应cell的初始化中进行修改。用户可以灵活的根据自己的使用需求进行设置。
    cell.changeColorWhenTouched = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableArray<TUIConversationCellData*> *sectionModel = indexPath.section == 0 ? self.viewModelPerson : self.viewModelGroup;
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
           [cell setSeparatorInset:UIEdgeInsetsMake(0, 75, 0, 0)];
        if (indexPath.row == (sectionModel.count - 1)) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
    }

    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

@end
