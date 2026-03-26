import { ComponentContent, display, KeyboardAvoidMode, promptAction, window } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';
import {
  VHGoodsInfo,
  VHRoomToolsStatusData,
  VHTimerMsg,
  VHTimerPauseMsg,
  VHAgreement,
  VHAnnouncementData,
  VHAnnouncementMessage,
  VHAnnouncementNewsItem,
  VHAnnouncementServer,
  VHBannedModeUpdate,
  VHCardInfo,
  VHChatMessageList,
  VHChatNickNameEncryptionUpdate,
  VHCommonConfig,
  VHConfigList,
  VHContent,
  VHCouponInfo,
  VHDisableMsg,
  VHDoingSignInfo,
  VHExaminationModel,
  VHExamInternal,
  VHExamList,
  VHExamRank,
  VHExamReportList,
  VHExamUserAnswerStatus,
  VHGetSignData,
  VHHistoryQuestionnaire,
  VHHistoryQuestionnaireInfo,
  VHIMMessageModel,
  VHIMServer,
  VHInteractRewardWinning,
  VHLotteryCarryOut,
  VHLotteryList,
  VHLotteryMessage,
  VHLotteryResultNoticeModel,
  VHLotteryServer,
  VHMarketingPublicAccount,
  VHMenus,
  VHMsgData,
  VHNotAvailableCouponInfo,
  VHPlayerConfig,
  VHPushGoodsChangeData,
  VHPushScreenCardMsg,
  VHPwdRedEnvelopeData,
  VHQuestionAnswerSwitchMsg,
  VHQuestionAnswerSetMsg,
  VHQuestionnairePushModel,
  VHRedEnvelopeInfo,
  VHRedPacketStatus,
  VHRoomEventType,
  VHRoomKickOutMsg,
  VHSaaSDK,
  VHSignData,
  VHSignInfo,
  VHSignMessage,
  VHSignServer,
  VHSurveyInternal,
  VHTimer,
  VHUserData,
  VHWatchGiftInfo,
  VHWebinarData,
  VHWebinarSurvey,
  VHWebinarSurveyExtend,
  VHGoodsActivitySettings,
  VHDataDownloadUpdateMsg,
  VHGoodsInfoCallback,
  VHGoodsListCallback,
  VHInviteData
} from '@vhall/vhall_live';
import { VHWatchLivePlayerComponent } from '../components/player/VHWatchLivePlayerComponent';
import { ChatComponent } from '../components/chat/ChatComponent';
import { VHSignDialog } from '../builder/SignBuilder';
import { VHDocPageComponent } from '../components/doc/VHDocPageComponent';
import { VHAnnouncementDialog, VHAnnouncementPopup } from '../builder/AnnouncementBuilder';
import { ToastUtil } from '../action/ToastUtil';
import { LotteryDetails, LotteryDialog } from '../builder/LotteryDialog';
import { VHIntroduction } from '../util/VHIntroduction';
import { QaComponent } from '../components/chat/QaComponent';
import { VHDownLoadFileComponent } from '../components/doc/VHDownLoadFileComponent';
import { QuestionnaireBuilder } from '../builder/QuestionnaireBuilder';
import { createPushCardView, PushCardParams } from '../builder/VHPushCardBuilder';
import { PromptActionClass } from '../util/PromptActionClass';
import { ExamBuilder } from '../builder/ExamBuilder';
import { TimerComponent } from '../components/timer/TimerComponent';
import { VHCardDialog } from '../builder/CardBuilder';
import { createWatchGiftView, WatchGiftParams } from '../builder/WatchGiftBuilder';
import { FloatingWindow, VHGoodsComponent } from '../components/goods/VHGoodsComponent';
import { VHAdvComponent } from '../components/adv/VHAdvComponent';
import { VHCustomMenu } from '../components/menu/VHCustomMenu';
import { createInteractAwardGiftView, InteractAwardParams } from '../builder/InteractAwardBuilder';
import { VHPasswordEnvelopePage } from './PasswordEnvelopePage';
import { EmitterMessage } from '../components/common/EmitterMessage';
import { common } from '@kit.AbilityKit';
import { BackgroundTaskManager } from '../utils/BackGroundTaskManager';
import { EmitterMsgData, EmitterUtil } from '../util/EmitterUtil';
import { VHIntroductionView } from '../components/introduction/VHIntroductionView';
import { preferences } from '@kit.ArkData';
import { PrivateChatComponent } from '../components/chat/PrivateChatComponent';
import MsgType from '../constants/MsgType';
import { VhallCaptureFrame, VhallCodeNum, VhallMediaType, VhallStream,
  VhallStreamType,
  VHRtcSDK,
  VHSpeakListInfo } from '@vhall/vhall_rtc';
import { VHRTCUserInfo } from '../components/rtc/VHRTCUserInfo';
import { VHRTCUserComponent } from '../components/rtc/VHRTCUserComponent';
import { VhallBeautyFrame, VHBeautyDataService, VHBeautySDK } from '@vhall/vhall_beauty';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import { AVSessionManager } from '../utils/AVSessionManager';

const WINDOW_SYSTEM_BAR: Array<'status' | 'navigation'> = ['navigation', 'status'];
const RECONNECT_TIMEOUT: number = 3000;

@Builder
export function GuestLivePageBuilder(name: string, param: object) {
  GuestLivePage({
    webinar_id: param['webinar_id'],
    nick_name: param['nick_name'],
  })
}

