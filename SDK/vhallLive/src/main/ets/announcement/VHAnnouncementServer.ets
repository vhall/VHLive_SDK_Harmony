import { VHMessage } from "@vhall/vhallyun-framework";
import { VHAnnouncementNewsList } from "../model/VHWatchWebinarInfo";
import { VHSaaSDK } from "../VhallSDK";
import { VHAnnouncementListCallback, VHCallBack } from "../VHCallback";
import { VHDataManager } from "../VHDataManager";
import { VHMessageManager } from "../VHMessageManager";
import { VHRoomEventType } from "../VHRoomEventType";
import { VHServerName } from "../VHServerConstant";
import { VHAnnouncementData, VHAnnouncementMessage, VHAnnouncementMessageInterface } from "./VHAnnouncementCallback";


export class VHAnnouncementServer {
  //消息回调
  private callback: VHAnnouncementMessageInterface;

  constructor(cb: VHAnnouncementMessageInterface) {
    this.callback = cb;
    VHMessageManager.getInstance().registerServer(VHServerName.ANNOUNCEMENT_NAME, this);
  }

  /**
   * @description 公告列表接口
   * @param roomId 房间id
   * @param Limit 每页数量
   * @param pos 条目节点
   * **/
  public performAnnouncementIn(roomId: string, Limit: number, pos: number, callback: VHAnnouncementListCallback) {
    VHSaaSDK.getInstance().performAnnouncementIn(roomId, Limit, pos, {
      // 成功
      onSucceed(data: VHAnnouncementNewsList) {
        callback.onSucceed(data);
      },
      // 失败
      onFailure(errorCode: number, errorMsg: string) {
        callback.onFailure(errorCode, errorMsg);
      }
    })
  }

  onRecvMessage(message: VHMessage): void {
    //解析消息类型。进行消息转换。
    if (this.callback != null) {
      //解析msgModel 将公告重点信息结构化
      let AnnouncementMsg: VHAnnouncementMessage =
        new VHAnnouncementMessage(VHDataManager.getInstance().getVHIMMessage(message));
      AnnouncementMsg.announcement_data = JSON.parse(message.data as string) as VHAnnouncementData;
      if (AnnouncementMsg.announcement_data.type == VHRoomEventType.ROOM_ANNOUNCEMENT) {
        this.callback.onStartAnnouncement(AnnouncementMsg);
      } else if (AnnouncementMsg.announcement_data.type == VHRoomEventType.DEL_ROOM_ANNOUNCEMENT) {
        this.callback.onDelAnnouncement(AnnouncementMsg);
      }
    }
  }
}