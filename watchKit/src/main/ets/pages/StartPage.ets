import {
  VHPrivacyAgreementInfo,
  VHAgreementModel,
  VHIMMessageModel,
  VHIMServer,
  VHPlayerConfig,
  VHRoomEventType,
  VHSaaSDK,
  VHUserData,
  VHWatchAuthInfo,
  VHWebinarData
} from "@vhall/vhall_live";
import { BusinessError, systemDateTime } from "@kit.BasicServicesKit";
import { ComponentContent, display, promptAction } from "@kit.ArkUI";
import { PromptActionClass } from "../util/PromptActionClass";
import { createLoadingView, EmitterMsgData, EmitterUtil } from "../../../../Index";
import { VHWatchVodPlayerComponent } from "../components/player/VHWatchVodPlayerComponent";
import web_webview from '@ohos.web.webview';
import { VHIntroduction } from "../util/VHIntroduction";
import { VHWarmPlayerView } from "../components/player/VHWarmPlayerView";
import { VHLinkTextView } from "../components/watch/VHLinkTextView";
import { ToastUtil } from "../action/ToastUtil";
import { common, Want } from "@kit.AbilityKit";
import { StartDialogPageBuilder } from "../components/Start/StartDialogPage";
import { VHIntroductionView } from "../components/introduction/VHIntroductionView";
import { ForcedLoginPageBuilder } from "../components/Start/ForcedLogin";

@Builder
export function StartPageBuilder(name: string, param: object) {
  StartPage({
    webinar_info: param['webinars'],
    player_config: param['player_config'],
    webinar_id: param['webinar_id']
  })
}


@Preview
@Component
export struct StartPage {
  @State pageList: Array<string> = new Array();
  @State currentIndex: number = 0;
  @State reservation_time: string = '距离开播：00天 00时 00分 00秒';
  private webinar_info?: VHWebinarData;
  private player_config?: VHPlayerConfig;
  private directHeight: number = 0;
  private imBase?: VHIMServer;

  private webinar_id: string = ''
  private textData: string = "";
  controller: TabsController = new TabsController();
  pageInfos: NavPathStack = new NavPathStack() // 导航
  private timer: number = 0; // 定时器ID
  @State reservationState: string = '观看验证'
  @State webinarState: string = '直播中'
  private isEnterRoom: boolean = true;
  private contentNode: ComponentContent<Object> | null = null;
  @State privacyAgreementInfo: VHPrivacyAgreementInfo | null = null;
  @State agree: VHAgreementModel = new VHAgreementModel

  aboutToAppear(): void {
    this.pageList.push("简介");
    if (this.webinar_info?.webinar?.type == 1) {

    }

    if (this.webinar_info?.webinar?.type == 1) {
      this.webinarState = "直播中";
      this.timer = setInterval(this.calculate, 1000);
    }
    else if(this.webinar_info?.webinar?.type == 5){
      this.webinarState = "回放";
    }
    else if (this.webinar_info?.webinar?.type == 2) {
      this.webinarState = "预约";
    }
    try {
      const displayInfo = display.getDefaultDisplaySync();
      this.directHeight = (displayInfo.width * 9) / 16;
    } catch (e) {
      console.error('获取屏幕尺寸失败: ' + JSON.stringify(e));
    }
    this.textData = VHIntroduction.getIntroduction(this.webinar_info?.webinar?.introduction ?? '');
    EmitterUtil.subscribe("toLivePage", (msgData: EmitterMsgData) => {

      let param: object = new Object()
      param['webinars'] = this.webinar_info
      param['player_config'] = this.player_config;
      this.pageInfos.replacePath({ name: 'WatchLivePage', param: param }, true);
    });
  }


  ForcedLoginDialog(param: object) {
    this.contentNode = new ComponentContent(this.getUIContext(), wrapBuilder(ForcedLoginPageBuilder), param);
    PromptActionClass.setContext(this.getUIContext());
    PromptActionClass.setContentNode(this.contentNode);
    PromptActionClass.setOptions({
      alignment: DialogAlignment.Center,
      offset: { dx: 0, dy: 0 },
      isModal: true,
      maskRect: {
        x: 0,
        y: 0,
        width: '100%',
        height: '100%'
      }
    });
    PromptActionClass.openDialog();
  }

  /**
   * 发送心跳，25秒一次
   */
  private calculate = () => {
    let date = new Date(this.webinar_info?.webinar?.actual_start_time!);
    let milliseconds = date.getTime();
    let current = systemDateTime.getTime();
    if (current >= milliseconds) {
      let diff = current - milliseconds;
      // 转换为天、时、分、秒
      let days = Math.floor(diff / (1000 * 60 * 60 * 24));
      let hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      let minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
      let seconds = Math.floor((diff % (1000 * 60)) / 1000);
      this.reservation_time = "已开播：" + days + " 天 " + hours + " 时 " + minutes + " 分 " + seconds + " 秒 ";
    } else {
      if (this.timer > 0) {
        clearInterval(this.timer);
      }
      this.reservation_time = "已开播：" + 0 + " 天 " + 0 + " 时 " + 0 + " 分 " + 0 + " 秒 ";
    }
  }

