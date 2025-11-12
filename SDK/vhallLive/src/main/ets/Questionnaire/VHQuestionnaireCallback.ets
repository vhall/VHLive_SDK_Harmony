import { VHIMMessageModel } from "../im/VHIMCallback";

/**
 * @description问卷推送
 */
export class VHQuestionnairePushModel {
  /*
  * @description是否必填（0：非必填，1：必填，默认0）
  * */
  mandatory_filling: number = 0;
  /*
  * @description问卷ID
  * */
  questionnaire_id: string = "";
  /*
  * @description 房间加入ID
  * */
  room_join_id: string = "";
  /*
  * @description创建者昵称
  * */
  nick_name: number = 0;
  /*
  * @description用户别名
  * */
  alias: string = "";
  /*
  * @description房间角色
  * */
  room_role: number = 0;
  /*
  * @description消息类型
  * */
  type: string = '';
  /*
  * @description问卷标题
  * */
  title: string = '';
}

/**
 * @description问卷消息
 * */
export class VHQuestionnaireMessage {
  constructor(base: VHIMMessageModel) {
    this.base_data = base;
  }

  //问卷数据
  questionnaire_data?: VHQuestionnairePushModel;
  // 原始数据
  base_data?: VHIMMessageModel;
}


export interface VHQuestionnaireInterface {
  /**
   * @description 问卷消息
   * @param msgModel 消息数据模型
   */
  onStartQuestionnaire: (msgModel: VHQuestionnaireMessage) => void;

  /**
   * @description 问卷结束
   * @param msgModel 消息数据模型
   */
  onEndQuestionnaire: (msgModel: VHQuestionnaireMessage) => void;
}