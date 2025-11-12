/**
 * @description 礼物清单
 */
export class GiftMessageInfo {
  /**
   * @description 房间ID
   */
  room_id: string = "";
  /**
   * @description 送礼用户昵称
   */
  gift_user_nickname: string = "";
  /**
   * @description 礼物ID
   */
  gift_id: number = 0;
  /**
   * @description 事件类型（此处为礼物发送成功）
   */
  type: String = "";
  // 送礼用户名称
  /**
   * @description 房间ID
   */
  gift_user_name: string = "";
  // 礼物图片URL（该URL指向的图片目前无法解析出文本信息）
  /**
   * @description 房间ID
   */
  gift_image_url: string = "";
  /**
   * @description 礼物创建者ID
   */
  gift_creator_id: string = "";
  /**
   * @description 送礼用户ID
   */
  gift_user_id: string = "";
  /**
   * @description 送礼用户头像
   */
  gift_user_avatar: string = "";
  /**
   * @description 礼物名称
   */
  gift_name: string = "";
  /**
   * @description 收礼用户ID
   */
  gift_receiver_id: number = 0;
  /**
   * @description 礼物价格
   */
  gift_price: number = 0;
  /**
   * @description 来源状态
   */
  source_status: string = "";
}

/**
 * @description 获取房间的点赞数量
 */
export class RoomLikeInfo {
  /**
   * @description 当前房间实际点赞数量
   */
  total: string = "";
  /**
   * @description 虚拟点赞数
   */
  virtual_count: string = "";
}

/// 定义点赞图标数据结构
export class LikeIcon {
  /**
   * @description X坐标
   */
  x: number = 0
  /**
   * @description Y坐标
   */
  y: number = 0
  /**
   * @description 初始X坐标
   */
  initialX: number = 0
  /**
   * @description 当初始Y坐标
   */
  initialY: number = 0
  /**
   * @description 半径
   */
  radius: number = 0
  /**
   * @description emoji表情资源
   */
  emoji: string = ''
  /**
   * @description 字体大小
   */
  fontSize: number = 0
  /**
   * @description 透明度
   */
  opacity: number = 0
  /**
   * @description 创建时间
   */
  createTime: number = 0
  /**
   * @description 生命周期(毫秒)
   */
  lifespan: number = 0
  /**
   * @description 当前缩放比例
   */
  scale: number = 0
  /**
   * @description 初始缩放比例
   */
  initialScale: number = 0
  /**
   * @description 最大缩放比例
   */
  maxScale: number = 0
  /**
   * @description 最大摆动幅度
   */
  maxOffset: number = 0
  /**
   * @description 摆动方向 (+1或-1)
   */
  direction: number = 0
}

export class VHQuestionAnswer {
  /**
   * @description 角色名
   */
  role_name: string = "";
  /**
   * @description 是否全员可见
   */
  question_public_status: string = "";
  /**
   * @description 事件类型
   */
  event_type: string = "";
  /**
   * @description 名称
   */
  nick_name: string = "";
  /**
   * @description 问答名称
   */
  name: string = "";
  /**
   * @description 类型
   */
  type: string = "";
}

/**
 * @description 聊天消息列表
 */
export class VHQuestionHistoryList {
  /**
   * @description 消息内容
   */
  list: VHQuestionHistoryInfo[] = [];
}

export class VHQuestionHistoryInfo {
  /**
   * @description 记录类型 : question 或者 answer
   */
  type: string = "";
  /**
   * @description 问题的id
   */
  id: string = "";
  /**
   * @description 昵称
   */
  nick_name: string = "";
  /**
   * @description 提问内容
   */
  content: string = "";
  /**
   * @description 问题的id
   */
  join_id: string = "";
  /**
   * @description 回复时间
   */
  created_at: string = "";
  /**
   * @description 创建时间
   */
  created_time: string = "";
  /**
   * @description 角色
   */
  role_name: string = "";
  /**
   * @description 是否为私密回答
   */
  is_open: number = 0;
  /**
   * @description 是否仅通过：1.是，0.否（为1时不显示答案内容）
   */
  is_only_pass: number = 0;
  /**
   * @description 参会人员的头像
   */
  avatar: string = "";
  /**
   * @description 同问数
   */
  like_count: number = 0;
  /**
   * @description 同问状态：1.已同问，0.未同问
   */
  like_status: number = 0;
  /**
   * @description 是否已推荐：1.是，0.否
   */
  recommend_status: number = 0;
  /**
   * @description 回复内容(如果主持人回复了此条内容才有)
   */
  answer: VHQuestionHistoryInfo | null = null;

