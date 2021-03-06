//
//  TConversationListViewModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/17.
//

#import "TConversationListViewModel.h"
#import "TUILocalStorage.h"
#import "TUIKit.h"
#import "THeader.h"
#import "THelper.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TIMMessage+DataProvider.h"
#import "UIColor+TUIDarkMode.h"
#import "NSBundle+TUIKIT.h"
#import <objc/runtime.h>


@import ImSDK;

@interface TConversationListViewModel ()
@property BOOL isLoadFinished;
@property BOOL isLoading;
@property (nonatomic, strong) NSMutableArray *localConvList;
@end

@implementation TConversationListViewModel

static char filterListKey;

+(void)setFilterArray:(NSArray * _Nonnull)filterList
{
    objc_setAssociatedObject(self, &filterListKey, filterList, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+( NSArray * _Nullable )getFilterArray
{
    return objc_getAssociatedObject(self, &filterListKey);
}

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onRefreshNotificationAdded:) name:TUIKitNotification_TIMRefreshListener_Add object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onRefreshNotificationChanged:) name:TUIKitNotification_TIMRefreshListener_Changed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onGroupDismiss:) name:TUIKitNotification_onGroupDismissed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onGroupRecycled:) name:TUIKitNotification_onGroupRecycled object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onKickOffFromGroup:) name:TUIKitNotification_onKickOffFromGroup object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onLeaveFromGroup:) name:TUIKitNotification_onLeaveFromGroup object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didTopConversationListChanged:) name:kTopConversationListChangedNotification object:nil];
        self.localConvList = [[NSMutableArray alloc] init];
        [self loadConversation];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didTopConversationListChanged:(NSNotification *)no
{
    NSMutableArray *dataList = [NSMutableArray arrayWithArray:self.dataList];
    [self sortDataList:dataList];
    self.dataList = dataList;
}

- (void)onRefreshNotificationAdded:(NSNotification *)notify {
    // ????????????
    NSArray *convList = notify.object;
    [self updateConversation:convList];
}

- (void)onRefreshNotificationChanged:(NSNotification *)notify {
    // ????????????
    NSArray *convList = notify.object;
    [self updateConversation:convList];
}

- (void)loadConversation
{
    @weakify(self)
//    NSMutableArray<V2TIMConversation *> *list = [NSMutableArray array];
//
//    [[V2TIMConversation alloc] init]
//    [list addObject:(nonnull V2TIMConversation *)]
    //???????????? ???????????????
    NSArray *filterArr = [TConversationListViewModel getFilterArray];
    NSMutableArray *gjList = [NSMutableArray array];
    for (int _loc1 = 0; _loc1 < filterArr.count; _loc1 ++) {
        [gjList addObject:[NSString stringWithFormat:@"c2c_w%@",[filterArr[_loc1] objectForKey:@"zgid"]]];
    }
    [gjList addObject:@"c2c_wsys_01"];
//    WithObjects:@"c2c_u18611416847",@"c2c_u18600663714",nil];
//    NSArray<V2TIMConversation *> *list = [NSArray array];
//    for (int _loc2 = 0; _loc2 < gjList.count; _loc2 ++) {
//        [self loadConversationCustom:gjList[_loc2] with:list];
//    }
    
    
    [[V2TIMManager sharedInstance] getConversationList:0 count:INT_MAX succ:^(NSArray<V2TIMConversation *> *list, uint64_t lastTS, BOOL isFinished) {
        @strongify(self)
        
        
        
        

        NSMutableArray *listM = [[NSMutableArray alloc] initWithArray:list];
        for (int _loc1 = 0; _loc1 < list.count; _loc1 ++) {
            NSString *conversationID = [list[_loc1] conversationID];
            NSInteger index = [gjList indexOfObject:conversationID];
            if (index >= 0 && index < 9223372036854775807){
                //????????????????????? ?????????????????????
                [gjList removeObjectAtIndex:index];
                
            }else{ //?????????
                if ( list[_loc1].type == 1 ){
                    //??????????????? ??? ?????????????????????
                    [listM removeObject:list[_loc1]];
                }
            }
            
        }
        
        [self updateConversation:listM];
        
        //??????????????????????????????
        for (int _loc2 = 0; _loc2 < gjList.count; _loc2 ++) {
            [self loadConversationCustom:gjList[_loc2] with:list];
        }

    } fail:^(int code, NSString *msg) {
        // ????????????????????????
    }];
    
}

-(void)loadConversationCustom:(NSString *)gjID with:(NSArray *)list
{
    
    [[V2TIMManager sharedInstance] getConversation:gjID succ:^(V2TIMConversation *conv) {
        NSMutableArray<V2TIMConversation *> *listT = [[NSMutableArray alloc] initWithArray:list];
        [listT addObject:conv];
        __weak V2TIMConversation *__weak_conv = conv;
        
        [self updateConversation:listT];
    } fail:^(int code, NSString *desc) {
        
    }];
}

