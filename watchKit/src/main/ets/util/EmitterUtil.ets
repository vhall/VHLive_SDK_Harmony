import emitter from '@ohos.events.emitter';
import { VHRoomEventType } from '@vhall/vhall_live';


/**
 * Emitter消息数据结构
 */
export interface EmitterMsgData {
  type: string;
  enable?:boolean;
  data?: Object;
}

/**
 * Emitter工具类：封装消息订阅、发送、取消订阅
 */
export class EmitterUtil {
  /**
   * 订阅Emitter消息
   * @param msgType 消息类型
   * @param callback 消息接收回调
   * @returns 订阅ID（用于取消订阅）
   */
  public static subscribe(msgType: string, callback: (data: EmitterMsgData) => void): void {
    if (!msgType || !callback) {
      console.error('EmitterUtil: 订阅参数不能为空');
    }
    // 创建订阅事件
    emitter.on(msgType, (eventData: emitter.EventData) => {
      try {
        const msgData = eventData.data as EmitterMsgData;
        callback(msgData);
      } catch (error) {
        console.error(`EmitterUtil: 解析消息失败，错误：${JSON.stringify(error)}`);
      }
    });

    console.log(`EmitterUtil: 成功订阅消息，类型：${msgType}`);
  }


  /**
   * 发送Emitter消息
   * @param msgData 消息数据
   */
  public static send(msgData: EmitterMsgData): void {
    if (!msgData || !msgData.type) {
      console.error('EmitterUtil: 发送消息缺少必要参数（type必填）');
      return;
    }

    try {
      // 发送事件
      emitter.emit(msgData.type, {
        data: msgData
      });
      console.log(`EmitterUtil: 成功发送消息，类型：${msgData.type}，数据：${JSON.stringify(msgData.data)}`);
    } catch (error) {
      console.error(`EmitterUtil: 发送消息失败，错误：${JSON.stringify(error)}`);
    }
  }

  /**
   * 取消订阅Emitter消息
   * @param msgType 消息类型
   * @param eventId 订阅ID（subscribe方法返回值）
   */


  public static unsubscribe(eventId: string): void {
    try {
      // 移除指定事件类型的所有监听器
      emitter.off(eventId);
      console.log(`EmitterUtil: 成功取消所有订阅，事件类型：${eventId}`);
    } catch (error) {
      console.error(`EmitterUtil: 取消订阅失败，错误：${JSON.stringify(error)}`);
    }
  }
}