  constructor(type: string, nick_name: string, content: string, created_time: string, avatar: string,
    answer: VHQuestionHistoryInfo,id: string) {
    this.id = id;
    this.type = type;
    this.nick_name = nick_name;
    this.content = content;
    this.created_time = created_time;
    this.avatar = avatar;
    this.answer = answer;
  }
}

export class VHQuestionAnswerMsg {
  account_id: string = "";
  /**
   * @description 用户头像
   */
  avatar: string = "";
  /**
   * @description 消息内容
   */
  content: string = "";
  created_at: string = "";
  created_time: string = "";
  event_type: string = "";
  id: number = 0;
  join_id: string = "";
  nick_name: string = "";
  sequence: number = 0;
  /**
   * @description 类型
   */
  type: string = "";
  /**
   * @description 问题id
   */
  question_id: string = "";
  /**
   * @description 问题id
   */
  question_answer_id: string = "";
  /**
   * @description 回复消息
   */
  answer: VHQuestionHistoryInfo | null = null;
}



export class VHQuestionAnswerDeleteMsg {
  /**
   * @description 回答id
   */
  answer_ids: string = "";
  /**
   * @description 事件类型
   */
  event_type: string = "";
  /**
   * @description 活动id
   */
  webinar_id: string = "";
  /**
   * @description 类型
   */
  type: string = "";
  /**
   * @description 问题id
   */
  question_ids: string = "";
}

export class TimerMsg {
  /**
   * @description 总时间   秒
   */
  duration: string = "";
  /**
   * @description 是否所有人可见   0=不可见|1=可见
   */
  is_all_show: string = "";
  /**
   * @description 是否允许超时   0=否|1=是
   */
  is_timeout: string = "";
  /**
   * @description 剩余时间 秒
   */
  remain_time: number = 0;
  /**
   * @description 4=暂停
   */
  status: string = "";
  /**
   * @description 事件类型
   */
  event_type: string = "";
  /**
   * @description 角色
   */
  role_name: string = "";
  /**
   * @description 房间号
   */
  room_id: string = "";
  /**
   * @description 类型
   */
  type: string = "";
}

export class TimerPauseMsg {
  /**
   * @description 类型
   */
  type: string = "";
  /**
   * @description 角色
   */
  role_name: string = "";
  /**
   * @description 暂停时间
   */
  remain_time: number = 0;
}


/**
 * @description 成员详细信息
 */
export class VHMemberInfo {
  /**
   * @description role_name 角色类型 1 主持人，2 观众，3 助理，4 嘉宾
   */
  role_name: number = 0;
  /**
   * @description 是否允许发言（0：不允许，1：允许）
   */
  is_speak: number = 0;
  /**
   * @description 设备状态1 可用 0 不可用
   */
  device_status: number = 0;
  /**
   * @description 用户账号ID
   */
  account_id: string = "";
  /**
   * @description 是否处于申请状态（0：否，1：是）
   */
  is_apply: number = 0;
  /**
   * @description 成员昵称
   */
  nickname: string = "";
  /**
   * @description 设备类型 0其他，1移动端 2PC 3 SDK
   */
  device_type: number = 0;
  /**
   * @description 用户头像URL地址
   */
  avatar: string = "";
  /**
   * @description 是否被禁言（0：未禁言，1：已禁言）
   */
  is_banned: number = 0;
}

export class VHRoomKickOutMsg {
  /**
   * @description 事件类型（固定为房间踢出事件）
   */
  event_type: string = "room_kickout";
  /**
   * @description 房间加入ID
   */
  room_join_id: string = "";
  /**
   * @description 用户昵称
   */
  nick_name: string = "";
  /**
   * @description 成员信息
   */
  member_info: VHMemberInfo = new VHMemberInfo();
  /**
   * @description 被踢出目标用户的账号ID
   */
  target_id: string = "";
  /**
   * @description 事件类型（与event_type一致，冗余字段，需结合业务确认是否保留）
   */
  type: string = "room_kickout";
  /**
   * @description 事件推送时间（格式：YYYY-MM-DD HH:MM:SS）
   */
  push_time: string = "";
}

