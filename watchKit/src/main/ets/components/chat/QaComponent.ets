import { ComponentContent, KeyboardAvoidMode } from '@kit.ArkUI';
import {
  VHLikeIcon,
  VHQuestionAnswerDeleteMsg,
  VHQuestionAnswerMsg,
  VHQuestionHistoryInfo,
  VHRoomLikeInfo,
  VHChatDisableAllMsg,
  VHContent,
  VHIMMessageModel,
  VHIMServer,
  VHMsgData,
  VHQuestionHistoryList,
  VHRoomEventType,
  VHSaaSDK,
  VHWebinarData,
  VHQuestionAnswerSetMsg,
  VHRoomToolsStatusData,
  VHConfigList
} from '@vhall/vhall_live';

import { EmitterMsgData, EmitterUtil } from '../../util/EmitterUtil';
import { ToastUtil } from "../../action/ToastUtil";
import { createGiftView } from './GiftComponent';
import { PromptActionClass } from '../../util/PromptActionClass';
import { CountDownTimer } from '../../util//CountDownTimer.ets';
import { EmojiTool } from './EmojiTool';
import ChatTools from '../../util/ChatTools';
import { QaRecommendDialog } from './QaRecommendDialog';

/**
 * 问答界面
 *
 */
@Component
export struct QaComponent {
  @Prop functionConfig: VHConfigList | null = null; //功能配置
  @Prop webinars: VHWebinarData | null = null;
  @State chatMessages: VHQuestionHistoryList | null = null;
  @Prop room_tool: VHRoomToolsStatusData | null = null;
  @Prop imBase: VHIMServer;
  @Prop isLive: boolean; //是否直播
  @State avatar: string | undefined = "";
  @State inputText: string = "快来提问吧";
  @State messageInput: string = '';
  @LocalStorageLink('likeCount') likeCount: number = 0;
  @State clickLikeNumber: number = 0;
  @State chatDisable: boolean = false;
  /** 聊天列表的滚动条组件 */
  private scroller: Scroller = new Scroller();
  private msgSubId: number = -1; // 订阅ID（用于取消订阅）
  private giftNode: ComponentContent<Object> | null = null;
  private timer: CountDownTimer | null = null;
  /** 聊天消息列表对应的数据源对象（本对象与MessageProvider配合，用于实现UI界面与数据组的解偶）*/
  @State historyData: VHQuestionHistoryInfo[] = [];
  // 用来配置CanvasRenderingContext2D对象的参数，开启抗锯齿
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  // 正确创建CanvasRenderingContext2D对象
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  @State likeIcons: VHLikeIcon[] = [] // 存储所有点赞图标
  private animationId: number = 0 // 动画ID
  // 问答历史记录 type为：question
  private qaQuestion: string = "question";
  // 问答历史记录 type为：answer
  private qaAnswer: string = "answer";

  // emoji表情数组
  private readonly emojis: string[] = [
    '❤️', '🧡', '💛', '💚', '💙', '💜',
    '🐼', '🦁', '🐯', '🦊',
    '🎁', '🎀', '🎉', '🎊', '✨', '⭐'
  ]
  // 状态管理：控制预览显示/隐藏 + 当前预览的图片URL
  @State isPreviewShow: boolean = false;
  @State currentPreviewUrl: string = '';
  @State isRecommendShow: boolean = false;
  // 问答区的问题所有观众可见 1可见 0不可见
  @State questionPublicStatus: string = '';

