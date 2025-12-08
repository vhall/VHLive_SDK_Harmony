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
  VHGoodsListCallback
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

const WINDOW_SYSTEM_BAR: Array<'status' | 'navigation'> = ['navigation', 'status'];
const RECONNECT_TIMEOUT: number = 3000;

@Builder
export function WatchLivePageBuilder(name: string, param: object) {
  WatchLivePage({
    webinar_info: param['webinars'],
    player_config: param['player_config'],
    chat_messages: param['chatMessages']
  })
}

@Entry
@Component
struct WatchLivePage {
  private screenWidth: number = 0;
  private screenHeight: number = 0;
  private directHeight: number = 0;
  private tabHeight: number = 0;
  private webinar_info?: VHWebinarData;
  private player_config?: VHPlayerConfig;
  private chat_messages?: VHChatMessageList;
  private imBase?: VHIMServer;
  private pushCardContentNode: ComponentContent<Object> | null = null;
  private interactAwardContentNode: ComponentContent<Object> | null = null;
  private signServer?: VHSignServer = new VHSignServer(this);
  private AnnouncementServer?: VHAnnouncementServer = new VHAnnouncementServer(this);
  private LotteryServer?: VHLotteryServer = new VHLotteryServer(this);
  @State @Watch('changeOrientation') isLandscapeStart: boolean = false; // 是否横屏状态
  @State @Watch('openSetting') openSettingBtn: boolean = false;
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
  @Provide lotteryPush: VHLotteryResultNoticeModel | null = null
  @Provide lotteryResultNotice: VHLotteryResultNoticeModel | null = null
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
  @Provide CardList: VHCardInfo[] = []