  aboutToDisappear(): void {
    if (!this.isEnterRoom) {
      this.imBase?.leave();
    }
  }

  /**
   * 接收聊天消息
   * @param im im
   * @param message chat消息  data中聊天消息格式  说明详见本文件底部注释
   */
  imReceiveChatMessage(type: string, message: VHIMMessageModel) {

  }

  /**
   * 接收上下线消息
   * @param im im
   * @param message 消息
   */
  imReceiveOnlineMessage(type: string, message: VHUserData) {

  }

  /**
   * 接收自定义消息
   * @param im im
   * @param message 自定义消息
   */
  imReceiveCustomMessage(type: string, message: VHIMMessageModel) {

  }

  /**
   * 接收房间消息
   * @param im im
   * @param message room消息
   */
  imReceiveRoomMessage(type: string, message: VHIMMessageModel) {
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

  agreementHttp() {
    if (this.webinar_info?.webinar?.id != undefined) {
      VHSaaSDK.getInstance().getAgreement(this.webinar_info?.webinar?.id.toString(), '', '', '', {
        onSucceed: (data) => {
          this.agree = data as VHAgreementModel;
          console.log('获取协议成功：' + JSON.stringify(this.agree));
        },
        onFailure: (code, message) => {
          console.log('获取协议失败：' + message);
          ToastUtil.showToast(message);
        }
      })
    }

  }

  agreementDialog() {
    let param: object = new Object()
    param['agree'] = this.agree
    param['webinar_info'] = this.webinar_info;
    param['webinar_id'] = this.webinar_id;
    this.contentNode =
      new ComponentContent(this.getUIContext(), wrapBuilder(StartDialogPageBuilder), param);
    PromptActionClass.setContext(this.getUIContext());
    PromptActionClass.setContentNode(this.contentNode);
    PromptActionClass.setOptions({
      alignment: DialogAlignment.Center,
      maskRect: {
        x: 0,
        y: 0,
        width: '100%',
        height: '100%'
      }
    });
    PromptActionClass.openDialog();
  }

  build() {
    NavDestination() { // 必须作为根组件
      Flex({ direction: FlexDirection.Column }) {
        Stack({ alignContent: Alignment.TopStart }) {
          Image(this.webinar_info?.webinar?.img_url)
            .width('100%')
            .height('100%')
            .zIndex(0)

          Text(this.webinarState)
            .padding(10)
            .borderRadius(10)
            .fontColor(Color.White)
            .zIndex(1)

          if (this.webinar_info && this.webinar_info.warm_up) {
            if (this.webinar_info.warm_up?.warmup_img_url.length > 0) {
              Column() {
                VHWarmPlayerView({ webinars: this.webinar_info, player_config: this.player_config })
                  .width('100%')
                  .height('100%')
              }
              .width('100%')
              .flexShrink(0)
              .zIndex(2)
              .height('100%')
            }
          }
        }
        .height(this.getUIContext().px2vp(this.directHeight))
        .width('100%')


        Row({ space: 10 }) {
          Text(this.reservation_time)
            .fontSize(16)
        }
        .width('100%')
        .height('10%')
        .justifyContent(FlexAlign.SpaceEvenly)

        Button(this.reservationState)
          .onClick((event) => {
            this.agreementHttp()
            //延迟0.5秒后在执行
            setTimeout(() => {
              this.agreementDialog()
              // setTimeout(() => {
              //   this.pageInfos.pop()
              // }, 20000)
            }, 500)
            //弹出协议
            // ToastUtil.showToast("请先阅读并同意隐私协议")
          })
          .backgroundColor(Color.Red)
          .alignSelf(ItemAlign.Center)
          .width(100)
          .height(40)

        Column() {
          Tabs({
            barPosition: BarPosition.Start,
            index: this.currentIndex,
            controller: this.controller
          }) {
            ForEach(this.pageList, (item: String, index) => {
              TabContent() {
                // 根据类型加载不同页面组件
                if (item === '简介') {
                  VHIntroductionView({introduction:this.textData})
                    .width('100%')
                    .height('100%')

                }
              }.tabBar(item as string)
            })
          }
          .barHeight(40)
          .height('100%')
          .width('100%')
        }.backgroundColor(Color.White)
        .width('100%')
        .height('50%')
      }
    }
    .width('100%')
    .height('100%')
    .hideToolBar(true)
    .hideTitleBar(true)
    .hideBackButton(true)
    .id('StartPage')
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack
    })
  }
}