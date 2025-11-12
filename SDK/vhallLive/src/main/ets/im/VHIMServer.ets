import { VHMessage } from "@vhall/vhallyun-framework";
import { VHIM, VHIMInterface } from "@vhall/vhallyun-ims";
import { VHUserData, VHUserInfo, VHWebinarData } from "../model/VHWatchWebinarInfo";
import { VHConstants } from '../VHConstants'
import { VHIMMessageModel, VHIMServerInterface } from "./VHIMCallback";
import { JSON } from "@kit.ArkTS";
import { VHRoomEventType } from "../VHRoomEventType";
import { VHMessageManager } from "../VHMessageManager";
import { VHServerName } from "../VHServerConstant";
import { VHSignMessage } from "../sign/VHSignMessageCallback";
import { cryptoFramework } from "@kit.CryptoArchitectureKit";
import { VHDataManager } from "../VHDataManager";
import { VHCallBack } from "../VHCallback";

export class VHIMServer {
  private access_token: string = ''; //this.params['access_token'];
  private channel_id: string = ''; // this.params['channel_id'];
  private isInit: boolean = false;
  private imBase: VHIM = new VHIM();
  private callback: VHIMServerInterface;
  private webinarInfo: VHWebinarData | null = null;

  constructor(cb: VHIMServerInterface) {
    this.callback = cb;
  }

  /**
   * @description 加入频道进行websocket建立
   * @param channelId 频道id （ch_xxxxx）
   * @param token
   * **/
  public join(webinar: VHWebinarData): number {
    this.webinarInfo = webinar;
    this.channel_id = this.webinarInfo.interact?.channel_id!;
    this.access_token = this.webinarInfo.interact?.paas_access_token!;
    this.imBase.setVHIMInterface(this);
    this.imBase.init(this.channel_id, this.access_token);
    return 0;
  }

  /**
   * @description 离开频道，断开websocket连接。整个活动内无法接收到消息通知
   * @param channelId 频道id （ch_xxxxx）
   * @param token
   * **/
  public leave() {
    this.imBase.closeMsg();
  }

  public sendMessage(message: string, callBack: VHCallBack) {
    this.imBase.sendMessage(message, {
      onSuccess() {
        callBack.onSuccess('消息发送成功');
      },
      onFailure(errorCode: number, errorMsg: string) {
        callBack.onFailure(errorCode, errorMsg);
      }
    });
  }

  public sendMessageToTarget(message: string, targetId: string, callBack: VHCallBack) {
    this.imBase.sendMessageToTarget(message, targetId, {
      onSuccess() {
        callBack.onSuccess('消息发送成功');
      },
      onFailure(errorCode: number, errorMsg: string) {
        callBack.onFailure(errorCode, errorMsg);
      }
    });
  }

  public sendTypeMessage(message: string, targetId: string, type: number, callBack: VHCallBack) {
    this.imBase.sendTypeMessage(message, targetId, type, {
      onSuccess() {
        callBack.onSuccess('消息发送成功');
      },
      onFailure(errorCode: number, errorMsg: string) {
        callBack.onFailure(errorCode, errorMsg);
      }
    });
  }

  /************************** 微吼云层 消息回调 ***************************************/


  /**
   * 接收聊天消息
   * @param im im
   * @param message chat消息  data中聊天消息格式  说明详见本文件底部注释
   */
  imSDKReceiveChatMessage(im: VHIM, message: VHMessage) {
    //解析 转为VHIMMessageModel
    if (this.callback) {
      if (message) {
        if (typeof message.data === 'string') {
          let msgObj: object = JSON.parse(message.data) as object;
          // 聊天禁言和取消禁言
          if (JSON.has(msgObj, "type")) {
            let type = msgObj['type'] as string;
            let event_type = msgObj['event_type'] as string;
            if (VHRoomEventType.CHAT_DISABLE == type || (VHRoomEventType.CHAT_PERMIT == type && event_type !== VHRoomEventType.CUSTOM_PRAISE) ||
              VHRoomEventType.CHAT_DISABLE_ALL == type || VHRoomEventType.CHAT_PERMIT_ALL == type) {
              let model: VHIMMessageModel = VHDataManager.getInstance().getVHIMMessage(message);
              this.callback.imReceiveRoomMessage(type, model);
              return;
            }
          }
          if (JSON.has(msgObj, "event_type")) {
            let event_type = msgObj['event_type'] as string;
            if (VHRoomEventType.CUSTOM_PRAISE == event_type) {
              let model: VHIMMessageModel = VHDataManager.getInstance().getVHIMMessage(message);
              this.callback.imReceiveChatMessage(VHRoomEventType.CUSTOM_PRAISE, model);
              return;
            }
          }
        }
      }

      let model: VHIMMessageModel = VHDataManager.getInstance().getVHIMMessage(message);
      this.callback.imReceiveChatMessage(VHRoomEventType.IM_TEXT, model);
    }
  }