export class VHDisableMsg {
  /**
   * @description 事件类型
   */
  event_type: string = "";
  /**
   * @description 房间加入ID
   */
  room_join_id: string = "";
  /**
   * @description 操作者用户昵称
   */
  nick_name: string = "";
  /**
   * @description 目标用户ID
   */
  target_id: string = "";
  /**
   * @description 用户头像URL
   */
  avatar: string = "";
  /**
   * @description 事件类型
   */
  type: string = "";
}

/**
 * @description 推屏卡片
 *
 * **/

export class VHPushScreenCard {
  /**
   * @description 事件类型
   */
  event_type: string = "";
  /**
   * @description 事件类型（与event_type一致）
   */
  type: string = "";
  /**
   * @description 卡片详细信息
   */
  card_info: VHCardInfo = new VHCardInfo();
}

/**
 * @description 卡片详细信息
 */
export class VHCardInfo {
  /**
   * @description 计时器是否启用（1：启用，0：禁用）
   */
  timer_enable: number = 0;
  /**
   * @description 操作者角色 eg.主持人
   */
  operator_role: string = "";
  /**
   * @description 图片比例 0竖版 1横板 2方形
   */
  img_rate: number = 0;
  /**
   * @description 创建时间（格式：YYYY-MM-DD HH:MM:SS）
   */
  created_at: string = "";
  /**
   * @description 描述信息
   */
  remark: string = "";
  /**
   * @description 活动场次id
   */
  switch_id: number = 0;
  /**
   * @description 倒计时（秒）
   */
  timer_interval: number = 0;
  /**
   * @description 卡片标题
   */
  title: string = "";
  /**
   * @description 链接是否启用（1：启用，0：禁用）
   */
  href_enable: number = 0;
  /**
   * @description 操作者名称
   */
  operator: string = "";
  /**
   * @description 显示模式 0弹窗 1气泡提醒
   */
  show_mode: number = 0;
  /**
   * @description 关闭按钮文案
   */
  href_btn_label: string = "";
  /**
   * @description 链接地址
   */
  href: string = "";
  /**
   * @description 角色名称标识 role_name: 1 主持人，2 观众，3 助理，4 嘉宾
   */
  role_name: string = "";
  /**
   * @description 更新时间（格式：YYYY-MM-DD HH:MM:SS）
   */
  updated_at: string = "";
  /**
   * @description 用户ID
   */
  user_id: number = 0;
  /**
   * @description 图片URL地址
   */
  img_url: string = "";
  /**
   * @description webinar ID
   */
  webinar_id: number = 0;
  /**
   * @description 卡片ID
   */
  id: number = 0;
  /**
   * @description 推送时间（格式：YYYY-MM-DD HH:MM:SS）
   */
  push_time: string = "";
}

/**
 * @description 推送观看有礼消息
 * **/
export class VHWatchGiftOpenMsg {
  /**
   * @description 推送者昵称
   */
  pusher_name: string = "";
  /**
   * @description role_name 角色类型 1 主持人，2 观众，3 助理，4 嘉宾
   */
  role_name: string = "";
  /**
   * @description 推送id
   */
  id: number = 0;
  /**
   * @description 观看时长 分钟
   */
  watch_minute: number = 0;
  /**
   * @description 展示效果 0 全屏展示，1 半屏展示
   */
  display_of_results: number = 0;
  /**
   * @description 消息类型 watch_gift_open
   */
  type: string = "";
  /**
   * @description 标题
   */
  title: string = "";
}

/**
 * @description 推送观看有礼消息
 * **/
export class VHWatchGiftEndMsg {
  /**
   * @description 标题
   */
  title: string = "";
  /**
   * @description 推送id
   */
  id: number = 0;
  /**
   * @description 消息类型 watch_gift_open
   */
  type: string = "";
}

/**
 * @description 观看有礼信息
 * **/
