import { ComponentContent, display, promptAction, window } from "@kit.ArkUI";
import { VHWebinarWatchModel } from "../model/VHWebinarWatchModel";
import { createLoadingView, EmitterMsgData, EmitterUtil, PromptActionClass } from "watchkit"
import {
  VHCallBack,
  VHSaaSDK,
  VHWatchAuthInfo,
  VHWebinarData,
  VHPlayerConfig,
  VHChatMessageList,
  VHCommonConfig,
  VHAgreementModel,
  VHCommonConfigCallback,
  VHMenus,
  VHScreenPoster,
  VHIMServer,
  VHIMMessageModel,
  VHAgreement,
  VHConfigList,
} from "@vhall/vhall_live";
import { preferences } from '@kit.ArkData';
import { scanBarcode, scanCore } from "@kit.ScanKit";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { BusinessError, emitter } from "@kit.BasicServicesKit";
import { ToastUtil } from "watchkit/src/main/ets/action/ToastUtil";

@Builder
export function LiveEnterPageBuilder(name: string, param: object) {
  LiveEnterPage({ third_id: param['third_id'], nick_name: param['nickname'] })
}

class RecordData {
  recordId: string = ""
}


@Entry
@Component
struct LiveEnterPage {
  private webinars?: VHWebinarData;
  private player_config?: VHPlayerConfig;
  private model: VHWebinarWatchModel = new VHWebinarWatchModel();
  private third_id: string = "";
  private nick_name: string = "";
  @State message: string = 'Hello World';
  @State webinar_id: string = '';
  @State input_id: string = '';
  @State pageList: Array<string> = new Array();
  @State recordId: string = "";
  private turnToRecord: boolean = false;
  @State agreement: VHAgreement = new VHAgreement();
  private imBase?: VHIMServer;
  private h5Live: boolean = false;
  private webinar_info?: VHWebinarData;
  private dataPreferences: preferences.Preferences | null = null;
  private is_auth_check: boolean = false;
  pageInfos: NavPathStack = new NavPathStack() // 导航
  private contentNode: ComponentContent<Object> | null = null;
  @Provide screenPoster: VHScreenPoster | null = null
  private functionConfig: VHConfigList | null = null; //功能配置

