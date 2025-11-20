import { ComponentContent, KeyboardAvoidMode } from '@kit.ArkUI';
import {
  VHGiftMessageInfo,
  VHLikeIcon,
  VHQuestionAnswerSwitchMsg,
  VHQuestionnairePushModel,
  VHRoomLikeInfo,
  VHRoomToolsStatusData,
  VHAgreement,
  VHChatDisableAllMsg,
  VHChatMessageList,
  VHConfigList,
  VHContent,
  VHContext,
  VHExaminationModel,
  VHIMMessageModel,
  VHIMServer,
  VHMsgData,
  VHReplyMessage,
  VHReplyMessageContent,
  VHRoomEventType,
  VHSaaSDK,
  VHUploadFileInfo,
  VHUserData,
  VHWebinarData,
  VHExamUserAnswerStatus,
  VHExamRank,
  VHExamReportList,
  VHChatDeleteMsg,
  VHChatMsgSetRecommend,
  VHChatMsgDelRecommend,
  VHExamList,
} from '@vhall/vhall_live';
import { EmitterMsgData, EmitterUtil } from '../../util/EmitterUtil';
import { ToastUtil } from '../../action/ToastUtil';
import { createGiftView } from './GiftComponent';
import { PromptActionClass } from '../../util/PromptActionClass';
import ChatTools from '../../util/ChatTools';
import { CountDownTimer } from '../../util//CountDownTimer.ets';
import { EmojiTool } from './EmojiTool';
import { QuestionnaireBuilder } from '../../builder/QuestionnaireBuilder';
import { ExamBuilder } from '../../builder/ExamBuilder';
import { ToastOptions } from '../../entity/ToastOptions';
import LoadingMoreView from '../../components/common/LoadingMoreView';
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { picker } from '@kit.CoreFileKit';
import MsgType from '../../constants/MsgType';
import { createExamReportView, reportParams } from '../../builder/ExamReportBuilder';


/**
 * 主界面（聊天单页）。
 *
 */
@Component
export struct ChatComponent {
  @Prop functionConfig: VHConfigList | null = null; //功能配置
  @Prop room_tool: VHRoomToolsStatusData | null = null;
  @Prop webinars: VHWebinarData | null = null;
  @Prop isLive: boolean; //是否直播
  @Prop welcomeContent: string;
  @Prop imBase: VHIMServer;
  @State avatar: string | undefined = "";
  @State inputText: string = "参与聊天";
  @State messageInput: string = '';
  @LocalStorageLink('likeCount') likeCount: number = 0;
  @State clickLikeNumber: number = 0;
  @Consume questionnairePush: VHQuestionnairePushModel | null
  @Consume examData: VHExaminationModel
  @Consume chatBannedMode:number;
  private examReportContentNode: ComponentContent<Object> | null = null;
  @Consume ExamList: VHExamList[]
  /** 聊天列表的滚动条组件 */
  private scroller: Scroller = new Scroller();
  private giftNode: ComponentContent<Object> | null = null;
  private timer: CountDownTimer | null = null;
  @State chatDisable: boolean = false;
  /** 聊天消息列表对应的数据源对象（本对象与MessageProvider配合，用于实现UI界面与数据组的解偶）*/
  @State historyData: VHContent[] = [];
  @State examRankMsg: VHExamRank[] = [];
  // 用来配置CanvasRenderingContext2D对象的参数，开启抗锯齿
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  // 正确创建CanvasRenderingContext2D对象
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  @State likeIcons: VHLikeIcon[] = [] // 存储所有点赞图标
  @State welcomeLoginUser: string = '';
  @State agreement: VHAgreement = new VHAgreement();
  private animationId: number = 0 // 动画ID
  @Consume chatNickNameEnc:number;
  // emoji表情数组
  private readonly emojis: string[] = [
    '❤️', '🧡', '💛', '💚', '💙', '💜',
    '🐼', '🦁', '🐯', '🦊',
    '🎁', '🎀', '🎉', '🎊', '✨', '⭐'
  ]
  // 状态管理：控制预览显示/隐藏 + 当前预览的图片URL
  @State isPreviewShow: boolean = false;
  @State currentPreviewUrl: string = '';
  @State reachStatus: number = 0 //触底状态 0:初始状态，1：加载中状态 2：已到底了
  @State isLoadingMore: boolean = false //是否正在通过接口请求加载数据
  @State hasMoreData: boolean = true
  @State initCompleted: boolean = false //初始化是否完成
  @State loadingMoreVisible: boolean = false //加载更多组件是否显示
  @State isRefreshing: boolean = false
  private total: number = 0
  private pageSize: number = 100 //分页每页个数
  private pageNo: number = 1 //分页当前页数
  private lastScrollOffset: number = 0
  // 添加防重标志
  private isHandlingReachEnd: boolean = false
  @State enableWelcome:boolean = false;
  @State welcomeMsg:string = "";

  aboutToAppear() {
    // 本界面显示时，将输入法软键盘避让模式设置为KeyboardAvoidMode.RESIZE（即压缩窗体，而不是将窗体整体上移）
    // this.setKeyboardAvoidModeToRESIZE(this.getUIContext(), true);
    this.avatar = this.webinars?.join_info?.avatar;
    this.initChatMessage(1);
    this.getLikeCount();
    // 启动动画循环
    this.startAnimation()
    this.initTimer();
    this.enableWelcome = this.functionConfig?.live_chat_welcome == 1 ? true : false;
    this.welcomeMsg = this.functionConfig?.live_chat_welcome_msg!;
    this.giftNode = new ComponentContent(this.getUIContext(), wrapBuilder(createGiftView), this.webinars!);
    // PromptActionClass.setContext(this.getUIContext());
    // PromptActionClass.setContentNode(this.giftNode);
    // PromptActionClass.setOptions({ alignment: DialogAlignment.BottomEnd, offset: { dx: 0, dy: 0 } });
    // 订阅消息
    this.subscribeTextMessage();
    this.subscribeGiftMessage();
    this.subscribePaperEndMessage();
    this.subLotteryMsg();
    this.subscribeChatDisable();
    this.subscribeLikeCount();
    this.subscribeClearAllChatMessage();
    this.subscribeChatDelete();
    this.subscribeChatMsgSetRecommend();
    this.subscribeChatMsgDelRecommend();
    if (this.isLive) {
      this.subscribeQuestionAnswerMessage();
      this.welcomeUser();
    }
    if (this.room_tool?.all_banned == 1 || this.webinars?.join_info?.is_gag == 1) {
      this.chatDisable = true;
    }
    if (this.isLive == false && this.functionConfig?.watch_record_no_chatting == 1) {
      // 回放禁言
      this.chatDisable = true;
    }
    this.AgreementMessage();
  }