export class VHWatchGiftInfo {
  /**
   * @description 观看有礼 ID
   */
  id?: number;
  /**
   * @description B 端用户 ID
   */
  business_uid?: number;
  /**
   * @description 标题
   */
  title?: string;
  /**
   * @description 观看时长，观看几分钟能抽奖
   */
  watch_minute?: number;
  /**
   * @description 展示效果 0 全屏展示，1 半屏展示
   */
  display_of_results?: number;
  /**
   * @description 是否可以显示中将名单 0不显示 1 显示
   */
  can_look_winner_list?: number;
  /**
   * @description 状态： 1 已推送，2 已结束
   */
  state?: number;
  /**
   * @description 中奖次数(当前用户在本场活动中过几次奖)
   */
  winners_times?: number;
  /**
   * @description 当前观看有礼中奖状态， 0 未抽奖，1 未中奖，2 已中奖，3 已领奖
   */
  winners_state?: number;
  /**
   * @description 用户在当前活动的领奖次数
   */
  take_award_times?: number;
  /**
   * @description 在线时长
   */
  online_duration?: number
}


/**
 * @description 奖项列表响应体
 */
export class VHWatchGiftAward {
  /**
   * @description 奖项总数
   */
  total: number = 0;
  /**
   * @description 奖项列表
   */
  list: VHGiftAwardItem[] = [];
}

/**
 * @description 奖项列表项
 */
export class VHGiftAwardItem {
  /**
   * @description 数量
   */
  quantity: string = "";
  /**
   * @description 排序值
   */
  sort: number = 0;
  /**
   * @description 场景：0=抽奖 1=观看有礼
   */
  scenes: number = 0;
  /**
   * @description 扩展信息
   */
  extension: string = "";
  /**
   * @description 奖项ID
   */
  award_id: number = 0;
  /**
   * @description 奖项名称
   */
  award_name: string = "";
  /**
   * @description 奖项图片URL
   */
  award_img_url: string = "";
  /**
   * @description 奖项描述
   */
  award_desc: string = "";
  /**
   * @description 创建时间（格式：YYYY-MM-DD HH:MM:SS）
   */
  create_time: string = "";
  /**
   * @description 奖品类型：0-自定义奖品 1-优惠券奖品 2-礼品 3-三方奖品 默认0
   */
  award_type: string = "";
  /**
   * @description 优惠券ID
   */
  coupon_id: string = "";
  /**
   * @description 第三方抽奖ID
   */
  third_lottery_id: string = "";
}

/**
 * @description 参数观看有礼响应消息
 * */

export class VHWatchGiftParticipate {
  /**
   * @description 是否中将 0未中奖，1 中奖
   * */
  winning: number = 0;
  /**
   * @description 中奖id
   * */
  award_id: number = 0;
  /**
   * @description 奖品名称
   * */
  award_name: string = "";
  /**
   * @description 奖品预览地址
   * */
  award_img_url: string = "";
  /**
   * @description 奖品描述
   * */
  award_desc: string = "";
}

/**
 * @description 中奖用户详情
 * */

export class VHWatchGiftWinnerDetail {
  /**
   * @description 观看有礼id
   * */
  watch_gift_id: number = 0;
  /**
   * @description 中奖者id
   * */
  winner_join_id: number = 0;
  /**
   * @description 奖品名称
   * */
  award_name: string = "";
  /**
   * @description 奖品预览地址
   * */
  award_img_url: string = "";
  /**
   * @description 是否允许查看中奖用户列表
   * */
  winner_award_remark: number | null = 0;
  /**
   * @description 是否允许查看中奖用户列表
   * */
  can_look_winner_list: number = 0;
}


/**
 * @description 中奖提交信息详情
 * */

export class VHGiftAwardFiled {
  /**
   * @description 填写内容
   * */
  field_value: string = "";
  /**
   * @description field名称
   * */
  field: string = "";
  /**
   * @description field_key 名字
   * */
  field_key: string = "";
  /**
   * @description 是否必填 true 必填，false 非必填
   * */
  is_required: boolean = true;
  /**
   * @description 是否系统自带选项。1 是 0否（自定义填写内容）
   * */
  is_system: number = 1;
  /**
   * @description 提示语
   * */
  placeholder: string = "";
  /**
   * @description 排列顺序
   * */
  rank: number = 0;
  /**
   * @description 是否需要校验 1：需要校验
   * */
  is_check: number | null = 0;
}

/**
 * @description 中奖地址信息填写
 * */
export class VHWatchGiftSetting {
  /**
   * @description 领奖方式。 1：寄送礼品，2：私信兑奖  3：无需领奖
   * */
  receive_award_way: number = 1;
  /**
   * @description 强制领奖开关。 开启后，中奖用户在未完成领奖时将无法关闭中奖页面及提交领奖页
   * */
  compulsory_award: number = 1;
  /**
   * @description 寄送礼品，填写信息
   * */
  receive_award_field: VHGiftAwardFiled[] = [];
}

