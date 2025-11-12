import { display, promptAction, window } from '@kit.ArkUI';
import {
  VHQuestionnairePushModel,
  RoomToolsStatusData,
  VHCommonConfig,
  VHConfigList,
  VHDisableMsg,
  VHExaminationModel,
  VHGoodsListData,
  VHIMMessageModel,
  VHIMServer,
  VHMenus,
  VHPlayerConfig,
  VHRoomEventType,
  VHRoomKickOutMsg,
  VHSaaSDK,
  VHUserData,
  VHWebinarData,
  VHAnnouncementData,
  VHAnnouncementNewsItem,
  VHHistoryQuestionnaireInfo,
  VHHistoryQuestionnaire,
  VHSurveyInternal,
  VHExamList,
  VHAnnouncementServer,
  VHAnnouncementMessage,
  VHCardInfo,
  VHLotteryCarryOut,
  VHLotteryList,
  VHMsgData,
  VHWebinarRecordWatch,
  VHQuestionAnswerSetMsg
} from '@vhall/vhall_live';
import { VHWatchVodPlayerComponent } from '../components/player/VHWatchVodPlayerComponent';
import { ChatComponent } from '../components/chat/ChatComponent';
import { VHIntroduction } from '../util/VHIntroduction';
import { VHVodMoments } from '../components/player/VHVodMoments';
import { VHAISummaryView } from '../components/player/VHAISummaryView';
import { EmitterMessage } from '../components/common/EmitterMessage';
import { VHDocPageComponent } from '../components/doc/VHDocPageComponent';
import { QaComponent } from '../components/chat/QaComponent';
import { VHDownLoadFileComponent } from '../components/doc/VHDownLoadFileComponent';
import { ToastUtil } from '../action/ToastUtil';
import { KeyboardAvoidMode } from '@kit.ArkUI';
import { VHAnnouncementDialog, VHAnnouncementPopup } from '../builder/AnnouncementBuilder';
import { ExamBuilder } from '../builder/ExamBuilder';
import { QuestionnaireBuilder } from '../builder/QuestionnaireBuilder';
import { VHCardDialog } from '../builder/CardBuilder';
import { VHCustomMenu } from '../components/menu/VHCustomMenu';
import { VHRecordListView } from '../components/menu/VHRecordListView';
import { VHIntroductionView } from '../components/introduction/VHIntroductionView';

const WINDOW_SYSTEM_BAR: Array<'status' | 'navigation'> = ['navigation', 'status'];

@Builder
export function WatchVodPagePageBuilder(name: string, param: object) {
  WatchVodPage({
    webinar_info: param['webinars'],
    player_config: param['player_config']
  })
}

