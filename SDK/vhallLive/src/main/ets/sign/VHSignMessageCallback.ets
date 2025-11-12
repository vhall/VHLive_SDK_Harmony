import { VHIMMessageModel } from "../im/VHIMCallback";

export class VHSignData {
  /*
  * @description 房间ID
  * */
  room_id: string = '';
  /*
  * @description 声音状态（0-关闭，1-开启）
  * */
  sound_status: number = 0;
  /*
  * @description 签到显示时间（秒）
  * */
  sign_show_time: number = 0;
  /*
  * @description 签到ID
  * */
  sign_id: number = 0;
  /*
  * @description 消息类型
  * */
  type: string = '';
  /*
  * @description 签到消息标题
  * */
  title: string = '';
  /*
  * @description 角色名称
  * */
  role_name: string = '';
  /*
  * @description 事件类型
  * */
  event_type: string = '';
  /*
  * @description 是否自动踢出未签到用户（0-不自动，1-自动）
  * */
  auto_kick_unsigned: number = 0;
  /*
  * @description 签到创建者ID
  * */
  sign_creator_id: string = '';
  /*
  * @description 签到创建者昵称
  * */
  sign_creator_nickname: string = '';
  /*
  * @description 签到成功提示语
  * */
  sign_in_success_tips: string = '';
}

/**
 * 获取签到信息数据
 * **/
export class VHGetSignData{
  /**
   * 签到id
   * **/
  id:number = 0;
  /**
   * 签到提示语
   * **/
  sign_tips:string = "主持人发起了签到"
  /**
   * 签到时长秒
   * **/
  show_time:number = 30
  /**
   * 签到创建时间
   * **/
  created_at:string = ""
  /**
   * @description 是否自动踢出未签到用户（0-不自动，1-自动）
   * **/
  auto_kick_unsigned:number =0
  /**
   * @description 签到成功提示语
   * **/
  sign_in_success_tips:string = ""
  push_type:number =0
  push_status:number =1
  push_time:string = "推送时间"
  /*
  * @description 声音状态（0-关闭，1-开启）
  * */
  sound_status:number =0
  type:number =0
  webinar_id:number = 0
  /***
  * @description是否自动发起签到
  * */
  is_auto_sign:number =0
  /**
   * @description自动发起签到的轮询时间，单位秒
   * */
  auto_sign_time:number =0
}

/**
 * @description
 * 签到消息
 * */
export class VHSignMessage {
  constructor(base: VHIMMessageModel) {
    this.base_data = base;
  }
  /**
   * 签到数据
   * */
  sign_data?: VHSignData;
  /**
   * 原始数据
   * */
  base_data?: VHIMMessageModel;
}

export interface VHSignMessageInterface {
  /**
   * @description 开始签到消息
   * @param msgModel 消息数据模型
   */
  onStartSign: (msgModel: VHSignMessage) => void;

  /**
   * @description 结束签到
   * @param msgModel 消息数据模型
   */
  onEndSign: (msgModel: VHSignMessage) => void;
}

