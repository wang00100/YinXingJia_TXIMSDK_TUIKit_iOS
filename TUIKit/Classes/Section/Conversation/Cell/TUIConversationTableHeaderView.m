//
//  TUIConversationCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/16.
//

#import "TUIConversationTableHeaderView.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TIMUserProfile+DataProvider.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "TUIKit.h"
#import "THeader.h"
#import "CreatGroupAvatar.h"
#import <ImSDK/ImSDK.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "UIColor+TUIDarkMode.h"
#import "THeader.h"

@interface TUIConversationTableHeaderView()<UIGestureRecognizerDelegate>
@property UITapGestureRecognizer *tapRecognizer;
@end

@implementation TUIConversationTableHeaderView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        _tapRecognizer.delegate = self;
        _tapRecognizer.cancelsTouchesInView = NO;
        
        self.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];

        _headImageView = [[UIImageView alloc] init];
        [self addSubview:_headImageView];

        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor d_systemGrayColor];
        _timeLabel.layer.masksToBounds = YES;
        _timeLabel.hidden = true;
        [self addSubview:_timeLabel];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        _titleLabel.layer.masksToBounds = YES;
        [self addSubview:_titleLabel];
        
        UIColor *title2Color = [[UIColor alloc] initWithRed:217.0/255.0 green:165/255.0 blue:82.0/255.0 alpha:1.0];
        _titleLabel2 = [[UILabel alloc] init];
        _titleLabel2.font = [UIFont systemFontOfSize:12];
        _titleLabel2.textColor = title2Color;
        _titleLabel2.text = @"  金牌管家  ";
        _titleLabel2.layer.masksToBounds = YES;
        _titleLabel2.layer.borderColor = title2Color.CGColor;
        _titleLabel2.layer.borderWidth = 1;
        _titleLabel2.layer.cornerRadius = 10;
        [self addSubview:_titleLabel2];
        
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor =  [[UIColor alloc] initWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0];
        [self addSubview:_lineView];
        
        _phoneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 116, 29)];
        [_phoneButton setImage:[UIImage imageNamed:@"TUIConversationTableHeaderView.phone_skip"] forState:UIControlStateNormal];
        [self addSubview:_phoneButton];
        [_phoneButton addTarget:self action:@selector(makePhoneCall) forControlEvents:UIControlEventTouchUpInside];
        
        _messageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 116, 29)];
        [_messageButton setImage:[UIImage imageNamed:@"TUIConversationTableHeaderView.message_skip"] forState:UIControlStateNormal];
        [self addSubview:_messageButton];
        [_messageButton addTarget:self action:@selector(tapGesture) forControlEvents:UIControlEventTouchUpInside];

        _unReadView = [[TUnReadView alloc] init];
        [self addSubview:_unReadView];

        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.layer.masksToBounds = YES;
        _subTitleLabel.font = [UIFont systemFontOfSize:14];
        _subTitleLabel.textColor = [UIColor d_systemGrayColor];
        [self addSubview:_subTitleLabel];

//        [self setSeparatorInset:UIEdgeInsetsMake(0, TConversationCell_Margin, 0, 0)];
//
//        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        //[self setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }
    return self;
}