- (void)updateConversation:(NSArray *)convList
{
    // ?????? UI ????????????????????? UI ?????????????????????????????????????????????????????????????????????
    for (int i = 0 ; i < convList.count ; ++ i) {
        V2TIMConversation *conv = convList[i];
        BOOL isExit = NO;
        for (int j = 0; j < self.localConvList.count; ++ j) {
            V2TIMConversation *localConv = self.localConvList[j];
            if ([localConv.conversationID isEqualToString:conv.conversationID]) {
                [self.localConvList replaceObjectAtIndex:j withObject:conv];
                isExit = YES;
                break;
            }
        }
        if (!isExit) {
            [self.localConvList addObject:conv];
        }
    }
    // ?????? cell data
    NSMutableArray *dataList = [NSMutableArray array];
    NSArray *filterArr = [TConversationListViewModel getFilterArray];
    for (V2TIMConversation *conv in self.localConvList) {
        // ????????????
        if ([self filteConversation:conv]) {
            continue;
        }
        
        // ??????cellData
        TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
        
        //???????????? bu vince
        [filterArr enumerateObjectsUsingBlock:^(NSMutableDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *tName = [NSString stringWithFormat:@"w%@",[obj objectForKey:@"zgid"]];
            if ([tName isEqualToString:conv.userID]){
                data.yinxingData = obj;
            }
        }];
//        data.yinxingData = conv.yinxingData;
        data.conversationID = conv.conversationID;
        data.groupID = conv.groupID;
        data.userID = conv.userID;
        data.title = conv.showName;
        data.faceUrl = conv.faceUrl;
        data.subTitle = [self getLastDisplayString:conv];
        data.atMsgSeqList = [self getGroupAtMsgSeqList:conv];
        data.time = [self getLastDisplayDate:conv];
        if (NO == [conv.groupType isEqualToString:@"Meeting"]) {
            data.unreadCount = conv.unreadCount;
        }
        data.draftText = conv.draftText;
        if (conv.type == V2TIM_C2C) {   // ???????????????????????????
            data.avatarImage = DefaultAvatarImage;
        } else {
            data.avatarImage = DefaultGroupAvatarImage;
        }
//        __weak TUIConversationCellData *_weak_data = data;
//        printf(data.userID);
//        if (data.userID){
//            NSLog(@"%@",data.userID);
//            NSArray *infoData = [NSArray arrayWithObject:data.userID];
//            [V2TIMManager.sharedInstance getUsersInfo:infoData succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
//                
//            } fail:^(int code, NSString *desc) {
//                data.unregistered = YES;
//            }];
//        }
        
        [dataList addObject:data];
    }
    // UI ?????????????????? lastMessage ?????????????????????
    [self sortDataList:dataList];
    self.dataList = dataList;
    // ???????????????
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onChangeUnReadCount object:self.localConvList];
}

- (BOOL)filteConversation:(V2TIMConversation *)conv
{
    // ??????AVChatRoom???????????????
    if ([conv.groupType isEqualToString:@"AVChatRoom"]) {
        return YES;
    }
    
    // ??????????????????
//    if ([self getLastDisplayString:conv] == nil || [self getLastDisplayDate:conv] == nil) {
//        if (conv.unreadCount != 0) {
//            // ?????? ???????????????????????????data.time???nil?????????????????????????????????????????????lastMessage??????(v1conv???lastmessage)?????????????????????????????????????????????????????????????????????????????????
//            // ????????????????????????????????????????????????
//            NSString *userID = conv.userID;
//            if (userID.length > 0) {
//                [[V2TIMManager sharedInstance] markC2CMessageAsRead:userID succ:^{
//
//                } fail:^(int code, NSString *msg) {
//
//                }];
//            }
//            NSString *groupID = conv.groupID;
//            if (groupID.length > 0) {
//                [[V2TIMManager sharedInstance] markGroupMessageAsRead:groupID succ:^{
//
//                } fail:^(int code, NSString *msg) {
//
//                }];
//            }
//        }
//        return YES;
//    }
    
    return NO;
}

- (void)onGroupDismiss:(NSNotification *)no
{
    NSString *groupID = no.object;
    TUIConversationCellData *data = [self cellDataOf:groupID];
    if (data) {
        [THelper makeToast:[NSString stringWithFormat:TUILocalizableString(TUIKitGroupDismssTipsFormat), data.groupID]];
        [self removeData:data];
    }
}

- (void)onGroupRecycled:(NSNotification *)no
{
    NSString *groupID = no.object;
    TUIConversationCellData *data = [self cellDataOf:groupID];
    if (data) {
        [THelper makeToast:[NSString stringWithFormat:TUILocalizableString(TUIKitGroupRecycledTipsFormat), data.groupID]];
        [self removeData:data];
    }
}

- (void)onKickOffFromGroup:(NSNotification *)no
{
    NSString *groupID = no.object;
    TUIConversationCellData *data = [self cellDataOf:groupID];
    if (data) {
        [THelper makeToast:[NSString stringWithFormat:TUILocalizableString(TUIKitGroupKickOffTipsFormat), data.groupID]];
        [self removeData:data];
    }
}

