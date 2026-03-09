import { abilityAccessCtrl, common } from "@kit.AbilityKit";
import { VHBeautySDK } from "@vhall/vhall_beauty";
import { VHRoomToolsStatusData, VHSaaSDK, VHWebinarData } from "@vhall/vhall_live";
import {
  VhallPushConfigProfile,
  VhallResolutionMode,
  VhallStreamType,
  VhallXComponentView,
  VHRtcSDK,
  VHSpeakListInfo
} from "@vhall/vhall_rtc";
import { EmitterUtil } from "../../util/EmitterUtil";
import { PreferencesUtil } from "../../utils/PreferencesUtil";
import { VHRTCUserInfo } from "./VHRTCUserInfo";

@Component
export struct VHRTCUserComponent {
  @State roomId: string = "";
  @State streamList: VHRTCUserInfo[] = [];
  @State userId: string = "";
  @Prop isScreenOrMediaStream:boolean = false;
  private webinarInfo?: VHWebinarData;

  onVHXComponentLoad(xComponentId: string, obj: object){
    this.streamList.forEach(item => {
      if(item.mainVideoViewID === xComponentId) {
        item.controller = obj;
        item.updateRenderParams(obj);
      }
    });
  }

  async aboutToAppear() {
    EmitterUtil.subscribe("CreateLocalStream", async ()=> {
      if(this.streamList.find(item => item.userId === this.userId)) {
        await this.init();
      }
    });
  }

  aboutToDisappear(): void {
    VHRtcSDK.getInstance().unPublish();
    EmitterUtil.unsubscribe("CreateLocalStream");
  }

  build(): void {
    Column() {
      if(this.isScreenOrMediaStream){
        ForEach(this.streamList, (item: VHRTCUserInfo) => {
          if (item.streamType == VhallStreamType.VHStreamType_Desktop || item.streamType == VhallStreamType.VHStreamType_MediaFile || item.streamType == VhallStreamType.VHStreamType_SoftWare ) {
            Stack({alignContent: Alignment.Bottom}){
              VhallXComponentView({ xComponentId: item.mainVideoViewID, type: VHRtcSDK.getInstance().getRtcType(), componentListener: this })
            }
            .width("100%")
            .height("100%")
          }
        })
      }else{
        ForEach(this.streamList, (item: VHRTCUserInfo) => {
          if (item.isMain) {
            Stack({alignContent: Alignment.Bottom}){
              if (!item.isCamera){
                Image($r("app.media.icon_no_video_bg"))
                  .width("100%")
                  .height("100%")
                  .zIndex(2)
              }
              Row(){
                Text(item.nickName)
                  .fontColor(Color.White)
                Row({space: 5}){
                  if(item.isMute) {
                    Image($r("app.media.icon_no_speak"))
                      .width(16)
                  } else {
                    Image($r("app.media.icon_microphone"))
                      .width(16)
                  }
                  if(!item.isLost) {
                    Image($r("app.media.icon_lost_green"))
                      .width(16)
                  }else {
                    Image($r("app.media.icon_lost_red"))
                      .width(16)
                  }
                }
              }
              .width("100%")
              .height("20%")
              .justifyContent(FlexAlign.SpaceBetween)
              .padding({left: 10, right: 10, top: 5, bottom: 5})
              .zIndex(3)
              VhallXComponentView({ xComponentId: item.mainVideoViewID, type: VHRtcSDK.getInstance().getRtcType(), componentListener: this })
            }
            .width("80%")
            .height(this.getMainHeight())
          }
        })
        Flex({wrap: FlexWrap.Wrap}){
          ForEach(this.streamList, (item: VHRTCUserInfo) => {
            if (!item.isMain) {
              Stack({alignContent: Alignment.Bottom}){
                if (!item.isCamera){
                  Image($r("app.media.icon_no_video_bg"))
                    .width("100%")
                    .height("100%")
                    .zIndex(2)
                }
                Row(){
                  Text(item.nickName)
                    .fontSize(6)
                    .fontColor(Color.White)
                  Row({space: 2}){
                    if(item.isMute) {
                      Image($r("app.media.icon_no_speak"))
                        .width(6)
                    } else {
                      Image($r("app.media.icon_microphone"))
                        .width(6)
                    }
                    if(!item.isLost) {
                      Image($r("app.media.icon_lost_green"))
                        .width(6)
                    }else {
                      Image($r("app.media.icon_lost_red"))
                        .width(6)
                    }
                  }
                }
                .width("100%")
                .height("20%")
                .justifyContent(FlexAlign.SpaceBetween)
                .padding({left: 2, right: 2, top: 1, bottom: 1})
                .zIndex(3)
                VhallXComponentView({ xComponentId: item.mainVideoViewID, type: VHRtcSDK.getInstance().getRtcType(), componentListener: this })
              }
              .width("20%")
              .height(this.getHeightItem())
            }
          })
        }
        .width("100%")
        .height(this.getHeight())
      }

    }
    .width("100%")
    .height("100%")
    .backgroundColor(Color.Black)
  }