  aboutToAppear() {
    this.avatar = this.webinars?.join_info?.avatar;
    this.questionPublicStatus = this.room_tool!.question_public_status!.toString();
    this.getQuestionHistory();
    this.getLikeCount();
    // 启动动画循环
    this.startAnimation()
    this.initTimer();
    this.giftNode = new ComponentContent(this.getUIContext(), wrapBuilder(createGiftView), this.webinars!);
    PromptActionClass.setContext(this.getUIContext());
    PromptActionClass.setContentNode(this.giftNode);
    PromptActionClass.setOptions({ alignment: DialogAlignment.BottomEnd, offset: { dx: 0, dy: 0 } });
    // 订阅消息
    this.subscribeCommitMessage();
    this.subscribeCreateMessage();
    this.subscribeDeleteMessage();
    this.subscribeBackOutMessage();
    this.subscribeChatDisable();
    this.subscribeLikeCount();
    this.subscribeSetMessage();
    this.subscribeLikeMessage();
    this.subscribeRecommendMessage();

    if (this.webinars?.join_info?.is_gag == 1 || this.room_tool?.all_banned == 1 || this.room_tool?.is_board == 1 ||
      this.room_tool?.is_kicked == 1) {
      this.chatDisable = true;
    }

    if(this.functionConfig?.watch_record_no_chatting == 1 && this.webinars?.webinar?.type == 5){
      this.chatDisable = true;
    }
  }