  @Provide card: VHPushScreenCardMsg | null = null;
  @Provide GoodsList: VHPushGoodsChangeData | null = null
  @Provide GoodsListData: VHGoodsInfo[] = []
  @Provide CouponsAvailable: VHCouponInfo[] = []
  @Provide CouponsNotAvailable: VHNotAvailableCouponInfo[] = []
  @Provide CouponsWebinarId: number = 0
  controller: TabsController = new TabsController();
  @State customMenuList: Array<VHMenus> = new Array();
  @State RedEnvelope: VHRedEnvelopeInfo | null = null;
  // @State RedEnvelopeUserList: VHWinningUserListInfo[] = [];
  @State RedEnvelopeData: VHPwdRedEnvelopeData  = new VHPwdRedEnvelopeData;
  @State functionConfig: VHConfigList | null = null; //功能配置
  @State room_tool: VHRoomToolsStatusData | null = null
  @Provide agreement: VHAgreement = new VHAgreement();
  @State SignPush: VHSignData = new VHSignData();
  @State DoingSign: VHDoingSignInfo = new VHDoingSignInfo();
  @Provide signInfo: VHSignInfo = new VHSignInfo();
  @Provide roomId: string = ''
  @State LotteryCarryOut: VHLotteryCarryOut | null = null
  @State LotteryList: VHLotteryList[] = []
  @State LotteryStatus: boolean = false
  @State LotteryStatusEnd: boolean = false
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
  aboutToAppear() {
    this.LotteryCarryOut = null;
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
        this.initRedPacket(this.commonConfig.pwd_red_packet?.status!,this.commonConfig?.pwd_red_packet?.red_packet_uuid!);
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
          if (value.name === '文件下载' && value.id !== undefined) {
            this.menusId = value.id.toString();
          }
          if (value.type === 1) {
            // 自定义菜单
            this.customMenuList.push(value);
          }
          if (value.name != "精彩时刻" && value.name != "概要总结" && value.name != "游戏互动") {
            if (value.status === '1' || (value.type === 1 && value.wap_show === '1') ||
              (value.type !== 5 && value.wap_show === '1')) {
              this.pageList.push(value);
            }
          }
          if (value.name === '聊天') {
            this.welcomeContent = value.welcome_content
            if (data.sign != null && data.sign !== undefined) {
              this.signInfo = data.sign;
              this.room_id = this.webinar_info?.interact?.room_id as string
              const hasAutoSignTimeTtl = data.sign?.auto_sign_time_ttl !== undefined;
              if (hasAutoSignTimeTtl) {
                if (Number(data.sign?.auto_sign_time_ttl) > 0 && data.sign?.is_signed == 0) {
                  this.SignDialog.open()
                  this.signId = Number(data.sign?.id);
                }
              }
            }
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
    //获取公告信息
    this.AnnouncementListHttp()
    this.textData = VHIntroduction.getIntroduction(this.webinar_info?.webinar?.introduction ?? '');
    this.CouponsWebinarId = this.webinar_info?.webinar?.id as number
    //获取问卷列表。问卷具体实现使用webview嵌入实现
    this.QuestionnaireListHttp(false)
    //快问快答也是使用嵌入方式实现
    this.ExamListHttp()
    this.initWatchGift()
    VHSaaSDK.getInstance().getDivertingConfig(this.webinar_info?.webinar?.id.toString()!, {
      onSucceed: (data: VHMarketingPublicAccount) => {
      },

      onFailure: (errorCode: number, errorMsg: string) => {
        ToastUtil.showToast(errorMsg);
      }
    })
    //商品信息
    this.GoodsListHttp()
    this.GoodsActivitySettings()
    this.getCouponsAvailableHttp()
    this.getCouponsNotAvailableHttp()

    this.AgreementMessage()
    this.CardListHttp()
    this.LotteryCarryOutHttp()
    this.LotteryListHttp()
    EmitterUtil.subscribe("sign_kick_out", (msgData: EmitterMsgData) => {
      this.pageInfos.pop();
    });
    let options: preferences.Options = { name: 'isAnnouncementShown' };
    this.dataPreferences =
      preferences.getPreferencesSync(this.getUIContext().getHostContext()?.getApplicationContext(), options);
    this.isAnnouncementShown = this.dataPreferences.getSync("isAnnouncementShown", "") as boolean
    this.chatBannedMode = this.room_tool?.banned_mode as number;
    this.chatNickNameEnc = this.functionConfig?.chat_nickname_encryption as number;

    EmitterUtil.subscribe('sign_kick_out', (msgData: EmitterMsgData) => {
      ToastUtil.showToast("您未进行签到已被踢出")
      this.pageInfos.pop()
    });

    EmitterUtil.subscribe(MsgType.SIGN_CONDITION, (msgData: EmitterMsgData) => {
      ToastUtil.showToast("很遗憾您未参与签到，不能进行抽奖")
      let sign_id = msgData.data as string;

    });
    this.PushProductData = this.dataPreferences.getSync('isPushProductData', '') as VHGoodsInfo[]
  }

  aboutToDisappear(): void {
    if (this.imConnectTimer != -1) {
      clearTimeout(this.imConnectTimer);
      this.imConnectTimer = -1;
    }
    this.imBase?.leave();
    this.VHExamDialog.close()
    this.VHQuestionnaireDialog.close()
    this.SignDialog.close()
    this.signId = 0
    this.VHCardDialog.close()
    this.VHEnvelopeDialog.close()
    this.VHAnnouncementDialog.close()
  }

  private initRedPacket(status:number,uuid:string){
    // 红包状态
    if(status == 1){
      VHSaaSDK.getInstance().getRedPacketStatus(this.webinar_info?.interact?.room_id!,uuid,{
        onSucceed: (data: VHRedPacketStatus) => {
          if(data.is_luck == 2){
            this.RedEnvelope = new VHRedEnvelopeInfo;
            this.RedEnvelope.status = 1;
            this.RedEnvelope.red_code = data.red_code;
            this.RedEnvelopeData.room_id = this.webinar_info?.interact?.room_id!;
            this.RedEnvelopeData.red_packet_uuid = uuid;
            if (this.RedEnvelope != null) {
              this.VHEnvelopeDialog.open()
            }
          }
        },
        onFailure: (errorCode: number, errorMsg: string) => {

        }
      })
    }
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

  initWebinarSurvey() {
    VHSaaSDK.getInstance()
      .getLastPublishWebinarSurvey(this.webinar_info?.interact?.room_id!, this.webinar_info?.switch_info?.start_time!,
        "",0, {
          onSuccess: (data: VHWebinarSurvey) => {
            let extend: VHWebinarSurveyExtend = JSON.parse(data.extend) as VHWebinarSurveyExtend;
            if (extend.mandatory_filling == 1) {
              this.questionnaireList.forEach((value: VHHistoryQuestionnaire, index: number,
                array: VHHistoryQuestionnaire[]) => {
                if (data.question_id == value.question_id && value.is_answered == "0") {
                  //获取url嵌入页面
                  this.SurveyQuestionnaireUrl =
                    VHSurveyInternal.getSurveyUrl(this.webinar_info!, data.question_id.toString());
                  this.openSurveyView();
                }
              })
            }
          },
          onFailure: (errorCode: number, errorMsg: string) => {

          }
        });
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

  SurveyQuestionnaire() {
    this.SurveyQuestionnaireUrl =
      VHSurveyInternal.getSurveyUrl(this.webinar_info!, this.questionnairePush?.questionnaire_id as string
        || this.questionnaireList[0].question_id.toString()) as string
    console.log(`获取问卷调查数据成功： ${this.SurveyQuestionnaireUrl}`)
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

  //观看协议消息
  AgreementMessage() {
    if (this.webinar_info?.webinar != null) {
      let recordId: string = "";
      if (this.webinar_info.webinar.type == 5) {
        recordId = this.webinar_info.record?.record_id!; //回放获取当前回放id
      }
      VHSaaSDK.getInstance().getWatchInfo(this.webinar_info.webinar.id.toString(), recordId, '', '',  {
        onSucceed: (data: VHWebinarData) => {
          this.agreement = data.agreement as VHAgreement;
        },
        onFailure: (errorCode, errorMsg) => {
          ToastUtil.showToast(errorMsg);
        }
      })
    }
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
            } else {
              this.initWebinarSurvey();
            }
            console.log(`获取问卷列表成功： ${JSON.stringify(this.questionnaireList)}`);
          },
          onFailure: (errorCode: number, errorMsg: string) => {
            console.log(`获取问卷列表失败： ${errorMsg}`);
            ToastUtil.showToast(errorMsg);
          }
        })
  }