@Entry
@Component
struct GuestLivePage {
  private screenWidth: number = 0;
  private screenHeight: number = 0;
  private directHeight: number = 0;
  private tabHeight: number = 0;
  private webinar_info?: VHWebinarData;
  private player_config?: VHPlayerConfig;
  private chat_messages?: VHChatMessageList;
  private imBase?: VHIMServer;
  private AnnouncementServer?: VHAnnouncementServer = new VHAnnouncementServer(this);
  @State webinar_id: string = '';
  @State nick_name: string = '';
  @State @Watch('changeOrientation') isLandscapeStart: boolean = false; // 是否横屏状态
  pageInfos: NavPathStack = new NavPathStack() // 导航
  @State pageList: Array<VHMenus> = new Array();
  @State menusId: string = '';
  @State currentIndex: number = 0;
  @State needExpand: boolean = false;
  @State VHbol: boolean = false
  private textData: string = "";
  @Provide room_id: string = ''
  @Provide signTime: number = 0;
  @Provide chatBannedMode: number = 0;
  @Provide chatNickNameEnc: number = 0;
  @State announcement: VHAnnouncementData = new VHAnnouncementData();
  @Provide AnnouncementList: VHAnnouncementNewsItem[] = []
  @Provide announcementValue: string = ''
  @State isShowQuestionAnswer: boolean = false;
  @State questionAnswerName: string = '';
  @State qaTabIndex: number = -1;
  @Provide timerMsg: VHTimerMsg | null = null
  @State timerPauseMsg: VHTimerPauseMsg | null = null
  @State showTimerDialog: boolean = false;
  @State timerTotalSeconds: number = 0;
  @State isTimerShow: boolean = false;
  @Provide questionnairePush: VHQuestionnairePushModel | null = null
  @Provide questionnaireList: VHHistoryQuestionnaire[] = []
  @Provide questionnaireAward: number = 0;
  @Provide SurveyQuestionnaireUrl: string = ''
  @Provide examData: VHExaminationModel | null = null
  @Provide ExamUrl: string = ''
  @Provide ExamList: VHExamList[] = []

