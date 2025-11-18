import {
  VHIMMessageModel,
  VHIMServer,
  VHPlayerConfig,
  VHPrivacyAgreementInfo,
  VHRoomEventType,
  VHSaaSDK,
  VHUserData,
  VHWatchAuthInfo,
  VHWebinarData
} from "@vhall/vhall_live";
import { systemDateTime } from "@kit.BasicServicesKit";
import { ComponentContent, display, promptAction } from "@kit.ArkUI";
import { PromptActionClass } from "../util/PromptActionClass";
import { createLoadingView } from "../../../../Index";
import { VHWatchVodPlayerComponent } from "../components/player/VHWatchVodPlayerComponent";
import web_webview from '@ohos.web.webview';
import { VHIntroduction } from "../util/VHIntroduction";
import { VHWarmPlayerView } from "../components/player/VHWarmPlayerView";
import { VHLinkTextView } from "../components/watch/VHLinkTextView";
import { ToastUtil } from "../action/ToastUtil";

@Builder
export function ReservationPagePageBuilder(name: string, param: object) {
  ReservationPage({ webinar_info: param['webinars'], player_config: param['player_config'] })
}


class inputParam {
  code: number = 0;
  tips: string = ""
  holder: string = "";
  inputText: string = "";
  join?: (pwd: string) => void;
  privacyAgreement: VHPrivacyAgreementInfo | null = null;
  verify: number = 0;
}

@Builder
function inputPwdDialog(params: inputParam) {
  Column({ space: 20 }) {
    Text(params.tips)
    TextInput({ placeholder: params.holder })
      .fontWeight(FontWeight.Bold)
      .fontSize(10)
      .fontColor(Color.Gray)
      .onChange((value: string, previewText?: PreviewText, options?: TextChangeOptions) => {
        params.inputText = value;
      })
      .width('90%')
      .margin({ bottom: 36 })
      // 设置占位符字体大小、字重等
      .placeholderFont({ size: 12 })
      .placeholderColor('#888888')
    Button('进入直播')
      .onClick(() => {
        if (params.join) {
          params.join(params.inputText)
        }
      })
    if (params.verify === 2 && params.privacyAgreement!.statement_content.length > 0) {
      VHLinkTextView({ privacyAgreementInfo: params.privacyAgreement })
        .width('100%')
        .height('100%')
    }
  }
  .backgroundColor('#F0F0F0')
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
  .width('70%')
  .height('30%')
  .borderRadius(8)
}

@Builder
function enterLiveDialog(params: inputParam) {
  Column({ space: 20 }) {
    Image($r('app.media.icon_start_bro'))
      .width(180)
      .height(180)
    Text('直播已开始，请观看直播吧')
    Button('立即观看')
      .onClick(() => {
        if (params.join) {
          params.join(params.inputText)
        }
      })
  }
  .backgroundColor('#F0F0F0')
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
  .width('70%')
  .height('30%')
  .borderRadius(8)
}

@Preview
@Component
export struct ReservationPage {
  @State pageList: Array<string> = new Array();
  @State currentIndex: number = 0;
  @State reservation_time: string = '距离开播：00天 00时 00分 00秒';
  @State reservation_count: string = '已预约0人';
  private webinar_info?: VHWebinarData;
  private player_config?: VHPlayerConfig;
  private directHeight: number = 0;
  private imBase?: VHIMServer;
  private textData: string = "";
  private contentNode: ComponentContent<Object> | null = null;
  private loadingContentNode: ComponentContent<Object> | null = null;
  controller: TabsController = new TabsController();
  pageInfos: NavPathStack = new NavPathStack() // 导航
  private timer: number = 0; // 定时器ID
  @State reservationState: string = '立即预约'
  @State webinarState: string = '预约'
  private isEnterRoom: boolean = true;
  @State privacyAgreementInfo: VHPrivacyAgreementInfo | null = null;

  aboutToAppear(): void {
    this.pageList.push("简介");
    //预约活动
    if (this.webinar_info?.webinar?.type == 2) {
      this.timer = setInterval(this.calculate, 1000);
    }
    if (this.webinar_info?.join_info?.is_subscribe == 1) {
      this.reservationState = '预约成功'
    }
    this.reservation_count = "已预约" + this.webinar_info?.subscribe?.num.toString() + "人";

    if (this.webinar_info?.webinar?.type == 2) {
      this.webinarState = "预约";
    } else if (this.webinar_info?.webinar?.type == 1) {
      this.webinarState = "直播中";
    }else if(this.webinar_info?.webinar?.type == 5){
      this.webinarState = "回放";
    }
    if (this.webinar_info?.webinar?.verify === 2) {
      // 白名单查询隐私协议
      this.getPrivacyAgreement();
    }
    //连接消息服务，监听开播事件. 如果未进行预约需要集成时自行进行判断是否二次进行验证
    this.imBase = new VHIMServer(this);
    this.imBase.join(this.webinar_info!);
    try {
      const displayInfo = display.getDefaultDisplaySync();
      this.directHeight = (displayInfo.width * 9) / 16;
    } catch (e) {
      console.error('获取屏幕尺寸失败: ' + JSON.stringify(e));
    }
    this.textData = VHIntroduction.getIntroduction(this.webinar_info?.webinar?.introduction ?? '');
  }