- (void)onLeaveFromGroup:(NSNotification *)no
{
    NSString *groupID = no.object;
    TUIConversationCellData *data = [self cellDataOf:groupID];
    if (data) {
        [THelper makeToast:[NSString stringWithFormat:TUILocalizableString(TUIKitGroupDropoutTipsFormat), data.groupID]];
        [self removeData:data];
    }
}

- (NSMutableArray<NSNumber *> *)getGroupAtMsgSeqList:(V2TIMConversation *)conv {
    NSMutableArray *seqList = [NSMutableArray array];
    for (V2TIMGroupAtInfo *atInfo in conv.groupAtInfolist) {
        [seqList addObject:@(atInfo.seq)];
    }
    if (seqList.count > 0) {
        return seqList;
    }
    return nil;
}

- (NSString *)getGroupAtTipString:(V2TIMConversation *)conv {
    NSString *atTipsStr = @"";
    BOOL atMe = NO;
    BOOL atAll = NO;
    for (V2TIMGroupAtInfo *atInfo in conv.groupAtInfolist) {
        switch (atInfo.atType) {
            case V2TIM_AT_ME:
                atMe = YES;
                continue;;
            case V2TIM_AT_ALL:
                atAll = YES;
                continue;;
            case V2TIM_AT_ALL_AT_ME:
                atMe = YES;
                atAll = YES;
                continue;;
            default:
                continue;;
        }
    }
    if (atMe && !atAll) {
        atTipsStr = TUILocalizableString(TUIKitConversationTipsAtMe); // @"[??????@???]";
    }
    if (!atMe && atAll) {
        atTipsStr = TUILocalizableString(TUIKitConversationTipsAtAll); // @"[@?????????]";
    }
    if (atMe && atAll) {
        atTipsStr = TUILocalizableString(TUIKitConversationTipsAtMeAndAll); // @"[??????@???][@?????????]";
    }
    return atTipsStr;
}

- (NSMutableAttributedString *)getLastDisplayString:(V2TIMConversation *)conv
{
    NSString *lastMsgStr = [conv.lastMessage getDisplayString];
    // ???????????? lastMsg ???????????????????????? nil
    if (lastMsgStr.length == 0 && conv.draftText.length == 0) {
        return nil;
    }
    NSString *atStr = [self getGroupAtTipString:conv];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",atStr]];
    NSDictionary *attributeDict = @{NSForegroundColorAttributeName:[UIColor d_systemRedColor]};
    [attributeString setAttributes:attributeDict range:NSMakeRange(0, attributeString.length)];
    
    if(conv.draftText.length > 0){
        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:TUILocalizableString(TUIKitMessageTypeDraftFormat),conv.draftText]]];
    } else {
        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:lastMsgStr]];
    }
    return attributeString;
}

- (NSDate *)getLastDisplayDate:(V2TIMConversation *)conv
{
    if(conv.draftText.length > 0){
        return conv.draftTimestamp;
    }
    if (conv.lastMessage) {
        return conv.lastMessage.timestamp;
    }
    return [NSDate distantPast];
}

- (TUIConversationCellData *)cellDataOf:(NSString *)groupID
{
    for (TUIConversationCellData *data in self.dataList) {
        if ([data.groupID isEqualToString:groupID]) {
            return data;
        }
    }
    return nil;
}

- (void)sortDataList:(NSMutableArray<TUIConversationCellData *> *)dataList
{
    // ????????????????????????????????????
    [dataList sortUsingComparator:^NSComparisonResult(TUIConversationCellData *obj1, TUIConversationCellData *obj2) {
        return [obj2.time compare:obj1.time];
    }];

    // ?????????????????????????????????
    NSArray *topList = [[TUILocalStorage sharedInstance] topConversationList];
    int existTopListSize = 0;
    for (NSString *convID in topList) {
        int userIdx = -1;
        for (int i = 0; i < dataList.count; i++) {
            if ([dataList[i].conversationID isEqualToString:convID]) {
                userIdx = i;
                dataList[i].isOnTop = YES;
                break;
            }
        }
        if (userIdx >= 0 && userIdx != existTopListSize) {
            TUIConversationCellData *data = dataList[userIdx];
            [dataList removeObjectAtIndex:userIdx];
            [dataList insertObject:data atIndex:existTopListSize];
            existTopListSize++;
        }
    }
}

- (void)removeData:(TUIConversationCellData *)data
{
    NSMutableArray *list = [NSMutableArray arrayWithArray:self.dataList];
    [list removeObject:data];
    self.dataList = list;
    for (V2TIMConversation *conv in self.localConvList) {
        if ([conv.conversationID isEqualToString:data.conversationID]) {
            [self.localConvList removeObject:conv];
            break;
        }
    }
    [[V2TIMManager sharedInstance] deleteConversation:data.conversationID succ:nil fail:nil];
}
@end
