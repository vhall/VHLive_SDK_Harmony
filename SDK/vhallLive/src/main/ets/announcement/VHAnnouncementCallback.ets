import { VHIMMessageModel } from "../im/VHIMCallback";

export class VHAnnouncementData {
  /**
   * 房间ID
   */
  room_id: string = '';
  /**
   * 显示类型
   * **/
  display_type: number = 0;
  /**
   * 显示时长
   * **/
  duration: number = 0;
  /**
   * 记录显示状态
   * **/
  record_display: number = 0;
  /**
   * 房间公告文本内容
   * **/
  room_announcement_text: string = '';
  /**
   * 事件类型
   * ***/
  event_type: string = '';
  /**
   * 房间加入ID
   * ***/
  room_join_id: string = '';
  /***
   * 设置类型
   * **/
  set_type: number = 0;
  /**
   * 公告ID
   * **/
  id: string = '';
  /**
   * 消息类型
   * */
  type: string = '';
  /**
   * 推送时间
   * **/
  push_time: string = '';
}


export class VHAnnouncementMessage {
  constructor(base: VHIMMessageModel) {
    this.base_data = base;
  }

  //公告数据
  announcement_data?: VHAnnouncementData;
  // 原始数据
  base_data?: VHIMMessageModel;
}

export interface VHAnnouncementMessageInterface {
  /**
   * @description 公告消息
   * @param msgModel 消息数据模型
   */
  onStartAnnouncement: (msgModel: VHAnnouncementMessage) => void;

  /**
   * @description 删除公告消息
   * @param msgModel 消息数据模型
   */
  onDelAnnouncement: (msgModel: VHAnnouncementMessage) => void;
}
