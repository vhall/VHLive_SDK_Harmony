import {
  VHIMMessageModel,
  VHIMServer,
  VHRoomEventType,
  VHSaaSDK,
  VHUserData,
  VHWebinarData,
  VhallUserInfo,
  VhallUserListInfo,
  VHRoleName
} from "@vhall/vhall_live";
import { ToastUtil } from "../action/ToastUtil";
import { abilityAccessCtrl, common } from "@kit.AbilityKit";
import {
  VhallCaptureFrame,
  VhallCodeNum,
  VhallMediaType,
  VhallPushConfigProfile,
  VhallResolutionMode,
  VhallStream,
  VhallXComponentView,
  VHRtcSDK
} from "@vhall/vhall_rtc";
import { VHRTCUserInfo } from "../components/rtc/VHRTCUserInfo";
import { AVSessionManager } from "../utils/AVSessionManager";
import { DefaultRecordDialog } from "../components/recoed/VHRecordComponent";

const RECONNECT_TIMEOUT: number = 3000;

@Builder
export function HostLivePageBuilder(name: string, param: object) {
  HostLivePage({
    nick_name: param['nick_name'],
    webinar_id: param['webinar_id']
  })
}

@Entry
@Component
struct HostLivePage {
  private webinar_info?: VHWebinarData;
  @State webinar_id: string = '';
  @State nick_name: string = '';
  private imBase?: VHIMServer;
  private imConnectTimer: number = -1;
  @State hideState: number = 0;
  @State streamList: VHRTCUserInfo[] = [];
  @State userId: string = '';
  @State isHost: boolean = false;
  @State isLive: boolean = false;
  @State enableSpeak: boolean = false;
  @State userList: VhallUserInfo[] = [];
  @State host_name: string = '主持人';
  @State guest_name: string = '嘉宾';
  @State assistant_name: string = '助理';
  @State record_id: string = '';
  pageInfos: NavPathStack = new NavPathStack() // 导航
  private avSessionManager = new AVSessionManager();

  // 添加计时器相关变量
  @State liveDuration: number = 0; // 直播持续时间（秒）
  private liveTimer: number = -1; // 计时器ID

  onVHXComponentLoad(xComponentId: string, obj: object){
    this.streamList.forEach(item => {
      if(item.mainVideoViewID === xComponentId) {
        item.controller = obj;
        item.updateRenderParams(obj);
      }
    });
  }

