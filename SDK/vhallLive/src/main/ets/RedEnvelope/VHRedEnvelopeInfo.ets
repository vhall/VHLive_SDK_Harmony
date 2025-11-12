import { VHIMMessageModel } from "../im/VHIMCallback";

/**
 * 口令红包
 */
export class VHPwdRedEnvelopeData {
  /**
   * 事件类型标识
   */
  event_type: string = "";
  /**
   * 红包金额
   */
  red_packet_amount: number = 0;
  /**
   * 红包数量
   */
  red_packet_number: number = 0;
  /**
   * 红包开始时间
   */
  red_packet_start_time: string = "";
  /**
   * 红包类型标识
   */
  red_packet_type: number = 0;
  /**
   * 红包UUID
   */
  red_packet_uuid: string = "";
  /**
   * 房间ID
   */
  room_id: string = "";
  /**
   * 发送者头像
   */
  sender_avatar: string = "";
  /**
   * 发送者的ID
   */
  sender_id: string = "";
  /**
   * 发送者的昵称
   */
  sender_nickname: string = "";
  /**
   * 类型标识
   */
  type: string = "";
}

/**
 * @description
 * 口令红包消息
 * */
export class VHPwdRedEnvelopeMessage {
  constructor(base: VHIMMessageModel) {
    this.base_data = base;
  }

  //口令红包数据
  RedEnvelope_data?: VHPwdRedEnvelopeData;
  // 原始数据
  base_data?: VHIMMessageModel;
}


export interface VHRedEnvelopeMessageInterface {
  /**
   * @description 开始
   * @param msgModel 消息数据模型
   */
  onStartRedEnvelope: (msgModel: VHPwdRedEnvelopeMessage) => void;

  /**
   * @description 结束
   * @param msgModel 消息数据模型
   */
  onEndRedEnvelope: (msgModel: VHPwdRedEnvelopeMessage) => void;
}