  /**
   * 发送心跳，25秒一次
   */
  private calculate = () => {
    let date = new Date(this.webinar_info?.webinar?.start_time!);
    let milliseconds = date.getTime();
    let current = systemDateTime.getTime();
    if (current <= milliseconds) {
      let diff = milliseconds - current;
      // 转换为天、时、分、秒
      let days = Math.floor(diff / (1000 * 60 * 60 * 24));
      let hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      let minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
      let seconds = Math.floor((diff % (1000 * 60)) / 1000);
      this.reservation_time = "距离开播：" + days + " 天 " + hours + " 时 " + minutes + " 分 " + seconds + " 秒 ";
    } else {
      if (this.timer > 0) {
        clearInterval(this.timer);
      }
      this.reservation_time = "距离开播：" + 0 + " 天 " + 0 + " 时 " + 0 + " 分 " + 0 + " 秒 ";
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
   * 注意： 消息中的头像和昵称需要 设置 [VHLiveBase setThirdPartyUserId:@"xxxx" context:@{@"nick_name":@"xxxx",@"avatar":@"xxxx"}]; 才能收到
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
    if (type == VHRoomEventType.LIVE_START) {
      let params = new inputParam();
      params.holder = this.webinar_info?.webinar?.verify_tip!;
      params.join = (pwd: string) => {
        PromptActionClass.closeDialog(); // 调用关闭弹窗方法
        VHSaaSDK.getInstance().getWatchInfo(this.webinar_info?.webinar?.id.toString()!,"", "", this.webinar_info?.join_info?.nickname!, {
            onSucceed: (webinar: VHWebinarData) => {
              this.webinar_info = webinar;
              VHSaaSDK.getInstance().getPlayerConfig(this.webinar_info?.webinar?.id.toString()!, {
                onSucceed: (data: VHPlayerConfig) => {
                  PromptActionClass.closeDialog();
                  //需要断点消息连接
                  this.imBase?.leave();
                  this.isEnterRoom = true;
                  let param: object = new Object()
                  param['webinars'] = this.webinar_info;
                  param['player_config'] = data;
                  this.pageInfos.replacePath({ name: 'WatchLivePage', param: param }, true);
                },
                onFailure: (errorCode, errorMsg) => {
                  PromptActionClass.closeDialog();
                  ToastUtil.showToast("getPlayerConfig:" + errorMsg);
                }
              });
            },
            onFailure: (errorCode, errorMsg) => {
              PromptActionClass.closeDialog();
              this.getUIContext().getPromptAction().showToast({
                message: errorMsg,
                duration: 2000,
                showMode: promptAction.ToastShowMode.DEFAULT,
                bottom: 80
              });
            }
          });
      };
      this.contentNode = new ComponentContent(this.getUIContext(), wrapBuilder(enterLiveDialog), params);
      PromptActionClass.setContext(this.getUIContext());
      PromptActionClass.setContentNode(this.contentNode);
      PromptActionClass.setOptions({
        alignment: DialogAlignment.Center,
        offset: { dx: 0, dy: 50 },
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

  /**
   * 获得隐私协议
   * */
  getPrivacyAgreement(): void {
    VHSaaSDK.getInstance()
      .getPrivacyAgreement(this.webinar_info!.webinar!.id.toString(), "1", "0", "1", {
        onSucceed: (data: VHPrivacyAgreementInfo) => {
          this.privacyAgreementInfo = data as VHPrivacyAgreementInfo;
        },
        onFailure: (errorCode, errorMsg) => {
          console.log("获得隐私协议失败：", errorMsg)
          ToastUtil.showToast("获得隐私协议失败:" + errorMsg);
        }
      });
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
            .fontColor(Color.Red)
            .backgroundColor('#C4C4C4C4')
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
            .fontSize(12)
          Text(this.reservation_count)
            .fontSize(12)
        }
        .width('100%')
        .height('10%')
        .justifyContent(FlexAlign.SpaceEvenly)

        Button(this.reservationState)
          .onClick((event) => {
            //1.活动是预约状态；
            //2.活动是开播状态；
            if (this.webinar_info?.join_info?.is_subscribe == 0) { //如果没有预约成功
              //如果没有验证通过需要先进行验证
              if (this.webinar_info?.join_info?.verified == 0 || this.webinar_info?.webinar?.verify == 1) {
                let params = new inputParam();
                params.holder = this.webinar_info?.webinar?.verify_tip!;
                params.verify = this.webinar_info?.webinar?.verify!;
                if (this.webinar_info?.webinar?.verify_tip.length === 0) {
                  if (this.webinar_info?.webinar?.verify === 1) {
                    params.holder = '请输入密码';
                  }
                }

                params.join = (pwd: string) => {
                  console.log("用户输入内容:", pwd); // 此处处理密码或白名单信息
                  PromptActionClass.closeDialog(); // 调用关闭弹窗方法
                  this.loadingContentNode = new ComponentContent(this.getUIContext(), wrapBuilder(createLoadingView));
                  PromptActionClass.setContext(this.getUIContext());
                  PromptActionClass.setContentNode(this.loadingContentNode);
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
                  PromptActionClass.openDialog();

                  const webinarId = this.webinar_info?.webinar?.id.toString()!;
                  //1 密码进行验证。验证通过则预约成功
                  VHSaaSDK.getInstance()
                    .getWatchAuth(webinarId, "1" , pwd, {
                      onSucceed: (data: VHWatchAuthInfo) => {
                        PromptActionClass.closeDialog();
                        //直播中
                        if (this.webinar_info?.webinar?.type == 1) {
                          let param: object = new Object()
                          param['webinars'] = this.webinar_info;
                          param['player_config'] = this.player_config;
                          //需要断点消息连接
                          this.imBase?.leave();
                          this.isEnterRoom = true;
                          this.pageInfos.replacePath({ name: 'WatchLivePage', param: param }, true);
                        } else {
                          //设置预约成功状态。
                          this.reservationState = '预约成功';
                          if (this.webinar_info?.join_info) {
                            this.webinar_info.join_info.is_subscribe = 1;
                          }
                          if (this.webinar_info?.subscribe) {
                            let count: number = this.webinar_info?.subscribe?.num + 1;
                            this.reservation_count = "已预约" + count.toString() + "人";
                          }

                        }
                      },
                      onFailure: (errorCode, errorMsg) => {
                        PromptActionClass.closeDialog();
                        this.getUIContext().getPromptAction().showToast({
                          message: errorMsg,
                          duration: 2000,
                          showMode: promptAction.ToastShowMode.DEFAULT,
                          bottom: 80
                        });
                      }
                    });
                };
                this.contentNode = new ComponentContent(this.getUIContext(), wrapBuilder(inputPwdDialog), params);
                PromptActionClass.setContext(this.getUIContext());
                PromptActionClass.setContentNode(this.contentNode);
                PromptActionClass.setOptions({
                  alignment: DialogAlignment.Center,
                  offset: { dx: 0, dy: 50 },
                  isModal: true,
                  maskRect: {
                    x: 0,
                    y: 0,
                    width: '100%',
                    height: '100%'
                  }
                });
                PromptActionClass.openDialog();
              } else {
                const webinarId = this.webinar_info?.webinar?.id.toString()!;
                //1 密码，2 白名单 进行验证。验证通过则预约成功
                VHSaaSDK.getInstance().getWatchAuth(webinarId, "0", "", {
                  onSucceed: (data: VHWatchAuthInfo) => {
                    PromptActionClass.closeDialog();
                    //直播中
                    if (this.webinar_info?.webinar?.type == 1) {
                      let param: object = new Object()
                      param['webinars'] = this.webinar_info;
                      param['player_config'] = this.player_config;
                      //需要断点消息连接
                      this.imBase?.leave();
                      this.isEnterRoom = true;
                      this.pageInfos.replacePath({ name: 'WatchLivePage', param: param }, true);
                    } else {
                      //设置预约成功状态。
                      this.reservationState = '预约成功';
                      if (this.webinar_info?.join_info) {
                        this.webinar_info.join_info.is_subscribe = 1;
                      }
                      if (this.webinar_info?.subscribe) {
                        let count: number = this.webinar_info?.subscribe?.num + 1;
                        this.reservation_count = "已预约" + count.toString() + "人";
                      }
                    }
                  },
                  onFailure: (errorCode, errorMsg) => {
                    PromptActionClass.closeDialog();
                    this.getUIContext().getPromptAction().showToast({
                      message: errorMsg,
                      duration: 2000,
                      showMode: promptAction.ToastShowMode.DEFAULT,
                      bottom: 80
                    });
                  }
                });
              }
            }
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
                  RichText(this.textData)
                    .height('90%')
                    .width('90%')
                    .onStart(() => {
                      // 加载开始时触发
                      console.log('富文本开始加载');
                      // 可在此处添加加载动画
                    })
                    .onComplete(() => {
                      // 加载完成时触发
                      console.log('富文本加载完成');
                      // 可在此处隐藏加载动画
                    })


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
    .id('ReservationPage')
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack
    })
  }
}