@Entry
@Component
struct WatchVodPage {
  private screenWidth: number = 0;
  private screenHeight: number = 0;
  private directHeight: number = 0;
  private tabHeight: number = 0;
  private webinar_info?: VHWebinarData;
  private player_config?: VHPlayerConfig;
  @State @Watch('changeOrientation') isLandscapeStart: boolean = false; // 是否横屏状态
  @State @Watch('openSetting') openSettingBtn: boolean = false;
  pageInfos: NavPathStack = new NavPathStack() // 导航
  private textData: string = "";
  @State pageList: Array<VHMenus> = new Array();
  @State currentIndex: number = 0;
  @State needExpand: boolean = false;
  @State menusId: string = '';
  @Provide chatBannedMode:number = 0;
  @Provide chatNickNameEnc:number = 0;
  @Provide questionnairePush: VHQuestionnairePushModel | null = null
  @Provide examData: VHExaminationModel | null = null
  @Prop imBase: VHIMServer;
  @State room_tool: RoomToolsStatusData | null = null
  @State customMenuList: Array<VHMenus> = new Array();
  @State questionAnswerName: string = '';
  @Provide GoodsListData: VHGoodsListData[] = []
  @Prop functionConfig: VHConfigList | null = null; //功能配置
  @State announcement: VHAnnouncementData = new VHAnnouncementData();
  @Provide AnnouncementListItem: VHAnnouncementNewsItem = new VHAnnouncementNewsItem();
  @Provide announcementValue: string = ''
  @State VHbol: boolean = false
  controller: TabsController = new TabsController();
  @Provide questionnaireList: VHHistoryQuestionnaire[] = []
  @Provide SurveyQuestionnaireUrl: string = ''
  @Provide questionnaireAward: number = 0;
  @Provide ExamList: VHExamList[] = []
  private AnnouncementServer?: VHAnnouncementServer = new VHAnnouncementServer(this);
  @Provide AnnouncementList: VHAnnouncementNewsItem[] = []
  @Provide CardList: VHCardInfo[] = []
  @State LotteryCarryOut: VHLotteryCarryOut | null = null
  @State LotteryList: VHLotteryList[] = []
  @State LotteryStatus: boolean = false
  @State LotteryStatusEnd: boolean = false
  @State roomStatus: RoomToolsStatusData = new RoomToolsStatusData();
  @State isShowQuestionAnswer: boolean = false;
  @State qaTabIndex: number = -1;
  @State commonConfig: VHCommonConfig = new VHCommonConfig;
  aboutToAppear() {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)
    try {
      const displayInfo = display.getDefaultDisplaySync();
      this.screenWidth = displayInfo.width; // 转换为虚拟像素单位
      this.screenHeight = displayInfo.height;
      this.directHeight = (this.screenWidth * 9) / 16;
      this.tabHeight = this.screenHeight - this.directHeight;
    } catch (e) {
      console.error('获取屏幕尺寸失败: ' + JSON.stringify(e));
    }
    //连接消息服务
    this.imBase = new VHIMServer(this);
    this.imBase.join(this.webinar_info!);
    this.textData = VHIntroduction.getIntroduction(this.webinar_info?.webinar?.introduction ?? '');
    // 获得房间状态及公共配置信息
    this.getRoomStatus();
    VHSaaSDK.getInstance()
      .permissionsCheck("3", this.webinar_info?.webinar?.id.toString()!,
        this.webinar_info?.webinar?.userinfo.user_id.toString()!, {
          onSucceed: (data: VHConfigList) => {
            this.functionConfig = data;
          },
          onFailure: (errorCode: number, errorMsg: string) => {
            console.error('获取功能配置失败: ' + JSON.stringify(errorMsg));
          }
        });
    this.textData = VHIntroduction.getIntroduction(this.webinar_info?.webinar?.introduction ?? '');
    this.AnnouncementListHttp()
    this.QuestionnaireListHttp(false)
  }

  aboutToDisappear(): void {
    this.imBase?.leave();
  }



  /**
   * @description 获取公告
   */
  onStartAnnouncement(msgModel?: VHAnnouncementMessage) {
    console.log('获取公告：', msgModel)
  }

  /**
   * @description 删除公告
   */
  onDelAnnouncement(msgModel?: VHAnnouncementMessage) {
    console.log('删除公告：', msgModel)
  }

  getCommonConfig(){
    let switchId: string = this.webinar_info?.switch_info?.switch_id.toString() as string;
    VHSaaSDK.getInstance().commonConfig(this.webinar_info?.webinar?.id.toString()!, switchId, {
      onSucceed: (data: VHCommonConfig) => {
      this.commonConfig = data;
        data.menus?.forEach((value: VHMenus, index: number, array: VHMenus[]) => {
          if (value.name === '问答' && this.roomStatus.question_status === 1 && this.roomStatus.question_name!) {
            this.questionAnswerName = this.roomStatus.question_name!;
            this.isShowQuestionAnswer = true;
            value.name = data.room_tool?.question_name!
            this.qaTabIndex = index;
            this.pageList.push(value);
          }
          if (value.name === '文件下载' &&  value.id != undefined) {
            this.menusId = value.id.toString();
          }
          if (value.type === 1) {
            // 自定义菜单
            this.customMenuList.push(value);
          }
          if (value.name != "商品" && value.name != "游戏互动") {
            if (value.status === '1' || (value.type === 1 && value.wap_show === '1') ||
              (value.type !== 5 && value.wap_show === '1')) {
              this.pageList.push(value);
            }
          }
        })
        this.room_tool = data.room_tool as RoomToolsStatusData;
      },
      onFailure: (errorCode: number, errorMsg: string) => {
        ToastUtil.showToast(errorMsg);
      }
    });
  }

  /**
   * 接收聊天消息
   * @param im im
   * @param message chat消息  data中聊天消息格式  说明详见本文件底部注释
   */
  imReceiveChatMessage(type: string, message: VHIMMessageModel) {
    if (type === VHRoomEventType.IM_TEXT) {
      EmitterMessage.handleChatImText(type, message);
    }
  // 点赞消息
    if (type === VHRoomEventType.CUSTOM_PRAISE) {
      EmitterMessage.handleCustomMessage(type, message);
    }
  }

  /**
   * 接收自定义消息
   * @param im im
   * @param message 自定义消息
   */
  imReceiveCustomMessage(type: string, message: VHIMMessageModel) {
    // 清空聊天消息
    if (type === VHRoomEventType.CLEAR_CHAT_MESSAGE) {
      EmitterMessage.handleCustomMessage(type, message);
    }
  }

  /**
   * 接收上下线消息
   * @param im im
   * @param message 消息
   * 注意： 消息中的头像和昵称需要
   */
  imReceiveOnlineMessage(type: string, message: VHUserData) {

  }

  //快问快答弹窗
  VHExamDialog = new CustomDialogController({
    builder: ExamBuilder({ webinar_info: this.webinar_info }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })
  //问卷弹窗
  VHQuestionnaireDialog = new CustomDialogController({
    builder: QuestionnaireBuilder({ webinar: this.webinar_info }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })
  //公告弹窗
  VHAnnouncementDialog = new CustomDialogController({
    builder: VHAnnouncementDialog({
      server: this.AnnouncementServer,
      announcementValue: this.announcementValue
    }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })
  //推屏卡片弹窗
  VHCardDialog = new CustomDialogController({
    builder: VHCardDialog(),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })

  // 问卷列表
  QuestionnaireListHttp(openDialog: boolean) {
    VHSaaSDK.getInstance()
      .performQuestionnaireListIn(this.webinar_info?.interact?.room_id!, this.webinar_info?.webinar?.id.toString()!,
        this.webinar_info?.switch_info?.switch_id.toString()!, {
          onSucceed: (data: VHHistoryQuestionnaireInfo) => {
            this.questionnaireList = data.list;
            if (data.total > 0) {
              this.SurveyQuestionnaire()
            }
            this.questionnaireAward = data.my_award_status;
            if (openDialog) {
              if (this.questionnaireList.length > 0) {
                this.VHQuestionnaireDialog.open()
              } else {
                ToastUtil.showToast("没有更多数据");
              }
            }else{
              for (let index = 0; index < this.questionnaireList.length; index++) {
                const value = this.questionnaireList[index];
                if (value.is_answered == "0" && value.mandatory_filling === 1) {
                  this.VHQuestionnaireDialog.open();
                  break; // 触发后立即终止循环
                }
              }
            }
            console.log(`获取问卷列表成功： ${JSON.stringify(this.questionnaireList)}`);
          },
          onFailure: (errorCode: number, errorMsg: string) => {
            console.log(`获取问卷列表失败： ${errorMsg}`);
            ToastUtil.showToast(errorMsg);
          }
        })
  }

  SurveyQuestionnaire() {
    this.SurveyQuestionnaireUrl =
      VHSurveyInternal.getSurveyUrl(this.webinar_info!, this.questionnairePush?.questionnaire_id as string
        || this.questionnaireList[0].question_id.toString()) as string
    console.log(`获取问卷调查数据成功： ${this.SurveyQuestionnaireUrl}`)
  }

  /**
   * 接收房间消息
   * @param im im
   * @param message room消息
   */
  imReceiveRoomMessage(type: string, message: VHIMMessageModel) {
    if (type == VHRoomEventType.GIFT_MSG) { // 礼物消息
      EmitterMessage.handleGiftMsg(message);
    } else if (type == VHRoomEventType.ROOM_KICK_OUT) {
      this.handleKickOutPush(message)
    } else if (type == VHRoomEventType.CHAT_DISABLE) {
      this.handleChatDisablePush(message)
    } else if (type == VHRoomEventType.CHAT_PERMIT) {
      this.handleChatDisableCancelPush(message)
    } else if (type == VHRoomEventType.CHAT_DISABLE_ALL) {
      EmitterMessage.handleChatDisableAll(message);
    } else if (type == VHRoomEventType.CHAT_PERMIT_ALL) {
      EmitterMessage.handleChatPermitAll(message);
    } else if (type === VHRoomEventType.QUESTION_ANSWER_CREATE ||
      type === VHRoomEventType.QUESTION_ANSWER_COMMIT ||
      type === VHRoomEventType.QUESTION_ANSWER_NOT_REPLAYING ||
      type === VHRoomEventType.QUESTION_ANSWER_DELETE ||
      type === VHRoomEventType.QUESTION_ANSWER_BACKOUT ||
      type === VHRoomEventType.QUESTION_ANSWER_SET ||
      type === VHRoomEventType.QUESTION_ANSWER_LIKE ||
      type === VHRoomEventType.QUESTION_ANSWER_RECOMMEND) {
      // 支持人问答处理
      this.handleQuestionAnswer(type, message);
    } else if(type == VHRoomEventType.CHAT_DELETE){
      EmitterMessage.handleChatDelete(message);
    } else if (type == VHRoomEventType.CHAT_MSG_SET_RECOMMEND) {
      EmitterMessage.handleChatMsgSetRecommend(message);
    } else if (type == VHRoomEventType.CHAT_MSG_DEL_RECOMMEND) {
      EmitterMessage.handleChatMsgDelRecommend(message);
    }
    // else if (type == VHRoomEventType.ROOM_ANNOUNCEMENT ||
    //   type == VHRoomEventType.DEL_ROOM_ANNOUNCEMENT) {
    //   this.handleAnnouncementMsg(message);
    // }
  }

  // private handleAnnouncementMsg(message: VHIMMessageModel) {
  //   let announcementData = message.data as VHAnnouncementData
  //   this.announcement = announcementData
  //   EmitterMessage.handleAnnouncementMsg(message);
  //   this.AnnouncementListHttp()
  // }

  getRoomStatus() {
    VHSaaSDK.getInstance()
      .getRoomStatus(
        this.webinar_info?.switch_info?.switch_id.toString()!, this.webinar_info?.interact?.room_id!, {
        onSuccess: (data: RoomToolsStatusData) => {
          this.roomStatus = data;
          // 获取公共配置信息
          this.getCommonConfig();
        },
        onFailure: (errorCode: number, errorMsg: string) => {
          console.log(`获取观看端-获取房间状态失败： ${errorMsg}`);
        }
      })
  }

  // 公告列表
  AnnouncementListHttp() {
    let total: number = 0
    VHSaaSDK.getInstance().performAnnouncementIn(this.webinar_info?.webinar?.id.toString()!, total, 0, {
      onSucceed: (data) => {
        total = data.total
        console.log(`获取公告列表成功： ${JSON.stringify(data)}`);
        if (total > 0) {
          this.AnnouncementList = data.list
          this.announcementValue = this.AnnouncementList[0].content?.content as string
          this.countdown(this.AnnouncementList[0].duration)
        }
      },
      onFailure: (errorCode, errorMsg) => {
        console.log(`获取公告列表失败： ${errorMsg}`);
        ToastUtil.showToast(errorMsg);
      }
    })
  }

  countdown(time: number) {
    if (time != 0) {
      const timer_id = setInterval(() => {
        time--
        if (time <= 0) {
          this.announcement.duration = -1
          clearInterval(timer_id)
        }
      }, 1000)
    }
  }

  private handleKickOutPush(message: VHIMMessageModel) {
    let kickOut = message.data as VHRoomKickOutMsg;
    if (kickOut.member_info.account_id == this.webinar_info?.join_info?.third_party_user_id) {
      this.getUIContext().getPromptAction().showToast({
        message: '您已被踢出房间',
        duration: 4000,
        showMode: promptAction.ToastShowMode.DEFAULT,
        bottom: 80
      });
      this.pageInfos.pop();
    }
  }

  private handleChatDisablePush(message: VHIMMessageModel) {
    let disable = message.data as VHDisableMsg;
    if (disable.target_id == this.webinar_info?.join_info?.third_party_user_id) {
      let msg = `您已被${disable.nick_name}禁言`
      this.getUIContext().getPromptAction().showToast({
        message: `您已被${disable.nick_name}禁言`,
        duration: 4000,
        showMode: promptAction.ToastShowMode.DEFAULT,
        bottom: 80
      });
      EmitterMessage.handleChatDisable(message);
    }
  }

  private handleChatDisableCancelPush(message: VHIMMessageModel) {
    let disable = message.data as VHDisableMsg;
    if (disable.target_id == this.webinar_info?.join_info?.third_party_user_id) {
      this.getUIContext().getPromptAction().showToast({
        message: `您已被${disable.nick_name} 取消禁言`,
        duration: 4000,
        showMode: promptAction.ToastShowMode.DEFAULT,
        bottom: 80
      });
      EmitterMessage.handleChatPermit(message);
    }
  }

  private handleQuestionAnswer(type: string, message: VHIMMessageModel) {
    if (type == VHRoomEventType.QUESTION_ANSWER_CREATE) {
      // 提交回答返回消息
      EmitterMessage.handleQuestionAnswerCreate(message);
    }
    if (type == VHRoomEventType.LIVE_OVER) {
      this.getUIContext().getPromptAction().showToast({
        message: '直播已结束',
        duration: 4000,
        showMode: promptAction.ToastShowMode.DEFAULT,
        bottom: 80
      });
      this.pageInfos.pop();
    }
    if (type == VHRoomEventType.BASE_NUM_UPDATE) {
      EmitterMessage.handleBaseUpdateMsg(message);
    }

    if (type == VHRoomEventType.QUESTION_ANSWER_COMMIT) {
      // 主持人：通过并回复消息,直播中回答
      EmitterMessage.handleQuestionAnswerCommit(message);
    }

    if (type == VHRoomEventType.QUESTION_ANSWER_NOT_REPLAYING) {
      // 主持人回复：不处理消息
      EmitterMessage.handleQuestionAnswerNotReplaying(message);
    }

    if (type == VHRoomEventType.QUESTION_ANSWER_DELETE) {
      // 主持人删除问答
      EmitterMessage.handleQuestionAnswerDeleteMsg(message);
    }
    if (type == VHRoomEventType.QUESTION_ANSWER_BACKOUT) {
      // 主持人撤销回复
      EmitterMessage.handleQuestionAnswerBackOut(message);
    }
    if (type == VHRoomEventType.QUESTION_ANSWER_SET) {
      // 问答区的问题所有观众可见
      let questionAnswerMsg = message.data as VHQuestionAnswerSetMsg;
      if (questionAnswerMsg !== null && questionAnswerMsg.name !== undefined) {
        this.questionAnswerName = questionAnswerMsg.name;
        let newList = [...this.pageList];
        newList.forEach((item: VHMenus, index) => {
          if (item.type === 13) {
            newList[index].name = this.questionAnswerName;
          }
        });
        this.pageList = newList;
      }
      EmitterMessage.handleQuestionAnswerSet(message);
    }
    if (type == VHRoomEventType.QUESTION_ANSWER_LIKE) {
      // 问答点赞
      EmitterMessage.handleQuestionAnswerLike(message);
    }
    if (type == VHRoomEventType.QUESTION_ANSWER_RECOMMEND) {
      // 问答推荐
      EmitterMessage.handleQuestionAnswerRecommend(message);
    }
  }

  /**
   * 错误回调
   * @param im im
   * @param error 错误
   */
  imSDKError(code: number, errorMsg: string) {

  }

  /**
   * 消息服务连接成功
   * */
  onVHNetworkConnect(): void {

  }

  /**
   * 消息服务链接已断开
   * @param im im
   * @param error 错误
   */
  onVHNetworkDisconnect(code: number, message: string): void {

  }

  /**
   * 消息服务连接正在重新链接
   * */
  onVHNetworkConnecting(): void {

  }

  openSetting() {

  }

  changeOrientation() {
    // 获取UIAbility实例的上下文信息
    let context = this.getUIContext().getHostContext();
    // 调用该接口手动改变设备横竖屏状态（设置全屏模式，先强制横屏，再加上传感器模式）
    window.getLastWindow(context).then((lastWindow) => {
      if (this.isLandscapeStart) {
        // 设置窗口的布局是否为沉浸式布局
        lastWindow.setWindowLayoutFullScreen(true).then(() => {
          // 设置窗口全屏模式时导航栏、状态栏的可见模式
          lastWindow.setWindowSystemBarEnable([]);
          // 设置窗口的显示方向属性，AUTO_ROTATION_LANDSCAPE表示传感器自动横向旋转模式
          lastWindow.setPreferredOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE, () => {
            // this.isLandscape = !this.isLandscape;
          });
        });
      } else {
        lastWindow.setWindowLayoutFullScreen(false).then(() => {
          // 设置窗口的显示方向属性，UNSPECIFIED表示未定义方向模式，由系统判定
          lastWindow.setPreferredOrientation(window.Orientation.UNSPECIFIED, () => {
            // 设置窗口全屏模式时导航栏、状态栏的可见模式
            lastWindow.setWindowSystemBarEnable(WINDOW_SYSTEM_BAR);
            // this.isLandscape = !this.isLandscape;
          });
        })
      }
    })
  }

  build() {
    NavDestination() { // 必须作为根组件
      Flex({ direction: FlexDirection.Column }) {
        Column() {
          VHWatchVodPlayerComponent({
            webinars: this.webinar_info,
            player_config: this.player_config,
            isLandscapeStart: this.isLandscapeStart,
            openSettingBtn: this.openSettingBtn
          })
            .width('100%')
            .height('100%')
        }
        .width('100%')
        .flexShrink(0)
        .height(this.isLandscapeStart ? '100%' : this.getUIContext().px2vp(this.directHeight))

        Column() {
          if (this.AnnouncementList != null) {
            if (this.announcement.duration >= 0) {
              VHAnnouncementPopup()
            }
          }
          Tabs({
            barPosition: BarPosition.Start,
            index: this.currentIndex,
            controller: this.controller
          }) {
            ForEach(this.pageList, (item: VHMenus, index) => {
              TabContent() {
                // 根据类型加载不同页面组件
                if (item.name === '聊天' || item.type == 3) {
                  Column() {
                    Column() {
                      if (this.VHbol) {
                        Column({ space: 4 }) {
                          //抽奖
                          Image($r('app.media.icon_lottery'))
                            .width(30)
                            .onClick(() => {
                              if (this.LotteryCarryOut?.icon != null || this.LotteryList.length != 0) {
                                if (this.LotteryCarryOut!.lottery_status == 0 ||
                                  this.LotteryList[0]?.lottery_status == 0) {
                                  this.LotteryStatus = !this.LotteryStatus
                                } else {
                                  this.LotteryStatusEnd = !this.LotteryStatusEnd
                                }
                                this.VHbol = !this.VHbol
                              } else {
                                ToastUtil.showToast("没有更多数据");
                              }
                            })
                          //快问快答
                          Image($r('app.media.icon_exam'))
                            .width(30)
                            .onClick(() => {
                              VHSaaSDK.getInstance()
                                .performExamIn(this.webinar_info?.webinar?.id!, 1,
                                  this.webinar_info?.switch_info?.switch_id!, 1, {
                                    onSucceed: (data) => {
                                      this.ExamList = data
                                      if( this.ExamList.length == 0){
                                        ToastUtil.showToast("没有更多数据");
                                        return
                                      }
                                      this.VHExamDialog.open()
                                      this.VHbol = !this.VHbol
                                      console.log(`获取快问快答列表成功： ${JSON.stringify(data)}`);
                                    },
                                    onFailure: (errorCode, errorMsg) => {
                                      console.log(`获取快问快答列表失败： ${errorMsg}`);
                                    }
                                  })
                            })
                          //问卷
                          Image($r('app.media.icon_task'))
                            .width(30)
                            .onClick(() => {
                              this.QuestionnaireListHttp(true);
                              this.VHbol = !this.VHbol
                            })
                          //公告
                          Image($r('app.media.icon_reminder'))
                            .width(30)
                            .onClick(() => {
                              if (this.AnnouncementList.length != 0) {
                                this.VHAnnouncementDialog.open()
                                this.VHbol = !this.VHbol
                              } else {
                                ToastUtil.showToast("没有更多数据");
                              }
                            })
                          //推屏卡片
                          Image($r('app.media.icon_laber'))
                            .width(30)
                            .onClick(() => {
                              if (this.CardList.length != 0) {
                                this.VHCardDialog.open()
                                this.VHbol = !this.VHbol
                              } else {
                                ToastUtil.showToast("没有更多数据");
                              }
                            })
                        }
                        .width(30)
                        .position({ x: 0, y: -170 })
                      }
                      Image($r('app.media.icon_all'))
                        .width(30)
                        .height(30)
                        .backgroundColor('#ffb7b7b7')
                        .borderRadius(15)
                        .padding(3)
                        .position({ x: 0, y: 0 })
                        .onClick(() => {
                          this.VHbol = !this.VHbol
                        })
                    }
                    .width(30)
                    .position({ x: 340, y: 420 })
                    .zIndex(1)

                    ChatComponent({
                      webinars: this.webinar_info,
                      imBase: this.imBase,
                      functionConfig: this.functionConfig,
                      room_tool: this.room_tool,
                      isLive: false
                    })
                      .width('100%')
                      .height('100%')
                  }
                } else if (item.name === '简介' || item.type == 4) {
                  VHIntroductionView({ introduction: this.webinar_info?.webinar?.introduction }).height('100%')
                    .width('100%')
                } else if (item.name === '文档' || item.type == 2) {
                  Row() {
                    VHDocPageComponent({ webinars: this.webinar_info, playConfig: this.player_config })
                      .width('100%')
                      .height('100%');
                  }.width('100%').height('100%')
                } else if (item.name === '问答' || item.name === this.questionAnswerName) {
                  QaComponent({ webinars: this.webinar_info, functionConfig:this.functionConfig,imBase: this.imBase,room_tool: this.room_tool,isLive: false })
                    .width('100%')
                    .height('100%')
                } else if (item.name === '文件下载') {
                  VHDownLoadFileComponent({ webinars: this.webinar_info, menusId: this.menusId })
                    .width('100%')
                    .height('100%')
                } else if (item.name === '精彩时刻') { //回放用此功能
                  VHVodMoments({ webinar: this.webinar_info }).width('100%').height("100%")
                } else if (item.name === '概要总结') { //回放用此功能
                  VHAISummaryView({ webinar: this.webinar_info }).width('100%').height("100%")
                } else if (this.customMenuList.find((menu) => menu.name === item.name)) {
                  VHCustomMenu({ menu_id: item.id.toString(), webinars: this.webinar_info,enableInviteCard: Number(this.commonConfig.invite_card) })
                    .width('100%')
                    .height('100%')
                } else if (item.name === '回放列表') { //回放用此功能
                    VHRecordListView({webinar:this.webinar_info,pageInfos:this.pageInfos})
                      .width('100%')
                      .height('100%')
                }
              }.tabBar(item.name as string)
            })
          }.barHeight(40).barMode(BarMode.Scrollable)
        }.backgroundColor(Color.White)
        .width('100%')
        .flexGrow(1)
      }
    }
    .width('100%')
    .height('100%')
    .hideToolBar(true)
    .hideTitleBar(true)
    .hideBackButton(true)
    .id('WatchVodPage')
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack
    })
  }
}