/**
 * @description 中奖用户信息
 * */
export class VHWatchGiftWinner {
  /**
   * @description 中奖id
   * */
  watch_gift_id: number = 0;
  /**
   * @description 中奖者join id
   * */
  winner_join_id: number = 0;
  /**
   * @description 中奖者昵称
   * */
  winner_nickname: string = "";
  /**
   * @description 中奖者名字
   * */
  winner_name: string | null = "";
  /**
   * @description 中奖者头像
   * */
  winner_avatar: string = "";
  /**
   * @description 活动id
   * */
  webinar_id: string = "";
  /**
   * @description 奖品名称
   * */
  award_name: string = "";
  /**
   * @description 奖品url
   * */
  award_img_url: string = "";
  /**
   * @description 中奖时间
   * */
  winner_at: string = "";
}


/**
 * @description 中奖名单
 * */
export class VHWinner {
  /**
   * 中奖人数
   * **/
  total: number = 0;
  /**
   * 中奖列表
   * **/
  list: VHWatchGiftWinner[] = [];
}

export class VHAwardSnapshot {
  /**
   * @description奖品名称
   * */
  award_name: string = "";
  /**
   * @description奖品图片地址
   * **/
  award_img_url: string = "";
  /**
   * @description中奖id
   * **/
  award_id: number = 0;
}

/**
 * 互动有礼中奖推送消息
 * **/
export class VHInteractRewardWinning {
  room_id: string = "";
  /**
   * 1强制领奖，强制领奖开关。 开启后，中奖用户在未完成领奖时将无法关闭中奖页面及提交领奖页
   * **/
  compulsory_award: number = 0;
  /**
   * @description 领奖方式。 1：寄送礼品，2：私信兑奖  3：无需领奖
   * */
  receive_award_way: number = 0;
  /**
   * 互动有礼id
   * */
  interact_reward_id: number = 0;
  /**
   * 中奖用户头像
   * **/
  winner_avatar: string = "";
  /**
   * 中奖用户id
   * **/
  winner_id: string = "";
  /**
   * @description 展示效果 0 全屏展示，1 半屏展示
   */
  display_of_results: number = 0;
  /**
   * 奖品title
   * */
  title: string = ""
  /**
   * 消息类型
   * */
  type: string = "interact_reward_winning_notice"
  /**
   * 中奖用户昵称
   * */
  winner_nickname: string = "";
  award_snapshot: VHAwardSnapshot = new VHAwardSnapshot();
}

export class VHInteractAwardSetting {
  /**
   * 领奖方式，1-寄送奖品 2-私信兑奖 3-无需领奖
   * **/
  receive_award_way: number = 1;
  json_data: VHGiftAwardFiled[] = [];
  /**
   * 强制领奖，0-否（默认） 1-是
   * **/
  compulsory_award: number = 0;
  /**
   * 状态，是否使用自定义隐私协议
   * **/
  statement_status: number = 0;
  /**
   * 隐私协议文本内容
   * */
  statement_content: string = "";
  statement_info: VHStatementInfo[] = [];
}

export class VHStatementInfo {
  /**
   * 关键词
   * **/
  title: string = "";
  /**
   * 链接
   * **/
  link: string = "";
}

/**
 * @description问卷关联的互动有礼奖品列表数据
 * ***/
export class VHInteractMyAward {
  /**
   * @description奖品数量
   * **/
  total: number = 0;
  /**
   * @description礼物详情
   * **/
  list: VHInteractMyAwardDetails[] = [];
  /**
   * @description请求位置
   * */
  pos: number = 0;
  /**
   * @description请求个数
   * */
  limit: number = 0;
}

/**
 * @description活动中奖用户信息
 * **/
export class VHInteractWinnerInfo {
  /**
   * @description 中奖用户名称
   * */
  lottery_user_name: string = ""
  /**
   * @description 中奖用户手机号
   * */
  lottery_user_phone: string = ""
  /**
   * @description 中奖用户地址
   * */
  lottery_user_address: string = ""
}

/**
 * @description问卷关联的互动有礼奖品列表数据详情
 * ***/
