/**
 * @description 消息类型
 * **/
export class VHRoomEventType {
  /**
   * @description 发起签到消息. 签到消息 VHSignData
   * */
  static SIGN_IN_PUSH: string = "sign_in_push";
  /**
   * @description 结束签到消息. 签到消息 VHSignData
   * */
  static SIGN_END: string = "sign_end";
  /**
   * @description 聊天文本消息
   * */
  static IM_TEXT: string = "im_text";
  /**
   * @description 用户上下线消息
   * */
  static ON_LINE: string = "on_line";
  /**
   * @description 自定义消息
   * */
  static CUSTOM_MSG: string = "custom_msg";
  /**
   * @description 房间公告消息
   * */
  static ROOM_ANNOUNCEMENT: string = "room_announcement"
  /**
   * @description 删除房间公告消息
   * */
  static DEL_ROOM_ANNOUNCEMENT: string = "del_room_announcement"
  /**
   * @description 发送礼物消息
   * */
  static GIFT_MSG: string = "gift_send_success";
  /**
   * @description 点赞消息
   * */
  static CUSTOM_PRAISE: string = "customPraiseTotal";
  /**
   * @description 开屏广告消息
   * */
  static SCREEN_POSTER: string = 'screenPoster';
  /**
   * @description 接收图片消息
   * */
  static IM_IMAGE: string = "image";
  /**
   * @description 开始直播消息
   * */
  static LIVE_START: string = "live_start";
  /**
   * @description 结束直播消息
   * */
  static LIVE_OVER: string = "live_over";
  /**
   * @description 发起抽奖消息
   */
  static LOTTERY_PUSH: string = "lottery_push";
  /**
   * @description 抽奖结果通知消息
   * */
  static LOTTERY_RESULT_NOTICE: string = "lottery_result_notice";
  /**
   * @description 用户上线消息
   * */
  static USER_JOIN: string = "Join";
  /**
   * @description 用户下线消息
   * */
  static USER_LEAVE: string = "Leave";
  /**
   * @description 开启问答消息
   * */
  static QUESTION_ANSWER_OPEN: string = "question_answer_open";
  /**
   * @description 关闭问答消息
   * */
  static QUESTION_ANSWER_CLOSE: string = "question_answer_close";
  /**
   * @description 问答类型
   * */
  static QUESTION_ANSWER_QUESTION: string = "question";
  /**
   * @description 问答类型
   * */
  static QUESTION_ANSWER_ANSWER: string = "answer";
  /**
   * @description 通过并回复，或直播中回复
   * */
  static QUESTION_ANSWER_COMMIT: string = "question_answer_commit";
  /**
   * @description 提交问答
   * */
  static QUESTION_ANSWER_CREATE: string = "question_answer_create";
  /**
   * @description 不处理
   * */
  static QUESTION_ANSWER_NOT_REPLAYING: string = "question_answer_not_replaying";
  /**
   * @description 删除问答
   * */
  static QUESTION_ANSWER_DELETE: string = "qa_delete";
  /**
   * @description 撤销回复
   * */
  static QUESTION_ANSWER_BACKOUT: string = "question_answer_backout";
  /**
   * @description 点赞数
   * */
  static IM_LIKE: string = "like";
  /**
   * @description 消息类型
   * */
  static IM_TYPE_TEXT: string = "text";
  /**
   * @description 虚拟人数更新消息
   * */
  static BASE_NUM_UPDATE: string = "base_num_update";
  /**
   * @description 问卷推送消息
   * */
  static QUESTIONNAIRE_PUSH: string = "questionnaire_push";
  /**
   * @description 开始计时器消息
   * */
  static TIMER_START: string = 'timer_start';
  /**
   * @description 继续计时器消息
   * */
  static TIMER_RESUME: string = 'timer_resume';
  /**
   * @description 重置计时器消息
   * */
  static TIMER_RESET: string = 'timer_reset';
  /**
   * @description 暂停计时器消息
   * */
  static TIMER_PAUSE: string = 'timer_pause';
  /**
   * @description 结束计时器
   * */
  static TIMER_END: string = 'timer_end';
  /*
   * @description 快问快答推送答题
   * */
  static PAPER_SEND: string = 'paper_send';
  /*
   * @description 快问快答 公布成绩 消息
   * */
  static PAPER_SEND_RANK: string = 'paper_send_rank';
  /*
   * @description 快问快答 自动公布成绩消息
   * */
  static PAPER_AUTO_SEND_RANK: string = 'paper_auto_send_rank';
  /*
   * @description 快问快答 结束消息
   * */
  static PAPER_END: string = 'paper_end';
  /**
   * @description 用户踢出消息
   * */
  static ROOM_KICK_OUT: string = 'room_kickout';
  /**
   * @description 取消用户踢出
   * */
  static ROOM_KICK_OUT_CANCEL: string = 'room_kickout_cancel';
  /**
   * @description 聊天禁言
   * */
  static CHAT_DISABLE: string = 'disable';
  /**
   * @description 取消聊天禁言
   * */
  static CHAT_PERMIT: string = 'permit';
  /**
   * @description 所有人禁言
   * */
  static CHAT_DISABLE_ALL:string = 'disable_all';
  /**
   * @description 取消所有人禁言
   * */
  static CHAT_PERMIT_ALL:string = 'permit_all';
  /**
   * @description 推屏卡片消息
   * */
  static PUSH_SCREEN_CARD: string = 'push_screen_card';
  /**
   * @description 删除推屏卡片消息
   * */
  static PUSH_SCREEN_CARD_DELETE: string = 'push_screen_card_delete';
  /**
   * @description 推送观看有礼消息
   * */
  static WATCH_GIFT_OPEN: string = 'watch_gift_open';
  /**
   * @description 观看有礼结束消息
   * */
  static WATCH_GIFT_END: string = 'watch_gift_end';
  /**
   * @description 互动有礼中奖推送消息
   * */
  static PUSH_INTERACT_REWARD_WINNING_NOTICE = 'interact_reward_winning_notice';
  /**
   * @description 推送商品消息
   * */
  static PUSH_GOODS_CHANGE: string = 'push_goods_change';
  /**
   * @description 商品更新
   * */
  static GOODS_UPDATE_INFO = 'goods_update_info';
  /**
   * @description 商品数据更新
   * */
  static DATA_DOWNLOAD_UPDATE = 'data_download_update';
  /**
   * @description 问答开启或关闭所有观众可见
   *  */
  static QUESTION_ANSWER_SET = 'question_answer_set';
  /**
   * @description 问答点赞
   *  */
  static QUESTION_ANSWER_LIKE= 'qa_like';
  /**
   * @description 问答推荐
   *  */
  static QUESTION_ANSWER_RECOMMEND= 'qa_recommend';
  /**
   * @description 私聊文本消息
   *  */
  static IM_PRIVATE_TEXT = "im_private_text";
  /**
   * @description 用户被禁言后聊天感知状态
   *  */
  static IM_BANNED_MODE_UPDATE = "banned_mode_update";
  /**
   * @description 聊天昵称加密事件
   *  */
  static IM_CHAT_NICK_NAME_ENCRYPTION = "chat_nickname_encryption";
  /**
   * @description 口令红包消息
   * */
  static PUSH_PWD_RED_ENVELOPE_OK = 'pwd_red_envelope_ok';
  /**
   * @description 清空聊天消息
   *  */
  static CLEAR_CHAT_MESSAGE: string = 'clear_chat_message';
  /**
   * @description 删除聊天消息
   *  */
  static CHAT_DELETE: string = 'chat_delete';
  /**
   * @description 聊天设置精选
   *  */
  static CHAT_MSG_SET_RECOMMEND: string = 'chat_msg_set_recommend';
  /**
   * @description 取消精选消息
   *  */
  static CHAT_MSG_DEL_RECOMMEND: string = 'chat_msg_del_recommend';

}