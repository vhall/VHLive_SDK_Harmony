import { VHRtcSDK } from "@vhall/vhall_rtc";

@ObservedV2
export class VHRTCUserInfo {
  constructor(userId: string, isRemote: boolean) {
    this.userId = userId;
    this.isRemote = isRemote;
  }
  userId: string = "";
  isRemote: boolean = false;
  @Trace isMain: boolean = false;
  streamId:string = "";
  streamType:number = 0;
  streamAttr:string = "";
  @Trace isMute: boolean = false;
  @Trace isCamera: boolean = true;
  nickName: string = "";
  @Trace isLost: boolean = false;
  isInit : boolean = false;
  controller: object = new Object;

  get mainVideoViewID(): string {
    return this.userId + "#MainStream" + this.streamType + this.streamId;
  }

  updateRenderParams(obj: object): void {
    if (this.isRemote) {
      VHRtcSDK.getInstance().subScribeRemoteView(this.streamId, this.streamType, this.mainVideoViewID, obj);
    } else {
      VHRtcSDK.getInstance().updateLocalView(this.mainVideoViewID, obj);
    }
  }
}