  aboutToAppear() {
    VHSaaSDK.getInstance().getRoleName(this.webinar_id, {
      onSucceed: (data: VHRoleName) => {
        this.host_name = data.host_name;
        this.guest_name = data.guest_name;
        this.assistant_name = data.assistant_name;
      },
      onFailure: (errorCode: number, errorMsg: string) => {
        console.info("获取角色名称失败：" + errorCode + " " + errorMsg);
      }
    })
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
          VHRtcSDK.getInstance().init(
            context,
            this.webinar_info,
            {
              onConnectRoom: (errorCode: number, errorMsg: string): void => {
                let selfItem = new VHRTCUserInfo(this.userId, false);
                selfItem.isMain = true;
                selfItem.nickName = this.webinar_info?.join_info?.nickname!;
                const isUserExists = this.streamList.some(item => item.userId === this.userId);
                if (!isUserExists) {
                  this.streamList.push(selfItem);
                }
                this.isHost = true;
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
                    if (stream.streamId == this.streamList[i].streamId) {
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
              },
              onUserAudioAvailable: (stream: VhallStream, available: number): void => {
              },
              onUserStatistics: (stream: VhallStream, lost: number): void => {
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
              }
            },
            {
              onSuccess: (): void => {
                VHRtcSDK.getInstance().enterRoom();
                this.init();
                this.getUserListInfo();
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
    this.imBase?.leave();
    VHRtcSDK.getInstance().exitRoom();
    VHRtcSDK.getInstance().destroy();
    this.streamList = [];
    this.stopLiveTimer();
    VHSaaSDK.getInstance().liveEnd(this.webinar_id,  "0", {
      onSuccess: (data: string | object) => {
        this.isLive = false;
      },
      onFailure: (code: number, errorMsg: string) => {
      }
    });
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
    if (type === VHRoomEventType.USER_JOIN || type === VHRoomEventType.USER_LEAVE) {
      this.getUserListInfo();
    }
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
    if (type === VHRoomEventType.MESSAGE_VRTC_CONNECT_SUCCESS || type === VHRoomEventType.MESSAGE_VRTC_DISCONNECT_SUCCESS) {
      this.getUserListInfo();
    }
    else if (type === VHRoomEventType.MESSAGE_VRTC_CONNECT_INVITE_REFUSED) {
      ToastUtil.showToast(`观众${message.data!["nick_name"]}拒绝了您的上麦邀请`);
    }
    else if (type == VHRoomEventType.MESSAGE_VRTC_BIG_SCREEN_SET) { //互动流设置混流大画面
      this.handleBigScreenSet(message);
    }
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

  // 格式化时间为 HH:MM:SS
  private formatTime(seconds: number): string {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;

    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  // 启动直播计时器
  private startLiveTimer(): void {
    if (this.liveTimer !== -1) {
      clearInterval(this.liveTimer);
    }

    this.liveDuration = 0;
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

  //默认回放生成弹窗
  VHDefaultRecordDialog = new CustomDialogController({
    builder: DefaultRecordDialog({record_id: this.record_id}),
    customStyle: true,
    alignment: DialogAlignment.Center
  })

  private async init() {
    const mainVideoViewID = this.userId + "#MainStream" + 0;
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    let request = await atManager.requestPermissionsFromUser(context, ['ohos.permission.CAMERA', 'ohos.permission.MICROPHONE']);
    if (request.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      VHRtcSDK.getInstance()
        .setVideoEncode(VhallPushConfigProfile.VHPushConfigProfile_Resolution_640_360,
          VhallResolutionMode.TRTCVideoResolutionModePortrait);
      let controller = this.streamList.find(item => item.userId === this.userId)?.controller ?? null;
      VHRtcSDK.getInstance().createLocalStream(true, mainVideoViewID, controller);
      VHRtcSDK.getInstance().muteLocalAudio(false);
      VHRtcSDK.getInstance().muteLocalVideo(false);
      VHRtcSDK.getInstance().switchCamera(true);
      VHRtcSDK.getInstance().setMirrorType(true);
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

  private handleBigScreenSet(message: VHIMMessageModel) {
    this.streamList.forEach((item: VHRTCUserInfo) => {
      item.isMain = item.userId === message.sender_id;
    });
  }

  build() {
    NavDestination() { // 必须作为根组件
      Column(){
        if (this.isHost) {
          Stack({alignContent: Alignment.TopEnd}){
            VhallXComponentView({ xComponentId: this.streamList[0].mainVideoViewID, type: VHRtcSDK.getInstance().getRtcType(), componentListener: this })
              .width(this.streamList[0].isMain ? '100%' :'20%')
              .height(this.streamList[0].isMain ? '100%' :'20%')
              .zIndex(this.streamList[0].isMain ? 1 : 2)
            if (this.streamList.length > 1){
              VhallXComponentView({ xComponentId: this.streamList[1].mainVideoViewID, type: VHRtcSDK.getInstance().getRtcType(), componentListener: this })
                .width(this.streamList[1].isMain ? '100%' :'20%')
                .height(this.streamList[1].isMain ? '100%' :'20%')
                .zIndex(this.streamList[1].isMain ? 1 : 2)
            }
          }
          .width('100%')
          .height('40%')
          .backgroundColor(Color.Black)
        }
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
        .position({top: 10, left: 10})
        .justifyContent(FlexAlign.Center)
        .backgroundColor("rgba(128, 128, 128, 0.2)")
        List({space: 10}){
          ForEach(this.userList, (item: VhallUserInfo, index) => {
            ListItem(){
              Row(){
                Row({space: 10}){
                  Image(item.avatar === "" ? $r("app.media.default_avatar") : item.avatar)
                  .width(50)
                  .height(50)
                  .borderRadius(25)
                  Text(item.nickname)
                  if (item.role_name === "1") {
                    Text(this.host_name)
                      .fontColor(Color.Red)
                      .padding(2)
                      .fontSize(12)
                      .borderRadius(10)
                      .backgroundColor("#ffcccc")
                  }else if (item.role_name === "3") {
                    Text(this.assistant_name)
                      .fontColor(Color.Red)
                      .padding(2)
                      .fontSize(12)
                      .borderRadius(10)
                      .backgroundColor("#ffcccc")
                  }
                  else if (item.role_name === "4") {
                    Text(this.guest_name)
                      .fontColor("#eeeeee")
                      .padding(2)
                      .fontSize(12)
                      .borderRadius(10)
                      .backgroundColor("#999999")
                  }
                }
                Row({space: 10}){
                  if (item.role_name === "2" || item.role_name === "4") {
                    Button(item.is_speak ? "下麦" : "上麦")
                      .onClick(() => {
                        if (item.is_speak) {
                          VHRtcSDK.getInstance().noSpeak(this.webinar_info?.interact?.room_id!, item.account_id, {
                            onSuccess: (data: string | object) => {
                              ToastUtil.showToast("下麦成功");
                            },
                            onFailure: (code: number, errorMsg: string) => {
                              console.info("下麦失败：" + code + " " + errorMsg)
                            }
                          })
                        } else {
                          VHRtcSDK.getInstance().invite(this.webinar_info?.interact?.room_id!, item.account_id, {
                            onSuccess: (data: string | object) => {
                              ToastUtil.showToast("邀请发送成功");
                            },
                            onFailure: (code: number, errorMsg: string) => {
                              ToastUtil.showToast(errorMsg);
                            }
                          })
                        }
                      })
                  }
                  Image($r("app.media.icon_mainScreen"))
                    .width(30)
                    .onClick(() => {
                      VHRtcSDK.getInstance().setMainScreen(this.webinar_info?.interact?.room_id!, item.account_id, {
                        onSuccess: (data: string | object) => {
                          ToastUtil.showToast("设置主讲人成功");
                        },
                        onFailure: (code: number, errorMsg: string) => {
                          console.info("设置失败：" + code + " " + errorMsg)
                        }
                      })
                    })
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .padding(10)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        Divider()
        Row(){
          if(!this.isLive) {
            Button("开始直播")
              .backgroundColor(Color.Red)
              .onClick(() => {
                VHSaaSDK.getInstance().liveStart(this.webinar_id, "0", {
                  onSuccess: (data: string | object) => {
                    ToastUtil.showToast("开始直播成功");
                    VHRtcSDK.getInstance().publish();
                    this.isLive = true;
                    this.startLiveTimer();
                  },
                  onFailure: (code: number, errorMsg: string) => {
                    console.info("开始直播失败：" + code + " " + errorMsg);
                  }
                });
              })
          }else {
            Button("结束直播")
              .onClick(() => {
                VHSaaSDK.getInstance().liveEnd(this.webinar_id, "0", {
                  onSuccess: (data: string | object) => {
                    ToastUtil.showToast("结束直播成功");
                    VHRtcSDK.getInstance().unPublish();
                    this.isLive = false;
                    if(this.liveDuration > 30) {
                      VHSaaSDK.getInstance().createRecord(this.webinar_id, "0", {
                        onSuccess: (data: string | object) => {
                          console.info("自动生成回放成功");
                          this.record_id = data as string;
                          this.VHDefaultRecordDialog.open();
                        },
                        onFailure: (code: number, errorMsg: string) => {
                          console.info("自动生成回放失败：" + code + " " + errorMsg);
                        }
                      })
                    }
                    this.stopLiveTimer();
                  },
                  onFailure: (code: number, errorMsg: string) => {
                    console.info("结束直播失败：" + code + " " + errorMsg);
                  }
                });
              })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({left: 20, right: 20})
        .margin({top:20, bottom: 20})
        if(this.isLive) {
          Row(){
            Text("允许观众申请连麦")
              .fontColor(Color.Black)
            Toggle({ type: ToggleType.Switch, isOn: this.enableSpeak })
              .onChange((isOn: boolean) => {
                this.enableSpeak = isOn;
                VHRtcSDK.getInstance().setHandSup(this.webinar_info?.interact?.room_id!, isOn? "1": "0", {
                  onSuccess: (data: string | object) => {
                    ToastUtil.showToast(isOn? "开启连麦功能" : "关闭连麦功能");
                  },
                  onFailure: (code: number, errorMsg: string) => {
                    console.info("设置举手状态失败：" + code + " " + errorMsg)
                  }
                })
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({left: 20, right: 20})
        }
      }
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