  // 快问快答列表
  ExamListHttp() {
    VHSaaSDK.getInstance()
      .performExamIn(this.webinar_info?.webinar?.id!, 1, this.webinar_info?.switch_info?.switch_id!, 0, {
        onSucceed: (data) => {
          this.ExamList = data as VHExamList[]
          console.log(`获取快问快答列表成功： ${JSON.stringify(data)}`);
        },
        onFailure: (errorCode, errorMsg) => {
          console.log(`获取快问快答列表失败： ${errorMsg}`);
        }
      })
  }

  //推屏卡片列表
  CardListHttp() {
    VHSaaSDK.getInstance()
      .getCardList(this.webinar_info?.webinar?.id.toString()!, this.webinar_info?.switch_info?.switch_id.toString()!, 1,
        10, {
          onSucceed: (data: VHCardInfo[]) => {
            this.CardList = data as VHCardInfo[]
            console.log(`获取卡片数据成功： ${JSON.stringify(this.CardList)}`)
          },
          onFailure: (errorCode: number, errorMsg: string) => {

          }
        });
  }

  //检查抽奖列表接口
  LotteryListHttp() {
    VHSaaSDK.getInstance().getHistoryLotteryList('',
      {
        onSucceed: (data: VHLotteryList[]) => {
          this.LotteryList = data as VHLotteryList[]
        },
        onFailure: (errorCode: number, errorMsg: string) => {

        }
      });
  }

  //检查抽奖进行中
  LotteryCarryOutHttp() {
    VHSaaSDK.getInstance().lotteryCheck(
      {
        onSucceed: (data) => {
          this.LotteryCarryOut = data
          console.log(`检查抽奖进行中成功： ${JSON.stringify(this.LotteryCarryOut)}`)
        },
        onFailure: (errorCode, errorMsg) => {
          console.log(`检查抽奖进行中失败： ${errorMsg}`)
          ToastUtil.showToast(errorMsg);
        }
      });
  }

  //商品列表
  GoodsListHttp() {
    VHSaaSDK.getInstance().getGoodsList(0,
      {
        onSucceed: (data:VHGoodsInfo[]) => {
          this.GoodsListData = data.filter(item => item.status === 1);
          console.log(`获取商品列表成功： ${JSON.stringify(this.GoodsListData)}`)
        },
        onFailure: (errorCode, errorMsg) => {
          console.log(`获取商品列表失败： ${errorMsg}`)
          ToastUtil.showToast(errorMsg);
        }
      });
  }

