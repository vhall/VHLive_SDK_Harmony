import { VHPusherSDK } from "@vhall/vhall_pusher";

@ObservedV2
export class VHPusherUserInfo {
  constructor(userId: string) {
    this.userId = userId;
  }
  userId: string = "";
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
    VHPusherSDK.getInstance().updateLocalView(this.mainVideoViewID, obj);
  }
}
