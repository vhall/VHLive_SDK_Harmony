import {
  VHIMMessageModel,
  VHIMServer,
  VHRoomEventType,
  VHSaaSDK,
  VHUserData,
  VHWebinarData,
  VhallUserInfo,
  VhallUserListInfo,
} from "@vhall/vhall_live";
import { ToastUtil } from "../action/ToastUtil";
import { abilityAccessCtrl, common } from "@kit.AbilityKit";
import { AVSessionManager } from "../utils/AVSessionManager";
import { window } from "@kit.ArkUI";
import { BusinessError } from "@kit.BasicServicesKit";
import { BeautyComponent } from "../components/beauty/BeautyComponent";
import { DefaultRecordDialog } from "../components/recoed/VHRecordComponent";
import { VhallMediaCaptureFrame,
  VhallMediaPusherCode,
  VhallPusherResolution, VhallXComponentView, VHPusherSDK } from "@vhall/vhall_pusher";
import { VHPusherUserInfo } from "../components/pusher/VHPusherUserInfo";
import { image } from "@kit.ImageKit";
import { VhallBeautyFrame, VHBeautySDK } from "@vhall/vhall_beauty";
import { WindowUtil } from "../utils/WindowUtil";

const RECONNECT_TIMEOUT: number = 3000;

@Builder
export function VideoLivePageBuilder(name: string, param: object) {
  VideoLivePage({
    nick_name: param['nick_name'],
    webinar_id: param['webinar_id'],
    version:param['version']
  })
}

interface ITopTool {
  icon: ResourceStr;
  onClick: () => void;
}

@Entry
@Component
struct VideoLivePage {
  private webinar_info?: VHWebinarData;
  @State webinar_id: string = '';
  @State nick_name: string = '';
  @State version:number = 1;
  private imBase?: VHIMServer;
  private imConnectTimer: number = -1;
  @State hideState: number = 0;
  @State streamList: VHPusherUserInfo[] = [];
  @State userId: string = '';
  @State record_id: string = '';
  @State isHost: boolean = false;
  @State userList: VhallUserInfo[] = [];
  @State isAudioMute: boolean = false;
  @State isVideoMute: boolean = false;
  @State isLiveStart: boolean = false;
  @State isPause: boolean = false;
  @State isFront: boolean = true;
  @State isMirror: boolean = true;
  @State selectHDIndex: number = 2;
  @State bitRate:string = '';
  @State screenSnap: PixelMap | null = null;
  pageInfos: NavPathStack = new NavPathStack() // 导航
  private avSessionManager = new AVSessionManager();

  // 添加计时器相关变量
  @State liveDuration: number = 0; // 直播持续时间（秒）
  private liveTimer: number = -1; // 计时器ID

  onVHXComponentLoad(xComponentId: string, obj: object){
    this.streamList.forEach(item => {
      item.controller = obj;
      item.updateRenderParams(obj);
    });
  }

  // 格式化时间为 HH:MM:SS
  private formatTime(seconds: number): string {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;

    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  // 启动直播计时器
  private startLiveTimer(startTime:number): void {
    if (this.liveTimer !== -1) {
      clearInterval(this.liveTimer);
    }

    this.liveDuration = startTime;
    this.liveTimer = setInterval(() => {
      this.liveDuration += 1;
    }, 1000); // 每秒更新一次
  }

  // 停止直播计时器
  private stopLiveTimer(): void {
    if (this.liveTimer !== -1) {
      clearInterval(this.liveTimer);
      this.liveTimer = -1;
    }
  }
  //美颜弹窗
  VHBeautyDialog = new CustomDialogController({
    builder: BeautyComponent(),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })

  //清晰度弹窗
  VHHDDialog = new CustomDialogController({
    builder: HDComponent({selectIndex: this.selectHDIndex}),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })

  //默认回放生成弹窗
  VHDefaultRecordDialog = new CustomDialogController({
    builder: DefaultRecordDialog({record_id: this.record_id, pageInfos: this.pageInfos}),
    customStyle: true,
    alignment: DialogAlignment.Center,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      if (dismissDialogAction.reason !== DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss();
      }
    }
  })

