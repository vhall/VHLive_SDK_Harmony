import { VHMessage } from "@vhall/vhallyun-framework";
import { VHSaaSDK } from "../VhallSDK";
import { VHCallBack } from "../VHCallback";
import { VHDataManager } from "../VHDataManager";
import { VHMessageManager } from "../VHMessageManager";
import { VHRoomEventType } from "../VHRoomEventType";
import { VHServerName } from "../VHServerConstant";
import { VHLotteryResultNoticeModel, VHLotteryMessage, VHLotteryMessageInterface } from "./VHLotteryMessageCallback";

export class VHLotteryServer {
  //消息回调
  private callback: VHLotteryMessageInterface;

  constructor(cb: VHLotteryMessageInterface) {
    this.callback = cb;
    VHMessageManager.getInstance().registerServer(VHServerName.LOTTERY_NAME, this);
  }

  /**
   * @description中奖人领奖信息接口
   * @param roomId 房间id
   * @param lottery_id 抽奖活动ID
   * @param lottery_user_name 中奖人姓名
   * @param lottery_user_phone 中奖人手机号（根据领奖信息配置做校验）
   * */
  public performLotteryIn(roomId: string, lottery_id: string, lottery_user_name: string,
    lottery_user_phone: string,
    callback: VHCallBack) {
    VHSaaSDK.getInstance()
      .performWinnerInformationIn(roomId, lottery_id, lottery_user_name, lottery_user_phone,
        {
          // 成功
          onSuccess(data: string | object) {
            callback.onSuccess(data);
          },
          // 失败
          onFailure(errorCode: number, errorMsg: string) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      )
  }


  onRecvMessage(message: VHMessage): void {
    //解析消息类型。进行消息转换。
    if (this.callback != null) {
      //解析msgModel 将签到重点信息结构化
      let lotteryMsg: VHLotteryMessage = new VHLotteryMessage(VHDataManager.getInstance().getVHIMMessage(message));
      lotteryMsg.lottery_data = JSON.parse(message.data as string) as VHLotteryResultNoticeModel;
      if (lotteryMsg.lottery_data.type == VHRoomEventType.LOTTERY_RESULT_NOTICE) {
        this.callback.onStartLottery(lotteryMsg);
      } else if (lotteryMsg.lottery_data.type == VHRoomEventType.LOTTERY_PUSH) {
        this.callback.onEndLottery(lotteryMsg);
      }
    }
  }
}