  /**
   * 接收上下线消息
   * @param im im
   * @param message 消息
   */
  imSDKReceiveOnlineMessage(im: VHIM, message: VHMessage) {
    //解析 转为VHIMMessageModel
    if (this.callback) {
      if (this.callback) {
        if (message) {
          if (typeof message.data === 'string') {
            let msgObj: object = JSON.parse(message.data) as object;
            // 解析礼物等消息
            if (JSON.has(msgObj, "type")) {
              let event_type = msgObj['type'] as string;
              if (VHRoomEventType.USER_JOIN == event_type || VHRoomEventType.USER_LEAVE == event_type) {
                let model: VHIMMessageModel = VHDataManager.getInstance().getVHIMMessage(message);
                let user: VHUserData = new VHUserData();
                user.base_data = model;
                let context: object = JSON.parse(model.context!) as object;
                user.role_name = context['role_name'];
                user.nickname = context['nickname'];
                user.avatar = context['avatar'];
                user.uv = model.uv;
                user.user_id = model.sender_id;
                this.callback.imReceiveOnlineMessage(event_type, user);
              }
            }
          }
        }
      }
    }
  }

  /**
   * 接收自定义消息
   * @param im im
   * @param message 自定义消息
   */
  imSDKReceiveCustomMessage(im: VHIM, message: VHMessage) {
    //解析 转为VHIMMessageModel
    if (this.callback) {
      try {
        let model: VHIMMessageModel = VHDataManager.getInstance().getVHIMMessage(message);
        let event_type = "";
        if (model != null) {
          if (typeof model.data === 'string') {
            let msgObj: object = JSON.parse(model.data) as object;
            if (JSON.has(msgObj, "type")) {
              event_type = msgObj['type'] as string;
              this.callback.imReceiveCustomMessage(event_type, model);
            }
          } else {
            let msgObj: object = model.data as object;
            if (JSON.has(msgObj, "type")) {
              event_type = msgObj['type'] as string;
              this.callback.imReceiveCustomMessage(event_type, model);
            }
          }
        }
      }
      catch (e) {
      }
    }
  }

  /**
   * 接收房间消息
   * @param im im
   * @param message room消息
   */
  imSDKReceiveRoomMessage(im: VHIM, message: VHMessage) {
    //解析 转为VHIMMessageModel
    if (this.callback) {
      if (message) {
        if (typeof message.data === 'string') {
          let msgObj: object = JSON.parse(message.data) as object;
          let event_type = "";
          if (JSON.has(msgObj, "event_type")) {
            event_type = msgObj['event_type'] as string;
          }
          // 解析礼物等消息
          if (JSON.has(msgObj, "type")) {
            event_type = msgObj['type'] as string;
          }

          if (event_type == VHRoomEventType.SIGN_END || event_type == VHRoomEventType.SIGN_IN_PUSH) {
            VHMessageManager.getInstance().broadCastMsg(VHServerName.SIGH_NAME, message);
          } else if (event_type == VHRoomEventType.ROOM_ANNOUNCEMENT ||
            event_type == VHRoomEventType.DEL_ROOM_ANNOUNCEMENT) {
            VHMessageManager.getInstance().broadCastMsg(VHServerName.ANNOUNCEMENT_NAME, message);
          }
          console.log(`imSDKReceiveRoomMessage message:${JSON.stringify(message)}`)
          console.log(`imSDKReceiveRoomMessage message data:${JSON.stringify(message.data)}`)
          let model: VHIMMessageModel = VHDataManager.getInstance().getVHIMMessage(message);
          this.callback.imReceiveRoomMessage(event_type, model);
        } else if (typeof message.data === 'object') {
          if (JSON.has(message.data, "event_type")) {
            let event_type = message.data['event_type'] as string;
            let model: VHIMMessageModel = VHDataManager.getInstance().getVHIMMessage(message);
            this.callback.imReceiveRoomMessage(event_type, model);
          } else if (JSON.has(message.data, "type")) {
            let type = message.data['type'] as string;
            let model: VHIMMessageModel = VHDataManager.getInstance().getVHIMMessage(message);
            this.callback.imReceiveRoomMessage(type, model);
          }
        }
      }
    }
  }

  /**
   * 错误回调
   * @param im im
   * @param error 错误
   */
  imSDKError(im: VHIM, code: number, errorMsg: string) {
    //解析 转为VHIMMessageModel
    if (this.callback) {
      this.callback.imSDKError(code, errorMsg);
    }
  }

  /**
   * 接收IM消息：当前用户是否被禁言
   * @param im im
   * @param forbidden YES:禁言  NO:取消禁言
   */
  imSDKForbidden(im: VHIM, forbidden: boolean) {

  }

  /**
   * 当前频道是否被全体禁言
   * @param im im
   * @param forbiddenAll    YES:禁言  NO:取消禁言
   */
  imSDKForbiddenAll(im: VHIM, forbiddenAll: boolean) {

  }


  /**
   * 消息服务连接成功
   * */
  onNetworkConnect(): void {
    if (this.callback) {
      this.callback.onVHNetworkConnect();
    }
  }

  /**
   * 消息服务连接正在重新链接
   * */
  onNetworkConnecting(): void {
    if (this.callback) {
      this.callback.onVHNetworkConnecting();
    }
  }

  /**
   * 消息服务连接断开
   * */
  onNetworkDisconnect(code: number, msg: string): void {
    if (this.callback) {
      this.callback.onVHNetworkDisconnect(code, msg);
    }
  }
}