  GoodsInfoHttp(url: string) {
    VHSaaSDK.getInstance().getGoodsInfoFromUrl(url,
      {
        onSuccess: (data:VHGoodsInfo[]) => {
          this.PushProductData = data
          this.dataPreferences?.putSync('isPushProductData', this.PushProductData);
          this.dataPreferences?.flushSync();
        },
        onFailure: (errorCode, errorMsg) => {
          ToastUtil.showToast(errorMsg)
        }
      })
  }

  GoodsActivitySettings() {
    VHSaaSDK.getInstance().getGoodsOrderSetting(this.webinar_info?.webinar!.id.toString() as string, '',
      {
        onSucceed: (data:VHGoodsActivitySettings) => {
          this.ActivitySettings = data as VHGoodsActivitySettings
        },
        onFailure: (errorCode, errorMsg) => {
          ToastUtil.showToast(errorMsg);
        }
      });
  }

  //可用优惠卷列表
  getCouponsAvailableHttp() {
    VHSaaSDK.getInstance()
      .getCouponAvailableList(this.webinar_info?.webinar?.id!, {
        onSucceed: (data:VHCouponInfo[]) => {
          this.CouponsAvailable = data
          console.log(`获取可用优惠卷列表成功： ${JSON.stringify(data)}`)
        },
        onFailure: (errorCode, errorMsg) => {
          console.log(`获取可用优惠卷列表失败： ${errorMsg}`)
          ToastUtil.showToast(errorMsg);
        }
      });
  }

  //不可用优惠卷列表
  getCouponsNotAvailableHttp() {
    VHSaaSDK.getInstance()
      .getCouponUnavailableList(this.webinar_info?.webinar?.id!, {
        onSucceed: (data: VHNotAvailableCouponInfo[] ) => {
          this.CouponsNotAvailable = data
          console.log(`获取不可用优惠卷列表成功： ${JSON.stringify(data)}`)
        },
        onFailure: (errorCode, errorMsg) => {
          console.log(`获取不可用优惠卷列表失败： ${errorMsg}`)
          ToastUtil.showToast(errorMsg);
        }
      });
  }

  openSetting() {

  }

