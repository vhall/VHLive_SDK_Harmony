/**
 * 消息的发送状态常量.
 *
 */
export default class MsgSendStatus {
  /** 消息发送中 */
  static readonly sending: number    = 0;
  /** 消息已被对方收到（我方已收到QoS应答包） */
  static readonly beReceived: number = 1;
  /** 消息发送失败（在QoS超时重传的时间内未收到应答包） */
  static readonly sendFaild: number  = 2;
}