  /**
   * 界面被销毁时被调用。
   */
  aboutToDisappear() {
    // this.setKeyboardAvoidModeToRESIZE(this.getUIContext(), false);
    this.timer?.cancel();
    // 清除动画循环
    clearInterval(this.animationId)
    EmitterUtil.unsubscribe(VHRoomEventType.IM_TEXT);
    EmitterUtil.unsubscribe(VHRoomEventType.GIFT_MSG);
    EmitterUtil.unsubscribe(VHRoomEventType.QUESTION_ANSWER_OPEN);
    EmitterUtil.unsubscribe(VHRoomEventType.USER_JOIN);
    EmitterUtil.unsubscribe(VHRoomEventType.CHAT_DISABLE);
    EmitterUtil.unsubscribe(VHRoomEventType.CHAT_PERMIT);
    EmitterUtil.unsubscribe(VHRoomEventType.CHAT_DISABLE_ALL);
    EmitterUtil.unsubscribe(VHRoomEventType.CHAT_PERMIT_ALL);
    EmitterUtil.unsubscribe(VHRoomEventType.CUSTOM_PRAISE);
    EmitterUtil.unsubscribe(MsgType.LOTTERY_MSG);
    EmitterUtil.unsubscribe(VHRoomEventType.CHAT_DELETE);
    EmitterUtil.unsubscribe(VHRoomEventType.CHAT_MSG_SET_RECOMMEND);
    EmitterUtil.unsubscribe(VHRoomEventType.CHAT_MSG_DEL_RECOMMEND);
  }

