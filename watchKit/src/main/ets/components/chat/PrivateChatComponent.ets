import { KeyboardAvoidMode } from '@kit.ArkUI';
import {
  LikeIcon,
  RoomToolsStatusData,
  VHChatDisableAllMsg,
  VHConfigList,
  VHContent,
  VHContext,
  VHIMMessageModel,
  VHIMServer,
  VHMsgData,
  VHQuestionAnswerMsg,
  VHQuestionHistoryInfo,
  VHQuestionHistoryList,
  VHRoomEventType,
  VHSaaSDK,
  VHWebinarData
} from '@vhall/vhall_live';

import { EmitterMsgData, EmitterUtil } from '../../util/EmitterUtil';
import { ToastUtil } from '../../action/ToastUtil';
import { EmojiTool } from './EmojiTool';
import ChatTools from '../../util/ChatTools';

/**
 * 问答界面
 *
 */
@Component
export struct PrivateChatComponent {
  @Prop functionConfig: VHConfigList | null = null; //功能配置
  @State chatDisable: boolean = false;
  @Prop room_tool: RoomToolsStatusData | null = null;
  @Prop webinars: VHWebinarData | null = null;
  @Prop imBase: VHIMServer;
  @State avatar: string | undefined = "";
  @State inputText: string = "参与聊天";
  @State messageInput: string = '';
  @State senderId: string = '';
  /** 聊天列表的滚动条组件 */
  private scroller: Scroller = new Scroller();
  /** 聊天消息列表对应的数据源对象（本对象与MessageProvider配合，用于实现UI界面与数据组的解偶）*/
  @State historyData: VHContent[] = [];
  // 用来配置CanvasRenderingContext2D对象的参数，开启抗锯齿
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  // 正确创建CanvasRenderingContext2D对象
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private animationId: number = 0 // 动画ID
  // emoji表情数组
  private readonly emojis: string[] = [
    '❤️', '🧡', '💛', '💚', '💙', '💜',
    '🐼', '🦁', '🐯', '🦊',
    '🎁', '🎀', '🎉', '🎊', '✨', '⭐'
  ]
  // 状态管理：控制预览显示/隐藏 + 当前预览的图片URL
  @State isPreviewShow: boolean = false;
  @State currentPreviewUrl: string = '';
  @State likeIcons: LikeIcon[] = [] // 存储所有点赞图标
  @StorageProp('privateChatMsg') privateChatMsg: string = '';
  aboutToAppear() {
    this.avatar = this.webinars?.join_info?.avatar;
    // 启动动画循环
    this.startAnimation();
    this.getHistoryData();
    this.subscribePrivateChatMessage();
    this.subscribeChatDisable();

    if (this.webinars?.join_info?.is_gag == 1 || this.room_tool?.all_banned == 1 || this.room_tool?.is_board == 1 ||
      this.room_tool?.is_kicked == 1) {
      this.chatDisable = true;
    }

    if(this.functionConfig?.watch_record_no_chatting == 1 && this.webinars?.webinar?.type == 5){
      this.chatDisable = true;
    }
  }

  /**
   * 界面被销毁时被调用。
   */
  aboutToDisappear() {
    // this.setKeyboardAvoidModeToRESIZE(this.getUIContext(), false);
    // 清除动画循环
    clearInterval(this.animationId);
    EmitterUtil.unsubscribe(VHRoomEventType.IM_PRIVATE_TEXT);
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

  getHistoryData(){
    if (this.privateChatMsg.length > 0) {
      let messageModel = JSON.parse(this.privateChatMsg) as VHIMMessageModel;
      if (messageModel.data!) {
        // 实际业务：将消息添加到列表、更新UI等
        this.handlePrivateChatMessage(messageModel);
        AppStorage.delete('privateChatMsg');
        // 延迟滚动到最新消息（确保UI已更新）
        setTimeout(() => {
          this.scrollToBottom();
        }, 100);
      }
    }
  }
  // 订阅Text类型消息
  subscribePrivateChatMessage() {
    EmitterUtil.subscribe(VHRoomEventType.IM_PRIVATE_TEXT, (msgData: EmitterMsgData) => {
      console.log(`收到私聊消息，类型：${VHRoomEventType.IM_PRIVATE_TEXT}`);
      let messageModel: VHIMMessageModel = msgData as VHIMMessageModel;
      if (messageModel.data!) {
        // 实际业务：将消息添加到列表、更新UI等
        this.handlePrivateChatMessage(messageModel.data);
        // 延迟滚动到最新消息（确保UI已更新）
        setTimeout(() => {
          this.scrollToBottom();
        }, 100);
      }
    });
  }

  handlePrivateChatMessage(msg?: VHIMMessageModel) {
    if (!msg) {
      return;
    }
    // 接收文本消息
    let senderId =msg.sender_id;
    let imMsg: VHContent = msg as VHContent;
    let msgData: VHMsgData = msg.data as VHMsgData;
    imMsg.nickname = msg.nick_name;
    imMsg.date_time = this.formatTime(msg.date_time!);
    imMsg.data = msgData;
    if (senderId === this.webinars!.join_info!.user_id!.toString()) {
      this.senderId = msgData.target_id;
    }else{
      this.senderId = senderId!.toString();
    }
    let context = JSON.parse(msg.context as string) as VHContext;
    imMsg.role_name = context.role_name === '1' ? '主持人' : '';
    this.historyData.push(imMsg);
  }

  sendQuestion() {
    this.imBase.sendMessageToTarget(this.messageInput, this.senderId, {
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

  // 创建一个图标对象
  createIcon(x: number, y: number, radius: number, emoji: string): LikeIcon {
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
    const newIcons: LikeIcon[] = []

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
      // 聊天界面内容区
      Column() {
        List({ space: 4, scroller: this.scroller }) {
          ForEach(this.historyData, (item: VHContent, index) => {
            ListItem() {
              Column({ space: 8 }) {
                Row() {
                  Image(item.avatar === '' ? $r("app.media.icon_visitorvatar") : item.avatar)
                    .width(30)
                    .height(30)
                    .borderRadius(20)
                  Column() {
                    Row() {
                      Text(ChatTools.getLimitString(item.nickname!, 8))
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
                        Text(this.formatTime(item.date_time!))
                          .fontColor(Color.Gray)
                          .fontSize(12)
                          .layoutWeight(1)
                          .padding({ right: 10 })
                          .textAlign(TextAlign.End)
                      }
                    }

                    Column() {
                      Text(EmojiTool.convertEmojiTags(item.data?.text_content!))
                        .fontSize(12)
                        .textAlign(TextAlign.Start)
                        .padding({ left: 5 })
                        .backgroundColor(Color.White)
                        .padding({
                          left: 4,
                          right: 4,
                          top: 2,
                          bottom: 2
                        })
                    }
                    .width('98%')
                    .margin({ right: 10 })
                    .justifyContent(FlexAlign.Start)
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('98%')
                  .padding(8)
                  .margin({ top: 2 })
                  .borderRadius(8)
                  .alignItems(HorizontalAlign.Start)
                  .justifyContent(FlexAlign.Start)
                }
                .width('98%')
                .padding({ right: 10 })
                .justifyContent(FlexAlign.Start)
                .alignItems(VerticalAlign.Top)

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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    // 适配流海屏（顶部状态栏透明并穿过，并透过底部上划操作区）
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}