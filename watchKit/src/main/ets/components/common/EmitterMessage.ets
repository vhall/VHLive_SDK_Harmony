import {
  VHChatDeleteMsg,
  VHChatMsgDelRecommend,
  VHChatMsgSetRecommend,
  VHDataDownloadUpdateMsg,
  VHGiftMessageInfo,
  VHTimerMsg,
  VHTimerPauseMsg,
  VHAnnouncementData,
  VHBaseNumUpdate,
  VHChatDisableAllMsg,
  VHIMMessageModel,
  VHMsgData,
  VHQuestionAnswerSwitchMsg,
  VHQuestionAnswerDeleteMsg,
  VHQuestionAnswerLikeMsg,
  VHQuestionAnswerMsg,
  VHQuestionAnswerRecommendMsg,
  VHQuestionAnswerSetMsg,
  VHRoomEventType,
  VHUserData
} from '@vhall/vhall_live';
import { EmitterMsgData, EmitterUtil } from '../../util/EmitterUtil';

export class EmitterMessage {
  public static handleGiftMsg(message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    let gifData = message.data as VHGiftMessageInfo
    msgData = {
      type: VHRoomEventType.GIFT_MSG,
      data: gifData
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleChatDisableAll(message: VHIMMessageModel) {
    let chatDisableAllMsg = message.data as VHChatDisableAllMsg;
    let msgData: EmitterMsgData;
    msgData = {
      type: VHRoomEventType.CHAT_DISABLE_ALL,
      data: chatDisableAllMsg
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleChatPermitAll(message: VHIMMessageModel) {
    let chatDisableAllMsg = message.data as VHChatDisableAllMsg;
    let msgData: EmitterMsgData;
    msgData = {
      type: VHRoomEventType.CHAT_PERMIT_ALL,
      data: chatDisableAllMsg
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleChatDisable(message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    msgData = {
      type: VHRoomEventType.CHAT_DISABLE,
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleChatPermit(message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    msgData = {
      type: VHRoomEventType.CHAT_PERMIT,
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleChatImText(type: string, message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    if (type === VHRoomEventType.IM_TEXT) {
      let content =message.data as VHMsgData;
      if (content.target_id!==undefined && content.target_id.length > 0) {
        // target_id有值时，为私聊消息
        msgData = {
          type: VHRoomEventType.IM_PRIVATE_TEXT,
          data: message
        } as EmitterMsgData;
        EmitterUtil.send(msgData);
      } else {
        // 普通聊天消息
        msgData = {
          type: VHRoomEventType.IM_TEXT,
          data: message
        } as EmitterMsgData;
        EmitterUtil.send(msgData);
      }
    }
  }

  public static handleCustomMessage(type: string, message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    msgData = {
      type: type,
      data: message
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handlePauseTimer(type: string, message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    let pauseMsg = message.data as VHTimerPauseMsg;
    msgData = {
      type: type,
      data: pauseMsg
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleDataDownloadUpdateMsg(message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    let updateMsg = message.data as VHDataDownloadUpdateMsg;
    msgData = {
      type: VHRoomEventType.DATA_DOWNLOAD_UPDATE,
      data: updateMsg
    } as EmitterMsgData;
    EmitterUtil.send(msgData);

  }

  public static handleChatMsgSetRecommend(message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    let chatMsg = message.data as VHChatMsgSetRecommend;
    msgData = {
      type: VHRoomEventType.CHAT_MSG_SET_RECOMMEND,
      data: chatMsg
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleChatMsgDelRecommend(message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    let chatMsg = message.data as VHChatMsgDelRecommend;
    msgData = {
      type: VHRoomEventType.CHAT_MSG_DEL_RECOMMEND,
      data: chatMsg
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleChatDelete(message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    let chatMsg = message.data as VHChatDeleteMsg;
    msgData = {
      type: VHRoomEventType.CHAT_DELETE,
      data: chatMsg
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleBaseUpdateMsg(message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    let baseNum: VHBaseNumUpdate;
    baseNum = message.data as VHBaseNumUpdate;
    msgData = {
      type: VHRoomEventType.BASE_NUM_UPDATE,
      data: baseNum
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleQuestionAnswerCreate(message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    let questionAnswerMsg = message.data as VHQuestionAnswerMsg
    msgData = {
      type: VHRoomEventType.QUESTION_ANSWER_CREATE,
      data: questionAnswerMsg
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleQuestionAnswerCommit(message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    let questionAnswerMsg = message.data as VHQuestionAnswerMsg
    msgData = {
      type: VHRoomEventType.QUESTION_ANSWER_COMMIT,
      data: questionAnswerMsg
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleQuestionAnswerNotReplaying(message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    let questionAnswerMsg = message.data as VHQuestionAnswerMsg
    msgData = {
      type: VHRoomEventType.QUESTION_ANSWER_NOT_REPLAYING,
      data: questionAnswerMsg
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleQuestionAnswerDeleteMsg(message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    let questionAnswerDeleteMsg = message.data as VHQuestionAnswerDeleteMsg;
    msgData = {
      type: VHRoomEventType.QUESTION_ANSWER_DELETE,
      data: questionAnswerDeleteMsg
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleQuestionAnswerBackOut(message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    let questionAnswerMsg = message.data as VHQuestionAnswerMsg
    msgData = {
      type: VHRoomEventType.QUESTION_ANSWER_BACKOUT,
      data: questionAnswerMsg
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleQuestionAnswerSet(message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    let questionAnswerMsg = message.data as VHQuestionAnswerSetMsg
    msgData = {
      type: VHRoomEventType.QUESTION_ANSWER_SET,
      data: questionAnswerMsg
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleQuestionAnswerLike(message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    let questionAnswerMsg = message.data as VHQuestionAnswerLikeMsg
    msgData = {
      type: VHRoomEventType.QUESTION_ANSWER_LIKE,
      data: questionAnswerMsg
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleQuestionAnswerRecommend(message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    let questionAnswerMsg = message.data as VHQuestionAnswerRecommendMsg
    msgData = {
      type: VHRoomEventType.QUESTION_ANSWER_RECOMMEND,
      data: questionAnswerMsg
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleAnnouncementMsg(message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    let announcementData = message.data as VHAnnouncementData;
    msgData = {
      type: VHRoomEventType.ROOM_ANNOUNCEMENT,
      data: announcementData,
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleTimer(type: string, message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    let timerMsg = message.data as VHTimerMsg;
    msgData = {
      type: type,
      data: timerMsg
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleQuestionAnswerOpenClose(type: string, message: VHIMMessageModel) {
    let msgData: EmitterMsgData;
    // 问答开启及关闭消息
    let questionAnswerData: VHQuestionAnswerSwitchMsg = message.data as VHQuestionAnswerSwitchMsg;
    msgData = {
      type: type,
      data: questionAnswerData
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }

  public static handleOnlineMessage(type: string, message: VHUserData) {
    let msgData: EmitterMsgData;
    msgData = {
      type: type,
      data: message
    } as EmitterMsgData;
    EmitterUtil.send(msgData);
  }
}