  //签到弹窗
  SignDialog = new CustomDialogController({
    builder: VHSignDialog({
      server: this.signServer,
      SignPush: this.SignPush,
    }),
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
  //问卷弹窗
  VHQuestionnaireDialog = new CustomDialogController({
    builder: QuestionnaireBuilder({ webinar: this.webinar_info }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })
  //快问快答弹窗
  VHExamDialog = new CustomDialogController({
    builder: ExamBuilder({ webinar_info: this.webinar_info }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })
  //推屏卡片弹窗
  VHCardDialog = new CustomDialogController({
    builder: VHCardDialog(),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })
  //口令红包弹窗
  VHEnvelopeDialog = new CustomDialogController({
    builder: VHPasswordEnvelopePage({
      RedEnvelope: this.RedEnvelope,
      RedEnvelopeData: this.RedEnvelopeData
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

  /**
   * @description 开始抽奖
   */
  onStartLottery(msgModel?: VHLotteryMessage) {
    console.log('开始抽奖：', msgModel)
  }

  /**
   * @description 抽奖结果
   */
  onEndLottery(msgModel?: VHLotteryMessage) {
    console.log('抽奖结果：', msgModel)
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
    if (
    // type == VHRoomEventType.CUSTOM_MSG||
      type == VHRoomEventType.GOODS_UPDATE_INFO
        || type == VHRoomEventType.PUSH_GOODS_CHANGE
    ) {
      this.handleGoods(type, message);
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
    } else if (type == VHRoomEventType.SIGN_IN_PUSH) { //签到推送
      this.handleSignInPush(message)
    } else if (type == VHRoomEventType.SIGN_END) { //签到结束
      this.handleSignInEnd(message)
    } else if (type == VHRoomEventType.LIVE_OVER) {
      this.handleLiveOver(message);
    } else if (type == VHRoomEventType.BASE_NUM_UPDATE) {
      EmitterMessage.handleBaseUpdateMsg(message);
    } else if (type == VHRoomEventType.LOTTERY_PUSH) {
      this.handleLotteryPush(message);
    } else if (type == VHRoomEventType.LOTTERY_RESULT_NOTICE) {
      this.handleLotteryResultNotice(message);
    } else if (type == VHRoomEventType.QUESTIONNAIRE_PUSH) {
      this.handleQuestionnairePush(message)
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
    } else if (type == VHRoomEventType.PUSH_SCREEN_CARD) {
      PromptActionClass.closeDialog();
      this.handlePushCardMsg(message);
      this.CardListHttp()
    } else if (type == VHRoomEventType.PUSH_SCREEN_CARD_DELETE) {
      this.CardListHttp()
    } else if (type == VHRoomEventType.PAPER_SEND) { //推送快问快答
      this.handleExam(message)
    } else if (type == VHRoomEventType.PAPER_SEND_RANK || type == VHRoomEventType.PAPER_AUTO_SEND_RANK) { //推送 快问快答 公布成绩
      this.handleExamRank(message);
    } else if (type == VHRoomEventType.PAPER_END) { //推送 PAPER_END
      this.handleExamEnd(message);
    } else if (type == VHRoomEventType.WATCH_GIFT_OPEN) { //推送观看有礼
      this.handleWatchGiftOpen(message)
    } else if (type == VHRoomEventType.WATCH_GIFT_END) { //推送观看有礼结束
      this.handleWatchGiftEnd(message)
    } else if (type == VHRoomEventType.PUSH_INTERACT_REWARD_WINNING_NOTICE) { //互动有礼中奖推送消息
      this.handleInteractRewardWinning(message)
    } else if (type == VHRoomEventType.PUSH_PWD_RED_ENVELOPE_OK) {
      this.handlePasswordPack(message)
    } else if (type == VHRoomEventType.PUSH_GOODS_CHANGE) {
      this.handleGoods(type, message);
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

  private handleSignInPush(message: VHIMMessageModel) {
    this.SignPush = message.data as VHSignData
    this.SignDialog.open()
    this.signId = this.SignPush?.sign_id;
  }

  private handleSignInEnd(message: VHIMMessageModel) {
    let msg: VHSignData = message.data as VHSignData
    //如果结束签到时，当前用户没有签到，若开启踢出则踢出直播间
    if (msg.sign_id == this.SignPush.sign_id && this.SignPush.auto_kick_unsigned == 1 && this.signTime > 0) {
      this.pageInfos.pop();
      ToastUtil.showToast("您未进行签到已被踢出")
    }
    this.SignDialog.close()
    this.signId = 0;
  }

  private handlePasswordPack(message: VHIMMessageModel) {
    this.VHEnvelopeDialog.close()
    const RedEnvelope = message.data as VHPwdRedEnvelopeData;
    this.RedEnvelopeData = RedEnvelope
    this.initRedPacket(1,RedEnvelope.red_packet_uuid);
  }

  private handleInteractRewardWinning(message: VHIMMessageModel) {
    // 创建参数对象
    const params = new InteractAwardParams(message.data as VHInteractRewardWinning, this.webinar_info!);
    this.interactAwardContentNode =
      new ComponentContent(this.getUIContext(), wrapBuilder(createInteractAwardGiftView), params);
    PromptActionClass.setContext(this.getUIContext());
    PromptActionClass.setContentNode(this.interactAwardContentNode);
    if (params.gift.display_of_results == 0) {
      PromptActionClass.setOptions({
        alignment: DialogAlignment.Center,
        isModal: true,
        maskRect: {
          x: 0,
          y: 0,
          width: '100%',
          height: '100%'
        }
      });
    }
    PromptActionClass.openDialog();
  }

  private handleWatchGift(gift: VHWatchGiftInfo) {
    // 创建参数对象
    const params = new WatchGiftParams(gift, this.webinar_info!);
    this.pushCardContentNode = new ComponentContent(this.getUIContext(), wrapBuilder(createWatchGiftView), params);
    PromptActionClass.setContext(this.getUIContext());
    PromptActionClass.setContentNode(this.pushCardContentNode);
    if (params.gift.display_of_results == 0) {
      PromptActionClass.setOptions({
        alignment: DialogAlignment.Center,
        isModal: true,
        maskRect: {
          x: 0,
          y: 0,
          width: '100%',
          height: '100%'
        }
      });
    }
    PromptActionClass.openDialog();
  }

  private handleWatchGiftOpen(message: VHIMMessageModel) {
    PromptActionClass.closeDialog();
    //参与观看有礼 需要先调用此接口，表示开始参与，否则会提示参与时长不够
    VHSaaSDK.getInstance().getWatchGiftLastInfo(this.webinar_info?.webinar?.id!, {
      // 成功
      onSucceed: (data: VHWatchGiftInfo | null) => {
        if (data == null) {
          //无观看有礼
          return;
        }
        //进入直播间如果正在推送且没有到达观看限制，则显示观看有礼信息
        if (data.state == 1 && data?.watch_minute! * 60 > data?.online_duration!) {
          this.handleWatchGift(data);
        }
      },
      // 失败
      onFailure: (errorCode: number, errorMsg: string) => {
        ToastUtil.showToast(errorMsg);
      }
    })
  }

  private initWatchGift() {
    VHSaaSDK.getInstance().getWatchGiftLastInfo(this.webinar_info?.webinar?.id!, {
      // 成功
      onSucceed: (data: VHWatchGiftInfo | null) => {
        if (data == null) {
          return;
        }
        //进入直播间如果正在推送且没有到达观看限制，则显示观看有礼信息
        if (data.state == 1 && data?.watch_minute! * 60 > data?.online_duration!) {
          this.handleWatchGift(data);
        }
      },
      // 失败
      onFailure: (errorCode: number, errorMsg: string) => {
        ToastUtil.showToast(errorMsg);
      }
    })
  }

  private handleWatchGiftEnd(message: VHIMMessageModel) {
    // let watchGift: VHWatchGiftEndMsg = message.data as VHWatchGiftEndMsg;
    PromptActionClass.closeDialog();
  }

  private handlePushCardMsg(message: VHIMMessageModel) {
    this.VHCardDialog.close()
    let card: VHPushScreenCardMsg = message.data as VHPushScreenCardMsg;
    this.card = card;
    // 创建参数对象
    const params = new PushCardParams(card.card_info, this.webinar_info!);
    this.pushCardContentNode = new ComponentContent(this.getUIContext(), wrapBuilder(createPushCardView), params);
    PromptActionClass.setContext(this.getUIContext());
    PromptActionClass.setContentNode(this.pushCardContentNode);
    if (card.card_info.show_mode == 0) {
      PromptActionClass.setOptions({
        alignment: DialogAlignment.Center,
        isModal: true,
        maskRect: {
          x: 0,
          y: 0,
          width: '100%',
          height: '100%'
        }
      });
    } else if (card.card_info.show_mode == 1) {
      if (card.card_info.timer_enable == 1 && card.card_info.href_enable == 1) {
        PromptActionClass.setOptions({
          alignment: DialogAlignment.BottomEnd,
          isModal: false,
          offset: { dx: -10, dy: -170 },
          maskRect: {
            x: 0,
            y: 0,
            width: '100%',
            height: '100%'
          }
        });
      } else if (card.card_info.timer_enable == 1 || card.card_info.href_enable == 1) {
        PromptActionClass.setOptions({
          alignment: DialogAlignment.BottomEnd,
          isModal: false,
          offset: { dx: -10, dy: -120 },
          maskRect: {
            x: 0,
            y: 0,
            width: '100%',
            height: '100%'
          }
        });
      } else {
        PromptActionClass.setOptions({
          alignment: DialogAlignment.BottomEnd,
          isModal: false,
          offset: { dx: -10, dy: -90 },
          maskRect: {
            x: 0,
            y: 0,
            width: '100%',
            height: '100%'
          }
        });
      }

    }
    PromptActionClass.openDialog();
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

  private handleLotteryPush(message: VHIMMessageModel) {
    this.lotteryPush = message.data as VHLotteryResultNoticeModel
    this.lotteryResultNotice = null;
    this.LotteryCarryOutHttp()
    this.LotteryListHttp()
    this.closeLotteryListDialog = false
    this.LotteryStatusEnd = false
  }

  private handleLotteryResultNotice(message: VHIMMessageModel) {
    this.lotteryResultNotice = message.data as VHLotteryResultNoticeModel
    this.LotteryCarryOutHttp()
    this.LotteryListHttp()
    this.LotteryStatus = false
  }

  private handleQuestionnairePush(message: VHIMMessageModel) {
    this.VHQuestionnaireDialog.close()
    this.QuestionnaireListHttp(false)
    this.questionnairePush = message.data as VHQuestionnairePushModel
    this.SurveyQuestionnaire()
    setTimeout(() => {
      const isQuestionnaire: VHHistoryQuestionnaire = this.questionnaireList.find(item => {
        return item.question_id.toString() === this.questionnairePush?.questionnaire_id
      }) as VHHistoryQuestionnaire

      // let param: object = new Object()
      // param['questionnaireUrl'] = this.SurveyQuestionnaireUrl
      // param['webinar_info'] = this.webinar_info
      // param['questionnaireList'] = this.questionnaireList
      // const pathInfo = new NavPathInfo(
      //   'QuestionnairePage', // 页面名称
      //   param, // 传递给子页面的参数
      //   undefined,
      //   true
      // );
      // // 配置导航选项
      // const options: NavigationOptions = {
      //   launchMode: LaunchMode.NEW_INSTANCE // 关键参数
      // };
      // let count: Array<number> = this.pageInfos.getIndexByName('QuestionnairePage')
      // if (count.length > 0) {
      //   this.pageInfos.pop();
      // }
      // this.pageInfos.pushPath(pathInfo, options);
      // if (isQuestionnaire.is_answered == '0') {
      //
      // }
      this.openSurveyView();
    }, 500)

  }

  private openSurveyView() {
    let param: object = new Object()
    param['questionnaireUrl'] = this.SurveyQuestionnaireUrl
    param['webinar_info'] = this.webinar_info
    param['questionnaireList'] = this.questionnaireList
    const pathInfo = new NavPathInfo(
      'QuestionnairePage', // 页面名称
      param, // 传递给子页面的参数
      undefined,
      true
    );
    // 配置导航选项
    const options: NavigationOptions = {
      launchMode: LaunchMode.NEW_INSTANCE // 关键参数
    };
    let count: Array<number> = this.pageInfos.getIndexByName('QuestionnairePage')
    if (count.length > 0) {
      this.pageInfos.pop();
    }
    this.pageInfos.pushPath(pathInfo, options);
  }

  private handleExam(message: VHIMMessageModel) {
    this.VHExamDialog.close()
    this.examData = message.data as VHExaminationModel
    //观看时长需要用户自行进行统计。满足条件后才可以进行答题
    if (this.examData.answer_condition?.viewing_minutes! > 0) {
      //需要自行实现。
    }
    this.ExamListHttp()
    this.VHExam(this.examData.paper_id, this.examData.type)
    let param: object = new Object()
    param['ExamUrl'] = this.ExamUrl
    const pathInfo = new NavPathInfo(
      'ExamPage', // 页面名称
      param, // 传递给子页面的参数
      undefined,
      true
    );
    this.pageInfos.pushPath(pathInfo, true);
  }

  private handleExamEnd(message: VHIMMessageModel) {
    this.VHExamDialog.close()
    this.examData = message.data as VHExaminationModel
    VHSaaSDK.getInstance()
      .setExamUserAnswerStatus(this.examData.paper_id, this.webinar_info?.webinar?.id!,
        this.webinar_info?.switch_info?.switch_id!, {
          onSucceed: (data: VHExamUserAnswerStatus) => {
            ToastUtil.showToast('data')
          },
          onFailure: (errorCode: number, errorMsg: string) => {
            ToastUtil.showToast(errorMsg)
          }
        });

    this.pageInfos.removeByName("ExamPage")
    ToastUtil.showToast("答题已结束")
  }

  private handleExamRank(message: VHIMMessageModel) {
    let msg: VHExamRank = message.data as VHExamRank
    let msgData: EmitterMsgData;
    msgData = {
      type: VHRoomEventType.PAPER_SEND_RANK, // 消息类型
      data: msg
    } as EmitterMsgData;
    // 通过EmitterUtil发送
    EmitterUtil.send(msgData);
  }

  private handleGoods(type: string, message: VHIMMessageModel) {
    this.GoodsList = message.data as VHPushGoodsChangeData
    if(this.GoodsList.cdn_url.length > 0){
      this.GoodsInfoHttp(this.GoodsList.cdn_url)
    }
    //建议当cdn_url不为空时，获取商品列表也使用getGoodsInfoFromUrl进行获取。
    this.GoodsListHttp()
    this.getCouponsAvailableHttp()
    this.getCouponsNotAvailableHttp()
    this.GoodsActivitySettings()
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
            VHWatchLivePlayerComponent({
              webinars: this.webinar_info,
              playerConfig: this.player_config,
              isLandscapeStart: this.isLandscapeStart,
              openSettingBtn: this.openSettingBtn,
              hideState:this.hideState
            })
              .width('100%')
              .height('100%')
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
                  if (this.GoodsListData.length > 0) {
                    if (this.GoodsListData[0].push_status == 1) {
                      FloatingWindow({
                        Floating: true,
                        GoodsListData: this.GoodsListData,
                        // ActivitySettings: this.GoodsList,
                        webinars: this.webinar_info
                      })
                    } else {
                      FloatingWindow({
                        Floating: false,
                        GoodsListData: this.GoodsListData,
                        // ActivitySettings: this.ActivitySettings,
                        webinars: this.webinar_info
                      })
                    }
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
                                          if(this.lotteryResultNotice == null){
                                            this.lotteryResultNotice = new VHLotteryResultNoticeModel;
                                            this.lotteryResultNotice.room_id = this.webinar_info?.interact?.room_id!;
                                            this.lotteryResultNotice.lottery_id = this.LotteryList[0].id;
                                            this.lotteryResultNotice.receive_award_way = this.LotteryList[0].receive_award_way;
                                            this.lotteryResultNotice.lottery_type = this.LotteryList[0].lottery_type;
                                          }
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
                                      if (this.examData != null || this.ExamList.length != 0) {
                                        VHSaaSDK.getInstance()
                                          .performExamIn(this.webinar_info?.webinar?.id!, 1,
                                            this.webinar_info?.switch_info?.switch_id!, 0, {
                                              onSucceed: (data) => {
                                                this.ExamList = data
                                                this.VHExamDialog.open()
                                                this.VHbol = !this.VHbol
                                                console.log(`获取快问快答列表成功： ${JSON.stringify(data)}`);
                                              },
                                              onFailure: (errorCode, errorMsg) => {
                                                console.log(`获取快问快答列表失败： ${errorMsg}`);
                                              }
                                            })
                                      } else {
                                        ToastUtil.showToast("没有更多数据");
                                      }
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
                            }.width(30)
                            .position({ x: 340, y: 420 })
                            .zIndex(1)

                            ChatComponent({
                              webinars: this.webinar_info,
                              imBase: this.imBase,
                              functionConfig: this.functionConfig,
                              room_tool: this.room_tool,
                              isLive: true,
                              welcomeContent: this.welcomeContent
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
                        } else if (item.name === '私聊') {
                          PrivateChatComponent({
                            webinars: this.webinar_info,
                            functionConfig: this.functionConfig,
                            room_tool: this.room_tool,
                            imBase: this.imBase
                          })
                            .width('100%')
                            .height('100%')
                        } else if (item.name === '文件下载') {
                          VHDownLoadFileComponent({ webinars: this.webinar_info, menusId: this.menusId })
                            .width('100%')
                            .height('100%')
                        } else if (item.name === '商品') {
                          if (this.GoodsListData.length != 0) {
                            VHGoodsComponent({ webinars: this.webinar_info, PushProductData: this.PushProductData })
                              .width('100%')
                              .height('100%')
                          }
                        } else if (item.name === '推荐') {
                          VHAdvComponent({ webinars: this.webinar_info })
                            .width('100%')
                            .height('100%')
                        } else if (this.customMenuList.find((menu) => menu.name === item.name)) {
                          VHCustomMenu({ menu_id: item.id.toString(), webinars: this.webinar_info,enableInviteCard: Number(this.commonConfig.invite_card) })
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

        if (this.lotteryPush != null || this.LotteryStatus) {
          LotteryDialog({
            LotteryCarryOut: this.LotteryCarryOut as VHLotteryCarryOut,
            room_id: this.webinar_info?.interact?.room_id,
            LotteryStatus: this.LotteryStatus,
          })
        }
        if (this.lotteryResultNotice != null || this.LotteryStatusEnd) {
          LotteryDetails(
            {
              user_id: this.webinar_info?.join_info?.user_id,
              room_id: this.webinar_info?.interact?.room_id,
              nickname: this.webinar_info?.join_info?.nickname,
              LotteryList: this.LotteryList,
              LotteryStatusEnd: this.LotteryStatusEnd,
            }
          )
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
    })
    .onHidden(() => {
      this.hideState = 1;
      console.log(`申请长时任务，避免退到后台导致消息服务中断`)
      BackgroundTaskManager.startContinuousTask(this.getUIContext().getHostContext() as common.UIAbilityContext);
    })
  }
}