  //问卷弹窗
  VHQuestionnaireDialog = new CustomDialogController({
    builder: QuestionnaireBuilder({ webinar: this.webinars! }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })
  //快问快答弹窗
  VHExamDialog = new CustomDialogController({
    builder: ExamBuilder({webinar_info:this.webinars!}),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })

  //观看协议消息
  AgreementMessage() {
    if (this.webinars?.webinar != null) {
      let recordId:string = "";
      if(this.webinars.webinar.type == 5){
        recordId = this.webinars.record?.record_id!;//回放获取当前回放id
      }
      VHSaaSDK.getInstance().getWatchInfo(this.webinars.webinar.id.toString(), recordId, '', '',  {
        onSucceed: (data: VHWebinarData) => {
          this.agreement = data.agreement as VHAgreement;
        },
        onFailure: (errorCode, errorMsg) => {
          ToastUtil.showToast(errorMsg);
        }
      })
    }
  }

  // 欢迎语
  welcomeUser() {
    this.welcomeLoginUser = this.webinars?.join_info?.nickname!;
    let options: ToastOptions = new ToastOptions();
    options.alignment = Alignment.Center;
    options.backgroundColor = '#FF8A80';
    options.offset = { dx: 0, dy: -300 }
    // if (this.welcomeLoginUser! && this.welcomeContent.length > 0) {
    //   ToastUtil.showToast(this.welcomeLoginUser + " " + this.welcomeContent, options);
    // }
    if(this.enableWelcome){
      let tips = this.welcomeMsg.replace("{user_nickname}",this.welcomeLoginUser);
      ToastUtil.showToast(tips, options);
    }
  }

  // 订阅Text类型消息
  subscribeTextMessage() {
    EmitterUtil.subscribe(VHRoomEventType.IM_TEXT, (msgData: EmitterMsgData) => {
      console.log(`收到文本消息，类型：${VHRoomEventType.IM_TEXT}`);
      let messageModel: VHIMMessageModel = msgData as VHIMMessageModel;
      if (messageModel.data!) {
        // 实际业务：将消息添加到列表、更新UI等
        this.handleTextMessage(messageModel.data);
        // 延迟滚动到最新消息（确保UI已更新）
        setTimeout(() => {
          this.scrollToBottom();
        }, 100);
      }
    });
  }

  subscribePaperEndMessage() {
    EmitterUtil.subscribe(VHRoomEventType.PAPER_SEND_RANK, (msgData: EmitterMsgData) => {
      let messageModel: VHExamRank = msgData.data as VHExamRank;
      this.examRankMsg.push(messageModel)
      setTimeout(() => {
        this.scrollToBottom();
      }, 100);
    });
  }



  subscribeLikeCount() {
    EmitterUtil.subscribe(VHRoomEventType.CUSTOM_PRAISE, (msgData: EmitterMsgData) => {
      console.log(`收到点赞消息，类型：${VHRoomEventType.IM_TEXT}`);
      let messageModel: VHIMMessageModel = msgData as VHIMMessageModel;
      if (messageModel.data!) {
        this.handleLikeCount(messageModel.data);
      }
    });
  }

  subscribeChatDelete() {
    EmitterUtil.subscribe(VHRoomEventType.CHAT_DELETE, (msgData: EmitterMsgData) => {
      console.log(`收到删除消息，类型：${VHRoomEventType.CHAT_DELETE}`);
      let chatDeleteMsg: VHChatDeleteMsg = msgData.data as VHChatDeleteMsg;
      if (chatDeleteMsg!) {
        if (typeof chatDeleteMsg === 'string') {
          const parsedMessage: VHChatDeleteMsg = JSON.parse(chatDeleteMsg) as VHChatDeleteMsg;
          this.handleChatDeleteMsg(parsedMessage);
        } else {
          this.handleChatDeleteMsg(chatDeleteMsg);
        }
      }
    });
  }

  subscribeClearAllChatMessage() {
    EmitterUtil.subscribe(VHRoomEventType.CLEAR_CHAT_MESSAGE, (msgData: EmitterMsgData) => {
      console.log(`收到清空所有消息，类型：${VHRoomEventType.CLEAR_CHAT_MESSAGE}`);
      let messageModel: VHIMMessageModel = msgData as VHIMMessageModel;
      if (messageModel.data!) {
        // 重新初始化消息
        this.initChatMessage(1);
      }
    });
  }

  subscribeChatMsgSetRecommend() {
    EmitterUtil.subscribe(VHRoomEventType.CHAT_MSG_SET_RECOMMEND, (msgData: EmitterMsgData) => {
      console.log(`收到设置精选消息，类型：${VHRoomEventType.CHAT_MSG_SET_RECOMMEND}`);
      let chatMsgSetRecommend: VHChatMsgSetRecommend = msgData.data as VHChatMsgSetRecommend;
      if (chatMsgSetRecommend!) {
        if (typeof chatMsgSetRecommend === 'string') {
          const parsedMessage: VHChatDeleteMsg = JSON.parse(chatMsgSetRecommend) as VHChatDeleteMsg;
        } else {
        }
      }
    });
  }

  subscribeChatMsgDelRecommend() {
    EmitterUtil.subscribe(VHRoomEventType.CHAT_MSG_DEL_RECOMMEND, (msgData: EmitterMsgData) => {
      console.log(`收到取消精选消息，类型：${VHRoomEventType.CHAT_MSG_DEL_RECOMMEND}`);
      let chatMsgDelRecommend: VHChatMsgDelRecommend = msgData.data as VHChatMsgDelRecommend;
      if (chatMsgDelRecommend!) {
        if (typeof chatMsgDelRecommend === 'string') {
          const parsedMessage: VHChatMsgDelRecommend = JSON.parse(chatMsgDelRecommend) as VHChatMsgDelRecommend;
        } else {
        }
      }
    });
  }

  subLotteryMsg(){
    EmitterUtil.subscribe(MsgType.LOTTERY_MSG, (msgData: EmitterMsgData) => {
      let messageModel: string = msgData.data as string;
      // 发送消息
      this.imBase.sendMessage(messageModel, {
        onSuccess: () => {
          console.log("消息发送成功");
        },
        onFailure(errorCode: number, errorMsg: string) {
          // 弹出消息信息
          ToastUtil.showToast("发送消息失败");
        }
      });
    });
  }

  subscribeGiftMessage() {
    EmitterUtil.subscribe(VHRoomEventType.GIFT_MSG, (msgData: EmitterMsgData) => {
      console.log(`收到礼物类型消息，类型：${VHRoomEventType.GIFT_MSG}`);
      let giftInfo: VHGiftMessageInfo = msgData.data as VHGiftMessageInfo;
      if (giftInfo!) {
        if (typeof giftInfo === 'string') {
          const parsedMessage: VHGiftMessageInfo = JSON.parse(giftInfo) as VHGiftMessageInfo;
          this.handleGiftMessage(parsedMessage);
        } else {
          this.handleGiftMessage(giftInfo);
        }
        // 延迟滚动到最新消息（确保UI已更新）
        setTimeout(() => {
          this.scrollToBottom();
        }, 100);
      }
    });
  }

  //订阅禁言事件
  subscribeChatDisable() {
    EmitterUtil.subscribe(VHRoomEventType.CHAT_DISABLE, (msgData: EmitterMsgData) => {
      this.chatDisable = true;
    });
    EmitterUtil.subscribe(VHRoomEventType.CHAT_PERMIT, (msgData: EmitterMsgData) => {
      this.chatDisable = false;
    });
    EmitterUtil.subscribe(VHRoomEventType.CHAT_DISABLE_ALL, (msgData: EmitterMsgData) => {
      let chatDisableAllMsg: VHChatDisableAllMsg = msgData.data as VHChatDisableAllMsg;
      if (chatDisableAllMsg != null && chatDisableAllMsg.chat_status == 1) {
        this.chatDisable = true;
      }
    });
    EmitterUtil.subscribe(VHRoomEventType.CHAT_PERMIT_ALL, (msgData: EmitterMsgData) => {
      let chatDisableAllMsg: VHChatDisableAllMsg = msgData.data as VHChatDisableAllMsg;
      if (chatDisableAllMsg != null && chatDisableAllMsg.chat_status == 1) {
        this.chatDisable = false;
      }
    });
  }

  // 订阅问答信息
  subscribeQuestionAnswerMessage() {
    EmitterUtil.subscribe(VHRoomEventType.QUESTION_ANSWER_OPEN, (msgData: EmitterMsgData) => {
      console.log(`收到问答开启信息，类型：${VHRoomEventType.QUESTION_ANSWER_OPEN}`);
      let questionAnswerInfo: VHQuestionAnswerSwitchMsg = msgData.data as VHQuestionAnswerSwitchMsg;
      if (questionAnswerInfo!) {
        if (typeof questionAnswerInfo === 'string') {
          const parsedMessage: VHQuestionAnswerSwitchMsg = JSON.parse(questionAnswerInfo) as VHQuestionAnswerSwitchMsg;
          this.handleQuestionAnswerMessage(parsedMessage);
        } else {
          this.handleQuestionAnswerMessage(questionAnswerInfo);
        }
        // 延迟滚动到最新消息（确保UI已更新）
        setTimeout(() => {
          this.scrollToBottom();
        }, 100);
      }
    });

    EmitterUtil.subscribe(VHRoomEventType.QUESTION_ANSWER_CLOSE, (msgData: EmitterMsgData) => {
      console.log(`收到问答关闭信息，类型：${VHRoomEventType.QUESTION_ANSWER_CLOSE}`);
      let questionAnswerInfo: VHQuestionAnswerSwitchMsg = msgData.data as VHQuestionAnswerSwitchMsg;
      if (questionAnswerInfo!) {
        if (typeof questionAnswerInfo === 'string') {
          const parsedMessage: VHQuestionAnswerSwitchMsg = JSON.parse(questionAnswerInfo) as VHQuestionAnswerSwitchMsg;
          this.handleQuestionAnswerMessage(parsedMessage);
        } else {
          this.handleQuestionAnswerMessage(questionAnswerInfo);
        }
        // 延迟滚动到最新消息（确保UI已更新）
        setTimeout(() => {
          this.scrollToBottom();
        }, 100);
      }
    });
  }

  handleTextMessage(msg?: VHIMMessageModel) {
    if (!msg) {
      return;
    }
    // 接收文本消息
    let imMsg: VHContent = msg as VHContent;
    imMsg.nickname = msg.nick_name;
    imMsg.date_time = this.formatTime(msg.date_time!);
    imMsg.data = msg.data as VHMsgData;
    let context = JSON.parse(msg.context as string) as VHContext;
    imMsg.role_name = context.role_name === '1' ? '主持人' : '';
    if (context?.replyMsg !== undefined) {
      // 回复消息
      let replyMessage = context?.replyMsg as VHReplyMessage;
      if (replyMessage != null && replyMessage.content !== undefined) {
        let replyContent = replyMessage.content as VHReplyMessageContent;
        if (replyContent !== null && replyContent.type === VHRoomEventType.IM_TYPE_TEXT) {
          let msgData = imMsg.data as VHMsgData;
          let replyContentStr = replyMessage.nickname  +"： "+replyContent.text_content + "\n\n" + "回复： " + imMsg.data?.text_content;
          imMsg.data =
            new VHMsgData(msgData.type, replyContentStr, replyContentStr, msgData.nickname, msgData.avatar, []);
        }
      }
    }
    this.historyData.push(imMsg);
  }

  handleLikeCount(msg?: VHIMMessageModel) {
    if (!msg) {
      return;
    }
    // 接收文本消息
    let imMsg: VHContent = msg as VHContent;
    imMsg.data = msg.data as VHMsgData;
    // 接收点赞数
    if (imMsg.data!.event_type === VHRoomEventType.CUSTOM_PRAISE && imMsg.data!.num! > 0) {
      this.likeCount = imMsg.data.num;
    }
  }

  handleChatDeleteMsg(chatDeleteMsg: VHChatDeleteMsg) {
    if (!chatDeleteMsg) {
      return;
    }
    // let msgIds: string[] = chatDeleteMsg.msg_ids.split(",");
    if (chatDeleteMsg.msg_ids.length > 0) {
      this.historyData = this.historyData.filter(item => !chatDeleteMsg.msg_ids.includes(item.msg_id));
    }
  }

  handleGiftMessage(giftInfo: VHGiftMessageInfo) {
    if (!giftInfo) {
      return;
    }
    // 将消息添加到列表（更新UI）
    let msgContent =
      ChatTools.getLimitString(giftInfo.gift_user_nickname, 8) + " " + "送出" + " " + giftInfo.gift_name;
    let image_urls: string[] = [];
    image_urls.push(giftInfo.gift_image_url);
    let msgData: VHMsgData = new VHMsgData(VHRoomEventType.GIFT_MSG, msgContent, msgContent, '', '', image_urls);
    let imMsg: VHContent = new VHContent("", "", msgData, '', undefined);
    this.historyData.push(imMsg);
  }

  handleQuestionAnswerMessage(questionAnswerInfo: VHQuestionAnswerSwitchMsg) {
    if (!questionAnswerInfo) {
      return;
    }
    // 将消息添加到列表（更新UI）role_name: 1 主持人，2 观众，3 助理，4 嘉宾
    let roleName = questionAnswerInfo.role_name === '1' ? '主持人' : '';
    let eventType = questionAnswerInfo.event_type === VHRoomEventType.QUESTION_ANSWER_OPEN ? '开启' : '关闭';
    let msgContent = roleName + " " +
    ChatTools.getLimitString(questionAnswerInfo.nick_name, 8) + " " + eventType + "了问答 ";
    let msgData: VHMsgData = new VHMsgData(VHRoomEventType.GIFT_MSG, msgContent, msgContent, '', '', []);
    let imMsg: VHContent = new VHContent("", "", msgData, '', undefined);
    this.historyData.push(imMsg);
  }

  //初始化
  initChatMessage(pageNo: number) {
    try {
      VHSaaSDK.getInstance()
        .chatGetList(this.webinars?.interact?.room_id!, pageNo, this.pageSize, '', '', '', 0, 0, '', {
          onSucceed: (data: VHChatMessageList) => {
            this.total = data.total;
            this.pageNo = pageNo;
            this.hasMoreData = this.pageNo * this.pageSize < this.total;
            if (pageNo === 1) {
              this.historyData = [];
            }
            if (this.hasMoreData) {
              //设置组件为初始状态
              this.reachStatus = 0
            } else {
              //到底了
              this.reachStatus = 2
            }
            this.changeChatMessage(data);
            setTimeout(() => {
              this.scrollToBottom();
            }, 100);
          },
          onFailure: (errorCode, errorMsg) => {
            console.log("聊天获得历史记录失败：", errorMsg)
            ToastUtil.showToast(errorMsg);
          }
        });
    } catch (e) {
      console.log("聊天获得历史记录失败：", e)
    } finally {
      this.isRefreshing = false
      this.isLoadingMore = false
      this.initCompleted = true
    }
  }

  // 刷新处理
  private handleRefresh() {
    if (!this.isRefreshing) {
      this.isRefreshing = true
      this.reachStatus = 0
      this.initChatMessage(1);
    }
  }

  //触底加载更多数据
  handleLoadingMore() {
    //防止多次请求，触底请求完才能进行下一次，节流
    if (this.isLoadingMore) {
      return
    }
    this.isLoadingMore = true
    //设置组件处于加载状态
    this.reachStatus = 1
    let pageNo = this.pageNo + 1
    this.initChatMessage(pageNo)

    // 更新最后滚动位置
    setTimeout(() => {
      const currentOffset = this.scroller.currentOffset()
      this.lastScrollOffset = currentOffset.yOffset
    }, 100)
  }

  getLikeCount() {
    VHSaaSDK.getInstance().getRoomLike(this.webinars?.interact?.room_id!, {
      onSucceed: (data: VHRoomLikeInfo) => {
        this.likeCount = Number(data.total) + Number(data.virtual_count) ;
      },
      onFailure: (errorCode, errorMsg) => {
        console.log("聊天获得历史记录失败：", errorMsg)
      }
    });
  }

  userLike() {
    VHSaaSDK.getInstance().userLike(this.webinars?.interact?.room_id!, this.clickLikeNumber.toString(), {
      onSuccess: (data: string | object) => {
        console.log("增加点赞数：", this.clickLikeNumber);
      },
      onFailure: (errorCode, errorMsg) => {
        console.log("增加点赞数失败：", errorMsg)
      }
    });
  }

  changeChatMessage(data: VHChatMessageList) {
    // 转换模型
    let newData: VHContent[] = [];
    let array = data?.list;
    if (Array.isArray(array) && array.length > 0) {
      array.reverse();
      array.forEach((obj: object) => {
        let contact = obj as VHContent;
        contact.msg_id = obj['msg_id'];
        contact.date_time = this.formatTime(obj['date_time']);
        contact.role_name = obj['context']?.role_name === 1 ? '主持人' : '';
        if (obj['data']?.text_content.indexOf(VHRoomEventType.GIFT_MSG) > 0) {
          // 处理礼物数据
          if (obj['data']?.text_content.length > 0) {
            let giftMsg = JSON.parse(obj['data']?.text_content as string) as VHGiftMessageInfo;
            let msgContent =
              ChatTools.getLimitString(giftMsg.gift_user_nickname, 8) + " " + "送出" + " " + giftMsg.gift_name;
            let image_urls: string[] = [];
            image_urls.push(giftMsg.gift_image_url);
            let msgData: VHMsgData =
              new VHMsgData(VHRoomEventType.GIFT_MSG, msgContent, msgContent, '', '', image_urls);
            contact.data = msgData;
            contact.date_time = '';
          }
        }
        if (obj['context']?.reply_msg !== undefined) {
          let replyMessage = obj['context']?.reply_msg as VHReplyMessage;
          if (replyMessage != null && replyMessage.content !== undefined) {
            let replyContent = replyMessage.content as VHReplyMessageContent;
            if (replyContent !== null && replyContent.type === VHRoomEventType.IM_TYPE_TEXT) {
              let msgData = contact.data as VHMsgData;
              let replyContentStr =
                replyMessage.nick_name + "： " + replyContent.text_content + "\n \n" + "回复： " + contact.data?.text_content;
              contact.data =
                new VHMsgData(msgData.type, replyContentStr, replyContentStr, msgData.nickname, msgData.avatar, []);
            }
          }
        }
        if (contact.data!.type === VHRoomEventType.IM_TYPE_TEXT && contact.data!.text_content.length === 0) {
          return;
        }
        newData.push(contact);
      });
      if (newData.length > 0) {
        // 批量更新数据
        if (this.pageNo === 1) {
          this.historyData = newData;
        } else {
          this.historyData = [...newData, ...this.historyData];
        }
      }
    }
  }


  formatTime(dateTime: string): string {
    return dateTime.substring(dateTime.lastIndexOf(" "));
  }

  /**
   * 滚动消息列表到最底部，以备显示最新消息。
   */
  scrollToBottom() {
    this.scroller.scrollEdge(Edge.Bottom);
  }

  setKeyboardAvoidModeToRESIZE(context: UIContext, toRESIZE: boolean) {
    context.setKeyboardAvoidMode(toRESIZE ? KeyboardAvoidMode.RESIZE : KeyboardAvoidMode.OFFSET);
  }

  /**
   * 收到键盘
   * @param context
   */
  hideSoftInputMethod(context: UIContext) {
    context.getFocusController().clearFocus();
  }

  // 初始化倒计时器（总时间2秒，间隔1秒）
  initTimer() {
    this.timer = new CountDownTimer(2000, 1000)
    // 倒计时中回调：更新UI展示剩余时间
      .onTick((remainingTime) => {
        const seconds = Math.ceil(remainingTime / 1000);
      })
      // 倒计时结束回调：更新结束状态
      .onFinish(() => {
        this.userLike();
        this.clickLikeNumber = 0;
      });
  }

  // 创建一个图标对象
  createIcon(x: number, y: number, radius: number, emoji: string): VHLikeIcon {
    // 为图标生成随机属性
    const initialScale = 0.4 + Math.random() * 0.2 // 初始缩放比例0.4-0.6
    const maxScale = 1.0 + Math.random() * 0.3 // 最大缩放比例1.0-1.3
    // 减小摆动幅度，改为最大8-15像素
    const maxOffset = 8 + Math.random() * 7 // 最大摆动幅度8-15像素
    // 随机决定初始摆动方向
    const direction = Math.random() > 0.5 ? 1 : -1

    return {
      x: x,
      y: y,
      initialX: x, // 记录初始X坐标
      initialY: y, // 记录初始Y坐标
      radius: radius,
      emoji: emoji,
      fontSize: Math.floor(radius * 1.2),
      opacity: 1.0,
      createTime: Date.now(),
      lifespan: 1500, // 延长生命周期至1.5秒
      scale: initialScale, // 当前缩放比例
      initialScale: initialScale, // 初始缩放比例
      maxScale: maxScale, // 最大缩放比例
      maxOffset: maxOffset, // 最大摆动幅度
      direction: direction // 初始摆动方向
    }
  }

  // 获取随机emoji
  getRandomEmoji(): string {
    return this.emojis[Math.floor(Math.random() * this.emojis.length)]
  }

  // 添加新的点赞图标
  addLikeIcon(baseX: number, baseY: number) {
    const radius = 80 + Math.random() * 20
    const emoji = this.getRandomEmoji()
    // 添加随机位置偏移（±15px范围内）
    const offsetX = Math.random() * 30 - 15
    const offsetY = Math.random() * 30 - 15
    this.likeIcons.push(this.createIcon(baseX + offsetX, baseY + offsetY, radius, emoji))
  }

  // 开始动画循环
  startAnimation() {
    this.animationId = setInterval(() => {
      this.updateIcons()
      this.drawAllIcons()
    }, 16) // 约60fps的刷新率
  }

  // 更新所有图标状态
  updateIcons() {
    const currentTime = Date.now()
    const newIcons: VHLikeIcon[] = []

    for (let icon of this.likeIcons) {
      // 计算图标已存在的时间
      const existTime = currentTime - icon.createTime

      if (existTime < icon.lifespan) {
        // 计算存在时间比例
        const progress = existTime / icon.lifespan

        // 1. 更新Y坐标 - 向上移动，速度变化更明显
        const verticalDistance = 200 * Math.pow(progress, 0.5) // 减缓上升速度 // 使用幂函数让上升更快
        icon.y = icon.initialY - verticalDistance

        // 2. 更新X坐标 - 快速的左右摆动
        // 每0.25秒一个阶段，总共1秒4个阶段
        let horizontalOffset = 0;

        if (progress < 0.25) {
          // 0-0.25s: 无偏移，专注于放大
          horizontalOffset = 0;
        } else if (progress < 0.5) {
          // 0.25-0.5s: 向左偏移
          const phaseProgress = (progress - 0.25) / 0.25;
          horizontalOffset = -icon.maxOffset * phaseProgress * icon.direction;
        } else if (progress < 0.75) {
          // 0.5-0.75s: 从向左偏移变为向右偏移
          const phaseProgress = (progress - 0.5) / 0.25;
          horizontalOffset = icon.maxOffset * (2 * phaseProgress - 1) * icon.direction;
        } else {
          // 0.75-1s: 从向右偏移回到向左偏移
          const phaseProgress = (progress - 0.75) / 0.25;
          horizontalOffset = icon.maxOffset * (1 - 2 * phaseProgress) * icon.direction;
        }

        icon.x = icon.initialX + horizontalOffset;

        // 3. 更新缩放比例 - 快速放大
        // 在生命周期的前20%阶段(0.2s)，缩放从initialScale增大到maxScale
        if (progress < 0.2) {
          // 平滑插值从initialScale到maxScale
          icon.scale = icon.initialScale + (icon.maxScale - icon.initialScale) * (progress / 0.2)
        } else {
          // 保持maxScale
          icon.scale = icon.maxScale
        }

        // 4. 更新透明度 - 前60%保持不变，后40%逐渐消失
        if (progress > 0.6) {
          // 在最后40%的生命周期内改变透明度，使消失更快
          icon.opacity = 1.0 - ((progress - 0.6) / 0.4)
        } else {
          icon.opacity = 1.0
        }

        // 保留未完成生命周期的图标
        newIcons.push(icon)
      }
    }

    // 更新图标数组
    this.likeIcons = newIcons
  }

  // 绘制所有图标
  drawAllIcons() {
    // 清除画布
    this.context.clearRect(0, 0, this.context.width, this.context.height)

    // 绘制所有图标
    for (let icon of this.likeIcons) {
      this.context.save()

      // 设置透明度
      this.context.globalAlpha = icon.opacity

      // 设置缩放（从中心点缩放）
      this.context.translate(icon.x, icon.y)
      this.context.scale(icon.scale, icon.scale)
      this.context.translate(-icon.x, -icon.y)

      // 绘制emoji
      this.context.font = `${icon.fontSize}px`
      this.context.textAlign = 'center'
      this.context.textBaseline = 'middle'
      this.context.fillText(icon.emoji, icon.x, icon.y)

      this.context.restore()
    }
  }

  // 点击列表图片：打开预览
  openImagePreview(url: string) {
    this.currentPreviewUrl = url;
    this.isPreviewShow = true;
  }

  // 点击聊天列表：关闭预览
  closeImagePreview() {
    this.isPreviewShow = false;
  }

  private async selectImage() {
    // 1. 打开相册选择图片
    try {
      // 1. 打开相册选择图片（异步）
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      const photoPicker = new picker.PhotoViewPicker();
      const res: picker.PhotoSelectResult = await photoPicker.select(photoSelectOptions); // 使用 await 等待结果
      let bufferStr: string = '';
      if (res && res.photoUris && res.photoUris.length > 0) {
        // 读取图片
        const uri = res.photoUris[0];
        const file = fs.openSync(uri)
        const stat = fs.statSync(file.fd)
        const buffer = new ArrayBuffer(stat.size)
        fs.readSync(file.fd, buffer)
        fs.closeSync(file)
        // 3. 转成base64编码的字符串
        const helper = new util.Base64Helper()
        bufferStr = helper.encodeToStringSync(new Uint8Array(buffer));
        bufferStr = "data:image/png;base64," + bufferStr;
        if (bufferStr.length > 0) {
          this.uploadToServer(bufferStr);
        }
      }
    } catch (error) {
      console.error("图片选择失败:", error);
      ToastUtil.showToast("图片选择失败!");
    }
  }

  // 上传二进制流
  uploadToServer(bufferStr: string) {
    VHSaaSDK.getInstance().uploadImage(bufferStr, {
      onSucceed: (data: VHUploadFileInfo) => {
        let domain_url: string = data.domain_url
        if (domain_url.length > 0) {
          let image_urls: string[] = [];
          image_urls.push(domain_url);
          let imageInfoStr = JSON.stringify(image_urls);
          // 发送图片消息
          this.imBase.sendTypeMessage(imageInfoStr,'', 1, {
            onSuccess: () => {
              console.log("图片消息发送成功!");
              setTimeout(() => {
                this.scrollToBottom();
              }, 100);
            },
            onFailure(errorCode: number, errorMsg: string) {
              console.error("图片消息发送失败：", errorMsg);
              ToastUtil.showToast("图片发送失败!");
            }
          });
        }
      },
      onFailure: (errorCode, errorMsg) => {
        console.log("上传图片二进制流失败：", errorMsg);
        ToastUtil.showToast("图片发送失败:" + errorMsg);
      }
    });
  }

  /**
   * 高亮显示文本中的关键字。
   *
   * @param fullText 完整文本
   * @param keyword 要高亮的关键字
   * @param keywordColor 关键字颜色，默认红色
   * @param normalColor 普通文本颜色，默认黑色
   */
  // @Builder
  // getHighlightedText(
  //   segments: Array<{ text: string; isKeyword: boolean }>,
  //   keywordColor: ResourceColor = Color.Red,
  //   normalColor: ResourceColor = Color.Black
  // ) {
  //   Text() {
  //     ForEach(segments, (segment) => {
  //       Span(segment.text)
  //         .fontColor(segment.isKeyword ? keywordColor : normalColor);
  //     });
  //   }
  // }

  build() {
    // Navigation(this.pageInfos) {
    Column() {
      Stack() {
        // 聊天界面内容区
        Column() {
          List({ space: 4, scroller: this.scroller }) {
            ForEach(this.historyData, (item: VHContent, index) => {
              ListItem() {
                Row({ space: 8 }) {
                  Image((item.avatar === '' && item.data!.type !== VHRoomEventType.GIFT_MSG) ?
                  $r("app.media.icon_visitorvatar") : item.avatar)
                    .width(30)
                    .height(30)
                    .borderRadius(20)
                  Column() {
                    Row() {
                      Text(this.chatNickNameEnc == 0 ? ChatTools.getLimitString(item.nickname!, 8) : ChatTools.getLimitString(item.nickname!, 2) )
                        .fontColor(Color.Gray).fontSize(12).padding({ right: 10 })
                      Text(item.role_name!)
                        .fontColor(Color.Red)
                        .fontSize(12)
                        .borderRadius(8)
                        .backgroundColor(item.role_name.length > 0 ? '#FFE6F2' : "#FAFAFA")
                        .padding({
                          top: 2,
                          left: 4,
                          right: 4,
                          bottom: 2
                        })
                      if (item.date_time!.length > 0) {
                        Text(item.date_time)
                          .fontColor(Color.Gray)
                          .fontSize(12)
                          .layoutWeight(1)
                          .padding({ right: 10 })
                          .textAlign(TextAlign.End)
                      }
                    }
                    if (item.data!.type !== VHRoomEventType.IM_IMAGE)
                    Column() {
                      Row(){
                        Text(EmojiTool.convertEmojiTags(item.data?.text_content!))
                          .fontSize(12)
                          .padding({
                            top: 6,
                            bottom: 6,
                            left: 10,
                            right: 10
                          })
                          .borderRadius(8)
                          .backgroundColor(item.data?.type === VHRoomEventType.GIFT_MSG ? '#fffff0f2' : Color.White)
                        if (item.data?.type === VHRoomEventType.GIFT_MSG)
                        Column() {
                          ForEach(item.data!.image_urls, (url: string) => {
                            Image(url)
                              .width(30)
                              .height(26)
                              .margin({ left: -5 })
                              .borderRadius(8)
                              .interpolation(ImageInterpolation.High)
                              .syncLoad(true)
                              .backgroundColor('#fffff0f2')
                          })
                        }
                      }
                      .width('100%')
                      .justifyContent(item.data?.type === VHRoomEventType.GIFT_MSG ? FlexAlign.Center : FlexAlign.Start)
                    }
                    .width('98%')

                    if (item.data!.type === VHRoomEventType.IM_IMAGE && item.data!.image_urls != null)
                    Row() {
                      ForEach(item.data!.image_urls, (url: string) => {
                        Image(url)
                          .width(40)
                          .height(40)
                          .margin(2)
                          .borderRadius(8)
                          .interpolation(ImageInterpolation.High)
                          .syncLoad(true)
                          .onClick(() => {
                            // 图片预览
                            this.openImagePreview(url!);
                          })
                      })
                    }

                    if (this.isPreviewShow) {
                      Stack() {
                        Column() {
                          // 预览图片（居中显示，限制最大宽高）
                          Image(this.currentPreviewUrl)
                            .width(300)
                            .height(300)
                            .objectFit(ImageFit.Fill)
                        }
                        .zIndex(105)
                        .width('100%')
                        .height('100%')
                        .padding({ left: -20 })
                        .position({ x: 0, y: 0 }) // 全屏覆盖在列表上方
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.Center)
                      }
                    }

                  }
                  .width('98%')
                  .padding({right:12})
                  .borderRadius(8)
                  .alignItems(item.data?.type === VHRoomEventType.GIFT_MSG ? HorizontalAlign.Center : HorizontalAlign.Start)
                }
                .width('98%')
                .padding(8)
                .borderRadius(8)
                .justifyContent(FlexAlign.Start)
                .alignItems(VerticalAlign.Top)
              }
            })

            ForEach(this.examRankMsg,(item:VHExamRank,index)=>{
              ListItem() {
                Column() {
                  Blank()
                    .layoutWeight(1)
                  Row() {
                    Text(item.role_name == "1" ? '主持人' : '')
                      .fontSize(12)
                      .fontColor('#f40')
                      .backgroundColor('#ffffcaca')
                      .borderRadius('50%')
                      .padding({ left: 6, right: 6 })
                      .margin({ right: 4 })
                    Text('公布了')
                      .fontSize(12)
                      .fontColor('#666')
                    Text(' 成绩排行榜 ')
                      .fontSize(12)
                      .fontColor('#ff503ea0')
                      .onClick(() => {
                        PromptActionClass.closeDialog()
                        // 创建参数对象
                        const params = new reportParams(item, this.webinars!);
                        this.examReportContentNode = new ComponentContent(this.getUIContext(), wrapBuilder(createExamReportView), params);
                        PromptActionClass.setContext(this.getUIContext());
                        PromptActionClass.setContentNode(this.examReportContentNode);
                        PromptActionClass.openDialog();

                      })
                    Text("《" + item.paper_title + "》")
                      .fontSize(12)
                      .fontColor('#666')
                  }
                  .height(20)
                  .padding({
                    left: 12,
                    right: 12
                  })
                  .backgroundColor('#e8ffe7e7')
                  .borderRadius('50%')
                  .justifyContent(FlexAlign.Center)

                  Blank()
                    .layoutWeight(1)
                }
                .width('100%')
                .height(20)
              }
            })



            LoadingMoreView({ visible: this.loadingMoreVisible, status: this.reachStatus, isShowTip: false })
            if (this.questionnairePush != null) {
              ListItem() {
                Column() {
                  Blank()
                    .layoutWeight(1)
                  Row() {
                    Text('主持人')
                      .fontSize(12)
                      .fontColor('#f40')
                      .backgroundColor('#ffffcaca')
                      .borderRadius('50%')
                      .padding({ left: 6, right: 6 })
                      .margin({ right: 4 })
                    Text('推送了问卷  ')
                      .fontSize(12)
                      .fontColor('#666')
                    Text('点击查看')
                      .fontSize(12)
                      .fontColor('#ff503ea0')
                      .onClick(() => {
                        // this.pageInfos.pushPath({ name: 'QuestionnairePage' }, true);
                        this.VHQuestionnaireDialog.open()
                      })
                  }
                  .height(20)
                  .padding({
                    left: 12,
                    right: 12
                  })
                  .backgroundColor('#e8ffe7e7')
                  .borderRadius('50%')
                  .justifyContent(FlexAlign.Center)

                  Blank()
                    .layoutWeight(1)
                }
                .width('100%')
                .height(20)
              }
            }
            if (this.examData != null) {
              ListItem() {
                Column() {
                  Blank()
                    .layoutWeight(1)
                  Row() {
                    Text('主持人')
                      .fontSize(12)
                      .fontColor('#f40')
                      .backgroundColor('#ffffcaca')
                      .borderRadius('50%')
                      .padding({ left: 6, right: 6 })
                      .margin({ right: 4 })
                    Text('推送了快问快答  ')
                      .fontSize(12)
                      .fontColor('#666')
                    Text('点击查看')
                      .fontSize(12)
                      .fontColor('#ff503ea0')
                      .onClick(() => {
                        // this.pageInfos.pushPath({ name: 'ExamPage' }, true);
                        VHSaaSDK.getInstance()
                          .performExamIn(this.webinars?.webinar?.id!, 1,
                            this.webinars?.switch_info?.switch_id!, 0, {
                              onSucceed: (data) => {
                                this.ExamList = data
                                this.VHExamDialog.open()
                                console.log(`获取快问快答列表成功： ${JSON.stringify(data)}`);
                              },
                              onFailure: (errorCode, errorMsg) => {
                                console.log(`获取快问快答列表失败： ${errorMsg}`);
                              }
                            })
                        // ToastUtil.showToast('快问快答已打开');
                      })
                  }
                  .height(20)
                  .padding({
                    left: 12,
                    right: 12
                  })
                  .backgroundColor('#e8ffe7e7')
                  .borderRadius('50%')
                  .justifyContent(FlexAlign.Center)

                  Blank()
                    .layoutWeight(1)
                }
                .width('100%')
                .height(20)
              }
            }
          }
          .width('100%')
          .height('80%')
          .cachedCount(3)
          // 监听组件触屏事件，确保触碰聊天列表时，能自动收起输入法软键盘，提升用户体验
          .onTouch((event: TouchEvent) => {
            // 收起软键盘
            this.hideSoftInputMethod(this.getUIContext());
            // 点击列表关闭预览
            this.closeImagePreview();
          })
          // 监听组件大小变化事件（用于实现当软键盘显示时，列表高度被压缩后，消息不能自动显示最后一条的问题）
          .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
            let oldHeight = oldValue.height, newHeight = newValue.height;
            oldHeight = (oldHeight === undefined ? 0 : oldHeight);
            newHeight = (newHeight === undefined ? 0 : newHeight);
            // 列表高度变小，可以认为是软键盘显示了
            let toBeSmall = (newHeight > 0 && newHeight < oldHeight);
            if (toBeSmall) {
              // 消息列表滚动到底部，确保最新一条消息被显示
              this.scrollToBottom();
            }
          })
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .width("100%")
          .height('100%')
          .layoutWeight(1)
          .listDirection(Axis.Vertical)
          .zIndex(100) // 保持最高层级
          .onReachEnd(() => {
            // 防止重复调用
            if (this.isHandlingReachEnd) {
              return
            }
            // 只有在用户主动滚动且满足条件时才触发加载更多
            if (this.initCompleted && this.reachStatus !== 2) {
              // 获取当前滚动位置判断是否为真实触底
              const currentOffset = this.scroller.currentOffset()
              const isRealScroll = currentOffset.yOffset > this.lastScrollOffset && this.lastScrollOffset > 0

              if (isRealScroll || currentOffset.yOffset > this.lastScrollOffset) {
                this.isHandlingReachEnd = true
                this.loadingMoreVisible = true
                this.handleLoadingMore()

                // 在加载完成后重置标志
                setTimeout(() => {
                  this.isHandlingReachEnd = false
                }, 300)
              }
              this.lastScrollOffset = currentOffset.yOffset
            }
          })

          Canvas(this.context)
            .width('100%')
            .height('80%')  // 进一步减少高度
            .position({ x: 0, y: 0 })
            // .position({ type: 'absolute' })
            .zIndex(0)
            .backgroundColor(Color.Transparent)
            .onReady(() => {
              console.info(`Canvas size: ${this.context.width} x ${this.context.height}`)
            })

          // 底部消息输入区
          Row() {
            Image(this.avatar)
              .width(30)
              .height(30)
              .borderRadius(20)

            TextInput({
              placeholder: this.chatDisable ? "您已被禁言" : "参与聊天", text: $$this.messageInput
            })
              .width('75%')
              .height(34)
              .backgroundColor('#EEEEEE')
              .fontSize(15)
              .layoutWeight(1)
              .borderRadius(8)
              .margin({ left: 5, right: 5 })
              .placeholderFont({ size: 14 })
              .placeholderColor('#a1a7af')
              .enabled(!this.chatDisable)
              .onChange((msg: string) => {
                this.messageInput = msg
              })

            Button("提交", { type: ButtonType.Normal, stateEffect: true })
              .width(44)
              .height(34)
              .borderRadius(8)
              .padding(0)
              .fontSize(14)
              .backgroundColor('#00de7a')
              .fontWeight(500)
              .enabled(!this.chatDisable)
              .onClick(() => {
                if (this.chatDisable) {
                  ToastUtil.showToast("您已被禁言");
                  return
                }

                if (this.messageInput === '') {
                  ToastUtil.showToast("请输入消息内容");
                  return
                }

                // 发送消息
                this.imBase.sendMessage(this.messageInput, {
                  onSuccess: () => {
                    console.log("消息发送成功");
                    this.messageInput = '';
                    // 收起软键盘
                    this.hideSoftInputMethod(this.getUIContext());
                    // 5. 延迟滚动到最新消息（确保UI已更新）
                    setTimeout(() => {
                      this.scrollToBottom();
                    }, 100);
                  },
                  onFailure(errorCode: number, errorMsg: string) {
                    // 弹出消息信息
                    ToastUtil.showToast("发送消息失败");
                  }
                });
              });
            // 上传图片
            Image($r('app.media.upload'))
              .width(35)
              .height(35)
              .margin({ left: 5, right: 5 })
              .onClick(() => {
                this.selectImage()
              })
            if (this.functionConfig?.hide_gifts == 0) {
              Image($r('app.media.icon_gift'))
                .width(30)
                .height(30)
                .margin({ left: 5, right: 5 })
                .onClick(() => {
                  PromptActionClass.setContext(this.getUIContext());
                  PromptActionClass.setContentNode(this.giftNode!);
                  PromptActionClass.setOptions({ alignment: DialogAlignment.BottomEnd, offset: { dx: 0, dy: 0 } });
                  PromptActionClass.openDialog();
                })
            }

            Stack() {
              if (this.functionConfig?.watch_hide_like == 0) {
                Image($r('app.media.icon_like'))
                  .width(30)
                  .height(30)
                  .margin({ right: 5 })
                  .onClick(() => {
                    this.likeCount++;
                    this.clickLikeNumber++;
                    this.timer?.cancel();
                    this.timer?.start();
                    // 在按钮中心上方50px位置生成气泡
                    // 获取按钮实际位置
                    const buttonWidth = 10
                    const buttonHeight = 10
                    const btnCenterX = (this.context.width * 0.9) + buttonWidth / 2
                    const btnCenterY = (this.context.height * 0.9) + buttonHeight / 2
                    // 在按钮中心生成气泡，并限制随机偏移范围
                    const maxOffset = 20
                    this.addLikeIcon(
                      btnCenterX + Math.random() * maxOffset - maxOffset / 2,
                      btnCenterY - 10 + Math.random() * maxOffset - maxOffset / 2
                    )
                  })
              }
              if (this.functionConfig?.hidden_watch_like_data == 0) {
                Text(this.likeCount > 999 ? '999+' : this.likeCount.toString())
                  .fontSize(8)
                  .fontColor(Color.White)
                  .backgroundColor(Color.Red)
                  .width(Math.max(10, 6 * this.likeCount.toString().length))
                  .height(Math.max(10, 6 * this.likeCount.toString().length))
                  .borderRadius('100%')
                  .textAlign(TextAlign.Center)
                  .position({ x: 22, y: -4 })
              }

            }

          }
          .height(54)
          .width('100%')
          .backgroundColor("#ffffff")
          .padding({ left: 10, right: 10 })
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)


          // if (this.agreement.is_open == 1 && this.agreement.is_agree == 0) {
          //   Blank()
          //     .height(68)
          // }
        }
        .backgroundColor("#FAFAFA")
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    // 适配流海屏（顶部状态栏透明并穿过，并透过底部上划操作区）
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  // }
}