-(void)makePhoneCall{
    NSString *phone = [self.convData.yinxingData objectForKey:@"phone"];
    if (phone){
        NSString *url = [NSString stringWithFormat:@"tel://%@",phone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}


- (void)tapGesture
{
    if (self.convData.cselector) {
        UIViewController *vc = self.mm_viewController;
        if ([vc respondsToSelector:self.convData.cselector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [vc performSelector:self.convData.cselector withObject:self];
#pragma clang diagnostic pop
        }
    }
}


- (void)fillWithData:(TUIConversationCellData *)convData
{
//    if (self.convData.cselector) {
//        [self addGestureRecognizer:self.tapRecognizer];
//    } else {
//        [self removeGestureRecognizer:self.tapRecognizer];
//    }
//    [super fillWithData:convData];
    self.convData = convData;

    self.timeLabel.text = [convData.time tk_messageString];
//    self.subTitleLabel.attributedText = convData.subTitle;
    if ([convData.yinxingData objectForKey:@"time"] != nil){
        self.subTitleLabel.text = [convData.yinxingData objectForKey:@"time"];
        self.titleLabel2.text = [convData.yinxingData objectForKey:@"position"];
    }
    
    //add by vince
    [self.unReadView setNum:convData.unreadCount];

    if (convData.isOnTop) {
        self.backgroundColor = [UIColor d_colorWithColorLight:TCell_OnTop dark:TCell_OnTop_Dark];
    } else {
        self.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
    }
    
    if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height / 2;
    } else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
    }

    @weakify(self)
    [[[RACObserve(convData, title) takeUntil:self.rac_prepareForReuseSignal]
      distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.titleLabel.text = x;
    }];
    
    // 修改默认头像
    if (convData.groupID.length > 0) {
        // 群组, 则将群组默认头像修改成上次使用的头像
        NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", convData.groupID];
        NSInteger member = [NSUserDefaults.standardUserDefaults integerForKey:key];
        UIImage *avatar = [self getCacheAvatarForGroup:convData.groupID number:(UInt32)member];
        if (avatar) {
            convData.avatarImage = avatar;
        }
    }
    
    [[RACObserve(convData,faceUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSURL *x) {
        @strongify(self)
        if (self.convData.groupID.length > 0) { //群组
            // fix: 由于getCacheGroupAvatar需要请求网络，断网时，由于并没有设置headImageView，此时当前会话发消息，会话会上移，复用了第一条会话的头像，导致头像错乱
            self.headImageView.image = self.convData.avatarImage;
            [self getCacheGroupAvatar:^(UIImage *avatar) {
                if (avatar != nil) { //已缓存群组头像
                    self.headImageView.image = avatar;
                } else { //未缓存群组头像
                    [self.headImageView sd_setImageWithURL:x
                                          placeholderImage:self.convData.avatarImage];
                    [self prefetchGroupMembers];
                }
            }];
        } else {//个人头像
            [self.headImageView sd_setImageWithURL:x
                                  placeholderImage:self.convData.avatarImage];
        }
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat height = [self.convData heightOfWidth:self.mm_w];
    self.mm_h = 132;
    CGFloat imgHeight = height-2*(TConversationCell_Margin);

    self.headImageView.mm_width(imgHeight).mm_height(imgHeight).mm_left(TConversationCell_Margin + 3).mm_top(TConversationCell_Margin);
    if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = imgHeight / 2;
    } else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
    }

    self.timeLabel.mm_sizeToFit().mm_top(TConversationCell_Margin_Text).mm_right(TConversationCell_Margin + 4);
    self.titleLabel.mm_sizeToFitThan(20, 30).mm_top(TConversationCell_Margin_Text - 5).mm_left(self.headImageView.mm_maxX+TConversationCell_Margin);
    
    //add by vince
    self.titleLabel2.mm_sizeToFitThan(10, 20).mm_top(TConversationCell_Margin_Text).mm_left(self.titleLabel.mm_maxX+TConversationCell_Margin);
    self.lineView.mm_height(1).mm_top(self.headImageView.mm_maxY + 15).mm_width(self.frame.size.width);
    
    self.messageButton.mm_width(116).mm_top(self.lineView.mm_maxY + 15).mm_left((self.frame.size.width/2 - self.messageButton.frame.size.width )/2 + 15);
    self.phoneButton.mm_width(116).mm_top(self.lineView.mm_maxY + 15).mm_right((self.frame.size.width/2 - self.phoneButton.frame.size.width )/2 + 15);
                                                                  
                                                                
    
    self.unReadView.mm_top(self.messageButton.mm_y - 5).mm_left(self.messageButton.mm_maxX - 15);
    self.subTitleLabel.mm_sizeToFit().mm_left(self.titleLabel.mm_x).mm_top( self.headImageView.mm_maxY - 16).mm_flexToRight(15);
}

/// 取得群组前9个用户
- (void)prefetchGroupMembers {
    @weakify(self)
    [[V2TIMManager sharedInstance] getGroupMemberList:self.convData.groupID filter:V2TIM_GROUP_MEMBER_FILTER_ALL nextSeq:0 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        @strongify(self)
        int i = 0;
        NSMutableArray *groupMemberAvatars = [NSMutableArray arrayWithCapacity:1];
        for (V2TIMGroupMemberFullInfo* member in memberList) {
            if (member.faceURL.length > 0) {
                [groupMemberAvatars addObject:member.faceURL];
                i++;
            }
            if (i == 9) {
                break;
            }
        }
        [self createGroupAvatar:groupMemberAvatars];
        
        // 存储当前获取到的群组头像信息
        NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", self.convData.groupID];
        [NSUserDefaults.standardUserDefaults setInteger:groupMemberAvatars.count forKey:key];
        [NSUserDefaults.standardUserDefaults synchronize];
        
    } fail:^(int code, NSString *msg) {
        @strongify(self)
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:self.convData.faceUrl]
                              placeholderImage:self.convData.avatarImage];
    }];
}