  private getMainHeight() {
    if (this.streamList.length <= 6) {
      return "80%";
    } else if (this.streamList.length <= 11) {
      return "60%";
    } else {
      return "40%";
    }
  }

  private getHeight() {
    if (this.streamList.length <= 6) {
      return "20%";
    } else if (this.streamList.length <= 11) {
      return "40%";
    } else {
      return "60%";
    }
  }

  private getHeightItem() {
    if (this.streamList.length <= 6) {
      return "100%";
    } else if (this.streamList.length <= 11) {
      return "50%";
    } else {
      return "33%";
    }
  }

  private async init() {
    const mainVideoViewID = this.userId + "#MainStream" + 0;
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    let request = await atManager.requestPermissionsFromUser(context, ['ohos.permission.CAMERA', 'ohos.permission.MICROPHONE']);
    if (request.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      // if(PreferencesUtil.getSync("isBeautyEnable", false) && VHBeautySDK.getInstance().enableBeauty()) {
      //   // 开启美颜功能，此方法必须在createLocalStream之前调用
      //   // VHRtcSDK.getInstance().enableCustomVideoCapture(true);
      //   // await VHBeautySDK.getInstance().startRender();
      //   // VHBeautySDK.getInstance().setVideoCallback({
      //   //   onBeautyFrame: (data: ArrayBuffer, width: number, height: number): void => {
      //   //     VHRtcSDK.getInstance().sendCustomVideoData(data, width, height)
      //   //   },
      //   // })
      //   // VHBeautySDK.getInstance().xcomponentId = mainVideoViewID;
      // }
      VHRtcSDK.getInstance().setVideoEncode(VhallPushConfigProfile.VHPushConfigProfile_Resolution_320_180,VhallResolutionMode.TRTCVideoResolutionModePortrait);
      VHRtcSDK.getInstance().enableCustomVideoProcess(true);
      let controller = this.streamList.find(item => item.userId === this.userId)?.controller ?? null;
      VHRtcSDK.getInstance().createLocalStream(true, mainVideoViewID, controller);
      VHRtcSDK.getInstance().muteLocalAudio(false);
      VHRtcSDK.getInstance().muteLocalVideo(false);
      VHRtcSDK.getInstance().switchCamera(true);
      VHRtcSDK.getInstance().setMirrorType(true);
      VHRtcSDK.getInstance().publish();
    } else {
      this.getUIContext().getPromptAction().showToast({
        message: "请允许相机权限",
      });
    }
    this.getDeviceStatus();
  }

  private getDeviceStatus(){
    VHRtcSDK.getInstance().getSpeakList(this.roomId,{
      onSuccess: (data: string | object) => {
        let speakList: VHSpeakListInfo = data as VHSpeakListInfo;
        for (let i = 0; i < speakList.total; i++) {
          let speakItem = speakList.list[i];
          let userInfo = this.streamList.find(item => item.userId === speakItem.account_id);
          if (userInfo) {
            userInfo.isMute = speakItem.audio === 0;
            userInfo.isCamera = speakItem.video === 1;
          }
        }
      },
      onFailure: (errorCode, errorMsg) => {
        console.error("getSpeakList errorCode:" + errorCode + " errorMsg:" + errorMsg);
      }
    })
  }
}