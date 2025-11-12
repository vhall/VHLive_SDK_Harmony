import { util } from "@kit.ArkTS";
import { VHReplyMessage, VHUserData } from "../model/VHWatchWebinarInfo";

/**
 * @description 消息体
 * */
export class VHIMMessageModel {
  /**
   * 消息ID
   */
  msg_id?: string;
  /**
   * 频道ID
   */
  channel?: string;
  /**
   * 消息事件类型
   */
  event?: string;
  /**
   * 时间
   */
  date_time?: string;
  /**
   * 发送者三方用户id
   */
  third_party_user_id?: string;
  /**
   * 在线人数
   */
  connection_online_num?: number;
  /**
   * 在线人数
   */
  user_online_num?: number;
  client?: string;
  dataJson?: string;
  /**
   * 发送者头像
   */
  avatar?: string;
  /**
   * 发送者昵称
   */
  nick_name?: string;
  /**
   * 服务类型
   */
  service_type?: string;
  /**
   * 发送者id
   */
  sender_id?: string;
  /**
   * 发送的自定义消息
   */
  context?: string;
  /**
   * -直播中观看次数
   */
  pv?: number;
  /**
   * 直播中观看人数
   */
  uv?: number;
  bu?: number;
  key?: string;
  /**
   * 消息体
   */
  data?: object;
}


/**
 *@description 用户被禁言后感知状态更新事件
 */
export class VHBannedModeUpdate{
  /**
   * 聊天感知状态 0禁言后有感知 1禁言后无感知
   * */
  mode:number = 0;
  event_type:string = "banned_mode_update";
  type:string = "banned_mode_update";
}

/**
 *@description 聊天昵称加密事件
 */
export class VHChatNickNameEncryptionUpdate{
  /**
   * 聊天感知状态 0不加密 1加密
   * */
  status:number = 0;
  type:string = "chat_nickname_encryption";
}


/**
 *@description 消息内容
 */
export class VHMsgData {
  /**
   *@description 消息类型，text 文本 image 图片
   */
  public  type: string = "";
  /**
   *@description 消息内容
   */
  public  barrage_txt: string = "";
  /**
   *@description 消息内容
   */
  public  text_content: string = "";
  /**
   *@description 昵称
   */
  public  nickname: string = "";
  /**
   *@description 头像
   */
  public  avatar: string = "";
  /**
   *@description 聊天图片列表
   */
  public  image_urls: string[] | null = null;

  /**
   *@description 点赞数
   */
  public num: number = 0;

  /**
   *@description 站点类型
   */
  public event_type: string  = "";

  /**
   *@description 目标id，用于私聊
   */
  public target_id: string = "";

  constructor(type: string, barrage_txt: string, text_content: string, nickname: string, avatar: string, image_urls: string[]) {
    this.type = type;
    this.barrage_txt = barrage_txt;
    this.text_content = text_content;
    this.nickname = nickname;
    this.avatar = avatar;
    this.image_urls = image_urls;
  }
}

export class VHContent {
  /**
   *@description 头像
   */
  avatar: string | undefined;
  /**
   *@description 昵称
   */
  nickname: string | undefined;
  /**
   *@description 消息体
   */
  data: VHMsgData | null = null;
  /**
   *@description 时间
   */
  date_time:string | undefined;
  /**
   *@description 图片资源
   */
  image_urls : string[] = [];
  /**
   *@description 角色  1 主持人，2 观众，3 助理，4 嘉宾
   */
  role_name: string ='';

  /**
   *@description 消息id
   */
  msg_id : string ='';

  key: string = util.generateRandomUUID(true);

  constructor(avatar: string, nickname: string, data: VHMsgData,date_time: string,  image_urls?: string[]) {
    this.avatar = avatar;
    this.nickname = nickname;
    this.data = data;
    this.date_time=date_time;
    if (image_urls) {
      this.image_urls = image_urls;
    }
  }
}

export class VHContext {
  /**
   *@description 角色
   */
  role_name: string = "";
  privacies: string = "";
  /**
   *@description 账号id
   */
  accountId: string = "";
  /**
   *@description 昵称
   */
  nick_name: string = "";
  /**
   *@description 昵称
   */
  nickname: string = "";
  /**
   *@description 设备类型
   */
  device_type: string = "";
  /**
   *@description 头像
   */
  avatar: string = "";

  replyMsg: VHReplyMessage = new VHReplyMessage();

  atList: VHAtListInfo[] = [];
}

export class VHAtListInfo {
  /**
   *@description 账号
   */
  accountId: string = '';
  /**
   *@description 昵称
   */
  nickName: string = '';
  /**
   *@description 序号
   */
  index: number = 0;
}


export interface VHIMServerInterface {
  /**
   * @description 接收聊天消息
   * @param im im
   * @param message chat消息  data中聊天消息格式  说明详见本文件底部注释
   */
  imReceiveChatMessage(type:string,message: VHIMMessageModel): void;

  /**
   * @description 接收上下线消息
   * @param im im
   * @param message 消息
   */
  imReceiveOnlineMessage(type:string,message: VHUserData): void;

  /**
   * @description 接收自定义消息
   * @param im im
   * @param message 自定义消息
   */
  imReceiveCustomMessage(type:string,message: VHIMMessageModel): void;

  /**
   * @description 接收房间消息
   * @param type 消息类型
   * @param message room消息
   */
  imReceiveRoomMessage(type:string,message: VHIMMessageModel): void;

  /**
   * 错误回调
   * @param im im
   * @param error 错误
   */
  imSDKError(code: number, errorMsg: string): void;

  /**
   * 消息服务连接成功
   * */
  onVHNetworkConnect(): void;

  /**
   * 消息服务链接已断开
   * @param im im
   * @param error 错误
   */
  onVHNetworkDisconnect(code: number, message: string): void;

  /**
   * 消息服务连接正在重新链接
   * */
  onVHNetworkConnecting(): void;
}