/// 创建九宫格群头像
- (void)createGroupAvatar:(NSMutableArray*)groupMemberAvatars{
    @weakify(self)
    [CreatGroupAvatar createGroupAvatar:groupMemberAvatars finished:^(NSData *groupAvatar) {
        @strongify(self)
        UIImage *avatar = [UIImage imageWithData:groupAvatar];
        self.headImageView.image = avatar;
        [self cacheGroupAvatar:avatar number:(UInt32)groupMemberAvatars.count];
    }];
}

/// 缓存群组头像
/// @param avatar 图片
/// 取缓存的维度是按照会议室ID & 会议室人数来定的，
/// 人数变化取不到缓存
- (void)cacheGroupAvatar:(UIImage*)avatar number:(UInt32)memberNum {
    if (self.convData.groupID.length == 0) {
        return;
    }
    NSString* tempPath = NSTemporaryDirectory();
    NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%d.png",tempPath,
                          self.convData.groupID,memberNum];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // check to delete old file
    NSNumber *oldValue = [defaults objectForKey:self.convData.groupID];
    if ( oldValue != nil) {
        UInt32 oldMemberNum = [oldValue unsignedIntValue];
        NSString *oldFilePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%d.png",tempPath,
        self.convData.groupID,oldMemberNum];
         NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:oldFilePath error:nil];
    }
    
    // Save image.
    BOOL success = [UIImagePNGRepresentation(self.headImageView.image) writeToFile:filePath atomically:YES];
    if (success) {
        [defaults setObject:@(memberNum) forKey:self.convData.groupID];
    }
}

/// 获取缓存群组头像
/// 缓存的维度是按照会议室ID & 会议室人数来定的，
/// 人数变化要引起头像改变
- (void)getCacheGroupAvatar:(void(^)(UIImage *))imageCallBack {
    [[V2TIMManager sharedInstance] getGroupsInfo:@[self.convData.groupID] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
        V2TIMGroupInfoResult *groupInfo = groupResultList.firstObject;
        if (!groupInfo) {
            imageCallBack(nil);
            return;
        }
        UInt32 memberNum = groupInfo.info.memberCount;
        //限定1-9的范围
        memberNum = MAX(1, memberNum);
        memberNum = MIN(memberNum, 9);;
        NSString* tempPath = NSTemporaryDirectory();
        NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%u.png",tempPath,
                              self.convData.groupID,(unsigned int)memberNum];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        UIImage *avatar = nil;
        BOOL success = [fileManager fileExistsAtPath:filePath];

        if (success) {
            avatar= [[UIImage alloc] initWithContentsOfFile:filePath];
            // 存储当前获取到的群组头像信息
            NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", self.convData.groupID];
            [NSUserDefaults.standardUserDefaults setInteger:memberNum forKey:key];
            [NSUserDefaults.standardUserDefaults synchronize];
        }
        imageCallBack(avatar);
    } fail:^(int code, NSString *msg) {
        imageCallBack(nil);
    }];
}


/// 同步获取本地缓存的群组头像
/// @param groupId 群id
/// @param memberNum 群成员个数, 最多返回9个成员的拼接头像
- (UIImage *)getCacheAvatarForGroup:(NSString *)groupId number:(UInt32)memberNum {
    //限定1-9的范围
    memberNum = MAX(1, memberNum);
    memberNum = MIN(memberNum, 9);;
    NSString* tempPath = NSTemporaryDirectory();
    NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%u.png",tempPath,
                          groupId,(unsigned int)memberNum];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    UIImage *avatar = nil;
    BOOL success = [fileManager fileExistsAtPath:filePath];

    if (success) {
        avatar= [[UIImage alloc] initWithContentsOfFile:filePath];
    }
    return avatar;
}

@end
