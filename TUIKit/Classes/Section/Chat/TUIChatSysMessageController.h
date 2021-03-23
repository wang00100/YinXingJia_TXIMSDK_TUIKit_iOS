/******************************************************************************
 *
 * 腾讯云通讯服务界面组件 TUIKIT - 聊天界面组件
 *
 * 本文件主要声明用于实现聊天界面的组件，支持 1v1 单聊和群聊天两种模式，其中包括：
 * - 消息展示区：也就是气泡展示区。
 * - 消息输入区：也就是让用户输入消息文字、发表情以及图片和视频的部分。
 *
 * TUIChatController 类用于实现聊天视图的总控制器，负责将输入、消息控制器、更多视图等进行统一控制。
 * 本文件中声明的类与协议，能够有效的帮助您实现自定义消息格式。
 *
 * TUIChatControllerDelegate 负责提供聊天控制器的部分回调委托。包括接收新消息、显示新消息和某一“更多”单元被点击的回调。
 *
 ******************************************************************************/
#import <UIKit/UIKit.h>
#import "TUIInputController.h"
#import "TUIMessageController.h"
#import "TUIConversationCell.h"
#import "TUIChatController.h"



/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIChatController
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】聊天界面组件（TUIChatController）
 *
 * 【功能说明】负责实现聊天界面的 UI 组件，包括消息展示区和消息输入区。
 *
 *  TUIChatController 类用于实现聊天视图的总控制器，负责将聊天消息控制器（TUIMessageController）、信息输入控制器（TUIInputController）和更多视频进行统一控制。
 *
 *  聊天消息控制器负责在您接收到新消息或者发送消息时在 UI 作出响应，并响应您在消息气泡上的交互操作，详情参考:Section\Chat\TUIMessageController.h
 *  信息输入控制器负责接收您的输入，向你提供输入内容的编辑功能并进行消息的发送，详情参考:Section\Chat\Input\TUIInputController.h
 *  本类中包含了“更多”视图，即在您点击 UI 中“+”按钮时，能够显示出更多按钮来满足您的进一步操作，详情参考:Section\Chat\TUIMoreView.h
 *
 *  Q: 如何实现自定义的个性化消息气泡功能？
 *  A: 如果您想要实现 TUIKit 不支持的消息气泡样式，比如在消息气泡中添加投票链接等，可以参考文档：
 *     https://github.com/tencentyun/TIMSDK/wiki/TUIKit-iOS%E8%87%AA%E5%AE%9A%E4%B9%89%E6%B6%88%E6%81%AF
 */
@interface TUIChatSysMessageController : UIViewController

//********************************
@property TUnReadView *unRead;
//********************************

/**
 *  TUIKit 聊天消息控制器
 *  负责消息气泡的展示，同时负责响应用户对于消息气泡的交互，比如：点击消息发送者头像、轻点消息、长按消息等操作。
 *  聊天消息控制器的详细信息请参考 Section\Chat\TUIMessageController.h
 */
@property TUIMessageController *messageController;

/**
 *  TUIKit 信息输入控制器。
 *  负责接收用户输入，同时显示“+”按钮与语音输入按钮、表情按钮等。
 *  同时 TUIInputController 整合了消息的发送功能，您可以直接使用 TUIInputController 进行消息的输入采集与发送。
 *  信息输入控制器的详细信息请参考 Section\Chat\Input\TUIInputController.h
 */
@property TUIInputController *inputController;

/**
 *  被委托类，负责实现并执行 TUIChatControllerDelegate 的委托函数
 */
@property (weak) id<TUIChatControllerDelegate> delegate;

/**
 *  更多菜单视图数据的数据组
 *  更多菜单视图包括：拍摄、图片、视频、文件。详细信息请参考 Section\Chat\TUIMoreView.h
 */
@property NSArray<TUIInputMoreCellData *> *moreMenus;

/**
 *  初始化函数。
 *  根据所选会话初始化当前界面。
 *  初始化内容包括对资源图标的加载、历史消息的恢复，以及 MessageController、InputController 和“更多”视图的相关初始化操作。
 *
 *  @param conversationData 会话数据
 */
- (instancetype)initWithConversation:(TUIConversationCellData *)conversationData;

/**
 *  发送自定义的个性化消息
 *
 *  TUIKit 已经实现了基本的文本、表情、图片、文字和视频的发送逻辑，如果已经能够满足您的需求，可以不关注此接口。
 *  如果您想要发送我们暂不支持的个性化消息，就需要使用该接口对消息进行自定义。
 *
 *  您可以参考一下代码示例来对自定义消息进行包装：
 *
 *  <pre>
 *      //实例化您的自定义消息数据源，并对消息数据源中的必要属性进行复制
 *      MyCustomCellData *cellData = [[MyCustomCellData alloc] initWithDirection:MsgDirectionOutgoing];
 *
 *      //创建 cellData 的 innerMessage（十分重要）。此处的 innerMessage 为 IM SDK 收发消息的核心元素之一。
 *      cellData.innerMessage = [[TIMMessage alloc] init];
 *
 *      //创建自定义元素，并添加进 innerMessage 中。
 *      TIMCustomElem * custom_elem = [[TIMCustomElem alloc] init];
 *      NSString * text = @"<xml><text>这是我的自定义消息</text><link>www.qq.com</link></xml>";
 *      NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
 *      [custom_elem setData:data];
 *      [cellData.innerMessage addElem:custom_elem];
 *
 *      //自此，自定义消息数据源包装完毕，调用 sendMessage 发送自定义消息。
 *      [chatController sendMessage:cellData];
 *  </pre>
 *
 *  调用 sendMessage() 之后，消息会被发送出去，但是如果仅完成这一步，个性化消息并不能展示在气泡区，
 *  需要继续监听 TUIChatControllerDelegate 中的 onNewMessage 和 onShowMessageData 回调才能完成个性化消息的展示。
 *
 *  @param message 需要发送的消息数据源。包括消息内容、发送者的头像、发送者昵称、消息字体与颜色等等。详细信息请参考 Section\Chat\CellData\TUIMessageCellData.h
 */
- (void)sendMessage:(TUIMessageCellData *)message;

/**
 *  保存草稿。
 *  以草稿的格式，保存当前聊天视图中未删除且未发送的信息。
 *  本函数会在您返回父视图时自动调用。
 *  需要注意的是，目前版本仅能保存未发送的文本消息作为草稿。
 */
- (void)saveDraft;

@end