  getUpdatedTool(): ITopTool[] {
    return [
      {
        icon: $r("app.media.icon_beauty_open"),
        onClick: () => {
          this.VHBeautyDialog.open();
        }
      },
      {
        icon: $r("app.media.icon_HD"),
        onClick: () => {
          this.VHHDDialog.open();
        }
      },
      {
        icon: $r("app.media.icon_mirror"),
        onClick: () => {
          this.isMirror = !this.isMirror;
          VHPusherSDK.getInstance().setMirrorType(this.isMirror);
        }
      },
      {
        icon: $r("app.media.icon_switch"),
        onClick: () => {
          this.isFront = !this.isFront;
          VHPusherSDK.getInstance().switchCamera(this.isFront);
        }
      },
      {
        icon: this.isVideoMute ? $r("app.media.icon_video_off") : $r("app.media.icon_video_on"),
        onClick: () => {
          this.isVideoMute = !this.isVideoMute;
          if (this.isVideoMute) {
            let context = this.getUIContext();
            if(this.screenSnap == null) {
              this.screenSnap = context.getComponentSnapshot().getSync("localVideo")
            }
            VHPusherSDK.getInstance().setVideoMuteImage(this.screenSnap);
          } else {
            VHPusherSDK.getInstance().setVideoMuteImage(null);
          }
          ToastUtil.showToast(this.isVideoMute ? "已关闭摄像头" : "已打开摄像头", {
            bottom: 200
          });
        }
      },
      {
        icon: this.isAudioMute ? $r("app.media.icon_voice_off") : $r("app.media.icon_voice_on"),
        onClick: () => {
          this.isAudioMute = !this.isAudioMute;
          VHPusherSDK.getInstance().muteLocalAudio(this.isAudioMute);
          ToastUtil.showToast(this.isAudioMute ?" 已关闭麦克风" : "已打开麦克风", {
            bottom: 200
          });
        }
      }
    ]
  }

