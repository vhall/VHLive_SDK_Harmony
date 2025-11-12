import { BroadcastMsgModelCallBlack, VHBaseCommunication, VHMessage } from "@vhall/vhallyun-framework";
import { VHCallBack } from "../VHCallback";
import { VHDataManager } from "../VHDataManager";
import { VHMessageManager } from "../VHMessageManager";
import { VHRoomEventType } from "../VHRoomEventType";
import { VHServerName } from "../VHServerConstant";
import { VHSignData, VHSignMessage, VHSignMessageInterface } from "./VHSignMessageCallback";
import { JSON } from "@kit.ArkTS";
import { VHSaaSDK } from "../VhallSDK";

export class VHSignServer {
  //消息回调
  private callback: VHSignMessageInterface;

  constructor(cb: VHSignMessageInterface) {
    this.callback = cb;
    VHMessageManager.getInstance().registerServer(VHServerName.SIGH_NAME, this);
  }

  /**
   * @description 签到接口
   * @param signId 签到id
   * @param roomId 房间id
   * **/
  public performSignIn(signId: string, roomId: string, callback: VHCallBack) {
    //签到接口 VhallSDK.sign
    VHSaaSDK.getInstance().performSignIn(signId, roomId, {
      // 成功
      onSuccess(data: string | object) {
        callback.onSuccess(data);
      },
      // 失败
      onFailure(errorCode: number, errorMsg: string) {
        callback.onFailure(errorCode, errorMsg);
      }
    })
  }


  onRecvMessage(message: VHMessage): void {
    //解析消息类型。进行消息转换。
    if (this.callback != null) {
      //解析msgModel 将签到重点信息结构化
      let signMsg: VHSignMessage = new VHSignMessage(VHDataManager.getInstance().getVHIMMessage(message));
      signMsg.sign_data = JSON.parse(message.data as string) as VHSignData;
      if (signMsg.sign_data.event_type == VHRoomEventType.SIGN_IN_PUSH) {
        this.callback.onStartSign(signMsg);
      } else if (signMsg.sign_data.event_type == VHRoomEventType.SIGN_END) {
        this.callback.onEndSign(signMsg);
      }
    }
  }
}