export class VHInteractMyAwardDetails {
  /**
   * @description记录id
   * */
  id: number = 0;
  /**
   * @description领奖方式，1-寄送奖品 2-私信兑奖 3-无需领奖
   * */
  receive_award_way: number = 1;
  /**
   * @description展示效果，0-全屏（默认） 1-半屏
   * */
  display_of_results: number = 0;
  /**
   * @description奖品名称
   * */
  award_name: string = "";
  /**
   * @description奖品图片地址
   * */
  award_img_url: string = "";
  /**
   * @description中奖时间
   * */
  winning_time: string = "";
  /**
   * @description领取状态，0-未领取 1-已领取 2-已中奖
   * */
  status: number = 0;
  /**
   * @description中奖者领奖备注，即：用户提交的领奖信息
   * */
  winner_award_remark: string = "";
  /**
   * @description互动有礼id
   * */
  interact_reward_id: number = 0;
  /**
   * @description强制领奖：0否 1是
   * */
  compulsory_award: number = 0;
}

/**
 * @description活动中奖用户信息
 * **/
export class VHRedEnvelopeInfo {
  /**
   * @description 是否抢到：0-未抢到，1-抢到了
   * */
  status: number = 0
  /**
   * @description 红包口令
   * */
  red_code: string = ""
}

/**
 * @description 查看口令红包中奖用户信息
 * **/
export class VHRedEnvelopeUserListInfo {
  /**
   * @description中奖人数
   * */
  count: number = 0
  /**
   * @description获奖用户列表
   * */
  list: VHWinningUserListInfo[] = []
  /**
   * @description排序
   * */
  order: string = ""
}

/**
 * @description 口令红包中奖用户信息
 * **/
export class VHWinningUserListInfo {
  /**
   * 领取金额
   * */
  amount: number = 0;
  /**
   * 领取金额排名
   * */
  amount_ranking: number = 0;
  /**
   * 应用ID，用于标识所属应用
   * */
  app_id: string = "";
  /**
   * 用户头像URL地址
   * */
  avatar: string = "";
  /**
   * 记录创建时间
   * */
  created_at: string = "";
  /**
   * 删除标识
   * */
  deleted: number = 0;
  /**
   * 删除时间
   * */
  deleted_at: null = null;
  /**
   * 扩展信息
   * */
  extension: string = "";
  /**
   * 领取红包记录ID
   * */
  get_red_packet_record_id: number = 0;
  /**
   * 礼物类型标识
   * */
  gift_type: string = "";
  /**
   * 用户昵称
   * */
  nickname: string = "";
  /**
   * 占比
   * */
  percent: number = 100;
  /**
   * 红包ID
   * */
  red_packet_id: number = 0;
  /**
   * 来源ID，标识红包来源相关
   * */
  source_id: string = "";
  /**
   * 第三方用户ID
   * */
  third_party_user_id: string = "";
  /**
   * 记录更新时间
   * */
  updated_at: string = "";
}

export class VHChatDisableAllMsg {
  /**
   * @description 头像
   */
  avatar: string = "";
  /**
   * @description 聊天状态 0-允许 1-禁止
   */
  chat_status: number = 0;
  /**
   * @description 事件类型
   */
  event_type: string = "";
  /**
   * @description 昵称
   */
  nick_name: string = "";
  /**
   * @description 私聊状态 0-允许 1-禁止
   */
  private_chat_status: number = 0;
  /**
   * @description 问答状态 0-允许 1-禁止
   */
  qa_status: number = 0;
  /**
   * @description 消息类型
   */
  type: string = "";
}

/**
 * @description 获取当前活动正在发起的签到
 * **/
