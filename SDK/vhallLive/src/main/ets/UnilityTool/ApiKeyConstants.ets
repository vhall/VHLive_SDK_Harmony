export class ApiKeyConstants {
  /**
   * 第三方账号id（max：255字符）
   */
  static KEY_THIRD_USER_ID = "third_user_id";
  /**
   * 用户昵称（max：50字符）
   */
  static KEY_NICK_NAME = "nick_name";
  /**
   * 用户头像网络路径（max：255字符）
   */
  static KEY_HEAD_NET_URL = "head";
  //请求头公共参数
  static KEY_TOKEN = "token";
  static KEY_INTERACT_TOKEN = "interact-token";
  static KEY_ZONE = "zone";
  static KEY_REQUEST_ID = 'request-id';
  static KEY_PLATFORM = 'platform';
  static KEY_GRAY_ID = 'gray-id'; //灰度id
  static KEY_SIGN_SPECIAL = 'sign_special';
  static KEY_APP_KEY = 'app_key';
  static KEY_SIGNED_AT = 'signed_at';
  static KEY_SIGN = 'sign';
  static KEY_SIGN_TYPE = 'sign_type';
  static KEY_CLIENT_VERSION = 'client_version'
  static KEY_PACKAGE_NAME = 'package_name'
  static KEY_SIGNATURE = 'signature'
  static KEY_AUTH_MODE = 'auth_model';
  static KEY_WEBINAR_ID = 'webinar_id';
  static KEY_WEBINAR_USER_ID = 'webinar_user_id';
  static KEY_RECORD_ID = 'record_id';
  static KEY_E_MAIL = 'email';
  static KEY_NICKNAME = 'nickname';
  static KEY_PHONE = 'phone';
  static KEY_USERNAME = 'username';
  static KEY_REMARK = 'remark';
  static KEY_PASS = 'pass';
  static KEY_TYPE = 'type';
  static KEY_DATA = 'data';
  static KEY_VERIFY_VALUE = 'verify_value';
  static KEY_VISITOR_ID = 'visitor_id';
  static KEY_SCENE_ID = 'scene_id';
  static KEY_TAGS = 'tags';
  static KEY_SWITCH_ID = 'switch_id';
  static KEY_SCENE_TYPE = 'scene_type';
  static KEY_ID = 'id';
  static KEY_LIMIT = 'limit';
  static KEY_MSG_ID = 'msg_id';
  static KEY_ANCHOR_PATH = "anchor_path";
  static KEY_POS = 'pos';
  static KEY_IS_ROLE = 'is_role';
  static KEY_MSG_TYPE = 'msg_type';
  static KEY_KEYWORD = 'keyword';
  static KEY_START_TIME = 'start_time';
  static KEY_ROOM_ID = 'room_id';
  static KEY_CURRENT_TIME = 'currentTime'
  static KEY_SIGN_ID = 'sign_id'
  static KEY_ACCOUNT = 'account'
  static KEY_PASSWORD = 'password'
  static KEY_REMEMBER = 'remember'
  static KEY_DYNAMIC_CODE = 'dynamic_code'
  static KEY_GIFT_ID = 'gift_id'
  static KEY_CHANNEL = 'channel'
  static KEY_SERVICE_CODE = 'service_code'
  static KEY_OPEN_ID = 'open_id'
  static KEY_Like_COUNT = 'num'
  static KEY_MSG_CONTENT = 'content'
  static KEY_BIZ_ID = 'biz_id'
  static KEY_LOTTERY_ID = 'lottery_id'
  static KEY_LOTTERY_USER_NAME = 'lottery_user_name'
  static KEY_LOTTERY_USER_PHONE = 'lottery_user_phone'
  static KEY_LOTTERY_USER_REMARK = 'lottery_user_remark'
  static KEY_MENU_ID = 'menu_id'
  static KEY_FILE_ID = 'file_id'
  static KEY_VISIT_ID = 'visit_id'
  static KEY_DOWNLOAD_TYPE = 'download_type'
  static KEY_CURR_PAGE = "curr_page"
  static KEY_PAGE_SIZE = "page_size"
  static KEY_CARD_ID = "card_id"
  static KEY_WATCH_GIFT_ID = "watch_gift_id"
  static KEY_STATUS = "status"
  static KEY_WINNER_AWARD_REMARK = "winner_award_remark"
  static KEY_MODULE = 'module'
  static KEY_SOURCE_ID = 'source_id'
  static KEY_SOURCE_TYPE = 'source_type'
  static KEY_GOODS = "goods"
  static KEY_GOODS_ID = "goods_id"
  static KEY_GOODS_NUM = 'goods_num'
  static KEY_PAY_AMOUNT = 'pay_amount'
  static KEY_PAY_CHANNEL = 'pay_channel'
  static KEY_QUANTITY = 'quantity'
  static KEY_BUY_TYPE = 'buy_type'
  static KEY_SUBJECT_IDS = "subject_ids"
  static KEY_WEBINAR_IDS = "webinar_ids"
  static KEY_INVITE_ID = 'invite_id'
  static KEY_INVITE_ID_TYPE = 'invite_id_type'
  static KEY_LANGUAGE_TYPE = 'language_type'
  static KEY_BUSINESS_UID = "business_uid"
  static KEY_INTERACT_REWARD_ID = "interact_reward_id"
  static KEY_COUPON_USER_IDS = "coupon_user_ids"
  static KEY_RED_PACKET_UUID = "red_packet_uuid"
  static KEY_ORDER_TYPE = "order_type"
  static KEY_PATH = "path";
  static KEY_RESFILE = "resfile";
  static KEY_METHOD = "method";
  static KEY_SHOW_ALL = "show_all";
  static KEY_SURVEY_ID = "survey_id";
  static KEY_QUESTION_ID = "question_id";
  static KEY_LIKE_STATUS= "like_status";
  static KEY_PLAYBACK_FILLING = "playback_filling";
  static KEY_PAPER_ID = "paper_id";
  static KEY_FROM_CONSUMER = "from_consumer";
  static KEY_ACCOUNT_ID = "account_id";
  static KEY_ACCOUNT_TYPE = "account_type";
  static KEY_WEBINAR_SWITCH_ID = "webinar_switch_id";
  static KEY_URL = "url";
  static KEY_SHOW_URL = "show_url";

}

