import { VHMessage } from "@vhall/vhallyun-framework";
import { VHCallBack } from "../VHCallback";
import { VHDataManager } from "../VHDataManager";
import { VHMessageManager } from "../VHMessageManager";
import { VHRoomEventType } from "../VHRoomEventType";
import { VHServerName } from "../VHServerConstant";
import { VHPwdRedEnvelopeData, VHPwdRedEnvelopeMessage, VHRedEnvelopeMessageInterface } from "./VHRedEnvelopeInfo";

export class VHRedEnvelopeServer {
  //消息回调
  private callback: VHRedEnvelopeMessageInterface;

  constructor(cb: VHRedEnvelopeMessageInterface) {
    this.callback = cb;
    VHMessageManager.getInstance().registerServer(VHServerName.RED_ENVELOPE_NAME, this);
  }

  /**
   * @description 口令红包接口
   * **/
  public performRedEnvelopeIn(callback: VHCallBack) {
  }


  onRecvMessage(message: VHMessage): void {
    //解析消息类型。进行消息转换。
    if (this.callback != null) {
      //解析msgModel 将签到重点信息结构化
      let RedEnvelopeMsg: VHPwdRedEnvelopeMessage =
        new VHPwdRedEnvelopeMessage(VHDataManager.getInstance().getVHIMMessage(message));
      RedEnvelopeMsg.RedEnvelope_data = JSON.parse(message.data as string) as VHPwdRedEnvelopeData;
      if (RedEnvelopeMsg.RedEnvelope_data.event_type == VHRoomEventType.PUSH_PWD_RED_ENVELOPE_OK) {
        this.callback.onStartRedEnvelope(RedEnvelopeMsg);
      } else {
        this.callback.onEndRedEnvelope(RedEnvelopeMsg);
      }
    }
  }
}