  controller: TabsController = new TabsController();
  @State customMenuList: Array<VHMenus> = new Array();
  @State functionConfig: VHConfigList | null = null; //功能配置
  @State room_tool: VHRoomToolsStatusData | null = null
  @Provide agreement: VHAgreement = new VHAgreement();
  @Provide roomId: string = ''
  private imConnected: boolean = false;
  private imConnectTimer: number = -1;
  @State welcomeContent: string = '';
  @Provide closeLotteryListDialog: boolean = false;
  @State isAnnouncementShown: boolean = false;
  @State signId: number = 0;
  private dataPreferences: preferences.Preferences | null = null;
  private forceLoginContentNode: ComponentContent<Object> | null = null;
  @Provide PushProductData: VHGoodsInfo[] = []
  @Provide ActivitySettings: VHGoodsActivitySettings = new VHGoodsActivitySettings()
  @State commonConfig: VHCommonConfig = new VHCommonConfig;
  @State hideState: number = 0;
  @State streamList: VHRTCUserInfo[] = [];
  @State userId: string = '';
  @State isRTCRoom: boolean = false;
  @State isSpeak: boolean = false;
  private avSessionManager = new AVSessionManager()

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
    VHSaaSDK.getInstance().getLiveInit(this.webinar_id, this.nick_name, '', {
      onSucceed: (data: VHWebinarData) => {
        this.webinar_info = data;
        //连接消息服务, 此方法会建立websocket进行消息的接收处理。在线状态也是通过此方法控制
        this.imBase = new VHIMServer(this);
        this.imBase.join(this.webinar_info!);
        VHSaaSDK.getInstance().getConfigList("3", this.webinar_info?.webinar?.id.toString()!,
          this.webinar_info?.webinar?.userinfo.user_id.toString()!, {
            onSucceed: (data: VHConfigList) => {
              this.functionConfig = data;
            },
            onFailure: (errorCode: number, errorMsg: string) => {
              console.error('获取功能配置失败: ' + JSON.stringify(errorMsg));
            }
          });

        let switchId: string = this.webinar_info?.switch_info?.switch_id.toString() as string;
        VHSaaSDK.getInstance().commonConfig(this.webinar_info?.webinar?.id.toString()!, switchId, {
          onSucceed: (data: VHCommonConfig) => {
            this.commonConfig = data;
            //当前是否有红包
            this.room_tool = data.room_tool as VHRoomToolsStatusData;
            if (data.timer !== null && data.timer.duration !== undefined) {
              let timer = data.timer as VHTimer;
              this.initTimer(timer);
            }

            data.menus?.forEach((value: VHMenus, index: number, array: VHMenus[]) => {
              if (value.name === '问答' && data.room_tool?.question_status === 1 && data.room_tool?.question_name!) {
                this.questionAnswerName = data.room_tool?.question_name!;
                this.isShowQuestionAnswer = true;
                value.name = data.room_tool?.question_name!
                this.qaTabIndex = index;
                this.pageList.push(value);
              }
              if (value.type === 2 || value.type === 3) {
                this.pageList.push(value);
              }
            })

            this.pageList.forEach((value: VHMenus, index: number, array: VHMenus[]) => {
              if (value.name == '聊天') {
                this.currentIndex = index;
              }
            })
          },
          onFailure: (errorCode: number, errorMsg: string) => {
            console.log(`${errorCode}:${errorMsg}`)
            ToastUtil.showToast(errorMsg)
          }
        });
        this.textData = VHIntroduction.getIntroduction(this.webinar_info?.webinar?.introduction ?? '');
        let options: preferences.Options = { name: 'isAnnouncementShown' };
        this.dataPreferences =
          preferences.getPreferencesSync(this.getUIContext().getHostContext()?.getApplicationContext(), options);
        this.isAnnouncementShown = this.dataPreferences.getSync("isAnnouncementShown", "") as boolean
        this.chatBannedMode = this.room_tool?.banned_mode as number;
        this.chatNickNameEnc = this.functionConfig?.chat_nickname_encryption as number;
        const context = this.getUIContext().getHostContext();
        // 是否开启美颜功能
        PreferencesUtil.putSync("isBeautyEnable", true);
        if(this.webinar_info && context) {
          this.userId = this.webinar_info?.join_info?.third_party_user_id!;
          VHBeautySDK.getInstance().init(this.webinar_info?.webinar?.id.toString()!,
            this.webinar_info?.webinar?.userinfo.user_id.toString()!,{
              onSucceed: (data: number) => {
                ToastUtil.showToast("美颜SDK初始化成功");
              },
              onFailure: (errorCode: number, errorMsg: string) => {
                ToastUtil.showToast("美颜SDK初始化失败");
              }
            });
          VHRtcSDK.getInstance().init(
            context,
            this.webinar_info,
            {
              onConnectRoom: (errorCode: number, errorMsg: string): void => {
                setTimeout(()=>{
                  VHRtcSDK.getInstance().getSpeakList(this.webinar_info?.interact?.room_id!, {
                    onSuccess: (data: string | object) => {
                      let speakList: VHSpeakListInfo = data as VHSpeakListInfo;
                      for (let i = 0; i < speakList.total; i++) {
                        let speakItem = speakList.list[i];
                        if (speakItem.account_id === this.webinar_info?.join_info?.third_party_user_id) {
                          this.isSpeak = true;
                          let selfItem = new VHRTCUserInfo(this.userId, false);
                          selfItem.nickName = this.webinar_info?.join_info?.nickname!;
                          const isUserExists = this.streamList.some(item => item.userId === this.userId);
                          if (!isUserExists) {
                            this.streamList.push(selfItem);
                            let msgData: EmitterMsgData;
                            msgData = {
                              type: "CreateLocalStream",
                              data: ""
                            } as EmitterMsgData;
                            EmitterUtil.send(msgData);
                          }
                        }
                      }
                    },
                    onFailure: (errorCode, errorMsg) => {
                      console.error("getSpeakList errorCode:" + errorCode + " errorMsg:" + errorMsg);
                    }
                  })
                }, 0)
              },
              onConnectionRoomLost: (): void => {
                console.info("SDK 与互动服务器的连接已经断开。");
              },
              onReconnectRoom: (): void => {
                console.info("SDK 正在尝试重新连接互动服务。");
              },
              onConnectionRecovery: (): void => {
                console.info("SDK 已恢复与互动服务端的连接。");
                //参考观看端重推处理
              },
              onError: (errCode: number, errMsg: string): void => {
                console.info("SDK 错误：" + errCode + " " + errMsg);
              },
              onWarning: (warningCode: number, warningMsg: string): void => {
                console.info("SDK 警告：" + warningCode + " " + warningMsg);
              },
              onPublishStream: (stream: VhallStream): void => {
                console.info("发布流");
              },
              onUnPublishStream: (stream: VhallStream): void => {
                console.info("取消发布流");
              },
              onRemoteStreamAdd: (stream: VhallStream): void => {
                const remoteStream = this.streamList.find(item => item.streamId === stream.streamId);
                if (!remoteStream) {
                  let selfItem = new VHRTCUserInfo(stream.userId, true);
                  selfItem.streamId = stream.streamId;
                  selfItem.streamType = stream.streamType;
                  selfItem.streamAttr = stream.attribute;
                  let attribute = JSON.parse(stream.attribute) as object;
                  selfItem.nickName = attribute["nickName"];
                  if (attribute["roleName"] === 1) {
                    selfItem.isMain = true;
                  }
                  this.streamList.push(selfItem);
                } else {
                  if (remoteStream.controller !== null) {
                    remoteStream.updateRenderParams(remoteStream.controller);
                  }
                }
              },
              onRemoteStreamRemoved: (stream: VhallStream): void => {
                for (let i = this.streamList.length - 1; i >= 0; i--) {
                  try {
                    if (stream.streamId == this.streamList[i].streamId && stream.streamType != VhallStreamType.VHStreamType_AudioAndVideo) {
                      this.streamList.splice(i, 1); // 从后往前删除元素
                      break;
                    }
                  } catch (err) {
                  }
                }
              },
              onSubScribeStream: (stream: VhallStream, type: VhallMediaType): void => {
                console.info("订阅流");
              },
              onSubScribeStreamFailed: (code: number, msg: string, stream_id: string): void => {
                console.info("订阅流失败：" + code + " " + msg);
                //订阅失败重新拉流订阅
                setTimeout(()=>{
                  if(code == VhallCodeNum.ERR_MEDIA_CONNECT_CONNECT_ERROR || code == VhallCodeNum.ERR_ICE_CONNECT_CONNECT_ERROR || code == VhallCodeNum.ERR_DISCONNECTED){
                    for (let i = this.streamList.length - 1; i >= 0; i--) {
                      try {
                        if (stream_id == this.streamList[i].streamId) {
                          let controller = this.streamList[i].controller;
                          if(controller != null){
                            this.streamList[i].updateRenderParams(controller!);
                          }
                          break;
                        }
                      } catch (err) {
                        console.error('request CAMERA error=' + JSON.stringify(err));
                      }
                    }
                  }
                },500)
              },
              onUnSubScribeStream: (stream: VhallStream): void => {
                console.info("取消订阅流");
              },
              onUserVideoAvailable: (stream: VhallStream, available: number): void => {
                this.streamList.forEach((item: VHRTCUserInfo) => {
                  item.isCamera = item.streamId === stream.streamId ? available === 0 ? false : true : item.isCamera;
                });
              },
              onUserAudioAvailable: (stream: VhallStream, available: number): void => {
                this.streamList.forEach((item: VHRTCUserInfo) => {
                  item.isMute = item.streamId === stream.streamId ? available === 1 ? false : true : item.isMute;
                });
              },
              onUserStatistics: (stream: VhallStream, lost: number): void => {
                this.streamList.forEach((item: VHRTCUserInfo) => {
                  item.isLost = item.streamId === stream.streamId ? lost > 10 ? true : false : item.isLost;
                });
              },
              onUserAudioVolume: (stream: VhallStream, value: number): void => {
                console.info("用户音量：" + value);
              },
              onPublishStreamFailed: (code: number, msg: string): void => {
                console.info("推流失败：" + code + " " + msg);
              },
              onUnPublishStreamFailed: (code: number, msg: string, stream_id: string): void => {
                console.info("停止推流失败：" + code + " " + msg);
              },
              onUnSubScribeStreamFailed: (code: number, msg: string, stream_id: string): void => {
                console.info("取消订阅远端流：" + code + " " + msg);
              },
              onCaptureFrame: (src: VhallCaptureFrame, dst: VhallCaptureFrame): void => {
                let srcFrame = new VhallBeautyFrame(src.data, src.width, src.height, src.timestamp);
                let dstFrame = new VhallBeautyFrame(dst.data, dst.width, dst.height, dst.timestamp);
                VHBeautySDK.getInstance().renderWithInput(srcFrame, dstFrame);
                dst.data = dstFrame.data;
              }
            },
            {
              onSuccess: (): void => {
                VHRtcSDK.getInstance().enterRoom();
                this.isRTCRoom = true;
              },
              onFailure: (errorCode: number, errorMsg: string): void => {
              }
            }
          )
        }
      },
      onFailure: (errorCode: number, errorMsg: string) => {
        ToastUtil.showToast(errorMsg);
        this.pageInfos.pop();
      }
    })
  }

  async aboutToDisappear(): Promise<void> {
    if (this.imConnectTimer != -1) {
      clearTimeout(this.imConnectTimer);
      this.imConnectTimer = -1;
    }
    this.imBase?.leave();
    this.VHAnnouncementDialog.close()
    const isUserExists = this.streamList.some(item => item.userId === this.userId);
    if (isUserExists) {
      VHRtcSDK.getInstance().userNoSpeak(this.webinar_info?.interact?.room_id!, {
        onSuccess: (): void => {
        },
        onFailure: (errorCode: number, errorMsg: string): void => {
        }
      });
    };
    //退出房间
    VHRtcSDK.getInstance().exitRoom();
    VHRtcSDK.getInstance().destroy();
    this.streamList = [];
  }


  initTimer(timer: VHTimer) {
    if (timer !== null) {
      let timerMsg: VHTimerMsg = new VHTimerMsg();
      timerMsg.duration = timer.duration;
      timerMsg.is_all_show = timer.is_all_show;
      timerMsg.is_timeout = timer.is_timeout;
      timerMsg.remain_time = timer.remain_time.length > 0 ? parseInt(timer.remain_time) : 0;
      timerMsg.status = timer.status;
      timerMsg.type = this.getTimerType(timer.status);
      timerMsg.room_id = this.webinar_info?.interact?.room_id as string;
      timerMsg.event_type = this.getTimerType(timer.status);
      this.showTimerDialog = timerMsg.is_all_show === '1' ? true : false;
      this.isTimerShow = this.showTimerDialog;
      this.timerTotalSeconds = timer.duration!.length > 0 ? parseInt(timer.duration!) : 0;
      this.timerMsg = timerMsg;
    }
  }



  getTimerType(status: string): string {
    // 4 TIMER_PAUSE
    let timerType: string = VHRoomEventType.TIMER_RESUME;
    switch (status) {
      case "4":
        timerType = VHRoomEventType.TIMER_PAUSE;
        break;
      default:
        timerType = VHRoomEventType.TIMER_RESUME;
        break;
    }
    return timerType;
  }

  countdown(time: number) {
    if (time != 0) {
      const timer_id = setInterval(() => {
        time--
        if (time <= 0) {
          this.announcement.duration = -1
          clearInterval(timer_id)
          this.isAnnouncementShown = true
          this.dataPreferences?.putSync('isAnnouncementShown', this.isAnnouncementShown);
          this.dataPreferences?.flushSync();
        }
      }, 1000)
    }
  }



  VHExam(id: string, type: string) {
    this.ExamUrl =
      VHExamInternal.getExamUrl(this.webinar_info!, id, type) as string
    console.log(`获取考试数据成功： ${this.ExamUrl}`)
  }

  // 添加新页签的方法
  addQaTab() {
    // 使用数组拷贝方式更新
    let newList = [...this.pageList];
    let isAddNew: boolean = true;
    newList.forEach((item: VHMenus, index) => {
      if (item.name === '问答') {
        this.qaTabIndex = index;
        newList[index].name = this.questionAnswerName;
        isAddNew = false;
      }
    });
    this.pageList = newList;
    if (isAddNew) {
      const newListCopy = [...this.pageList];
      const chatIndex = newListCopy.findIndex((item: VHMenus) => item.name === '聊天');
      const qaMenu: VHMenus = { name: this.questionAnswerName } as VHMenus;
      if (chatIndex !== -1) {
        this.qaTabIndex = chatIndex + 1;
        newListCopy.splice(chatIndex + 1, 0, qaMenu);
      } else {
        newListCopy.unshift(qaMenu);
        this.qaTabIndex = newListCopy.length - 1;
      }
      this.pageList = newListCopy;
    }
  }

  addPrivateChatTab(message: string) {
    // 使用数组拷贝方式更新
    let newList = [...this.pageList];
    let isAddNew: boolean = true;
    newList.forEach((item: VHMenus) => {
      if (item.name === '私聊') {
        isAddNew = false;
        return;
      }
    });
    this.pageList = newList;
    if (isAddNew) {
      AppStorage.SetOrCreate('privateChatMsg', message);
      const newListCopy = [...this.pageList];
      const chatIndex = newListCopy.findIndex((item: VHMenus) => item.name === '聊天');
      const qaMenu: VHMenus = { name: '私聊' } as VHMenus;
      if (chatIndex !== -1) {
        newListCopy.splice(chatIndex + 1, 0, qaMenu);
      } else {
        newListCopy.unshift(qaMenu);
      }
      this.pageList = newListCopy;
    }
  }

  // 删除页签
  deleteQaTab() {
    this.isShowQuestionAnswer = false;
    if (this.qaTabIndex === -1) {
      return
    }
    const deletedIndex = this.qaTabIndex
    // 使用splice+数组拷贝触发更新
    let newList = [...this.pageList];
    newList.splice(deletedIndex, 1);
    this.pageList = newList;
    // 重置对话框状态
    this.qaTabIndex = -1
  }


  // 公告列表
  AnnouncementListHttp() {
    let total: number = 0
    VHSaaSDK.getInstance().getNoticeList(this.webinar_info?.webinar?.id.toString()!, total, 0, {
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


  //公告弹窗
  VHAnnouncementDialog = new CustomDialogController({
    builder: VHAnnouncementDialog({
      server: this.AnnouncementServer,
      announcementValue: this.announcementValue
    }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })

  /**
   * @description 开始签到
   */
  onStartSign(msgModel: VHSignMessage) {
    console.log('开始签到：', msgModel)
  }

  /**
   * @description 结束签到
   */
  onEndSign(msgModel?: VHSignMessage) {
    console.log('结束签到：', msgModel)
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

  /**
   * 接收聊天消息
   * @param im im
   * @param message chat消息  data中聊天消息格式  说明详见本文件底部注释
   */
  imReceiveChatMessage(type: string, message: VHIMMessageModel) {
    if (type === VHRoomEventType.IM_TEXT) {
      let newMsg = message.data as VHMsgData;
      if (newMsg.target_id !== undefined && newMsg.target_id.length > 0) {
        // 如果是私聊消息，需要产生tab
        this.addPrivateChatTab(JSON.stringify(message));
        EmitterMessage.handleChatImText(type, message);
      } else {
        EmitterMessage.handleChatImText(type, message);
      }
    }
    // 点赞消息
    if (type === VHRoomEventType.CUSTOM_PRAISE) {
      EmitterMessage.handleCustomMessage(type, message);
    }
  }

  /**
   * 接收上下线消息
   * @param im im
   * @param message 消息
   * 注意： 消息中的头像和昵称需要 设置 [VHLiveBase setThirdPartyUserId:@"xxxx" context:@{@"nick_name":@"xxxx",@"avatar":@"xxxx"}]; 才能收到
   */
  imReceiveOnlineMessage(type: string, message: VHUserData) {
    console.log("接收上下线消息:", message);
    if (type == VHRoomEventType.USER_JOIN) {
      // 上线消息
      EmitterMessage.handleOnlineMessage(type, message);
    } else if (type == VHRoomEventType.USER_LEAVE) {
      // 下线消息
      EmitterMessage.handleOnlineMessage(type, message);
    }
  }

  /**
   * 接收自定义消息
   * @param im im
   * @param message 自定义消息
   */
  imReceiveCustomMessage(type: string, message: VHIMMessageModel) {
    if (type == VHRoomEventType.TIMER_PAUSE) {
      this.handlePauseTimer(type, message);
    }
    if (type == VHRoomEventType.DATA_DOWNLOAD_UPDATE) {
      this.handleDataDownloadUpdateMsg(message);
    }
    // 清空聊天消息
    if (type === VHRoomEventType.CLEAR_CHAT_MESSAGE) {
      EmitterMessage.handleCustomMessage(type, message);
    }
    console.log("接收自定义消息:", message);
  }

  /**
   * 接收房间消息
   * @param im im
   * @param message room消息
   */
  imReceiveRoomMessage(type: string, message: VHIMMessageModel) {
    console.log("接收房间消息:", message);
    if (type == VHRoomEventType.GIFT_MSG) { // 礼物消息
      EmitterMessage.handleGiftMsg(message);
    } else if (type == VHRoomEventType.ROOM_ANNOUNCEMENT ||
      type == VHRoomEventType.DEL_ROOM_ANNOUNCEMENT) {
      this.handleAnnouncementMsg(message);
    } else if (type == VHRoomEventType.QUESTION_ANSWER_OPEN ||
      type == VHRoomEventType.QUESTION_ANSWER_CLOSE) {
      // 开启及关闭问答
      this.handleQuestionAnswerOpenClose(type, message);
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
    } else if (type === VHRoomEventType.TIMER_START ||
      type === VHRoomEventType.TIMER_RESUME ||
      type === VHRoomEventType.TIMER_RESET ||
      type === VHRoomEventType.TIMER_END) {
      // 处理计时器
      this.handleTimer(type, message);
    } else if (type == VHRoomEventType.LIVE_OVER) {
      this.handleLiveOver(message);
    } else if (type == VHRoomEventType.BASE_NUM_UPDATE) {
      EmitterMessage.handleBaseUpdateMsg(message);
    }  else if (type == VHRoomEventType.ROOM_KICK_OUT) {
      this.handleKickOutPush(message)
    } else if (type == VHRoomEventType.CHAT_DISABLE) {
      this.handleChatDisablePush(message)
    } else if (type == VHRoomEventType.CHAT_PERMIT) {
      this.handleChatDisableCancelPush(message)
    } else if (type == VHRoomEventType.CHAT_DISABLE_ALL) {
      EmitterMessage.handleChatDisableAll(message);
    } else if (type == VHRoomEventType.CHAT_PERMIT_ALL) {
      EmitterMessage.handleChatPermitAll(message);
    } else if (type == VHRoomEventType.IM_BANNED_MODE_UPDATE) { //禁言感知状态
      this.handleBannedModeUpdate(message);
    } else if (type == VHRoomEventType.IM_CHAT_NICK_NAME_ENCRYPTION) { //聊天昵称加密
      this.handleChatNicknameEncryption(message);
    } else if (type == VHRoomEventType.CHAT_DELETE) {
    } else if (type == VHRoomEventType.IM_BANNED_MODE_UPDATE) { //禁言感知状态
      this.handleBannedModeUpdate(message);
    } else if (type == VHRoomEventType.IM_CHAT_NICK_NAME_ENCRYPTION) { //聊天昵称加密
      this.handleChatNicknameEncryption(message);
    } else if (type == VHRoomEventType.CHAT_DELETE) { //删除聊天消息
      EmitterMessage.handleChatDelete(message);
    } else if (type == VHRoomEventType.CHAT_MSG_SET_RECOMMEND) { //设置推荐
      EmitterMessage.handleChatMsgSetRecommend(message);
    } else if (type == VHRoomEventType.CHAT_MSG_DEL_RECOMMEND) { //删除推荐
      EmitterMessage.handleChatMsgDelRecommend(message);
    }else if (type == VHRoomEventType.MESSAGE_VRTC_CONNECT_OPEN) { //开启连麦功能
      EmitterMessage.handleConnectOpen(message);
    } else if (type == VHRoomEventType.MESSAGE_VRTC_CONNECT_CLOSE) { //取消连麦功能
      EmitterMessage.handleConnectClose(message);
    } else if (type == VHRoomEventType.MESSAGE_VRTC_CONNECT_INVITE) { //邀请连麦功能
      this.handleConnectInvite(message);
    } else if (type == VHRoomEventType.MESSAGE_VRTC_CONNECT_AGREE) { //互动连麦连接同意
      this.handleConnectAgree(message);
    } else if (type == VHRoomEventType.MESSAGE_VRTC_CONNECT_INVITE_AGREE) { //互动连麦连接邀请同意
      this.handleConnectInviteAgree(message);
    } else if (type == VHRoomEventType.MESSAGE_VRTC_CONNECT_SUCCESS) { //互动连麦连接邀请同意
      this.handleConnectSuccess(message);
    } else if (type == VHRoomEventType.MESSAGE_VRTC_DISCONNECT_SUCCESS) { //互动连麦断开连接成功
      this.handleDisConnectSuccess(message);
    } else if (type == VHRoomEventType.MESSAGE_VRTC_MUTE) { //静音某路流
      this.handleMute(message);
    } else if (type == VHRoomEventType.MESSAGE_VRTC_MUTE_CANCEL) { //取消静音某路流
      this.handleMuteCancel(message);
    } else if (type == VHRoomEventType.MESSAGE_VRTC_FRAMES_FORBID) { //禁止显示某路流的画面
      this.handleFramesForbid(message);
    } else if (type == VHRoomEventType.MESSAGE_VRTC_FRAMES_DISPLAY) { //显示某路流的画面
      this.handleFramesDisplay(message);
    } else if (type == VHRoomEventType.MESSAGE_VRTC_BIG_SCREEN_SET) { //互动流设置混流大画面
      this.handleBigScreenSet(message);
    }
  }

  private handleChatNicknameEncryption(message: VHIMMessageModel) {
    let enc: VHChatNickNameEncryptionUpdate = message.data as VHChatNickNameEncryptionUpdate
    //聊天禁言是否有感知。如果用户被禁言 mode=1 时为无感知禁言，发送聊天时不调用接口，但是聊天区域显示聊天内容。业务需要用户自行实现
    this.chatNickNameEnc = enc.status;
  }

  private handleBannedModeUpdate(message: VHIMMessageModel) {
    let bannedMode: VHBannedModeUpdate = message.data as VHBannedModeUpdate
    //聊天禁言是否有感知。如果用户被禁言 mode=1 时为无感知禁言，发送聊天时不调用接口，但是聊天区域显示聊天内容。业务需要用户自行实现
    this.chatBannedMode = bannedMode.mode;
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

  private handleLiveOver(message: VHIMMessageModel) {
    this.getUIContext().getPromptAction().showToast({
      message: '直播已结束',
      duration: 4000,
      showMode: promptAction.ToastShowMode.DEFAULT,
      bottom: 80
    });
    this.pageInfos.pop();
  }

  private handleQuestionAnswerOpenClose(type: string, message: VHIMMessageModel) {
    // 问答开启及关闭消息
    let questionAnswerData: VHQuestionAnswerSwitchMsg = message.data as VHQuestionAnswerSwitchMsg;
    if (type == VHRoomEventType.QUESTION_ANSWER_OPEN) {
      this.isShowQuestionAnswer = true;
      this.questionAnswerName = questionAnswerData.name;
      // 增加问答页签
      this.addQaTab();
    }
    if (type == VHRoomEventType.QUESTION_ANSWER_CLOSE) {
      // 清除问答页签
      this.questionAnswerName = '';
      this.deleteQaTab();
    }
    EmitterMessage.handleQuestionAnswerOpenClose(type, message);
  }

  private handleTimer(type: string, message: VHIMMessageModel) {
    if (typeof message.data === 'string') {
      this.timerMsg = JSON.parse(message.data) as VHTimerMsg;
    } else {
      this.timerMsg = message.data as VHTimerMsg;
    }
    this.showTimerDialog = this.timerMsg.is_all_show === '1' ? true : false;
    this.isTimerShow = this.showTimerDialog;
    this.timerTotalSeconds = this.timerMsg.duration.length > 0 ? parseInt(this.timerMsg.duration) : 0;
    EmitterMessage.handleTimer(type, message);
  }

  private handlePauseTimer(type: string, message: VHIMMessageModel) {
    if (typeof message.data === 'string') {
      this.timerPauseMsg = JSON.parse(message.data) as VHTimerPauseMsg;
    } else {
      this.timerPauseMsg = message.data as VHTimerPauseMsg;
    }
    EmitterMessage.handlePauseTimer(type, message);
  }

  private handleDataDownloadUpdateMsg(message: VHIMMessageModel) {
    EmitterMessage.handleDataDownloadUpdateMsg(message);
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
      // 虚拟人数
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
            this.qaTabIndex = index;
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

  private handleAnnouncementMsg(message: VHIMMessageModel) {
    this.isAnnouncementShown = false
    this.dataPreferences?.putSync('isAnnouncementShown', this.isAnnouncementShown);
    this.dataPreferences?.flushSync();
    let announcementData = message.data as VHAnnouncementData
    this.room_id = announcementData.room_join_id
    this.announcement = announcementData
    EmitterMessage.handleAnnouncementMsg(message);
    this.AnnouncementListHttp()
  }

  private handleConnectInvite(message: VHIMMessageModel) {
    let content =message.data as VHMsgData;
    if (content.target_id === this.webinar_info?.join_info?.third_party_user_id){
      EmitterMessage.handleConnectInvite(message);
    }
  }

  private handleConnectAgree(message: VHIMMessageModel) {
    let content =message.data as VHMsgData;
    if (content.target_id === this.webinar_info?.join_info?.third_party_user_id){
      EmitterMessage.handleConnectAgree(message);
    }
  }

  private handleConnectInviteAgree(message: VHIMMessageModel) {
    let content =message.data as VHInviteData;
    if (content.room_join_id === this.webinar_info?.join_info?.third_party_user_id) {
      EmitterMessage.handleConnectInviteAgree(message);
    }
  }

  private handleDisConnectSuccess(message: VHIMMessageModel) {
    let content = message.data as VHMsgData;
    if (content.target_id === this.webinar_info?.join_info?.third_party_user_id) {
      EmitterMessage.handleDisConnectSuccess(message);
      VHRtcSDK.getInstance().unPublish();
      VHRtcSDK.getInstance().stopLocalPreview();
    }
    try {
      // 从后往前遍历数组，找到匹配项并删除
      for (let i = this.streamList.length - 1; i >= 0; i--) {
        // 匹配userId等于目标ID的元素
        if (this.streamList[i].userId === content.target_id) {
          this.streamList.splice(i, 1); // 删除当前索引的元素
        }
      }
    }catch (e) {
    }
  }

  private handleConnectSuccess(message: VHIMMessageModel) {
    let content =message.data as VHMsgData;
    if(this.webinar_info?.join_info?.third_party_user_id === message.sender_id){
      let selfItem = new VHRTCUserInfo(this.userId, false);
      selfItem.nickName = this.webinar_info?.join_info?.nickname!;
      const isUserExists = this.streamList.some(item => item.userId === this.userId);
      if (!isUserExists) {
        this.streamList.push(selfItem);
        let msgData: EmitterMsgData;
        msgData = {
          type: "CreateLocalStream",
          data: ""
        } as EmitterMsgData;
        EmitterUtil.send(msgData);
      }
    }
  }

  private handleMute(message: VHIMMessageModel) {
    let content =message.data as VHMsgData;
    if (content.target_id === this.webinar_info?.join_info?.third_party_user_id) {
      EmitterMessage.handleMute(message);
      if(message.sender_id !== this.webinar_info?.join_info?.third_party_user_id) {
        ToastUtil.showToast('您已被禁言');
      }
      this.streamList.forEach((item: VHRTCUserInfo) => {
        if (item.userId === this.webinar_info?.join_info?.third_party_user_id) {
          item.isMute = true;
          return;
        }
      });
    }
  }

  private handleMuteCancel(message: VHIMMessageModel) {
    let content =message.data as VHMsgData;
    if (content.target_id === this.webinar_info?.join_info?.third_party_user_id) {
      EmitterMessage.handleMuteCancel(message);
      if(message.sender_id !== this.webinar_info?.join_info?.third_party_user_id) {
        ToastUtil.showToast('您已被取消禁言');
      }
      this.streamList.forEach((item: VHRTCUserInfo) => {
        if (item.userId === this.webinar_info?.join_info?.third_party_user_id) {
          item.isMute = false;
          return;
        }
      });
    }
  }

  private handleFramesForbid(message: VHIMMessageModel) {
    let content =message.data as VHMsgData;
    if (content.target_id === this.webinar_info?.join_info?.third_party_user_id) {
      EmitterMessage.handleFramesForbid(message);
      if(message.sender_id !== this.webinar_info?.join_info?.third_party_user_id) {
        ToastUtil.showToast('您已被关闭摄像头');
      }
      this.streamList.forEach((item: VHRTCUserInfo) => {
        if (item.userId === this.webinar_info?.join_info?.third_party_user_id) {
          item.isCamera = false;
          return;
        }
      });
    }
  }

  private handleFramesDisplay(message: VHIMMessageModel) {
    let content =message.data as VHMsgData;
    if (content.target_id === this.webinar_info?.join_info?.third_party_user_id) {
      EmitterMessage.handleFramesDisplay(message);
      if(message.sender_id !== this.webinar_info?.join_info?.third_party_user_id) {
        ToastUtil.showToast('您已被取消关闭摄像头');
      }
      this.streamList.forEach((item: VHRTCUserInfo) => {
        if (item.userId === this.webinar_info?.join_info?.third_party_user_id) {
          item.isCamera = true;
          return;
        }
      });
    }
  }

  private handleBigScreenSet(message: VHIMMessageModel) {
    this.streamList.forEach((item: VHRTCUserInfo) => {
      item.isMain = item.userId === message.sender_id;
    });
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
    if (this.imConnectTimer != -1) {
      clearTimeout(this.imConnectTimer);
      this.imConnectTimer = -1;
    }
  }

  /**
   * 消息服务链接已断开
   * @param im im
   * @param error 错误
   */
  onVHNetworkDisconnect(code: number, message: string): void {
    ToastUtil.showToast("消息服务已断开")
    if (this.imConnectTimer != -1) {
      return;
    }
    //启用定时器进行重连。
    this.imConnectTimer = setTimeout(() => {
      //重连只需要重新调用join方法
      this.imBase?.join(this.webinar_info!);
      this.imConnectTimer = -1;
    }, RECONNECT_TIMEOUT);
  }

  /**
   * 消息服务连接正在重新链接
   * */
  onVHNetworkConnecting(): void {
    ToastUtil.showToast("网络异常，正在重连")
  }

  build() {
    NavDestination() { // 必须作为根组件
      Stack() {
        Flex({ direction: FlexDirection.Column }) {
          Column() {
            if (this.isRTCRoom) {
              VHRTCUserComponent({
                roomId: this.webinar_info?.interact?.room_id,
                streamList: this.streamList,
                userId: this.userId,
                webinarInfo: this.webinar_info
              })
            } else {
              Column()
                .width('100%')
                .height('100%')
                .backgroundColor(Color.Black)
            }
          }
          .width('100%')
          .flexShrink(0)
          .height(this.isLandscapeStart ? '100%' : this.getUIContext().px2vp(this.directHeight))

          if (!this.isLandscapeStart) {
            Column() {
              if (!this.isLandscapeStart) {
                Column() {
                  if (this.announcement.duration >= 0 && !this.isAnnouncementShown) {
                    VHAnnouncementPopup()
                  }
                  if (this.isTimerShow)
                  Column() {
                    Image($r("app.media.timer"))
                      .width(30)
                      .height(30)
                      .onClick(() => {
                        VHSaaSDK.getInstance()
                          .commonConfig(this.webinar_info?.webinar?.id.toString()!,
                            this.webinar_info?.switch_info?.switch_id.toString()!, {
                              onSucceed: (data: VHCommonConfig) => {
                                this.room_tool = data.room_tool as VHRoomToolsStatusData;
                                if (data.timer !== null && data.timer.duration !== undefined) {
                                  let timer = data.timer as VHTimer;
                                  this.initTimer(timer);
                                  this.showTimerDialog = true;
                                }
                              },
                              onFailure: (errorCode: number, errorMsg: string) => {
                                console.log(`${errorCode}:${errorMsg}`)
                                ToastUtil.showToast(errorMsg)
                              }
                            });
                      })
                    Text('计时器')
                      .fontSize(10)
                  }.zIndex(3)
                  .position({ x: 340, y: 455 })

                  Tabs({ barPosition: BarPosition.Start, index: this.currentIndex, controller: this.controller }) {
                    ForEach(this.pageList, (item: VHMenus, index) => {
                      TabContent() {
                        // 根据类型加载不同页面组件
                        if (item.name === '聊天' || item.type == 3) {
                          Column() {
                            Column() {
                              if (this.VHbol) {
                                Column({ space: 4 }) {
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
                            }.width(30)
                            .position({ x: 340, y: 420 })
                            .zIndex(1)
                            ChatComponent({
                              webinars: this.webinar_info,
                              imBase: this.imBase,
                              functionConfig: this.functionConfig,
                              room_tool: this.room_tool,
                              isLive: true,
                              welcomeContent: this.welcomeContent,
                              isSpeak: this.isSpeak
                            })
                              .width('100%')
                              .height('100%')
                          }
                        } else if (item.name === '简介' || item.type == 4) {
                          VHIntroductionView({ introduction: this.webinar_info?.webinar?.introduction }).height('100%')
                            .width('100%')
                        } else if (item.name === '文档' || item.type == 2) {
                          VHDocPageComponent({ webinars: this.webinar_info, playConfig: this.player_config })
                            .width('100%')
                            .height('100%')
                        } else if (item.name === '问答' || item.name === this.questionAnswerName) {
                          QaComponent({
                            webinars: this.webinar_info,
                            functionConfig: this.functionConfig,
                            imBase: this.imBase,
                            room_tool: this.room_tool,
                            isLive: true
                          })
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
          }
        }

        if (this.showTimerDialog && this.isTimerShow) {
          TimerComponent({
            showTimerDialog: this.showTimerDialog,
            isTimerShow: this.isTimerShow,
            totalSeconds: this.timerTotalSeconds
          })
            .width('100%')
            .height('100%')
            .position({ x: 160, y: 500 })
            .zIndex(4)
        }


      }
    }
    .width('100%')
    .height('100%')
    .hideToolBar(true)
    .hideTitleBar(true)
    .hideBackButton(true)
    .id('WatchLivePage')
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack
    })
    .backgroundColor(Color.White)
    .onShown(() => {
      this.hideState = 0;
      console.log(`取消长时任务`)
      BackgroundTaskManager.stopContinuousTask(this.getUIContext().getHostContext() as common.UIAbilityContext)
      this.avSessionManager.stop();
    })
    .onHidden(() => {
      this.hideState = 1;
      console.log(`申请长时任务，避免退到后台导致消息服务中断`)
      // BackgroundTaskManager.startContinuousTask(this.getUIContext().getHostContext() as common.UIAbilityContext);
      this.avSessionManager.start();
    })
    .onWillDisappear(async () => {
      VHBeautyDataService.getInstance().VHShapeViewModel.saveShapeDataPersistently();
      VHBeautyDataService.getInstance().VHFilterViewModel.saveFilterDataPersistently();
    })
  }

}