  aboutToAppear(): void {
    this.contentNode = new ComponentContent(this.getUIContext(), wrapBuilder(createLoadingView));
    PromptActionClass.setContext(this.getUIContext());
    PromptActionClass.setContentNode(this.contentNode);
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

    let options: preferences.Options = { name: 'room' };
    this.dataPreferences =
      preferences.getPreferencesSync(this.getUIContext().getHostContext()?.getApplicationContext(), options);
    this.input_id = this.dataPreferences.getSync("room_id", "") as string

    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      console.info(`eventData: ${JSON.stringify(eventData)}`);
      let record = eventData.data as RecordData;
      this.recordId = record.recordId;
      this.turnToRecord = true;
      this.initWebinar();
    }
    // 接收端事件，跳转到活动
    emitter.on("turn_to_record", callback);
  }

  InvitationCard() {
    let switchId: string = this.webinar_info?.switch_info?.switch_id.toString() as string;
    VHSaaSDK.getInstance().commonConfig(this.webinar_info?.webinar?.id.toString()!, switchId, {
      onSucceed: (data: VHCommonConfig) => {
        data.menus?.forEach((value: VHMenus, index: number, array: VHMenus[]) => {
          if (data.screen_poster != null) {
            this.screenPoster = data.screen_poster as VHScreenPoster
          }
        })
      },
      onFailure: (errorCode: number, errorMsg: string) => {
        console.log(`获取开屏广告数据失败： ${JSON.stringify(errorMsg)}`)
        ToastUtil.showToast(errorMsg);
      }
    });
  }

  imReceiveChatMessage(type: string, message: VHIMMessageModel) {
    console.log("接收聊天消息:", message);
  }

  imReceiveOnlineMessage(type: string, message: VHIMMessageModel) {
    console.log("接收上下线消息:", message);
  }

  imReceiveCustomMessage(type: string, message: VHIMMessageModel) {
    console.log("接收自定义消息:", message);
  }

  imReceiveRoomMessage(type: string, message: VHIMMessageModel) {
    console.log("接收房间消息:", message)
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

  initWebinar() {
    PromptActionClass.setContext(this.getUIContext());
    PromptActionClass.setContentNode(this.contentNode!);
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
    this.model.doInitWatch(this.webinar_id, this.recordId, this.nick_name, {
      onSucceed: (data: VHWebinarData) => {
        this.agreement = data.agreement as VHAgreement;
        this.webinars = data;
        if (this.webinars.join_info?.is_kick == 1) {
          ToastUtil.showToast("您已被踢出房间");
          return
        }

        VHSaaSDK.getInstance().permissionsCheck("3", this.webinars?.webinar?.id.toString()!,
          this.webinars?.webinar?.userinfo.user_id.toString()!, {
            onSucceed: (configData: VHConfigList) => {
              this.functionConfig = configData;
              let switchId: string = this.webinars?.switch_info?.switch_id.toString() as string;
              VHSaaSDK.getInstance().commonConfig(this.webinars?.webinar?.id.toString()!, switchId, {
                onSucceed: (data: VHCommonConfig) => {
                  this.screenPoster = data.screen_poster as VHScreenPoster
                  if (data.screen_poster?.status == 0) {
                    PromptActionClass.closeDialog();
                    let param: object = new Object()
                    param['webinars'] = this.webinars;
                    param['screenPoster'] = this.screenPoster;
                    param['webinar_id'] = this.webinar_id;
                    param['nick_name'] = this.nick_name;
                    param['h5Live'] = this.h5Live;
                    this.pageInfos.pushPath({ name: 'InvitationCard', param: param })
                  } else {
                    this.model.doGetPlayerConfig(this.webinar_id, {
                      onSucceed: (data: VHPlayerConfig) => {
                        PromptActionClass.closeDialog();
                        //预约状态或者有观看验证的情况但是没有通过。则跳到预约页面
                        if (this.h5Live) {
                          let param: object = new Object()
                          param['webinars'] = this.webinars;
                          this.pageInfos.pushPath({ name: 'VHH5LivePage', param: param },
                            { launchMode: LaunchMode.MOVE_TO_TOP_SINGLETON })
                        } else if (this.webinars?.webinar?.type == 2 ||
                          (this.webinars?.webinar?.verify == 1 &&
                            this.webinars.join_info?.verified == 0)) {
                          let param: object = new Object()
                          param['webinars'] = this.webinars;
                          param['player_config'] = data;
                          param['webinar_id'] = this.webinar_id;
                          // this.pageInfos.pushPath({ name: 'ReservationPage', param: param }, true);
                          this.pageInfos.pushPath({ name: 'ReservationPage', param: param },
                            { launchMode: LaunchMode.MOVE_TO_TOP_SINGLETON })
                        } else if (this.webinars?.webinar?.type == 4 || this.webinars?.webinar?.type == 5) {
                          let param: object = new Object()
                          param['webinars'] = this.webinars;
                          param['player_config'] = data;
                          // this.pageInfos.pushPath({ name: 'WatchVodPage', param: param }, true);
                          if (this.agreement.is_open == 1 && this.agreement.is_agree == 0) {
                            this.pageInfos.pushPath({ name: 'StartPage', param: param }, true);
                          } else {
                            this.pageInfos.pushPath({ name: 'WatchVodPage', param: param },
                              { launchMode: LaunchMode.MOVE_TO_TOP_SINGLETON })
                          }
                        } else if (this.webinars?.webinar?.type == 1) {
                          let param: object = new Object()
                          param['webinars'] = this.webinars
                          param['player_config'] = data;
                          param['webinar_id'] = this.webinar_id;
                          VHSaaSDK.getInstance()
                            .doInitWatch(this.webinars.webinar.id.toString(), '', '', '', '', true, {
                              onSucceed: (data: VHWebinarData) => {
                                this.agreement = data.agreement as VHAgreement;
                                //this.functionConfig?.hard_login 是否开启了强制登录。
                                if (this.agreement.is_open == 1 && this.agreement?.is_agree == 0) {
                                  this.pageInfos.pushPath({ name: 'StartPage', param: param }, true);
                                } else {
                                  this.pageInfos.pushPath({ name: 'WatchLivePage', param: param }, true);
                                }
                              },
                              onFailure: (errorCode, errorMsg) => {
                                this.pageInfos.pushPath({ name: 'WatchLivePage', param: param }, true);
                                ToastUtil.showToast(errorMsg);
                              }
                            })
                        } else if (this.webinars?.webinar?.type == 3) {
                          this.getUIContext().getPromptAction().showToast({
                            message: "直播已结束",
                            duration: 2000,
                            showMode: promptAction.ToastShowMode.DEFAULT,
                            bottom: 80
                          });
                        }
                      },
                      onFailure: (errorCode, errorMsg) => {
                        PromptActionClass.closeDialog();
                        ToastUtil.showToast(errorMsg);
                      }
                    })
                  }
                },
                onFailure: (errorCode: number, errorMsg: string) => {
                  ToastUtil.showToast(`${errorCode}:` + `${errorMsg}`)
                }
              });


            },
            onFailure: (errorCode: number, errorMsg: string) => {
              console.error('获取功能配置失败: ' + JSON.stringify(errorMsg));
              ToastUtil.showToast(errorMsg);
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
  }

  build() {
    NavDestination() { // 必须作为根组件
      Flex({ direction: FlexDirection.Column }) {
        Stack({ alignContent: Alignment.TopEnd }) {
          Image($r('app.media.main_bg_top'))
            .width('100%')
            .height('30%')
          Button('登出').onClick(() => {
            VHSaaSDK.getInstance().logout({
              onSuccess: (data) => {
                this.pageInfos.pop();
              },
              onFailure: (errorCode, errorMsg) => {
                ToastUtil.showToast(errorMsg);
              }
            })
          })
        }

        Column({ space: 20 }) {
          TextInput({ text: this.input_id, placeholder: '请输入活动Id' })
            .onChange(val => this.webinar_id = val)

          Button('二维码扫码').onClick(() => {
            // 定义扫码参数options
            let options: scanBarcode.ScanOptions = {
              scanTypes: [scanCore.ScanType.ALL],
              enableMultiMode: true,
              enableAlbum: true
            };
            try {
              // 可调用getContext接口获取当前页面关联的UIAbilityContext
              scanBarcode.startScanForResult(this.getUIContext().getHostContext(), options)
                .then((result: scanBarcode.ScanResult) => {
                  // 获得活动id
                  let jsonUrlStr: string = result.originalValue as string;
                  if (jsonUrlStr != null) {
                    if (jsonUrlStr.indexOf('watch/') != -1 && jsonUrlStr.indexOf('?') != -1) {
                      this.input_id = jsonUrlStr.substring(jsonUrlStr.indexOf('watch/') + 6, jsonUrlStr.indexOf('?'));
                    }
                  }
                })
                .catch((error: BusinessError) => {
                  hilog.error(0x0001, '[Scan CPSample]',
                    `Failed to get ScanResult by promise with options. Code:${error.code}, message: ${error.message}`);
                });
            } catch (error) {
              hilog.error(0x0001, '[Scan CPSample]',
                `Failed to start the scanning service. Code:${error.code}, message: ${error.message}`);
            }
          })

          Button('观看直播').onClick(() => {
            this.dataPreferences?.putSync('room_id', this.webinar_id);
            this.dataPreferences?.flushSync();
            this.h5Live = false;
            this.turnToRecord = false;
            this.recordId = "";
            this.initWebinar();
          })
          Button('H5观看直播').onClick(() => {
            this.dataPreferences?.putSync('room_id', this.webinar_id);
            this.dataPreferences?.flushSync();
            this.h5Live = true;
            this.turnToRecord = false;
            this.recordId = "";
            this.initWebinar();
          })
        }
        .width('100%')
        .padding(10)
      }
    }
    .hideToolBar(true)
    // .hideTitleBar(true,false)
    .hideBackButton(true)
    .id('LiveEnterPage')
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack
    })
  }
}