export class API_INTERFACE {
  /**
   * 活动 通过活动id获取活动拥有者用户id
   * 灰度id 获取
   */
  static API_INIT_BEFORE = "/v3/webinars/webinar/init-before";
  //回滚接口
  static API_VERSION_INIT_CONFIG = "/v3/commons/version/init-config";
  /**
   * http://yapi.vhall.domain/project/100/interface/api/24453
   * <p>
   * 发送验证码接口
   */
  static API_CODE_SEND = "/v3/users/code/send";
  /**
   * 登录
   * http://yapi.vhall.domain/project/100/interface/api/21429
   */
  static API_USER_LOGIN = "/v3/users/user/login";
  //登录 通过id
  static API_USER_LOGIN_THIRD_ID = "/v3/users/open-user/login"
  /**
   * 登出
   * http://yapi.vhall.domain/project/100/interface/api/21471
   */
  static API_USER_LOGOUT = "/v3/users/user/logout";
  /**
   * 获取用户信息
   * <p>
   * http://yapi.vhall.domain/project/100/interface/api/24507
   */
  static API_USER_GET_INFO = "/v3/users/user/get-info";
  /**
   * 活动 观看端 授权和获取授权状态
   */
  static API_GET_WEBINAR_WATCH_AUTH = "/v3/webinars/watch/sdk-auth";
  /**
   * 活动 观看端 获取直播信息
   */
  static API_GET_WEBINAR_WATCH_INFO = "/v3/webinars/watch/sdk-init";
  /**
   * 活动 检测配置项权限
   * <p>
   * http://yapi.vhall.domain/project/100/interface/api/28479
   */
  static API_GET_CONFIG_LIST = "/v3/users/permission/get-config-list";
  /**
   * 活动 获取活动角色配置接口.获取角色新名词
   * http://yapi.vhall.domain/project/99/interface/api/22119
   */
  static API_PRIVILEGE_INFO = "/v3/webinars/privilege/info";
  /**
   * 观看端-用户协议
   */
  static API_AGREEMENT = "/v3/interacts/agreement/get-agreement";
  /**
   * 观看端-用户同意观看协议
   */
  static API_SET_USER_AGREE_AGREEMENT = "/v3/interacts/agreement/set-user-agree";
  /**
   * 活动 获取直播状态接口
   */
  static API_GET_WEBINAR_STATE = "/v3/webinars/webinar/get-webinar-state";
  /**
   * 活动 获取角色名称
   */
  static API_GET_ROLE_NAME = "/v3/webinars/privilege/get-role-name";
  /**
   * 活动 标签列表接口
   */
  static API_LABEL_LIST = "/v3/webinars/label/get-list";
  /**
   * 聊天 观看端_提交一个提问
   */
  static API_SUBMIT_QUESTION = "/v3/interacts/qa/submit-one-question";
  /**
   * 聊天 观看端_获取当前活动的历史问答记录
   */
  static API_GET_QUESTION_HISTORY = "/v3/interacts/qa/get-webinar-history-questions";
  /**
   * 刷新token
   */
  static API_REFRESH_TOKEN = "/v3/users/user/refresh-token";
  /**
   * 获取分享信息
   */
  static API_SHARE_INFO = "/v3/webinars/share/info";
  /**
   * 房间 获取直播间互动工具状态
   */
  static API_GET_ROOM_STATUS = "/v3/interacts/room/get-inav-tool-status";
  /**
   * 聊天 获取当前房间聊天列表
   */
  static API_CHAT_GET_LIST = "/v3/interacts/chat/get-list";
  /**
   * 聊天 获取当前房间聊天列表（高频调用建议采用） 不返回问答私聊直接过滤
   */
  static API_CHAT_GET_LIST_LATEST = "/v3/interacts/chat/latest-list";
  /**
   * 聊天 发送自定义消息
   */
  static API_SEND_CUSTOM_MESSAGE = "/v3/interacts/chat/send-custom-message";
  /**
   * 聊天 获取禁言用户列表
   */
  static API_GET_BANNED_LIST = "/v3/interacts/chat-user/get-banned-list";
  /**
   * 聊天 获取踢出用户列表
   */
  static API_GET_KICKED_LIST = "/v3/interacts/chat-user/get-kicked-list";
  /**
   * 聊天 获取在线用户列表
   */
  static API_GET_ONLINE_LIST = "/v3/interacts/chat-user/get-online-list";
  /**
   * 聊天 获取特殊用户列表
   */
  static API_GET_SPECIAL_LIST = "/v3/interacts/chat-user/get-bounded-list";
  /**
   * 聊天 获取直播间互动工具状态
   */
  static API_GET_ROOM_NOTICE = "/v3/interacts/chat/get-announcement-list";
  /**
   * 文档 获取当前房间聊天列表
   */
  static API_GET_DOCUMENT_LIST = "/v3/interacts/document/get-webinar-document-list";
  /**
   * 文档 直播设置_获取活动下的文档列表
   */
  static API_GET_DOC_LIST = "/v3/interacts/document/get-webinar-document-list";
  /**
   * 抽奖 抽奖-立即参与
   */
  static API_JOIN_LOTTERY = "/v3/vss/lottery/participation";
  /**
   * 抽奖 抽奖-获取中奖用户列表
   */
  static API_USER_GET_LOTTERY = "/v3/vss/lottery/users-get";
  /**
   * 抽奖 领奖页-获取信息
   */
  static API_GET_PRIZE_INFO = "/v3/vss/lottery/watch/get-draw-prize-info";
  /**
   * 抽奖 新领奖页-获取信息， 包括 领奖方式1寄送奖品2私信兑奖3无需领奖 http://yapi.vhall.domain/project/101/interface/api/54735
   */
  static API_GET_PRIZE_INFO1 = "/v3/vss/lottery/get-receive-award-setting";
  /**
   * 抽奖 抽奖-保存中奖人领奖信息
   */
  static API_AWARD_LOTTERY = "/v3/vss/lottery/award";
  /**
   * 抽奖 抽奖-观看端-检查抽奖进行中 判断自己是否中奖
   */
  static API_AWARD_CHECK = "/v3/vss/lottery/check";
  /**
   * 抽奖 抽奖-观看端-检查抽奖列表接口
   */
  static API_AWARD_CHECK_LIST = "/v3/vss/lottery/check-list";
  /**
   * 观看端-抽奖-获取中奖人信息
   * http://yapi.vhall.domain/project/101/interface/api/53999
   */
  static API_AWARD_USER_INFO = "/v3/vss/lottery/user-info";
  /**
   * 观看端-抽奖-查看中奖详情
   * http://yapi.vhall.domain/project/101/interface/api/54018
   */
  static API_AWARD_USER_DETAIL = "/v3/vss/lottery/user-detail";
  /**
   * 签到 用户进行签到
   */
  static API_USER_SIGN = "/v3/interacts/sign/user-sign";

