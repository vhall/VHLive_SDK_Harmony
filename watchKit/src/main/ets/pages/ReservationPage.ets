import {
  PrivacyAgreementInfo,
  VHAgreement,
  VHCommonConfig,
  VHConfigList,
  VHIMMessageModel,
  VHIMServer,
  VHMenus,
  VHPlayerConfig,
  VHRoomEventType,
  VHSaaSDK,
  VHUserData,
  VHWatchAuthInfo,
  VHWatchVodPlayerView,
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
import { VHCustomMenu } from "../components/menu/VHCustomMenu";
import { VHIntroductionView } from "../components/introduction/VHIntroductionView";
import { ToastUtil } from "../action/ToastUtil";

@Builder
export function ReservationPagePageBuilder(name: string, param: object) {
  ReservationPage({
    webinar_info: param['webinars'],
    player_config: param['player_config'],
    webinar_id: param['webinar_id']
  })
}


class inputParam {
  code: number = 0;
  tips: string = ""
  holder: string = "";
  inputText: string = "";
  join?: (pwd: string) => void;
  privacyAgreement: PrivacyAgreementInfo | null = null;
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
  @State pageList: Array<VHMenus> = new Array();
  @State currentIndex: number = 0;
  @State reservation_time: string = '距离开播：00天 00时 00分 00秒';
  @State reservation_count: string = '已预约0人';
  private webinar_info?: VHWebinarData;
  private player_config?: VHPlayerConfig;
  private directHeight: number = 0;
  private imBase?: VHIMServer;
  private textData: string = "";
  private webinar_id: string = ''
  @State customMenuList: Array<VHMenus> = new Array();
  private contentNode: ComponentContent<Object> | null = null;
  private loadingContentNode: ComponentContent<Object> | null = null;
  controller: TabsController = new TabsController();
  pageInfos: NavPathStack = new NavPathStack() // 导航
  private timer: number = 0; // 定时器ID
  @State reservationState: string = '立即预约'
  @State webinarState: string = '预约'
  @State functionConfig: VHConfigList | null = null; //功能配置
  private isEnterRoom: boolean = false;
  @State privacyAgreementInfo: PrivacyAgreementInfo | null = null;
  @State agreement: VHAgreement = new VHAgreement();
  @State commonConfig: VHCommonConfig = new VHCommonConfig;
  aboutToAppear(): void {
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
      this.reservationState = '立即观看'
    } else if (this.webinar_info?.webinar?.type == 5) {
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


    let switchId: string = this.webinar_info?.switch_info?.switch_id.toString() as string;
    VHSaaSDK.getInstance().commonConfig(this.webinar_info?.webinar?.id.toString()!, switchId, {
      onSucceed: (data: VHCommonConfig) => {
        this.commonConfig = data;
        data.menus?.forEach((value: VHMenus, index: number, array: VHMenus[]) => {
          if (value.type === 1) {
            // 自定义菜单
            this.customMenuList.push(value);
            this.pageList.push(value);
          }
          if (value.name == "简介") {
            this.pageList.push(value);

          }
        })
      },
      onFailure: (errorCode: number, errorMsg: string) => {
        console.log(`${errorCode}:${errorMsg}`)
        ToastUtil.showToast(errorMsg);
      }
    });

  }

  private isEnablePlay(advance_play_time: number): boolean {
    if (advance_play_time == 0) {
      return true;
    }
    let date = new Date(this.webinar_info?.webinar?.start_time!);
    let milliseconds = date.getTime();
    let current = systemDateTime.getTime();
    //未到开播时间
    if (current <= milliseconds) {
      let diff = milliseconds - current;
      // 暖场视频播放
      if (diff / 1000 < advance_play_time) {
        return true;
      } else {
        return false;
      }
    }
    //已经超过开播时间不播放暖场视频
    return false;
  }

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
        VHSaaSDK.getInstance()
          .initWatch(this.webinar_info?.webinar?.id.toString()!,"", "", this.webinar_info?.join_info?.nickname!, {
            onSucceed: (webinar: VHWebinarData) => {
              this.webinar_info = webinar;
              VHSaaSDK.getInstance().getPlayerConfig(this.webinar_info?.webinar?.id.toString()!, {
                onSucceed: (data: VHPlayerConfig) => {
                  PromptActionClass.closeDialog();
                  this.imBase?.leave();
                  this.isEnterRoom = true;
                  let param: object = new Object()
                  param['webinars'] = this.webinar_info;
                  param['player_config'] = data;
                  param['webinar_id'] = this.webinar_id;
                  VHSaaSDK.getInstance()
                    .doInitWatch(this.webinar_info?.webinar?.id.toString() as string, '', '', '', '', true, {
                      onSucceed: (data: VHWebinarData) => {
                        this.agreement = data.agreement as VHAgreement;
                        //判断是否开启
                        if (this.agreement.is_open == 1 && this.agreement.is_agree == 0) {
                          this.pageInfos.pushPath({ name: 'StartPage', param: param }, true);
                        } else {
                          this.pageInfos.pushPath({ name: 'WatchLivePage', param: param }, true);
                        }
                      },
                      onFailure: (errorCode, errorMsg) => {
                        ToastUtil.showToast(errorMsg);
                      }
                    })
                  // this.pageInfos.replacePath({ name: 'WatchLivePage', param: param }, true);
                },
                onFailure: (errorCode, errorMsg) => {
                  PromptActionClass.closeDialog();
                  ToastUtil.showToast(errorMsg);
                }
              });
            },
            onFailure: (errorCode, errorMsg) => {
              PromptActionClass.closeDialog();
              ToastUtil.showToast(errorMsg);
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
        onSucceed: (data: PrivacyAgreementInfo) => {
          this.privacyAgreementInfo = data as PrivacyAgreementInfo;
        },
        onFailure: (errorCode, errorMsg) => {
          console.log("获得隐私协议失败：", errorMsg)
        }
      });
  }

  build() {
    NavDestination() { // 必须作为根组件
      Flex({ direction: FlexDirection.Column }) {
        Stack({ alignContent: Alignment.TopStart }) {
          if(this.webinar_info?.warm_up?.warmup_img_url && this.webinar_info?.warm_up?.warmup_img_url.length > 0){
            Image(this.webinar_info?.warm_up?.warmup_img_url)
              .width('100%')
              .height('100%')
              .zIndex(0)
          }else{
            Image(this.webinar_info?.webinar?.img_url)
              .width('100%')
              .height('100%')
              .zIndex(0)
          }


          Text(this.webinarState)
            .padding(10)
            .borderRadius(10)
            .fontColor(Color.Red)
            .backgroundColor('#C4C4C4C4')
            .zIndex(1)


          if (this.webinar_info && this.webinar_info.warm_up) {
            if (this.isEnablePlay(this.webinar_info.warm_up.advance_play_time)) {
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
          if (this.webinar_info?.subscribe?.show) {
            Text(this.reservation_count)
              .fontSize(12)
          }
        }
        .width('100%')
        .height('10%')
        .justifyContent(FlexAlign.SpaceEvenly)

        Button(this.reservationState)
          .onClick((event) => {
            //示例展示在活动预约状态下，如果开启了密码和白名单验证。用户可以自行判断是否在其他状态填写观看限制
            if (this.webinar_info?.join_info?.is_subscribe == 0) { //如果没有预约成功
              //如果配置了密码没有通过密码验证
              if (this.webinar_info?.webinar?.verify == 1 && this.webinar_info?.join_info?.verified == 0) {
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
                  PromptActionClass.closeDialog();
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
                    .checkWatchAuth(webinarId, "1", pwd, {
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
                          if(this.webinar_info?.webinar?.type == 5){
                            this.pageInfos.pop();
                            //回到进入直播页面进行观看
                          }else{
                            this.reservationState = '预约成功';
                            if (this.webinar_info?.join_info) {
                              this.webinar_info.join_info.is_subscribe = 1;
                            }
                            if (this.webinar_info?.subscribe) {
                              let count: number = this.webinar_info?.subscribe?.num + 1;
                              this.reservation_count = "已预约" + count.toString() + "人";
                            }
                          }

                        }
                      },
                      onFailure: (errorCode, errorMsg) => {
                        PromptActionClass.closeDialog();
                        ToastUtil.showToast(errorMsg);
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
                VHSaaSDK.getInstance().checkWatchAuth(webinarId, "0", "", {
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
                    ToastUtil.showToast(errorMsg);
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
            ForEach(this.pageList, (item: VHMenus, index) => {
              TabContent() {
                // 根据类型加载不同页面组件
                if (item.name === '简介') {
                  VHIntroductionView({ introduction: this.webinar_info?.webinar?.introduction })
                    .width('100%')
                    .height('100%')
                } else if (this.customMenuList.find((menu) => menu.name === item.name)) {
                  VHCustomMenu({ menu_id: item.id.toString(), webinars: this.webinar_info,enableInviteCard: Number(this.commonConfig.invite_card) })
                    .width('100%')
                    .height('100%')
                }
              }.tabBar(item.name as string)
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