export class VHDoingSignInfo {
  /**
   * @description签到 ID
   * */
  id: string = ""
  /**
   * @description PaaS应用ID
   * */
  app_id: string = ""
  /**
   * @description创建者 ID
   * */
  creator_id: string = ""
  /**
   * @description创建者昵称
   * */
  creator_nickname: string = ""
  /**
   * @description创建者头像
   * */
  creator_avatar: string = ""
  /**
   * @description签到显示时间，单位秒
   * */
  show_time: string = ""
  /**
   * @description来源 ID
   * */
  source_id: string = ""
  /**
   * @description业务单元
   * */
  bu: string = ""
  /**
   * @description删除标识
   * */
  deleted: string = ""
  /**
   * @description创建时间
   * */
  created_at: string = ""
  /**
   * @description删除时间
   * */
  deleted_at: null = null
  /**
   * @description更新时间
   * */
  updated_at: null = null
  /**
   * @description签到提示语
   * */
  sign_tips: string = ""
  /**
   * @description是否自动发起签到
   * */
  is_auto_sign: string = ""
  /**
   * @description自动发起签到的轮询时间，单位秒
   * */
  auto_sign_time: number = 0
  /**
   * @description自动发起签到的倒计时
   * */
  auto_sign_time_ttl: number = 0
  /**
   * @description签到倒计时时间
   * */
  sign_time_ttl: number = 0
  /**
   * @description是否开启未签到用户自动踢出：1. 开启，0. 不开启
   * */
  auto_kick_unsigned: number = 0
  /**
   * @description签到成功提示语
   * */
  sign_in_success_tips: string = ""
  /**
   * @description推送方式：0. 手动推送，1. 定时推送
   * */
  push_type: number = 0
  /**
   * @description推送状态：0. 未推送，1. 已推送
   * */
  push_status: string = ""
  /**
   * @description定时签到的推送时间
   * */
  push_time: string = ""
}

export class DataDownloadUpdateMsg {
  /**
   * @description 用户ID
   */
  user_id: string = "";
  /**
   * @description 活动ID
   */
  webinar_id: string = "";
  /**
   * @description 名称（如"文件下载"）
   */
  name: string = "";
  /**
   * @description  数据类型（如"data_download_update"）
   */
  type: string = "";
  /**
   * @description 用户ID
   */
  config: FileConfigMsg = new FileConfigMsg();
  /**
   * @description 文件下载URL
   */
  url: string = "";
  /**
   * @description 菜单ID
   */
  menu_id: string = "";
  /**
   * @description  状态
   */
  status: number = 0;
}

export class FileConfigMsg {
  /**
   * @description 指定表单条件时是否支持填写报名表单也允许下载：1.是，0.否，默认为1
   */
  form_allow_download: number = 0;
  /**
   * @description 样式 list 列表 card 卡片
   */
  style: string = '';
  /**
   * @description 下载条件 0:无条件 1:问卷 2:登入 3:设置观看时长
   */
  where: string = '';
  /**
   * @description 条件ID
   */
  where_content: string = '';
  /**
   * @description 条件观看时间，单位分钟
   */
  where_watch_duration: number = 0;
}

export class VHQuestionAnswerSetMsg {
  /**
   * @description 开启状态：1开启，0关闭
   */
  question_public_status: string = '';
  /**
   * @description 事件类型
   */
  event_type: string = '';
  /**
   * @description 消息内容
   */
  name: string = '';
  /**
   * @description 消息类型
   */
  type: string = '';
}

export class VHQuestionAnswerLikeMsg {
  /**
   * @description 账号id
   */
  account_id: string = '';
  /**
   * @description 事件类型
   */
  event_type: string = '';
  /**
   * @description 点赞数
   */
  like_count: number = 0;
  /**
   * @description 状态：1点赞，0取消点赞
   */
  like_status: string = '';
  /**
   * @description 问题id
   */
  question_id: string = '';
  /**
   * @description 类 型
   */
  type: string = '';
  /**
   * @description 活动id
   */
  webinar_id: string = '';
}

export class VHQuestionAnswerRecommendMsg {

  /**
   * @description 事件类型
   */
  event_type: string = '';

  /**
   * @description 状态：1推荐，0取消推荐
   */
  recommend_status: string = '';
  /**
   * @description 问题id
   */
  question_id: string = '';
  /**
   * @description 类 型
   */
  type: string = '';
  /**
   * @description 活动id
   */
  webinar_id: string = '';
}

export class ChatDeleteMsg {
  /**
   * @description 事件类型
   */
  event_type: string = "";
  /**
   * @description 消息ID
   */
  msg_id: string = '';
  /**
   * @description 删除消息ID多个
   */
  msg_ids: string = '';
  /**
   * @description 类 型
   */
  type: string = '';
}

export class ChatMsgSetRecommend {
  /**
   * @description 事件类型
   */
  msg_content: string = "";
  /**
   * @description 消息ID
   */
  msg_id: string = '';

  /**
   * @description 类 型
   */
  type: string = '';
}

export class ChatMsgDelRecommend {
  /**
   * @description 消息ID
   */
  msg_id: string = '';

  /**
   * @description 类 型
   */
  type: string = '';
}