  /**
   * 签到 获取签到详情
   */
  static API_SIGN_GET_INFO = "/v3/interacts/sign/get-info";

  /**
   * 获取当前活动正在发起的签到
   */
  static API_DOING_SIGN = "/v3/interacts/sign/get-doing-sign";
  /*
   * 获取公告列表
   * */
  static API_ANNOUNCEMENT_LIST = "/v3/interacts/chat/get-announcement-list"
  // /*
  //  * 公告 获取快问快答列表
  //  * */
  // static API_PAPER_LIST = "/v3/interacts/exam/get-paper-list"
  /*
   * 获取快问快答列表
   * */
  static API_PAPER_LIST = "/v1/fqa/app/paper/get-push-list"
  /**
   * 问卷 查询房间历史问卷
   */
  static API_GET_HISTORY_SURVEY = "/v3/vss/survey/get-webinar-history-survey-list";
  /**
   * 走马灯接口
   */
  static API_SCROLLING = "/v3/interacts/players/get-scrolling-screen-config";
  /**
   * 获取轮询用户
   */
  static API_GET_ROUND_USERS = "/v3/interacts/video-round/get-round-users";
  /**
   * 查询计时器进度
   * http://yapi.vhall.domain/project/101/interface/api/42454
   */
  static API_TIMER_INFO = "/v3/interacts/timer/info";
  /**
   * 创建房间的用户点赞
   * <p>
   * http://yapi.vhall.domain/project/101/interface/api/26295
   */
  static API_CREATE_USER_LIKE = "/v3/interacts/like/create-user-like";
  /**
   * 获取房间的点赞数量
   * <p>
   * http://yapi.vhall.domain/project/101/interface/api/28245
   */
  static API_GET_ROOM_LIKE = "/v3/interacts/like/get-room-like";
  /**
   * 获取点赞总数量 当前用户
   * <p>
   * http://yapi.vhall.domain/project/101/interface/api/28251
   */
  static API_GET_ALL_LIKE = "/v3/interacts/like/get-all-like";
  /**
   * 观看端_获取活动使用的礼物列表
   * http://yapi.vhall.domain/project/101/interface/api/25815
   */
  static API_GET_GIFT_LIST = "/v3/interacts/gift/get-webinar-using-gift-list";
  /**
   * 发送礼物给主持人
   * <p>
   * http://yapi.vhall.domain/project/101/interface/api/25821
   */
  static API_SEND_GIFT = "/v3/interacts/gift/send-gift";
  /**
   * 互动配置聚合接口
   * <p>
   * http://yapi.vhall.domain/project/101/interface/api/40741
   */
  static API_COMMON_CONFIG = "/v3/interacts/union/common-config";
  /**
   * 互动播放器聚合配置
   * <p>
   * http://yapi.vhall.domain/project/101/interface/api/40742
   */
  static API_PLAYER_CONFIG = "/v3/interacts/union/player-config";
  /**
   * 获取暖场视频详情接口
   * <p>
   * http://yapi.vhall.domain/project/99/interface/api/25413
   */
  static API_GET_WARM_INFO = "/v3/webinars/warm/info";
  /**
   * 查询章节信息-章节打点
   * <p>
   * http://yapi.vhall.domain/project/99/interface/api/30777
   */
  static API_GET_RECORD_CHAPTERS_LIST = "/v3/webinars/record/get-doc-info-from-rid";
  /**
   * 查询回放列表
   * <p>
   * http://yapi.vhall.domain/project/99/interface/api/25701
   */
  static API_GET_RECORD_LIST = "/v3/webinars/record/get-list";
  /**
   * 查询文件列表
   * <p>
   *  http://yapi.vhall.domain/project/101/interface/api/54518
   */
  static API_GET_FILES_LIST = "/v3/interacts/data-download/data-download-list";
  /**
   * 获取文件下载地址
   * <p>
   * http://yapi.vhall.domain/project/101/interface/api/54519
   */
  static API_GET_CHECK_DOWNLOAD = "/v3/interacts/data-download/check-download";
  /**
   * 观看端-获取推送的推屏卡片列表
   * <p>
   *  http://yapi.vhall.domain/project/101/interface/api/56860
   */
  static API_SCREEN_CARD_LIST = "/v3/interacts/push-screen-card/push-list";
  /**
   * 观看端-获取推送的推屏卡片信息
   * <p>
   *  http://yapi.vhall.domain/project/101/interface/api/56710
   */
  static API_SCREEN_CARD_INFO = "/v3/interacts/push-screen-card/info";
  /**
   * 观看端-点击推屏卡片
   * <p>
   *  http://yapi.vhall.domain/project/101/interface/api/56720
   */
  static API_SCREEN_CARD_CLICKED = "/v3/interacts/push-screen-card/click";
  /**
   * 查询商品列表
   * <p>
   * http://yapi.vhall.domain/project/1285/interface/api/57988
   */
  static API_SALE_GOODS_LIST = "/v3/goods/webinar/get-online-goods";
  /**
   *获取上架商品详情
   * <p>
   * http://yapi.vhall.domain/project/1285/interface/api/58310
   */
  static API_SALE_GOODS_INFO = "/v3/goods/webinar/get-online-goods-info";
  /**
   *获取活动下商品订单提交信息设置项
   * <p>
   * http://yapi.vhall.domain/project/1285/interface/api/58002
   */
  static API_GOODS_ORDER_SETTING = "/v3/goods/webinar-setting/get-info";
  /**
   *查询商户号绑定列表
   * <p>
   * http://yapi.vhall.domain/project/1285/interface/api/58009
   */
  static API_GOODS_PARTNER_LIST = "/v3/goods/partner/get-list";
  /**
   * 创建订单
   * <p>
   * http://yapi.vhall.domain/project/1285/interface/api/57911
   */
  static API_GOODS_ORDER_CREATE = "/v3/goods/order/create";
  /**
   * 获取商品订单信息
   */
  static API_GOODS_SHOW_URL = "https://live-xyz.vhall.com/v3/lives/watch/";
  /**
   * 获取我的订单信息
   * <p>
   *http://yapi.vhall.domain/project/1285/interface/api/58016
   */
  static API_GOODS_MY_ORDER_INFO = "/v3/goods/order/my-order-info";
  /**
   /**
   * 微信授权场景提交手机号
   * <p>
   * http://yapi.vhall.domain/project/99/interface/api/52861
   */
  static API_INTERACTS_NOTICE_WECHAT_SUBMIT = "/v3/interacts/notice/notice-wechat-submit";
  /**
   * 观看端-答题前置条件检查
   * <p>
   * http://yapi.vhallops.com/project/1181/interface/api/54468
   */
  static API_INTERACTS_EXAM_USER_FORM_CHECK = "/v3/interacts/exam/user-form-check";
  /**
   * 观看端-保存用户表单信息
   * <p>
   * http://yapi.vhallops.com/project/1181/interface/api/54469
   */
  static API_INTERACTS_EXAM_SAVE_USER_FORM = "/v3/interacts/exam/save-user-form";
  /**
   * 观看端-单题提交
   * <p>
   * http://yapi.vhallops.com/project/1181/interface/api/54470
   */
  static API_INTERACTS_EXAM_ANSWER_QUESTION = "/v3/interacts/exam/answer-question";
  /**
   * 观看端-主动交卷
   * <p>
   * http://yapi.vhallops.com/project/1181/interface/api/54471
   */
  static API_INTERACTS_EXAM_INITIATIVE_SUBMIT_PAPER = "/v3/interacts/exam/initiative-submit-paper";
  /**
   * 观看端-获取场次已推送试卷列表
   * <p>
   * http://yapi.vhallops.com/project/1181/interface/api/54472
   */
  static API_INTERACTS_EXAM_GET_PUSHED_PAPER_LIST = "/v3/interacts/exam/get-pushed-paper-list";
  /**
   * 观看端-获取试卷详情
   * <p>
   * http://yapi.vhallops.com/project/1181/interface/api/54473
   */
  static API_INTERACTS_EXAM_GET_PAPER_INFO_FOR_WATCH = "/v3/interacts/exam/get-paper-info-for-watch";
  /**
   * 观看端-获取已答题记录
   * <p>
   * http://yapi.vhallops.com/project/1181/interface/api/54474
   */
  static API_INTERACTS_EXAM_GET_USER_ANSWER_PAPER_HISTORY = "/v3/interacts/exam/get-user-answer-paper-history";
  /**
   * 观看端-初始化用户表单
   * <p>
   * http://yapi.vhallops.com/project/1181/interface/api/54475
   */
  static API_INTERACTS_EXAM_GET_USER_FORM_INFO = "/v3/interacts/exam/get-user-form-info";
  /**
   * 观看端-发送验证码
   * <p>
   * http://yapi.vhallops.com/project/1181/interface/api/54476
   */
  static API_INTERACTS_EXAM_SEND_VERIFY_CODE = "/v3/interacts/exam/send-verify-code";
  /**
   * 观看端-验证验证码
   * <p>
   * http://yapi.vhallops.com/project/1181/interface/api/54477
   */
  static API_INTERACTS_EXAM_VERIFY_CODE = "/v3/interacts/exam/verify-code";
  /**
   * 观看端-获取榜单信息
   * <p>
   * http://yapi.vhallops.com/project/1181/interface/api/54478
   */
  static API_INTERACTS_EXAM_GET_SIMPLE_RANK_LIST = "/v3/interacts/exam/get-simple-rank-list";
  /**
   * 观看端-获取个人成绩
   * <p>
   * http://yapi.vhallops.com/project/1181/interface/api/54479
   */
  static API_INTERACTS_EXAM_PERSON_SCORE_INFO = "/v3/interacts/exam/person-score-info";
  /**
   * 可用优惠券列表
   * <p>
   * http://yapi.vhall.domain/project/1285/interface/api/58709
   */
  static API_COUPON_AVAILABLE_LIST = "/v3/goods/coupon-webinar/available-list";
  /**
   * 不可用优惠券列表
   * <p>
   * http://yapi.vhall.domain/project/1285/interface/api/58716
   */
  static API_COUPON_UNAVAILABLE_LIST = "/v3/goods/coupon-webinar/unavailable-list";
  /**
   * ai 回放
   * <p>
   */
  static API_AI_WATCH = "/v3/ai/video/watch-union";
  /**
   * 观看端-获取当前直播最后一次推送的观看有礼
   * <p>
   */
  static API_WATCH_GIFT_GET_LAST_INFO = "/v3/vss/watch-gift/get-last-info";
  /**
   * 观看端-观看有礼奖品列表 https://app.apifox.com/project/6462986
   * <p>
   */
  static API_WATCH_GIFT_AWARD_LIST = "/v3/vss/watch-gift/award/watch-list";
  /*
   * 观看端-观看端-观众参与观看有礼 https://app.apifox.com/project/6462986
   * <p>
   */
  static API_WATCH_GIFT_PARTICIPATE = "/v3/vss/watch-gift/participate";
  /**
   * 观看端-观看端-观看端-查询用户中奖详情 https://app.apifox.com/project/6462986
   * <p>
   */
  static API_WATCH_GIFT_WINNER_DETAIL = "/v3/vss/watch-gift/get-winner-detail";
  /**
   * 控制台/观看端-查询领奖配置 https://app.apifox.com/project/6462986
   * <p>
   */
  static API_WATCH_GIFT_AWARD_SETTING = "/v3/vss/watch-gift/get-receive-award-setting";
  /**
   * 观看端-提交用户领奖信息
   * <p>
   */
  static API_WATCH_GIFT_SAVE_TAKE_AWARD_REMARK = "/v3/vss/watch-gift/save-take-award-remark";
  /**
   * 观看端-查询观看有礼的中奖名单
   GET /v3/vss/watch-gift/get-winner-rank
   接口ID：301115129
   接口地址：https://app.apifox.com/link/project/6462986/apis/api-301115129
   * <p>
   */
  static API_WATCH_GIFT_WINNER_RANK = "/v3/vss/watch-gift/get-winner-rank";
  /*
   * 获取隐私协议
   * <p>
   */
  static API_GET_PRIVACY_AGREEMENT = "/v3/interacts/agreement/get-privacy-agreement";
  /**
   * 获取广告列表
   *
   */
  static API_GET_ADV_LIST = '/v3/interacts/recommend-adv/watch-get-adv-list';
  /**
   * 获取单个菜单详情
   */
  static API_GET_MENU_INFO = '/v3/interacts/menu/menu-get-info';
  /**
   * 获取公众号引流配置
   */
  static API_GET_DIVERTING_CONFIG = '/v1/marketing/app/wechat-oa/get-diverting-config';
  /**
   * 获取主题详情
   *
   */
  static API_GET_SUBJECT_BATCH_INFO = '/v3/webinars/subject/get-batch-info';
  /**
   * 获取活动详情
   *
   */
  static API_GET_WEBINAR_INFO = '/v3/webinars/webinar/batch-get-webinar-info';
  /**
   * 互动有礼 观看端-领奖页-获取领奖页信息
   */
  static API_RECEIVE_AWARD_SETTING = '/v3/vss/interact-reward/get-receive-award-setting';
  /**
   * 互动有礼 -保存中奖人领奖信息
   */
  static API_SAVE_AWARD_INFO = '/v3/vss/interact-reward/save-award-info';
  /**
   * 互动有礼 -保存中奖人领奖信息
   */
  static API_INTERACT_WINNER_INFO = '/v3/vss/interact-reward/winner-info';
  /**
   * 获排行榜列表
   */
  static API_GET_TOP_LIST = '/v1/marketing/app/invite/stat/get-top-list';
  /**
   * 获取邀请卡信息
   */
  static API_INVITE_CARD = '/v1/marketing/app/invite/card/init-invite-card';
  /**
   * 问卷关联的我的礼品列表
   */
  static API_MY_AWARD_LIST = '/v3/vss/interact-reward/my-award-list';
  /**
   * 口令红包
   */
  static API_OPEN_REDPACKET = '/v3/interacts/pwd-redpacket/open-redpacket';
  /**
   * 获取我的口令红包
   */
  static API_GET_RED_PACKET_STATUS = "/v3/interacts/pwd-redpacket/get-redpacket-status";
  /**
   * 获取口令红包的用户列表
   */
  static API_REDPACKET_PARTITION_RECORDER = '/v3/interacts/pwd-redpacket/get-redpacket-partition-recorder';
  /**
   * 上传文件
   */
  static API_UPLOAD_FILE = '/v3/commons/upload/index';
  /**
   * 直播详情
   */
  static API_LIVE_DETAIL = '/v3/lives/watch/';
  /**
   * 专题详情
   */
  static API_SUBJECT_DETAIL = '/v3/special/detail?id=';
  /**
   * 获得我的邀请明细
   */
  static API_GET_MY_INVITE_DETAILS = '/v1/marketing/app/invite/stat/my-invite-details';
  /**
   * 获得我的邀请明细下载url
   */
  static API_GET_MY_INVITE_DETAILS_URL = '/v1/marketing/app/invite/stat/my-invite-details-url';
  /**
   * 获取用户提交的答案
   */
  static API_GET_SURVEY_ANSWER_REPLAY = '/v3/vss/survey/get-answer-replay';

  /**
   * 邀请卡获得默认头像
   */
  static API_GET_DEFAULT_AVATAR = 'https://cnstatic01.e.vhall.com/common-static/images/default_avatar.png';

  /**
   * 设置问答同问
   */
  static API_QA_SET_LIKE = "/v3/interacts/qa/set-like";

  /**
   * 获取问答推荐列表
   */
  static API_QA_RECOMMEND_LIST = "/v3/interacts/qa/recommend-list";

  /**
   * 获取最新发布的
   */
  static API_WEBINAR_SURVEY = "/v3/vss/survey/latest-publish-webinar-survey";
  /**
   * 快问快答 成绩排名列表
   */
  static API_USER_PERFORMANCE_LIST = "/v1/fqa/app/stats/user-performance-list";
  /**
   * 快问快答 指定快问快答的用户答题状态
   */
  static API_USER_ANSWER_STATUS = "/v1/fqa/app/paper/user-answer-status";
  /**
   * 快问快答 查看个人成绩详情
   */
  static API_GET_PERSONAL_REPORT = "/v1/fqa/app/stats/get-personal-report";

  /**
   * 获取回放列表
   */
  static API_GET_WATCH_LIST = "/v3/webinars/record/get-watch-list";
}