  aboutToAppear() {
    WindowUtil.setWindowKeepScreenOn(true);

    window.getLastWindow(this.getUIContext().getHostContext()!, (err: BusinessError, windowClass) => {
      if (err.code) {
        console.error(`Failed to obtain the top window. Cause code: ${err.code}, message: ${err.message}`);
        return;
      }
      let systemBarProperties: window.SystemBarProperties = {
        statusBarColor: '#000000', // 状态栏背景色
        statusBarContentColor: "#FFFFFF",
      };
      windowClass.setWindowSystemBarProperties(systemBarProperties).then(() => {
        console.info('Succeeded in setting the system bar properties.');
      }).catch((err: BusinessError) => {
        console.error(`Failed to set systemBar properties. Cause code: ${err.code}, message: ${err.message}`);
      });
    });

    VHSaaSDK.getInstance().getLiveInit(this.webinar_id, this.nick_name, '', {
      onSucceed: (data: VHWebinarData) => {
        if (data.webinar_show_type === 1) {
          ToastUtil.showToast("不支持横屏互动连麦");
          this.pageInfos.pop();
        }
        this.webinar_info = data;
        //连接消息服务, 此方法会建立websocket进行消息的接收处理。在线状态也是通过此方法控制
        this.imBase = new VHIMServer(this);
        this.imBase.join(this.webinar_info!);
        const context = this.getUIContext().getHostContext();
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
          VHPusherSDK.getInstance().init(
            context,
            this.version,
            null,
            null,
            this.webinar_info,
            {
              onPushConnectSuccess: (): void => {
                ToastUtil.showToast("已连接");
              },
              onPushDisconnect: (): void => {
                ToastUtil.showToast("已断开");
                setTimeout(()=>{
                  VHPusherSDK.getInstance().unPublish();
                  VHPusherSDK.getInstance().publish();
                },2000)
              },
              onReConnecting: (): void => {
                ToastUtil.showToast("正在重连");
              },
              onError: (errCode: number, errMsg: string): void => {
                ToastUtil.showToast(errMsg);
                if(errCode == VhallMediaPusherCode.ERROR_PUBLISH_CONNECT || errCode == VhallMediaPusherCode.ERROR_MUXER_EMPTY){
                  setTimeout(()=>{
                    VHPusherSDK.getInstance().unPublish();
                    VHPusherSDK.getInstance().publish();
                  },2000)
                }
              },
              onWarning: (warningCode: number, warningMsg: string): void => {
                ToastUtil.showToast(warningMsg);
              },
              onMicrophoneVolumeUpdate: (volume: number): void => {
              },
              onPushStreamBitrate: (bitrate: number): void => {
                console.info("bitrate: " + bitrate);
                this.bitRate = Number(bitrate).toString();
              },
              onCaptureFrame: (src: VhallMediaCaptureFrame, dst: VhallMediaCaptureFrame): void => {
                let srcFrame = new VhallBeautyFrame(src.data, src.width, src.height, src.timestamp);
                let dstFrame = new VhallBeautyFrame(dst.data, dst.width, dst.height, dst.timestamp);
                VHBeautySDK.getInstance().renderWithInput(srcFrame, dstFrame);
                dst.data = dstFrame.data;
              }
            },
            {
              onSuccess: (): void => {
                let selfItem = new VHPusherUserInfo(this.userId);
                selfItem.isMain = true;
                selfItem.nickName = this.webinar_info?.join_info?.nickname!;
                const isUserExists = this.streamList.some(item => item.userId === this.userId);
                if (!isUserExists) {
                  this.streamList.push(selfItem);
                }
                this.isHost = true;
                this.init();
                this.getUserListInfo();
                if(this.webinar_info?.webinar?.type === 1){
                  VHPusherSDK.getInstance().publish();
                  this.isLiveStart = true;
                  // 开始计时器
                  this.startLiveTimer(this.webinar_info?.webinar?.live_time);
                }
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
    this.stopLiveTimer();
    window.getLastWindow(this.getUIContext().getHostContext()!, (err: BusinessError, windowClass) => {
      if (err.code) {
        console.error(`Failed to obtain the top window. Cause code: ${err.code}, message: ${err.message}`);
        return;
      }
      let systemBarProperties: window.SystemBarProperties = {
        statusBarColor: '#FFFFFF', // 状态栏背景色
        statusBarContentColor: "#000000",
      };
      windowClass.setWindowSystemBarProperties(systemBarProperties).then(() => {
        console.info('Succeeded in setting the system bar properties.');
      }).catch((err: BusinessError) => {
        console.error(`Failed to set systemBar properties. Cause code: ${err.code}, message: ${err.message}`);
      });
    });

    this.imBase?.leave();
    VHPusherSDK.getInstance().destroy();
    this.streamList = [];
    VHSaaSDK.getInstance().liveEnd(this.webinar_id, "0", {
      onSuccess: (data: string | object) => {
      },
      onFailure: (code: number, errorMsg: string) => {
      }
    });

    WindowUtil.setWindowKeepScreenOn(false);
  }

  /**
   * @description 接收聊天消息
   * @param im im
   * @param message chat消息  data中聊天消息格式  说明详见本文件底部注释
   */
  imReceiveChatMessage(type: string, message: VHIMMessageModel) {
    console.log("接收聊天消息:", type , " + ",  JSON.stringify( message));
  };

  /**
   * @description 接收上下线消息
   * @param im im
   * @param message 消息
   */
  imReceiveOnlineMessage(type: string, message: VHUserData) {
    console.log("接收上下线消息:", type , " + ",  JSON.stringify( message));
  };

  /**
   * @description 接收自定义消息
   * @param im im
   * @param message 自定义消息
   */
  imReceiveCustomMessage(type: string, message: VHIMMessageModel) {
    if (type ===VHRoomEventType.INVITE_OUT_TIME ) {
      ToastUtil.showToast(message.data!["msg"]);
    }
    console.log("接收自定义消息:", type , " + ",  JSON.stringify( message));
  };

  /**
   * 接收房间消息
   * @param im im
   * @param message room消息
   */
  imReceiveRoomMessage(type: string, message: VHIMMessageModel) {
    console.log("接收房间消息:", type , " + ",  JSON.stringify( message));
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
    ToastUtil.showToast("消息服务链接成功")
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

  private async init() {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    let request = await atManager.requestPermissionsFromUser(context, ['ohos.permission.CAMERA', 'ohos.permission.MICROPHONE']);
    if (request.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      VHPusherSDK.getInstance().setVideoEncode(VhallPusherResolution.VhallPusherResolution1280x720);
      VHPusherSDK.getInstance().enableCustomDataProcess(true);
      VHPusherSDK.getInstance().createLocalStream(true);
      VHPusherSDK.getInstance().muteLocalAudio(false);
      VHPusherSDK.getInstance().switchCamera(true);
      VHPusherSDK.getInstance().setMirrorType(true);
    } else {
      this.getUIContext().getPromptAction().showToast({
        message: "请允许相机权限",
      });
    }
  }

  private getUserListInfo() {
    VHSaaSDK.getInstance().getOnlineList(this.webinar_info?.interact?.room_id!, 0, 10, {
      onSuccess: (data: string | object) => {
        this.userList = (data as VhallUserListInfo).list;
        console.info("获取在线列表成功：", JSON.stringify(data))
      },
      onFailure: (code: number, errorMsg: string) => {
        console.info("获取在线列表失败：" + code + " " + errorMsg);
      }
    })
  }

  build() {
    NavDestination() { // 必须作为根组件
      Stack({alignContent: Alignment.TopEnd}){
        if (this.isHost && !this.isVideoMute) {
          VhallXComponentView({ xComponentId: this.streamList[0].mainVideoViewID, type: VHPusherSDK.getInstance().getPusherType(), componentListener: this })
            .width('100%')
            .height('100%')
        }
        Column(){
          Image('https://cnstatic01.e.vhall.com/upload/user/avatar/57/72/577252bda8f072ef8e4dc680123c1651.jpg')
          .width(150)
          .height(150)
          .borderRadius(75)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Black)
        .justifyContent(FlexAlign.Center)
        .id("localVideo")
        .position({bottom:this.isVideoMute ? 0 : -999})

        Row(){
          Text(this.bitRate + "kbps")
        }
        .width(100)
        .zIndex(0)
        .justifyContent(FlexAlign.Center)

        Row(){
          if (this.isLiveStart) {
            Column({space: 5}){
              Row({space: 5}){
                Image('https://cnstatic01.e.vhall.com/upload/user/avatar/57/72/577252bda8f072ef8e4dc680123c1651.jpg')
                  .width(20)
                  .borderRadius(10)
                Column(){
                  Text(this.formatTime(this.liveDuration))
                    .fontSize(10)
                    .fontColor(Color.White)
                  Text(`${this.userList.length > 99 ? "99+" : this.userList.length}观看`)
                    .fontSize(10)
                    .fontColor(Color.White)
                }
              }
              .width(80)
              .height(30)
              .borderRadius(15)
              .justifyContent(FlexAlign.Center)
              .backgroundColor("rgba(128, 128, 128, 0.2)")
            }
          }
          else {
            Row()
              .width(80)
          }
          Row({space: 5}){
            ForEach(this.getUpdatedTool(), (item: ITopTool, index) => {
              if(index !== 1 || !this.isLiveStart) {
                Image(item.icon)
                  .width(30)
                  .backgroundColor("rgba(128, 128, 128, 0.2)")
                  .borderRadius(15)
                  .onClick(() => {
                    item.onClick();
                  })
              }
            })
            Image($r("app.media.icon_close"))
              .fillColor(Color.White)
              .width(15)
              .onClick(() => {
                if(this.liveDuration > 30) {
                  VHSaaSDK.getInstance().createRecord(this.webinar_id, "0", {
                    onSuccess: (data: string | object) => {
                      console.info("自动生成回放成功");
                      this.record_id = data as string;
                      this.VHDefaultRecordDialog.open();
                    },
                    onFailure: (code: number, errorMsg: string) => {
                      console.info("自动生成回放失败：" + code + " " + errorMsg);
                      this.pageInfos.pop();
                    }
                  })
                } else {
                  this.pageInfos.pop();
                }
              })
          }
        }
        .position({top:20})
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Top)
        .padding({left: 15, right:15})
        .width("100%")
        if (!this.isLiveStart) {
          Row(){
            Button("开始直播")
              .fontSize(16)
              .backgroundColor(Color.Red)
              .onClick(() => {
                VHSaaSDK.getInstance().liveStart(this.webinar_id,  "0", {
                  onSuccess: (data: string | object) => {
                    ToastUtil.showToast("开始直播成功");
                    VHPusherSDK.getInstance().publish();
                    this.isLiveStart = true;
                    // 开始计时器
                    this.startLiveTimer(0);
                  },
                  onFailure: (code: number, errorMsg: string) => {
                    console.info("开始直播失败：" + code + " " + errorMsg);
                  }
                });
              })
          }
          .width("100%")
          .justifyContent(FlexAlign.Center)
          .position({bottom:50})
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
    }
    .width('100%')
    .height('100%')
    .hideToolBar(true)
    .hideTitleBar(true)
    .hideBackButton(true)
    .backgroundColor(Color.White)
    .onShown(() => {
      this.hideState = 0;
      console.log(`取消长时任务`)
      this.avSessionManager.stop();
    })
    .onHidden(() => {
      this.hideState = 1;
      console.log(`申请长时任务，避免退到后台导致消息服务中断`)
      this.avSessionManager.start();
    })
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack
    })
  }
}

@CustomDialog
export struct HDComponent {
  controller: CustomDialogController;
  @State HDList: string[] = ["标清", "流畅", "高清", "超清"];
  @Link selectIndex: number;

  build() {
    Column(){
      ForEach(this.HDList, (item: string, index) => {
        Row(){
          Text(item)
            .fontSize(16)
            .fontColor(this.selectIndex === index ? Color.Red : Color.Black)
            .onClick(() => {
              this.selectIndex = index;
              ToastUtil.showToast(`已切换至${item}`,{
                bottom: 200
              });
              switch (index) {
                case 0:
                  VHPusherSDK.getInstance().setVideoEncode(VhallPusherResolution.VhallPusherResolution640x360);
                  break;
                case 1:
                  VHPusherSDK.getInstance().setVideoEncode(VhallPusherResolution.VhallPusherResolution960x540);
                  break;
                case 2:
                  VHPusherSDK.getInstance().setVideoEncode(VhallPusherResolution.VhallPusherResolution1280x720);
                  break;
                case 3:
                    VHPusherSDK.getInstance().setVideoEncode(VhallPusherResolution.VhallPusherResolution1920x1080);
                    break;
                default:
                    VHPusherSDK.getInstance().setVideoEncode(VhallPusherResolution.VhallPusherResolution1920x1080);
               }
              this.controller.close();
            })
        }
        .width("100%")
        .height("20%")
        .justifyContent(FlexAlign.Center)
        Divider()
          .height(1)
      })
      Row(){
        Text("取消")
          .fontSize(16)
          .fontColor(Color.Black)
      }
      .width("100%")
      .height("20%")
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.controller.close();
      })
    }
    .width("100%")
    .height(365)
    .backgroundColor(Color.White)
  }
}