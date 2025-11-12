import { VHMessage } from "@vhall/vhallyun-framework";
import { VHSaaSDK } from "../VhallSDK";
import { VHCallBack } from "../VHCallback";
import { VHDataManager } from "../VHDataManager";
import { VHMessageManager } from "../VHMessageManager";
import { VHRoomEventType } from "../VHRoomEventType";
import { VHServerName } from "../VHServerConstant";
import { VHQuestionnairePushModel, VHQuestionnaireInterface, VHQuestionnaireMessage } from "./VHQuestionnaireCallback";

export class VHQuestionnaireServer {
  //消息回调
  private callback: VHQuestionnaireInterface;

  constructor(cb: VHQuestionnaireInterface) {
    this.callback = cb;
    VHMessageManager.getInstance().registerServer(VHServerName.QUESTIONNAIRE_NAME, this);
  }

  /**
   * @description 问卷接口
   * */
  public performQuestionnaireIn(roomId: string, lottery_id: string, callback: VHCallBack) {
  }


  onRecvMessage(message: VHMessage): void {
    //解析消息类型。进行消息转换。
    if (this.callback != null) {
      //解析msgModel 将签到重点信息结构化
      let questionnaireMsg: VHQuestionnaireMessage =
        new VHQuestionnaireMessage(VHDataManager.getInstance().getVHIMMessage(message));
      questionnaireMsg.questionnaire_data = JSON.parse(message.data as string) as VHQuestionnairePushModel;
      if (questionnaireMsg.questionnaire_data.type == VHRoomEventType.QUESTIONNAIRE_PUSH) {
        this.callback.onStartQuestionnaire(questionnaireMsg);
      } else if (questionnaireMsg.questionnaire_data.type == VHRoomEventType.QUESTIONNAIRE_PUSH) {
        this.callback.onEndQuestionnaire(questionnaireMsg);
      }
    }
  }
}