  QaRecommendDialog = new CustomDialogController({
    builder: QaRecommendDialog({ webinars: this.webinars ? this.webinars : undefined }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })

  /**
   * 界面被销毁时被调用。
   */
  aboutToDisappear() {
    // this.setKeyboardAvoidModeToRESIZE(this.getUIContext(), false);
    this.timer?.cancel();
    // 清除动画循环
    clearInterval(this.animationId);
    EmitterUtil.unsubscribe(VHRoomEventType.QUESTION_ANSWER_COMMIT);
    EmitterUtil.unsubscribe(VHRoomEventType.QUESTION_ANSWER_CREATE);
    EmitterUtil.unsubscribe(VHRoomEventType.QUESTION_ANSWER_DELETE);
    EmitterUtil.unsubscribe(VHRoomEventType.QUESTION_ANSWER_BACKOUT);
    EmitterUtil.unsubscribe(VHRoomEventType.CUSTOM_PRAISE);
    EmitterUtil.unsubscribe(VHRoomEventType.QUESTION_ANSWER_SET);
    EmitterUtil.unsubscribe(VHRoomEventType.QUESTION_ANSWER_LIKE);
    EmitterUtil.unsubscribe(VHRoomEventType.QUESTION_ANSWER_RECOMMEND);
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

  subscribeSetMessage() {
    EmitterUtil.subscribe(VHRoomEventType.QUESTION_ANSWER_SET, (msgData: EmitterMsgData) => {
      console.log(`收到是否开启所有观众可见消息，类型：${VHRoomEventType.QUESTION_ANSWER_SET}`);
      let messageModel: VHIMMessageModel = msgData as VHIMMessageModel;
      if (messageModel.data!) {
        let message: VHQuestionAnswerSetMsg = messageModel.data as VHQuestionAnswerSetMsg;
        this.questionPublicStatus = message.question_public_status;
        this.getQuestionHistory();
      }
    });
  }

  subscribeLikeMessage() {
    EmitterUtil.subscribe(VHRoomEventType.QUESTION_ANSWER_LIKE, (msgData: EmitterMsgData) => {
      console.log(`收到点击消息，类型：${VHRoomEventType.QUESTION_ANSWER_LIKE}`);
      let messageModel: VHIMMessageModel = msgData as VHIMMessageModel;
      if (messageModel.data!) {
        this.getQuestionHistory();
      }
    });
  }

  subscribeRecommendMessage() {
    EmitterUtil.subscribe(VHRoomEventType.QUESTION_ANSWER_RECOMMEND, (msgData: EmitterMsgData) => {
      console.log(`收到推荐消息，类型：${VHRoomEventType.QUESTION_ANSWER_RECOMMEND}`);
      let messageModel: VHIMMessageModel = msgData as VHIMMessageModel;
      if (messageModel.data!) {
        this.isRecommendShow = true;
        this.getQuestionHistory();
      }
    });
  }


  subscribeCreateMessage() {
    // 接收问答消息
    EmitterUtil.subscribe(VHRoomEventType.QUESTION_ANSWER_CREATE, (msgData: EmitterMsgData) => {
      console.log(`收到问答消息，类型：${VHRoomEventType.QUESTION_ANSWER_CREATE}`);
      let qaMsg: VHQuestionAnswerMsg = msgData.data as VHQuestionAnswerMsg;
      if (qaMsg!) {
        if (typeof qaMsg === 'string') {
          const parsedMessage: VHQuestionAnswerMsg = JSON.parse(qaMsg) as VHQuestionAnswerMsg;
          this.handleQAMessage(parsedMessage, VHRoomEventType.QUESTION_ANSWER_CREATE);
        } else {
          this.handleQAMessage(qaMsg, VHRoomEventType.QUESTION_ANSWER_CREATE);
        }
        // 延迟滚动到最新消息（确保UI已更新）
        setTimeout(() => {
          this.scrollToBottom();
        }, 100);
      }
    });
  }

  subscribeCommitMessage() {
    // 主持人：通过并回复消息,直播中回答
    EmitterUtil.subscribe(VHRoomEventType.QUESTION_ANSWER_COMMIT, (msgData: EmitterMsgData) => {
      console.log(`主持人：通过并回复消息,直播中回答：${VHRoomEventType.QUESTION_ANSWER_COMMIT}`);
      let qaMsg: VHQuestionAnswerMsg = msgData.data as VHQuestionAnswerMsg;
      if (qaMsg!) {
        if (typeof qaMsg === 'string') {
          const parsedMessage: VHQuestionAnswerMsg = JSON.parse(qaMsg) as VHQuestionAnswerMsg;
          this.handleQAMessage(parsedMessage, VHRoomEventType.QUESTION_ANSWER_COMMIT);
        } else {
          this.handleQAMessage(qaMsg, VHRoomEventType.QUESTION_ANSWER_COMMIT);
        }
        // 延迟滚动到最新消息（确保UI已更新）
        setTimeout(() => {
          this.scrollToBottom();
        }, 100);
      }
    });
  }

  subscribeDeleteMessage() {
    // 接收删除问答消息
    EmitterUtil.subscribe(VHRoomEventType.QUESTION_ANSWER_DELETE, (msgData: EmitterMsgData) => {
      console.log(`收到删除问答消息，类型：${VHRoomEventType.QUESTION_ANSWER_DELETE}`);
      let qaMsg: VHQuestionAnswerDeleteMsg = msgData.data as VHQuestionAnswerDeleteMsg;
      if (qaMsg!) {
        if (typeof qaMsg === 'string') {
          qaMsg = JSON.parse(qaMsg) as VHQuestionAnswerDeleteMsg;
        }
        let question_ids: string = qaMsg.question_ids;
        if (question_ids.length > 0) {
          this.historyData = this.historyData.filter(item => !question_ids.includes(item.id));
        }
      }
    });
  }

  subscribeBackOutMessage() {
    // 主持人：撤销回复
    EmitterUtil.subscribe(VHRoomEventType.QUESTION_ANSWER_BACKOUT, (msgData: EmitterMsgData) => {
      console.log(`主持人：撤销回复：${VHRoomEventType.QUESTION_ANSWER_BACKOUT}`);
      let qaMsg: VHQuestionAnswerMsg = msgData.data as VHQuestionAnswerMsg;
      if (qaMsg!) {
        if (typeof qaMsg === 'string') {
          qaMsg = JSON.parse(qaMsg) as VHQuestionAnswerMsg;
        }
        let question_answer_id = qaMsg.question_answer_id;
        const newData: VHQuestionHistoryInfo[] =
          this.historyData.filter(item => (item.answer === undefined || item.answer!.id !== question_answer_id));
        this.historyData = newData;
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
      if (chatDisableAllMsg != null && chatDisableAllMsg.qa_status === 1) {
        this.chatDisable = true;
      }
    });
    EmitterUtil.subscribe(VHRoomEventType.CHAT_PERMIT_ALL, (msgData: EmitterMsgData) => {
      let chatDisableAllMsg: VHChatDisableAllMsg = msgData.data as VHChatDisableAllMsg;
      if (chatDisableAllMsg != null && chatDisableAllMsg.qa_status === 1) {
        this.chatDisable = false;
      }
    });
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

  handleQAMessage(msg: VHQuestionAnswerMsg, type: string) {
    if (!msg) {
      return;
    }
    let answer: VHQuestionHistoryInfo = msg.answer as VHQuestionHistoryInfo;
    let qaInfo: VHQuestionHistoryInfo =
      new VHQuestionHistoryInfo(type, msg.nick_name, msg.content, msg.created_time,
        msg.avatar, answer, msg.id.toString());
    // 问答区的问题所有观众可见,且提问相同
    if (this.questionPublicStatus === '1') {
      this.historyData.push(qaInfo);
    } else if (msg.nick_name === this.webinars?.join_info?.nickname) {
      // 如问答区的问题所有观众不可见，只有自己可见
      this.historyData.push(qaInfo);
    }
  }

  getQuestionHistory() {
    VHSaaSDK.getInstance()
      .getQuestionHistory(this.webinars?.interact?.room_id!, {
        onSucceed: (data: VHQuestionHistoryList) => {
          this.chatMessages = data;
          this.historyData=[];
          this.changeChatMessage(data);
        },
        onFailure: (errorCode, errorMsg) => {
          console.log("聊天获得历史记录失败：", errorMsg)
          ToastUtil.showToast(errorMsg);
        }
      });
  }

  getLikeCount() {
    VHSaaSDK.getInstance().getRoomLike(this.webinars?.interact?.room_id!, {
      onSucceed: (data: VHRoomLikeInfo) => {
        this.likeCount = Number(data.total);
      },
      onFailure: (errorCode, errorMsg) => {
        console.log("聊天获得历史记录失败：", errorMsg)
        ToastUtil.showToast(errorMsg);
      }
    });
  }

  //设置问卷同问
  setQaLike(questionId: string, likeStatus: string) {
    VHSaaSDK.getInstance().setQaLike(this.webinars!.webinar!.id!.toString(), questionId, likeStatus, {
      onSuccess: (data: string | object) => {
        console.log("设置点赞数成功");
      },
      onFailure: (errorCode, errorMsg) => {
        console.log("设置点赞数失败：", errorMsg)
        ToastUtil.showToast(errorMsg);
      }
    });
  }

  userLike() {
    VHSaaSDK.getInstance().createUserLikeWithRoomId(this.webinars?.interact?.room_id!, this.clickLikeNumber.toString(), {
      onSuccess: (data: string | object) => {
        console.log("增加点赞数：", this.clickLikeNumber);
      },
      onFailure: (errorCode, errorMsg) => {
        console.log("增加点赞数失败：", errorMsg)
        ToastUtil.showToast(errorMsg);
      }
    });
  }

  sendQuestion() {
    VHSaaSDK.getInstance().sendQuestion(this.webinars?.interact?.room_id!, this.messageInput, {
      onSuccess: (data: string | object) => {
        console.log("消息发送成功");
        this.messageInput = '';
        // 收起软键盘
        this.hideSoftInputMethod(this.getUIContext());
        //延迟滚动到最新消息（确保UI已更新）
        setTimeout(() => {
          this.scrollToBottom();
        }, 200);
      },
      onFailure: (errorCode, errorMsg) => {
        ToastUtil.showToast("15秒内不可提问!");
      }
    });
  }

  changeChatMessage(data: VHQuestionHistoryList) {
    // 转换模型
    let array = data?.list;
    if (Array.isArray(array)) {
      array.forEach((obj: object) => {
        let qaInfo = obj as VHQuestionHistoryInfo;
        if (qaInfo != null) {
          this.historyData.push(qaInfo);
        }
      });
      if (this.isRecommendShow === false) {
        array.forEach((obj: object) => {
          let qaInfo = obj as VHQuestionHistoryInfo;
          if (qaInfo != null && qaInfo.recommend_status == 1) {
            this.isRecommendShow = true;
            return;
          }
        });
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

  build() {
    Column() {
      // Stack() {
      // 聊天界面内容区
      Column() {
        List({ space: 4, scroller: this.scroller }) {
          ForEach(this.historyData, (item: VHQuestionHistoryInfo, index) => {
            ListItem() {
              Column({ space: 8 }) {
                // 提问
                if (item.type === this.qaQuestion ||
                  item.type === VHRoomEventType.QUESTION_ANSWER_CREATE)
                Row() {
                  Image(item.avatar === '' ? $r("app.media.icon_visitorvatar") : item.avatar)
                    .width(30)
                    .height(30)
                    .borderRadius(20)
                  Column() {
                      Row() {
                        Text(ChatTools.getLimitString(item.nick_name, 8))
                          .fontColor(Color.Gray).fontSize(12).padding({ right: 10 })
                        if (item.created_time!.length > 0) {
                          Text(this.formatTime(item.created_time))
                            .fontColor(Color.Gray)
                            .fontSize(12)
                            .layoutWeight(1)
                            .padding({ right: 10 })
                            .textAlign(TextAlign.End)
                        }
                      }

                      Column() {
                        Text(EmojiTool.convertEmojiTags(item.content!))
                          .fontSize(12)
                          .textAlign(TextAlign.Start)
                          .padding({ left: 5 })
                          .backgroundColor(Color.White)
                          .padding({left: 4,right: 4,top: 2,bottom: 2})
                      }
                      .width('98%')
                      .margin({ right: 10 })
                      .justifyContent(FlexAlign.Start)
                      .alignItems(HorizontalAlign.Start)
                  }
                  .width('98%')
                  .padding({ left: 8, right: 8 })
                  .margin({ top: 2 })
                  .borderRadius(8)
                  .alignItems(HorizontalAlign.Start)
                  .justifyContent(FlexAlign.Start)
                }
                .width('98%')
                .padding({right: 10})
                .justifyContent(FlexAlign.Start)
                .alignItems(VerticalAlign.Top)

                //  提问
                if (item.type === this.qaAnswer ||
                  item.type === VHRoomEventType.QUESTION_ANSWER_COMMIT)
                Row() {
                  Image(item.avatar === '' ? $r("app.media.icon_visitorvatar") : item.avatar)
                    .width(30)
                    .height(30)
                    .borderRadius(20)
                  Column() {
                    Row() {
                      Text(ChatTools.getLimitString(item.nick_name, 8))
                        .fontColor(Color.Gray).fontSize(12).padding({ right: 10 })
                      if (item.created_time!.length > 0) {
                        Text(this.formatTime(item.created_time))
                          .fontColor(Color.Gray)
                          .fontSize(12)
                          .layoutWeight(1)
                          .padding({ right: 10 })
                          .textAlign(TextAlign.End)
                      }
                    }

                    Column() {
                      Row() {
                        Text() {
                          Span('提问 ').fontColor(Color.Red)
                          Span(EmojiTool.convertEmojiTags(item.content!)).fontColor(Color.Black)
                        }
                        .fontSize(12)
                        .textAlign(TextAlign.Start)
                        .backgroundColor(Color.White)
                      }.justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Top)

                      //  回复
                      if (item.type === this.qaAnswer ||
                        item.type === VHRoomEventType.QUESTION_ANSWER_COMMIT)
                      Column() {
                        Row() {
                          Image(item.answer?.avatar)
                            .width(30)
                            .height(30)
                            .borderRadius(20)
                          Column() {
                            Row() {
                              Text(ChatTools.getLimitString(item.answer!.nick_name, 8))
                                .fontColor(Color.Gray).fontSize(12).padding({ right: 10 })
                              Text(ChatTools.changeRoleToRoleName(item.answer!.role_name))
                                .fontColor(Color.Red)
                                .fontSize(12)
                                .borderRadius(8)
                                .backgroundColor('#FFE6F2')
                                .padding({
                                  top: 2,
                                  left: 4,
                                  right: 4,
                                  bottom: 2
                                })
                            }

                            Row() {
                              Text() {
                                Span('回复 ').fontColor(Color.Red)
                                Span(EmojiTool.convertEmojiTags(item.answer?.content!)).fontColor(Color.Black)
                              }
                                .fontSize(12)
                                .textAlign(TextAlign.Start)
                                .padding({
                                  top: 2,
                                  left: 6,
                                  right: 2,
                                  bottom: 2
                                })
                                .layoutWeight(1)
                            } .width('98%') .alignItems(VerticalAlign.Top)
                          }
                          .alignItems(HorizontalAlign.Start)
                          .padding({ left: 6 })
                          .width('95%')
                        }
                        .padding(8)
                        .borderRadius(8)
                        .alignItems(VerticalAlign.Top)
                        .justifyContent(FlexAlign.Start)
                      }
                      .width('100%')

                    }
                    .width('98%')
                    .padding(4)
                    .justifyContent(FlexAlign.Start)
                    .alignItems(HorizontalAlign.Start)
                    .backgroundColor(Color.White)
                  }
                  .width('98%')
                  .margin({ top: 2 })
                  .padding({left:8,right:8})
                  .borderRadius(8)
                  .alignItems(HorizontalAlign.Start)
                  .justifyContent(FlexAlign.Start)
                }
                .width('98%')
                .padding({right: 10})
                .justifyContent(FlexAlign.Start)
                .alignItems(VerticalAlign.Top)

                // 同问
                Row() {
                  Text() {
                    SymbolSpan(item.like_status > 0 ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'))
                      .fontWeight(FontWeight.Lighter)
                      .renderingStrategy(SymbolRenderingStrategy.SINGLE)
                      .fontSize(12)
                      .fontColor(item.like_status > 0 ? [Color.Red] : [Color.Black])
                  }
                  Text('同问')
                    .fontColor(Color.Red)
                    .fontSize(12)
                    .fontColor(item.like_status > 0 ? Color.Red : Color.Black)
                  Text(item.like_count.toString()).fontSize(12).fontColor(item.like_status > 0 ? Color.Red : Color.Black)
                }
                .width('100%')
                .padding({ right: 10 })
                .justifyContent(FlexAlign.End)
                .onClick(() => {
                  if (item.nick_name === this.webinars?.join_info?.nickname!) {
                    ToastUtil.showToast("不支持对自己发的问题进行同问！");
                    return;
                  }
                  let likeStatus = item.like_status > 0 ? '0' : '1';
                  this.setQaLike(item.id, likeStatus);
                })
              }.width('100%')
            }
          }
          )
        }
        .width('100%')
        .height('80%')
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
            placeholder: this.chatDisable ? "您已被禁言" : "快来提问吧", text: $$this.messageInput
          })
            .width('70%')
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
              this.sendQuestion();
            });

          if (this.isRecommendShow)
          Image($r('app.media.icon_recommend'))
            .width(30)
            .height(30)
            .objectFit(ImageFit.Cover)
            .margin({ left: 5, right: 5 })
            .backgroundColor(Color.White)
            .onClick(() => {
              this.QaRecommendDialog.open();
            })
          if (this.isLive)
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

          if (this.isLive)
          Stack() {
            Image($r('app.media.icon_like'))
              .width(30)
              .height(30)
              .margin({ left: 5, right: 5 })
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
        .height(54)
        .width('100%')
        .backgroundColor("#ffffff")
        .padding({ left: 10, right: 10 })
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
      }
      .backgroundColor('#EEEEEE')
      .layoutWeight(1)

      // }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    // 适配流海屏（顶部状态栏透明并穿过，并透过底部上划操作区）
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}