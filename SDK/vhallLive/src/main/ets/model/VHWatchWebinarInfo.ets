import { VHIMMessageModel } from "../im/VHIMCallback";

/**
 * @description 投屏相关参数
 * */
export interface VHCastMediaSource {
  /**
   * @description name 标题名字
   * **/
  name: string;

  /**
   * @description title 标题内容
   * **/
  title: string;

  /**
   * @description description 描述
   * **/
  description: string;

  /**
   * @description headImage 显示头像
   * **/
  headImage: string;
}

/***
 * @description 视频播放器的缩放模式
 */
export enum VHPlayerVideoScalingMode {
  /**
   * @description VH_FILL 将图像拉伸填充
   * **/
  VH_FILL = 0,
  /**
   * @description VH_ASPECT_FIT 将图像等比例缩放，适配最长边，居中显示，可能会留有黑边
   * **/
  VH_ASPECT_FIT = 1,
  /**
   * @description VH_ASPECT_FILL 将图像等比例铺满整个屏幕，多余部分裁剪掉
   * **/
  VH_ASPECT_FILL = 2
}

/**
 * @description 设置画中画小窗控制中心播放按键状态回调。
 */
export enum VHPipControlPanelStatus {
  /**
   * @description VH_CONTROL_PAUSE 画中画暂停
   */
  VH_CONTROL_PAUSE = 1,
  /**
   * @description VH_CONTROL_PLAY 画中画恢复播放
   */
  VH_CONTROL_PLAY = 2
}

/**
 * @description 错误码定义。
 */
export interface VHErrorInfo {
  /**
   * @description code 错误码VHConstants
   */
  code: number;

  /**
   * @description name 错误信息
   */
  name: string;
  message: string;
}

/**
 * @description 播放器播放过程中状态信息举
 */
export enum VHPlayerState {
  /**
   * @description VH_PLAYER_INIT 默认
   */
  VH_PLAYER_INIT = 0,
  /**
   * @description VH_PLAYER_PREPARED 播放器初始化错误
   */
  VH_PLAYER_PREPARED = 1,
  /**
   * @description VH_PLAYER_LOADING 加载中
   */
  VH_PLAYER_LOADING = 2,
  /**
   * @description VH_PLAYER_PLAYING 播放中
   */
  VH_PLAYER_PLAYING = 3,
  /**
   * @description VH_PLAYER_PAUSE 已暂停
   */
  VH_PLAYER_PAUSE = 4,
  /**
   * @description VH_PLAYER_STOP 已停止
   */
  VH_PLAYER_STOP = 5,
  /**
   * @description VH_PLAYER_COMPLETE 播放已完成
   */
  VH_PLAYER_COMPLETE = 6,
  /**
   * @description VH_PLAYER_RELEASE 播放器已释放
   */
  VH_PLAYER_RELEASE = 7,
  /**
   * @description VH_PLAYER_BUFFERING_END 播放器已释放
   */
  VH_PLAYER_BUFFERING_END = 8,
}


/**
 * @description 画中画状态
 */
export enum VHPlayerPipState {
  /**
   * @description VH_PIP_START 画中画开始
   */
  VH_PIP_START = 0,
  /**
   * @description VH_PIP_STOP 画中画停止
   */
  VH_PIP_STOP = 1,
  /**
   * @description VH_PIP_ERROR 画中画异常
   */
  VH_PIP_ERROR = 2,
  /**
   * @description VH_PIP_RESTORE 画中画点击小窗恢复
   */
  VH_PIP_RESTORE = 3,
  /**
   * @description VH_PIP_CONTROL_PAUSE 画中画点击小窗暂停
   */
  VH_PIP_CONTROL_PAUSE = 4,
  /**
   * @description VH_PIP_CONTROL_RESUME 画中画点击小窗恢复播放
   */
  VH_PIP_CONTROL_RESUME = 5,
}

/**
 * @description 表示视频播放速度
 */
export enum VHVodSupportSpeed {
  /**
   * @description VH_PLAYER_SPEED_0_75_X 表示视频播放正常播速的0.75倍。
   */
  VH_PLAYER_SPEED_0_75_X = 0,
  /**
   * @description VH_PLAYER_SPEED_1_00_X 表示视频播放正常播速。
   */
  VH_PLAYER_SPEED_1_00_X = 1,
  /**
   * @description VH_PLAYER_SPEED_1_25_X 表示视频播放正常播速的1.25倍。
   */
  VH_PLAYER_SPEED_1_25_X = 2,
  /**
   * @description VH_PLAYER_SPEED_1_75_X 表示视频播放正常播速的1.75倍。
   */
  VH_PLAYER_SPEED_1_75_X = 3,
  /**
   * @description VH_PLAYER_SPEED_2_00_X 表示视频播放正常播速的2.00倍。
   */
  VH_PLAYER_SPEED_2_00_X = 4,
}

/**
 * @description 视频清晰度
 * **/
export enum VHPlayDefinition {
  /**
   * @description VH_ORIGIN 原画
   * **/
  VH_ORIGIN = 0,
  /**
   * @description VH_UHD 高清720p
   * **/
  VH_UHD = 1,
  /**
   * @description VH_HD 标清480p
   * **/
  VH_HD = 2,
  /**
   * @description VH_SD 流畅360p
   * **/
  VH_SD = 3,
  /**
   * @description VH_AUDIO 纯音频
   * **/
  VH_AUDIO = 4,
  /**
   * @description VH_FULL_HD 超清1080p
   * **/
  VH_FULL_HD = 6,
}

/**
 * @description 投屏设备信息
 * **/
export class VHCastPickerDevice {
  /**
   * @description deviceName 设备名称
   */
  deviceName: string = '';
  /**
   * @description deviceId 设备ID
   */
  deviceId: string = '';
}

/**
 * @description 投屏信息
 * **/
export enum VHCastPickerState {
  /**
   * @description VH_CAST_PICKER_STATE_NO_CAST_PLAY 无投屏
   */
  VH_CAST_PICKER_STATE_NO_CAST_PLAY = -1,
  /**
   * @description VH_CAST_PICKER_STATE_INITIAL 初始化投屏中
   */
  VH_CAST_PICKER_STATE_INITIAL = 0,

  /**
   * @description VH_CAST_PICKER_STATE_PREPARE 投屏视频准备中
   */
  VH_CAST_PICKER_STATE_PREPARE = 1,
  /**
   * @description VH_CAST_PICKER_STATE_PLAY 投屏播放
   */
  VH_CAST_PICKER_STATE_PLAY = 2,

  /**
   * @description VH_CAST_PICKER_STATE_PAUSE 投屏暂停
   */
  VH_CAST_PICKER_STATE_PAUSE = 3,
  /**
   * @description VH_CAST_PICKER_STATE_STOP 投屏停止
   */
  VH_CAST_PICKER_STATE_STOP = 6,
}

/**
 * @description 观看端用户认证信息
 * */
export class VHWatchAuthInfo {
  /**
   * @description visitor_id 访客唯一标识
   */
  public visitor_id: string = "";
  /**
   * @description join_id 参会id
   */
  public join_id: string = "";
  /**
   * @description status live-直播；subscribe-预约
   */
  public status: string = "";
  /**
   * @description type 0:免费（默认），1:密码，2：白名单
   */
  public type: string = "";
  public token_id: string = "";
}

/**
 * @description 用户信息
 * */
export class VHUserInfo {
  /**
   * @description user_id 用户id
   */
  public user_id: number = 0;
  /**
   * @description nickname 昵称
   */
  public nickname: string = "";
  /**
   * @description avatar 头像地址
   */
  public avatar: string = "";
  /**
   * @description company 企业名称
   */
  public company: string = "";
}

/**
 * @description 活动场次信息
 * */
export class VHSwitchInfo {
  /**
   * @description switch_id 活动场次id。
   */
  public switch_id: number = 0;
  /**
   * @description start_time 当前场次活动开始时间。
   */
  public start_time: string = "";
  /**
   * @description end_time 当前场次活动结束时间。
   */
  public end_time: string = "";
  /**
   * @description start_type 开始类型
   */
  public start_type: number = 0;
  /**
   * @description end_type 结束类型
   */
  public end_type: number = 0;
  /**
   * @description type 1-录播，0-直播
   */
  public type: number = 0;
}

/**
 * @description 参会信息
 * */
export class VHJoinInfo {
  /**
   * @description third_party_user_id 三方用户id
   */
  public third_party_user_id: string = "";
  /**
   * @description nickname 昵称
   */
  public nickname: string = "";
  /**
   * @description avatar 头像url
   */
  public avatar: string = "";
  /**
   * @description phone 电话
   */
  public phone: string = "";
  /**
   * @description email 邮箱
   */
  public email: string = "";
  /**
   * @description role_name 角色类型 1 主持人，2 观众，3 助理，4 嘉宾
   */
  public role_name: number = 0;
  public privacies: string = "";
  /**
   * @description join_id 参会id
   */
  public join_id: number = 0;
  /**
   * @description is_gag 是否禁言 1：禁言 0 未禁言
   */
  public is_gag: number = 0;
  /**
   * @description 是否踢出 1：踢出 0 未踢出
   */
  public is_kick: number = 0;
  /**
   * @description user_id 用户id
   */
  public user_id: number = 0;
  /**
   * @description 是否预约：0-否，1-是
   */
  public is_subscribe: number = 0;
  /**
   * @description 使用密码通过验证。是否已通过观看限制（不含报名表单）0 未验证通过 1 已验证通过
   * */
  public verified: number = 0;
  /**
   * @description 是否已填写报名表单
   * */
  public reg_form: number = 0;
  /**
   * @description 专题参会id
   * */
  public subject_join_id: number = 0;
  /**
   * @description 审核状态，0=待审核（审核中），1=审核通过，2=审核驳回
   * */
  public audit_status: number = 0;
}

/**
 * @description 互动参数
 * */
export class VHInteract {
  /**
   * @description room_id 房间号 。比如：lss_a1232bc
   */
  public room_id: string = "";
  /**
   * @description channel_id 频道id ch_xxx
   */
  public channel_id: string = "";
  /**
   * @description inav_id 互动连麦房间id
   */
  public inav_id: string = "";
  /**
   * @description interact_token 互动token
   */
  public interact_token: string = "";
  /**
   * @description paas-app-id paas 层 appid
   */
  public paas_app_id: string = "";
  /**
   * @description paas_access_token paas-token 信息
   */
  public paas_access_token: string = "";
  public subscribe_paas_access_token: string = "";
}

/**
 * @description 单点登录配置
 * **/
export class VHSso {
  /**
   * @description enabled 是否开启 1是0否
   */
  public enabled: number = 0;
  /**
   * @description kick_id 单点登录唯一标示
   */
  public kick_id: string = "";
}

/**
 * @description 预约人数显示
 * **/
export class VHSubscribe {
  /**
   * @description enabled 是否开启 1是0否
   */
  public show: number = 0;
  /**
   * @description num 预约人数
   */
  public num: number = 0;
}

export class VHReportData {
  public vid: number = 0;
  public vfid: number = 0;
  public biz_id: number = 0;
  public guid: string = "";
  public report_extra: string = "";
}

/**
 * @description url
 * */
export class VHUrls {
  /***
   *  问答、问卷静态页地址
   * */
  public static_url: string = "";
  /**
   * 上传地址
   * **/
  public upload_url: string = "";
  /**
   * h5嵌入地址
   * **/
  public web_url: string = "";
}

/**
 * @description 回放信息
 * **/
export class VHRecord {
  /**
   * @description paas_record_id 回放paas_record_id
   */
  public paas_record_id: string = "";
  /**
   * @description record_id 回放id
   */
  public record_id: string = "";
  /**
   * @description record_remark_layout 回放重置布局：0-无 1-三分屏 2-画中画 3-纯文档
   */
  public record_remark_layout: number = 0;
  /**
   * @description preview_paas_record_id
   * 试看paas_record_id。当活动配置了观看限制，如密码或白名单，如果开通了试看则此字段有值，如果挂壁你了试看此字段为空。
   * 可以使用回放播放器VHWatchVodPlayer.startPlayWithRecordId 方法进行播放
   */
  public preview_paas_record_id: string = "";
  /**
   * @description encrypt_status 0:未加密 1:加密中 2:加密成功
   */
  public encrypt_status: number = 0;
  /**
   * @description is_union_screen 是否融屏 1:是 0 否
   */
  public is_union_screen: number = 0;
}


/**
 * @description 暖场视频
 * **/
export class VHWarmup {
  /**
   * @description warmup_paas_record_id 暖场paas_record_id
   */
  public warmup_paas_record_id: string[] = [];
  /**
   * @description warmup_img_url 暖场封面
   */
  public warmup_img_url: string = "";
  /**
   * @description warmup_player_type 1:单次播放 2:循环播放
   */
  public warmup_player_type: number = 0;
  /**
   * @description advance_play_time 提前播放时间，单位秒. 预约或开播前展示
   */
  public advance_play_time: number = 0;
}

/**
 * @description 热度
 * **/
export class VHPageView {
  /**
   * @description show 是否显示 1显示 0隐藏
   */
  public show: number = 0;
  /**
   * @description real 真实热度
   */
  public real: number = 0;
  /**
   * @description virtual 虚拟热度
   */
  public virtual: number = 0;
}

/**
 * @description 在线人数
 * **/
export class VHOnline {
  /**
   * @description show 是否显示 1显示 0隐藏
   */
  public show: number = 0;
  /**
   * @description real 真实在线人数
   */
  public real: number = 0;
  /**
   * @description virtual 虚拟在线人数
   */
  public virtual: number = 0;
}


/**
 * @description 活动信息
 * **/
export class VHWebinarDetail {
  /**
   * @description id 活动id
   */
  public id: number = 0;
  /**
   * @description subject 活动标题
   */
  public subject: string = "";
  /**
   * @description introduction 活动简介
   */
  public introduction: string = "";
  /**
   * @description mode 模式（1-音频、2-视频、3-互动、 4-文档、5-定时直播、6-分组讨论）
   */
  public mode: number = 0;
  /**
   * @description live_time 直播时长
   */
  public live_time: number = 0;
  /**
   * @description document_id 文档id
   */
  public document_id: number = 0;
  /**
   * @description start_time 开始时间
   */
  public start_time: string = "";
  /**
   * @description end_time 结束时间
   */
  public end_time: string = "";
  /**
   * @description actual_start_time 实际开始时间
   */
  public actual_start_time: string = "";
  /**
   * @description img_url 直播预览图片
   */
  public img_url: string = "";
  /**
   * @description type 活动当前状态 1-直播中，2-预约，3-结束，4-点播，5-回放
   */
  public type: number = 0;
  /**
   * @description verify_source
   */
  public verify_source: string = "";
  /**
   * @description verify app验证类别， sdk目前只支持密码验证。 0 无验证，1 密码
   */
  public verify: number = 0;
  /**
   * @description verify_tip 观看限制提示语
   */
  public verify_tip: string = "";
  /**
   * @description reg_form 是否开启报名表单
   */
  public reg_form: number = 0;
  public fee: string = "";
  public category: string = "";
  public no_delay_webinar: number = 0; //无延迟直播：1-是，0-否
  public inav_num: number = 0;
  /**
   * @description hide_subscribe 预约按钮状态 1开启 0关闭
   */
  public hide_subscribe: number = 0;
  /**
   * @description webinar_show_type 1:横屏 0:竖屏
   */
  public webinar_show_type: number = 0;
  /**
   * @description vertical_img_url 竖屏直播封面图
   */
  public vertical_img_url: string = "";
  public is_director: number = 0;
  public live_subtitle_type: number = 0;
  /**
   * @description pv 观看人数
   */
  public pv: number = 0;
  /**
   * @description hide_pv 是否显示pv 1:显示 0:不显示
   */
  public hide_pv: number = 0;
  /**
   * @description 活动类型 1 音频 2 视频 3 互动 5 定时直播
   */
  public webinar_type: number = 0;
  /**
   * @description type 活动当前状态 1-直播中，2-预约，3-结束，4-点播，5-回放
   */
  public webinar_state: number = 0;
  /**
   * @description userinfo 用户信息
   */
  public userinfo: VHUserInfo = new VHUserInfo();
}

export class VHAgreement {
  /**
   * 是否开启观看协议：0-关闭；1-开启
   * **/
  is_open: number = 0;
  /**
   *   用户是否同意观看协议：0-未同意；1-已同意
   * **/
  is_agree: number = 0;
}

/***
 * @description 活动信息
 * **/
export class VHWebinarData {
  /**
   * @description webinar VHWebinarDetail 活动信息
   */
  public webinar: VHWebinarDetail | null = null;
  /**
   * @description switch_info VHSwitchInfo 场次信息
   */
  public switch_info: VHSwitchInfo | null = null;
  /**
   * @description 观看协议状态
   */
  public agreement: VHAgreement | null = null;
  /**
   * @description join_info VHJoinInfo 参会信息
   */
  public join_info: VHJoinInfo | null = null;
  /**
   * @description sso VHSso 设置单点登录
   */
  public sso: VHSso | null = null;
  /**
   * @description 嵌入页地址
   */
  public urls: VHUrls | null = null;
  /**
   * @description record VHRecord 回放信息
   */
  public record: VHRecord | null = null;
  /**
   * @description warm_up VHWarmup 暖场视频
   */
  public warm_up: VHWarmup | null = null;
  /**
   * @description pv VHPageView 热度
   */
  public pv: VHPageView | null = null;
  /**
   * @description online VHOnline 在线人数
   */
  public online: VHOnline | null = null;
  /**
   * @description subscribe VHSubscribe 预约人数
   */
  public subscribe: VHSubscribe | null = null;
  /**
   * @description interact VHInteract 互动信息
   */
  public interact: VHInteract | null = null;
  public system_time: string = "";
  /**
   * @description paas_record_id 回放id
   */
  public paas_record_id: string = ""; //
  public record_remark_layout: number = 0;
  /**
   * @description live_type 直播类型 live_type:0-正式（默认）；2-彩排
   */
  public live_type: number = 0;
  /**
   * @description status 状态：subscribe-预约，live-直播
   */
  public status: string = "";
  /**
   * @description cast_screen 投屏权限：0-无权限投屏，1-有权限投屏
   */
  public cast_screen: number = 0;
  /**
   * @description cheat_num 在线人数显示系数
   */
  public cheat_num: number = 0; //
  /**
   * @description webinar_show_type 1:横屏 0:竖屏
   */
  public webinar_show_type: number = 0;
  public visitor_id: string = "";
  /**
   * @description 状态工具
   */
  public roomToolsStatusData: RoomToolsStatusData | null = null;
  /**
   * @description 点赞数
   */
  public likeCount: number = 0;
}


/***
 * @description 配置信息
 * **/
export class VHBasicConfig {
  /**
   * @description webinar_id 活动ID（数字类型）
   */
  public webinar_id: number = 0;
  /**
   * @description barrage_button 弹幕按钮是否显示 (0:关闭)(1:开启)默认开启
   * */
  public barrage_button: number = 0;
  /**
   * @description barrage_show_nickname 弹幕显示昵称（1-显示，0-隐藏，数字类型）
   * */
  public barrage_show_nickname: number = 0;
  /**
   * @description progress_bar 进度条(0:关闭)(1:开启)默认开启
   * */
  public progress_bar: number = 0;
  /**
   * @description speed 倍速(0:关闭)(1:开启)默认为1
   * */
  public speed: number = 0;
  /**
   * @description 自动播放（1-开启，0-关闭，数字类型）
   * */
  public autoplay: number = 0;
  /**
   * @description 画中画(0:关闭)(1:开启)默认为1
   * */
  public picture_in_picture: number = 0;
  /**
   * @description record_audio 回放及点播状态是否显示音频入口：1.是，0.否
   * */
  public record_audio: number = 0;
  /**
   * @description barrage_style 弹幕样式开关：1.开启，0.关闭
   * */
  public barrage_style: number = 0;
  /**
   * @description 是否显示全屏开关：1.开启，0.关闭
   * */
  public show_full_screen_entry: number = 0;
  /**
   * @description 是否显示全屏开关：1.开启，0.关闭
   * */
  public user_id: number = 0;
}

/**
 * @description 跑马灯信息
 * **/
export class VHMarqueeConfig {
  public webinar_id: number = 0;
  /**
   * @description scrolling_open 是否开启跑马灯（1-开启，0-关闭）
   * */
  public scrolling_open: number = 0;
  /**
   * @description text_type 文本显示格式（1=固定文本|2=固定文本+观看者ID和昵称）
   * */
  public text_type: number = 0;
  /**
   * @description text 滚动文本内容
   * */
  public text: string = "";
  /**
   * @description 不透明度（0-100）
   * */
  public alpha: number = 100;
  /**
   * @description 文本大小
   * */
  public size: number = 12;
  /**
   * @description 十六进制色值 文本颜色
   * */
  public color: string = "#FFFFFF";
  /**
   * @description 间隔时间ms
   * */
  public interval: number = 0;
  /**
   * @description 滚屏速度. 快：3000  中：6000  慢：10000
   * */
  public speed: number = 0;
  /**
   * @description 显示位置 随机:1、上:2、中:3、下:4
   * */
  public position: number = 0;
  /**
   * @description 显示方式 1 滚动 2 闪烁
   * */
  public scroll_type: number = 0;
}

/**
 * @description 文档水印
 * **/
export class VHDocWatermarkType {
  /**
   * @description 文本水印（1-启用，0-禁用）
   * */
  public text: number = 0;
  /**
   * @description 用户ID水印（1-启用，0-禁用）
   * */
  public user_id: number = 0;
  /**
   * @description 昵称水印（1-启用，0-禁用）
   * */
  public nick_name: number = 0;
  /**
   * @description 文本水印内容
   * */
  public text_value: string = "";
}

/**
 * @description 文字水印
 * **/
export class VHTextWatermarkType {
  /**
   * @description 文本水印（0-固定文本，1-观看者Id和昵称）
   * */
  public text_type: number = 0;
  /**
   * @description text_value 水印文本
   * */
  public text_value: string = "";
  /**
   * @description 字体大小
   * */
  public size: number = 0;
  /**
   * @description 文本颜色#BFBFBF
   * */
  public color: string = "#BFBFBF";
  /**
   * @description 透明度 0-100
   * */
  public alpha: number = 100;
  /**
   * @description 多行水印 1 单行 2 多行
   * */
  public line_mode: number = 1;
  /**
   * @description 旋转水印 1 倾斜 2 水平
   * */
  public orientation: number = 1;
}


/**
 * @description 水印设置
 * **/
export class VHWatermarkConfig {
  /**
   * @description 活动id
   * */
  public webinar_id: number = 0;
  /**
   * @description 播放器 图片水印是否开启（1-开启，0-关闭）
   * */
  public watermark_open: number = 0;
  /**
   * @description 播放器 文字水印是否开启（1-开启，0-关闭）
   * */
  public text_watermark_open: number = 0;
  /**
   * @description 水印图片URL
   * */
  public img_url: string = "";
  /**
   * @description 图片水印透明度（0-100）
   * */
  public img_alpha: number = 100;
  /**
   * @description 图片水印位置 1左上角  2右上角  3左下角 4右下角
   * */
  public img_position: number = 0;
  /**
   * @description 水印图片大小，1 大，2 中，3 小
   * */
  public img_size: number = 0;
  /**
   * @description 文档水印是否开启（1-开启，0-关闭）
   * */
  public doc_watermark_open: number = 0;
  /**
   * @description 文档水印类型配置
   * */
  public doc_watermark_type: VHDocWatermarkType = new VHDocWatermarkType();
  /**
   * @description 文字水印类型
   * */
  public text_watermark: VHTextWatermarkType = new VHTextWatermarkType();
  /**
   * @description 文档水印字体大小
   * */
  public doc_font_size: number = 12;
  /**
   * @description 文档水印字体颜色
   * */
  public doc_font_color: string = "#000000";
  /**
   * @description 文档水印透明度（0-100）
   * */
  public doc_transparency: number = 50;
}

/**
 * @description 播放器聚合参数
 * **/
export class VHPlayerConfig {
  /**
   * @description 水印
   * **/
  public water: VHWatermarkConfig | null = null; //
  /**
   * @description 跑马灯
   * **/
  public marquee: VHMarqueeConfig | null = null;
  /**
   * @description 基础配置
   * **/
  public basic: VHBasicConfig | null = null;
  /**
   * @description 清晰度
   * **/
  public default_definition: VHPlayDefinition = VHPlayDefinition.VH_SD;
}

/**
 * @description 观看协议
 * **/
export class StatementInfo {
  /**
   * @description 协议标题
   * **/
  public title: string = "";
  /**
   * @description 协议链接
   * **/
  public link: string = "";
}

/**
 * @description 观看协议信息
 * ***/
export class VHAgreementModel {
  /**
   * @description 协议ID
   * **/
  public id: number = 0;
  /**
   * @description 活动id
   * **/
  public webinar_id: number = 0;
  /**
   * @description 0:设置中心 1:活动详情
   * **/
  public type: number = 0;
  /**
   * @description 观看协议开关 0:关闭 2:1打开
   * **/
  public is_open: number = 0;
  /**
   * @description 协议标题
   **/
  public title: string = "";
  /**
   * @description 协议内容协议内容(富文本)
   **/
  public content: string = "";
  /**
   * @description 声明状态 0:关 1:开
   **/
  public statement_status: number = 0;
  /**
   * @description 协议提示内容
   **/
  public statement_content: string = "";
  /**
   * @description 协议信息
   **/
  public statement_info: StatementInfo[] = [];
  /**
   * @description 模块类型：0.观看协议，7.开播协议
   **/
  public module: number = 0;
  /**
   * @description 同意类型，0.直接点击，1.阅读完内容，2.至少阅读多少秒
   **/
  public agree_type: number = 0;
  /**
   * @description 阅读时间(秒)
   **/
  public agree_time: number = 0;
  /**
   * @description 生效角色，多个角色以逗号连接，如生效于主持人和嘉宾，则返回值为host,guest
   **/
  public apply_roles: string = "";
  /**
   * @description 是否已同意，（1-同意，0-未同意）
   **/
  public is_agree: number = 0;
}

/**
 * @description 互动菜单
 * **/
export class VHMenus {
  /**
   * @description 菜单主键id
   **/
  public id: number = 0;
  /**
   * @description 菜单名称
   **/
  public name: string = '';
  /**
   * @description 分类1自定义,2文档,3聊天,4简介,5商品,6推荐,9文档下载,10游戏互动,11精彩时刻,12概要总结,13问答,14回放列表,15AI直播间
   **/
  public type: number = 0;
  /**
   * @description 1显示,2隐藏,3直播回放显示,4预告结束显示
   **/
  public status: string = '';
  /**
   * @description SDK 是否显示，0：否，1：是
   **/
  public wap_show: string = '';
  /**
   * @description 欢迎语
   **/
  public welcome_content: string = '';
}


/**
 * @description 皮肤
 * ***/
export class VHSkin {
  /**
   * @description 主键ID
   **/
  public skin_id: string = "";
  /**
   * @description 皮肤名称
   **/
  public skin_name: string = "";
  /**
   * @description wap皮肤设置json内容
   **/
  public skin_json_wap: string = "";
  /**
   * @description wap预览代码
   **/
  public skin_preview_code_wap: string = "";
  /**
   * @description wap皮肤样式代码
   **/
  public skin_style_code_wap: string = "";
  /**
   * @description 更新时间
   **/
  public updated_at: string = "";
  /**
   * @description 创建时间
   **/
  public created_at: string = "";
  /**
   * @description 用户id
   **/
  public user_id: string = "";
  /**
   * @description 是否使用状态 0:关闭 1:开启
   **/
  public status: number = 0;
}

/**
 * 广告
 * **/
export class VHAdvItem {
  // 广告ID
  public adv_id: number = 0;
  // 广告标题
  public subject: string = '';
  // 广告图片地址
  public img_url: string = '';
  // 广告对应超链接
  public url: string = '';
}

/**
 * 广告
 * **/
export class VHAdvDefault {
  //广告列表
  public adv_list: VHAdvItem[] = [];
  // 总数
  public total: number = 0;
  // 当前页数
  public pos: string = '';
  // 每次查询条目数
  public limit: string = '';
}

/**
 * @description 活动标签
 * */
export class VHWebinarTag {
  // tag-id
  public tag_id: number = 0;
  // 主办方状态
  public organizers_status: number = 0;
  // 预约状态
  public reserved_status: number = 0;
  // 可见状态
  public view_status: number = 0;
  // logo-url
  public logo_url: string = '';
  // 活动id
  public webinar_id: number = 0;
  // 每次查询条目数
  public skip_url: string = '';
}

/**
 * @description 红包
 * **/
export class VHRedPacket {
  /**
   * description 0=无|1=有|2=无效
   **/
  public status: number = 0;
  /**
   * @description 红包唯一标识ID
   **/
  public red_packet_uuid: string = '';
  /**
   * @description 已抢数量
   **/
  public get_user_count: string = '';
  /**
   * @description 红包总数量
   **/
  public number: number = 0;
  /**
   * @description 标识当前用户是否已领取红包， 1 是，0 否
   **/
  public is_luck: string = '';
}

/**
 * @description 获取我的口令红包
 * **/
export class VHRedPacketStatus {
  /**
   * 1：抢到 ；0：未抢到；2-没有抢
   * */
  is_luck: number = 0;
  /**
   * 红包口令
   * */
  red_code: string = "";
  /**
   * 红包信息
   * **/
  red_packet: VHPacketStatus = new VHPacketStatus;
}

/**
 * 红包信息
 * **/
export class VHPacketStatus {
  /**
   * 红包数量
   * */
  number: number = 1;
  /**
   * 红包唯一标识
   * */
  red_packet_uuid: string = "";
  /**
   * 昵称
   * */
  nickname: string = "";
  /**
   * 头像
   * */
  avatar: string = "";
  /**
   * 橘色
   * */
  join_type: number = 1;
}

/**
 * @description 签到信息
 * **/
export class VHSignInfo {
  /**
   * @description 创建者昵称
   **/
  public app_id: string = "";
  /**
   * @description 创建者昵称
   **/
  public creator_nickname: string = "";
  /**
   * @description 创建者头像
   **/
  public creator_avatar: string = "";
  /**
   * @description 签到显示时间，单位秒
   **/
  public show_time: string = "";
  /**
   * @description 创建者ID
   **/
  public creator_id: string = "";
  /**
   * @description 是否自动签到（字符串类型，可能为"0"或"1"）
   **/
  public is_auto_sign: number = 0;
  /**
   * @description 自动签到时间
   **/
  public auto_sign_time: number = 0;
  /**
   * @description 自动签到时间有效期
   **/
  public auto_sign_time_ttl: number = 0;
  /**
   * @description 签到时间有效期
   **/
  public sign_time_ttl: string = "";
  /**
   * @description 业务线标识
   **/
  public bu: string = "";
  /**
   * @description 是否删除（字符串类型，可能为"0"或"1"）
   **/
  public deleted: string = "";
  /**
   * @description 创建时间
   **/
  public created_at: string = "";
  /**
   * @description 删除时间
   **/
  public deleted_at: string = "";
  /**
   * @description updated_at
   **/
  public updated_at: string = "";
  /**
   * @description 唯一标识ID
   **/
  public id: string = "";
  /**
   * @description 签到提示语
   **/
  public sign_tips: string = "";
  /**
   * @description 是否开启未签到用户自动踢出：1.开启，0.不开启
   **/
  public auto_kick_unsigned: number = 0;
  /**
   * @description 签到成功提示语
   **/
  public sign_in_success_tips: string = "";
  /**
   * @description 是否签到 1=已签到，0=未签到
   **/
  public is_signed: number = 0;
  public source_id: number = 0;
}

/**
 * 计时器
 * */
export class VHTimer {
  /**
   * @description 总时间 秒
   */
  public duration: string = "";
  /**
   * @description 是否所有人可见 0=不可见|1=可见
   */
  public is_all_show: string = "";
  /**
   * @description 是否允许超时 0=否|1=是
   */
  public is_timeout: string = "";
  /**
   * @description 剩余时间 秒
   * **/
  public remain_time: string = "";
  /**
   * @description 状态 4=暂停
   * */
  public status: string = "";
}

/**
 * @description 开屏海报
 */
export class VHScreenPoster {
  /**
   * @description 跳转链接地址
   */
  public url: string = '';
  /**
   * @description 状态：0开启1关闭
   */
  public status: number = 0;
  /**
   * @description 海报关闭方式：0手动关闭1自动关闭
   */
  public shutdown_type: number = 0;
  /**
   * @description 开屏海报移动端图片地址
   */
  public m_img: string = '';
}

/**
 * @description 公众号配置
 */
export class VHPublicAccount {
  /**
   * @description 开屏提示关注 1：关闭 0：开启
   */
  public status: number = 0;
  /**
   * @description 是否自动弹出 0：自动弹出 1：不弹出
   */
  public alert_type: number = 0;
  /**
   * @description 已开启，在顶部导航栏展示 1:展示 0:不展示
   */
  public show_icon: string = '';
  /**
   * @description 文案设置开关。0 关闭1 开启
   */
  public tip_status: number = 0;
  /**
   * @description 二维码头部提示文案
   */
  public head_tip: string = '';
  /**
   * @description 二维码图片地址
   */
  public img: string = '';
  /**
   * @description 二维码底部提示文案
   */
  public bottom_tip: string = '';
}

// 商品图片子模型
export class VHGoodsImage {
  /**
   * @description 图片地址
   */
  public img_url: string = "";
  /**
   * @description 是否为封面图 1 是 0 不是.同一个商品只能有一个默认封面
   */
  public is_cover: string = "";
  /**
   * @description 图片ID
   */
  public img_id: string = "";
}

/*
 * 单个商品模型
 * **/
export class VHGoodsItem {
  /**
   * @description 图片ID
   */
  public goods_id: string = "";
  /**
   * @description 商品名称
   */
  public name: string = "";
  /**
   * @description 商品描述
   */
  public description: string = "";
  /**
   * @description 原价格 两位有效数字的浮点数
   */
  public price: string = "";
  /**
   * @description 优惠后价格
   */
  public discount_price: string = "";
  /**
   * @description 商品链接
   */
  public goods_url: string = "";
  /**
   * @description 商品是否为淘宝/天猫 0 否 1 是
   * **/
  public is_url_to_taobao: string = "";
  /**
   * @description 淘口令
   * **/
  public tao_password: string = "";
  /**
   * @description 店铺地址
   * **/
  public shop_url: string = "";
  /**
   * @description 商品展示状态 ，也就是新版本的上下架状态 0 开启 1 展示
   * **/
  public status: string = "";
  /**
   * @description 商品图片列表
   * **/
  public img_list: VHGoodsImage [] = [];
}

/**
 * @description 商品信息
 */
export class VHGoodsData {
  // 商品列表
  public goods_list: VHGoodsItem [] = [];
  // 总数量
  public total: number = 0;
  // 当前位置
  public pos: number = 0;
  // 每页限制数量
  public limit: number = 0;
}

/**
 * @description 关键字
 * ****/
export class VHKeyWords {
  // 总数
  public total: number = 0;
  // 总数
  public name: string = '';
}

/**
 * @description 互动配置参数
 * */
export class VHCommonConfig {
  /**
   * @description 菜单标签
   */
  public menus: VHMenus[] | null = null;
  /**
   * @description 签到信息
   */
  public sign: VHSignInfo | null = null;
  /**
   * @description 计时器信息
   */
  public timer: VHTimer | null = null;
  /**
   * @description 观看端皮肤
   */
  public skin: VHSkin | null = null;
  /**
   * @description 开屏海报
   */
  public screen_poster: VHScreenPoster | null = null;
  /**
   * @description 公众号配置
   */
  public public_account: VHPublicAccount | null = null;
  /**
   * @description 广告
   */
  public adv: VHAdvDefault | null = null;
  /**
   * @description 商品
   */
  public goods: VHGoodsData | null = null;
  /**
   * @description 关键字
   */
  public keywords: VHKeyWords | null = null;
  /**
   * @description 活动表示
   */
  public webinar_tag: VHWebinarTag | null = null;
  /**
   * @description 最近一次红包
   */
  public red_packet: VHRedPacket | null = null;
  /**
   * @description 点赞数量
   */
  public like_total: number = 0;
  /**
   * @description 是否开启邀请 1:开启 0:关闭
   */
  public invite_card: string = '';
  /**
   * @description 本场直播已推送的推屏卡片 ID
   */
  public push_screen_card: string = '';
  /**
   * @description 互动工具
   */
  public room_tool: RoomToolsStatusData | null = null;
}

/**
 * @description 角色名称. 可用于在聊天内显示对应角色名称。
 * */
export class VHRoleName {
  public host_name: string = '主持人';
  public guest_name: string = '嘉宾';
  public assistant_name: string = '助理';
}

/**
 * @description 提及用户项
 * */
export class VHAtUserItem {
  public account_id: string = "";
  public nick_name: string = "";
  public index: string = "";
}

/**
 * @description 回复消息
 */
export class VHReplyMessage {
  /**
   * @description 发送消息用户id
   */
  public send_id: string = "";
  /**
   * @description 发送消息用户昵称
   */
  public nick_name: string = "";
  public nickname: string = "";
  public count: number = 0;
  public msg_id: string = "";
  /**
   * @description 发送消息用户头像
   */
  public avatar: string = "";
  /**
   * @description 消息类型text文本、image图片、system_notice互动消息
   */
  public type: string = "";
  /**
   * @description 消息类型text文本、image图片、system_notice互动消息
   */
  public send_time: string = "";
  /**
   * @description 嵌套的回复
   */
  public reply_msg: VHReplyMessage[] = [];
  /**
   * @description 角色类型  1 主持人，2 观众，3 助理，4 嘉宾
   */
  public role_name: string = "";
  /**
   * @description 平台类型
   */
  public client: string = "";
  /**
   * @description @用户信息
   */
  public at_list: VHAtUserItem[] = [];
  public content: VHReplyMessageContent | null = null;
}

/**
 * @description 回复消息内容
 */
export class VHReplyMessageContent {
  /**
   * @description 图片地址
   */
  public image_urls: string = '';
  /**
   * @description 回复内容
   */
  public text_content: string = '';
  /**
   * @description 内容类型
   */
  public type: string = '';
  /**
   * @description 昵称
   */
  public nickname: string = "";
  /**
   * @description 头像
   */
  public avatar: string = "";
}

/**
 * @description 消息内容
 */
export class VHMessageContext {
  /**
   * @description 角色类型  1 主持人，2 观众，3 助理，4 嘉宾
   */
  public role_name: number = 0;
  /**
   * @description 回复消息体
   */
  public reply_msg: VHReplyMessage | null = null;
  /**
   * @description 昵称
   */
  public nickname: string = "";
  /**
   * @description 头像
   */
  public avatar: string = "";
  /**
   * @description @用户列表
   */
  public at_list: VHAtUserItem[] = [];
}


/**
 * @description 消息内容
 */
export class VHMessageData {
  /**
   * @description 消息类型，text 文本 image 图片
   */
  public type: string = "";
  /**
   * @description 消息内容
   */
  public barrage_txt: string = "";
  /**
   * @description 消息内容
   */
  public text_content: string = "";
  /**
   * @description 昵称
   */
  public nickname: string = "";
  /**
   * @description 头像
   */
  public avatar: string = "";
  /**
   * @description 聊天图片列表
   */
  public image_urls: string[] | null = null;
}

/**
 * @description 单个聊天消息
 */
export class VHChatMessageItem {
  /**
   * @description 消息内容
   */
  public data: VHMessageData | null = null;
  /**
   * @description 发送时间
   */
  public date_time: string = "";
  /**
   * @description 发送人id 微吼体系的用户或游客
   */
  public sender_id: string = "";
  /**
   * @description 发送人account_id
   */
  public account_id: string = "";
  /**
   * @description 显示时间
   */
  public show_time: string = "";
  /**
   * @description 显示时间
   */
  public showTime: string = "";
  public msg_id: string = "";
  /**
   * @description 包括回复消息
   */
  public context: VHMessageContext | null = null;
  public channel_id: string = "";
  /**
   * @description 接收人
   */
  public accept_name: string = "";
  public email: string = "";
  /**
   * @description msg：普通消息，private：私聊消息
   */
  public event: string = "";
  public nickname: string = "";
  public avatar: string = "";
  public role_name: number = 0;
}


/**
 * @description 聊天消息列表
 */
export class VHChatMessageList {
  /**
   * @description 总消息个数
   */
  total: number = 0;
  /**
   * @description 消息内容
   */
  list: VHChatMessageItem[] = [];
}

/**
 * @description 公告内容详情
 * */
export class VHAnnouncementListData {
  public content: string = "";
}

/**
 * @description 单个公告消息
 */
export class VHAnnouncementNewsItem {
  /**
   * @description 公告id
   */
  public id: string = "";
  /**
   * @description 公告内容
   */
  public content: VHAnnouncementListData | null = null;
  /**
   * @description 创建时间
   */
  public created_at: string = "";
  /**
   * @description 时长 单位：秒 最小传入10 0:默认一直显示
   */
  public duration: number = 0;
  /**
   * @description 设置类型 1:固定选项 2 自定义选项
   */
  public set_type: number = 1;
  /**
   * @description 展示方式：0.滚动，1.不滚动
   */
  public display_type: number = 0;
}

/**
 * @description 公告消息列表
 */
export class VHAnnouncementNewsList {
  /**
   * @description 总消息个数
   */
  total: number = 0;
  /**
   * @description 消息内容
   */
  list: VHAnnouncementNewsItem[] = [];
}


/**
 * @description 快问快答消息列表
 */
export class VHExamList {
  /**
   * @description 试卷标题
   */
  public title: string = "";
  /**
   * @description 创建时间
   */
  public push_time: string = "";
  /**
   * @description 得分
   */
  public score: number = 0;
  /**
   * @description 问卷题数
   */
  public question_num: string = "";
  /**
   * @description 限时（数值）
   */
  public limit_time: number = 0;
  /**
   * @description 限时开关 0关闭 1开启
   */
  public limit_time_switch: number = 0;
  /**
   * @description 是否作答 0. 否 1. 是
   */
  public status: number = 0;
  /**
   * @description答题是否结束 0. 否 1. 是
   */
  public is_end: number = 0;
  /**
   * @description 试卷 id
   */
  public paper_id: number = 0;
  /**
   * @description 限时单位类型：0 分（默认） 1 秒
   */
  public limit_time_type: number = 0;
  /**
   * @description 是否显示成绩和答案：1.是，0.否
   */
  public display_score: number = 0;
  /**
   * @description 是否强制填写，0-否（默认） 1-是
   */
  public mandatory_filling: number = 0;
  /**
   * @description 推送方式，0-手动（默认） 1-自动
   */
  public push_mode: number = 0;
  /**
   * @description 是否可重新作答，0-否（默认） 1-是
   */
  public can_re_answer: number = 0;
  /**
   * @description 答题条件
   */
  public answer_condition: condition | null = null;
  /**
   * @description 是否支持回放填写，0-否（默认） 1-是
   */
  public replay_filling: number = 0;
  /**
   * @description 总分
   */
  public total_score: number = 0;
}

export class condition {
  /**
   * @description 类型
   * */
  type: number = 0;
  /**
   * @description 观看分钟数
   * */
  viewing_minutes?: number = 0;
}


export class VHUserData {
  /**
   * 用户角色名称 角色类型 1 主持人，2 观众，3 助理，4 嘉宾
   * */
  role_name: number = 0;
  /**
   * 是否为观众 true观众
   * */
  audience?: boolean;
  /**
   * 昵称
   * */
  nickname?: string;
  /**
   * 用户id
   * */
  user_id?: string;
  /**
   * 头像URL
   * */
  avatar?: string;
  /**
   * 是否被禁言 1 被禁言  0 非禁言
   * */
  is_banned?: number;
  /**
   * 在线用户
   * */
  uv?: number;
  // 原始数据
  base_data?: VHIMMessageModel;
}

export class RoomToolsStatusData {
  /**
   * @description 开关白板，1开0关
   */
  is_board: number = 0;
  /**
   * @description 获取文档开关状态 0 否 1是
   */
  is_doc: number = 0;
  /**
   * @description 举手开关是否开启。1 开启 0 关闭
   */
  is_handsup: number = 0;
  /**
   * @description 获取观看端布局, 未设置返回空
   */
  layout: string = '';
  /**
   * @description 是否开启文档融屏 1=是|0=否
   */
  speakerAndShowLayout: number = 0;
  /**
   * @description 获取视频清晰度， 未设置返回空
   */
  definition: string = '';
  /**
   * @description 获取桌面清晰度， 未设置返回空
   */
  screen_definition: string = '';
  /**
   * @description 主画面绑定的参会ID，默认为主持人
   */
  main_screen: string = '';
  /**
   * @description 主讲人参会id
   */
  presentation_screen: string = '';
  /**
   * @description 主讲人id 文档操作权限绑定的参会ID. 默认为主持人
   */
  doc_permission: string = '';
  /**
   * @description 获取活动发起类型 1 web 2 app 3 sdk 4 推拉流 5 定时 6 admin后台 7第三方8 助手
   */
  start_type: number = 1;
  /**
   * @description 获取全体禁言 0 否 1 是
   */
  all_banned: number = 0;
  /**
   * @description 聊天状态 1开启。0 关闭
   */
  chat_status: string = '';
  /**
   * @description 获取是否开启桌面演示状态  0 否 1 是
   */
  is_desktop: number = 0;
  /**
   * @description 问答是否处于开启状态 1 开启 0 关闭，对应原始qa_open
   */
  question_status: number = 0;
  /**
   * @description 推送清晰度
   */
  public push_definition: number = 0;
  /**
   * @description HD清晰度
   */
  public hd_definition: number = 0;
  /**
   * @description 问答名称
   */
  question_name: string = '';
  /**
   * @description 废弃
   */
  cast_screen: number = 0;
  /**
   * @description 问题公开状态 0:不公开
   */
  question_public_status: number = 0;
  /**
   * @description 当前用户是否被禁言，1禁言，0取消禁言
   */
  is_banned: number = 0;
  /**
   * @description 当前用户是否被踢出，1踢出，0取消踢出
   */
  is_kicked: number = 0;
  /**
   * @description 问答状态：1开启 0关闭
   */
  qa_status: number = 0;
  /**
   * @description 私聊维度：1开启 0关闭
   */
  private_chat_status: number = 0;
  /**
   * @description 观众是否可预览文档1:是 0 否
   */
  is_adi_watch_doc: number = 0;
  /**
   * @description 是否开启分组讨论1=是|0=否
   */
  is_open_switch: number = 0;
  /**
   * @description 是否自动发言 0:否
   */
  auto_speak: number = 0;
  /**
   * @description 是否主持人在群组中 0:否
   */
  is_host_in_group: number = 0;
  /**
   * @description 视频轮询 0:关闭
   */
  video_polling: number = 0;
  /**
   * @description 加入角色
   */
  join_role: number = 2;
  /**
   * @description 禁言模式， 0 用户有感知，1 用户无感知
   */
  banned_mode: number = 0;
  /**
   * @description 群组ID
   */
  group_id: number = 0;
  raw: string = '';
  speaker_list: SpeakerList[] = [];
  videoBackGroundMap: VideoBackGround | null = null;
}

export class SpeakerList {
  nick_name: string = '';
  role_name: string = '';
  account_id: string = '';
  audio: string = '';
  video: string = '';
}

export class VideoBackGround {
  videoBackGroundSize: VideoBackGroundSize | null = null;
  videoBackGroundColor: string = '';
  videoBackGround: string = '';
}

export class VideoBackGroundSize {
  x: number = 0;
  y: number = 0;
  width: number = 0;
  height: number = 0;
}

/**
 * @description 更新虚拟人数消息。
 * */
export class VHBaseNumUpdate {
  /**
   * 更新虚拟在线人数
   * */
  update_online_num?: string;
  /**
   * 更新虚拟热度
   * */
  update_pv?: string;
  /**
   * 消息类型
   * */
  type?: string;
}

/**
 * @description 中奖者信息
 */
export class VHWinnerInformationItem {
  /**
   * @description 抽奖中奖者ID
   */
  lottery_user_id: string = "";
  /**
   * @description 抽奖中奖者昵称
   */
  lottery_user_nickname: string = "";
  /**
   * @description 中奖者头像
   */
  lottery_user_avatar: string = "";
  /**
   * @description 奖品id
   */
  lottery_award_id: string = "";
  /**
   * @description 奖品名称
   */
  lottery_award_name: string = "";
  /**
   * @description 当前用户是否中奖，true：中奖，false未中奖
   */
  win: boolean = true;
}

/**
 * @description 中奖人信息
 */
export class VHWinnerInformation {
  /**
   * @description 抽奖ID
   */
  lottery_id: number = 0;
  /**
   * @description 总消息个数
   */
  total: number = 0;
  /**
   * @description 当前用户是否中奖，true：中奖，false未中奖-新增字段
   */
  user_win: boolean = true;
  /**
   * @description 查询条件返回的结果集
   */
  list: VHWinnerInformationItem[] = [];
}

/**
 * @description 检查抽奖列表
 */
export class VHLotteryList {
  /**
   * @description 奖品信息
   */
  award_snapshoot: awardSnapshoot = new awardSnapshoot();
  /**
   * @description 抽奖id
   * **/
  id: number = 0;
  /**
   * @description 剩余数量
   * **/
  surplus: number = 0;
  /**
   * @description 排序
   * **/
  sort: number = 0;
  /**
   * @description 奖品快照
   * **/
  bus_award_snapshot_pool: number = 0;
  /**
   * @description 私信号码
   * **/
  command: string = '';
  /**
   * @description 强制奖励
   * **/
  compulsory_award: number = 0;
  /**
   * @description 创建时间
   * **/
  created_at: string = '';
  /**
   * @description 结果显示
   * **/
  display_of_results: number = 0;
  /**
   * @description 扩展信息
   * **/
  extension: string = "";
  /**
   * @description 动态图片
   * **/
  icon: string = "";
  /**
   * @description 图片顺序
   * **/
  img_order: number = 0;
  /**
   * @description 抽奖状态 0=正在抽奖 1=抽奖结束
   * **/
  lottery_status: number = -1;
  /**
   * @description 抽奖类型
   * **/
  lottery_type: number = 0;
  /**
   * @description 需要领取奖励
   * **/
  need_take_award: number = 0;
  /**
   * @description 权限
   * **/
  permission: number = 0;
  /**
   * @description 公布获奖者
   * **/
  publish_winner: number = 0;
  /**
   * @description 领取奖励天数
   * **/
  receive_award_way: number = 0;
  /**
   * @description 备注
   * **/
  remark: string = "";
  /**
   * @description 提交奖励
   * **/
  submit_award: number = 0;
  /**
   * @description 领取奖励
   * **/
  take_award: number = 0;
  /**
   * @description 标题
   * **/
  title: string = "";
  /**
   * @description 是否中奖
   * **/
  win: number = 1;
}

/**
 * @description 奖品信息
 */
export class awardSnapshoot {
  /**
   * @description 应用id
   * **/
  app_id: string = "";
  /**
   * @description 奖励描述
   * **/
  award_desc: string = "";
  /**
   * @description 奖励名称
   * **/
  award_name: string = "";
  /**
   * @description 业务id
   * **/
  business_id: string = "";
  /**
   * @description 创建时间
   * **/
  created_at: string = "";
  /**
   * @description 图片id
   * **/
  image_id: number = 0;
  /**
   * @description 图片url
   * **/
  image_url: string = "";
  /**
   * @description 链接url
   * **/
  link_url: string = "";
  /**
   * @description 抽奖id
   * **/
  lottery_id: number = 0;
  /**
   * @description 数量
   * **/
  quantity: number = 0;
  /**
   * @description 排序
   * **/
  sort: number = 0;
  /**
   * @description 来源id
   * **/
  source_id: string = '';
  /**
   * @description 剩余数量
   * **/
  surplus: number = 0;
}

/**
 * @description 检查抽奖进行中
 */
export class VHLotteryCarryOut {
  /**
   * @description 参与抽奖人员范围  1 - 参会用户 2 - 填写问卷用户 3 - 签到用户 8 - 口令抽奖
   */
  lottery_type: number = 0;
  /**
   * @description 抽奖标题
   */
  title: string = '';
  /**
   * @description 奖品快照
   */
  award_snapshoot: string = '';
  /**
   * @description 抽奖ID
   */
  id: number = 0;
  /**
   * @description 扩展字段
   */
  extension: string = '';
  /**
   * @description 图标地址
   */
  icon: string = '';
  /**
   * @description 抽奖动图下标
   */
  img_order: string = '';
  /**
   * @description 本次抽奖说明
   */
  remark: string = '';
  /**
   * @description 中奖口令
   */
  command: string = '';
  /**
   * @description 是否已提交过口令  0 - 否 1 - 是
   */
  submit_command: number = 0;
  /**
   * @description 是否公布中奖名单  0 - 否（默认）  1 - 是
   */
  publish_winner: number = 0;
  /**
   * @description 抽奖创建时间
   */
  created_at: string = '';
  /**
   * @description 是否有权限结束抽奖  1 - 有 0 - 无
   */
  permission: number = 0;
  /**
   * @description 抽奖状态 0 - 开始抽奖 1 - 抽奖完成（结束）
   */
  lottery_status: number = -1;
  /**
   * @description 是否已中奖 0 - 否 1 - 是
   */
  win: number = 0;
  /**
   * @description 是否已领奖 0 - 否  1 - 是
   */
  take_award: number = 0;
  /**
   * @description 是否需要领奖  0 - 否 1 - 是
   */
  need_take_award: number = 0;
  /**
   * @description 是否允许查看奖品池 0 不允许 1允许
   */
  can_look_award_pool: number = 0;
  /**
   * @description 展示效果 0:全屏 1:半屏
   */
  display_of_results: number = 0;
  /**
   * @description 是否强制领奖 0:否 1:是
   */
  compulsory_award: number = 0;
}

export class VHHistoryQuestionnaireInfo {
  /**
   * 个数
   * **/
  total: number = 0;
  /**
   * 问卷标题内容
   * **/
  list: VHHistoryQuestionnaire[] = [];
  /**
   *中奖状态 0-不可用 1-可用
   * ***/
  my_award_status: number = 0;
  /**
   * 个数
   * */
  limit: number | null = null
  /**
   * 位置
   * */
  pos: number | null = null;
}

/**
 * @description 问卷
 */
export class VHHistoryQuestionnaire {
  /**
   * @description 名称
   */
  title: string = '';
  /**
   * @description 活动id
   */
  webinar_id: number = 0;
  /**
   * @description 问卷id
   */
  question_id: number = 0;
  /**
   * @description 问卷编号
   */
  question_no: string = '';
  /**
   * @description 别名
   */
  alias: string = '';
  /**
   * @description 是否参与 1参与 0未参与
   */
  is_answered: string = '';
  /**
   * @description 创建时间
   */
  created_at: string = '';
  /**
   * @description 更新时间
   */
  updated_at: string = '';
  /**
   *是否开启强制提交 0：否  1：是
   * */
  mandatory_filling: number = 0;
}

export class FilesList {
  /**
   * @description 文件个数
   */
  total: number = 0;
  /**
   * @description 文件内容
   */
  list: FilesInfo[] = [];
  config: FileConfig | null = null;
}

export class FileConfig {
  /**
   * @description 指定表单条件时是否支持填写报名表单也允许下载：1.是，0.否，默认为1
   */
  form_allow_download: number = 0;
  /**
   * @description 样式 list 列表 card 卡片
   */
  style: string = '';
  /**
   * @description 0:无条件 1:问卷 2:登入 3:设置观看时长
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

export class FilesInfo {
  /**
   * @description 文件名称
   */
  file_name: string = '';
  /**
   * @description 文件大小
   */
  file_size: string = '';
  /**
   * @description 文件格式
   */
  file_ext: string = '';
  /**
   * @description 文件ID
   */
  file_id: string = '';
  /**
   * @description 文件类型 0:文档 1:音视频
   */
  file_type: string = '';
  /**
   * @description 文件描述
   */
  file_desc: string = '';
  /**
   * @description 文件封面
   */
  img_url: string = '';
}

/**
 * @description AI创作字幕信息
 */
export class VHAISubtitles {
  /**
   * @description 字幕状态
   */
  status: number = 0;
  /**
   * @description AI字幕开关状态
   */
  ai_subtitle_switch: number = 0;
  /**
   * @description 字幕语言
   */
  lang: string = '';
  /**
   * @description 字幕文件URL
   */
  file_url: string = '';
}

/**
 * @description AI创作字幕信息
 */
export class VHAISubtitleStyle {
  /**
   * @description 字体大小
   */
  font_size: number = 0.0;
  /**
   * @description 字体颜色
   */
  font_color: string = '';
  /**
   * @description 是否粗体
   */
  is_bold: number = 0;
  /**
   * @description 是否下划线
   */
  is_underline: number = 0;
  /**
   * @description 是否倾斜
   */
  is_incline: number = 0;
  /**
   * @description 透明度
   */
  opacity: number = 0;
  /**
   * @description 描边颜色
   */
  stroke_color: string = '';
  /**
   * @description 描边宽度
   */
  stroke_width: number = 0;
}

/**
 * @description AI精彩时刻
 */
export class VHAIMoments {
  /**
   * @description 精彩瞬间文件URL
   */
  file_url: string = '';
  /**
   * @description 精彩瞬间状态
   */
  status: number = 0;
  /**
   * @description 精彩瞬间ID
   */
  id: number = 0;
}

/**
 * @description 概要总结
 */
export class VHAISummary {
  /**
   * @description 摘要文件URL
   */
  file_url: string = '';
  /**
   * @description 摘要状态
   */
  status: number = 0;
  /**
   * @description 摘要ID
   */
  id: number = 0;
}

// 如果需要一个包含所有属性的主类
export class VHAIMediaInfo {
  /**
   * @description 字幕信息
   */
  subtitles: VHAISubtitles = new VHAISubtitles();
  /**
   * @description 字幕样式
   */
  subtitle_style: VHAISubtitleStyle = new VHAISubtitleStyle();
  /**
   * @description 精彩瞬间
   */
  moments: VHAIMoments = new VHAIMoments();
  /**
   * @description 内容摘要
   */
  summary: VHAISummary = new VHAISummary();
}

/**
 * @description ai 精彩回放信息
 */
export class VHAIHighlightModel {
  /**
   * @description 高亮截图的网络URL地址
   */
  image_url: string = '';
  /**
   * @description 主题描述
   */
  subject: string = '';
  /**
   * @description 开始时间
   */
  start_time: number = 0;
}

/**
 * @description ai 概要
 */
export class VHAISummaryModel {
  /**
   * @description 关键词
   */
  keywords: string[] = [];
  /**
   * @description 主题描述
   */
  subject: string = '';
  /**
   * @description 概要总结
   */
  summary: string = "";
}

/**
 * @description 图片信息
 */
export class WebinarGoodsImgInfo {
  /**
   * @description 图片地址
   */
  img_url: string = '';
  /**
   * @description 是否是封面图片(0.否 1.是)
   */
  is_cover: number = 0;
}

/**
 * @description 小程序配置
 */
export class MiniProgramConfig {
  /**
   * @description 小程序ID
   */
  mini_program_id: string = '';
  /**
   * @description 小程序APPID
   */
  mini_program_app_id: string = '';
  /**
   * @description 小程序商品的跳转方式 0 内部跳转 [缺省值], 1 H5跳转到小程序 小程序跳转方式 默认值: 0
   */
  mini_program_jump_type: string = '';
  /**
   * @description 小程序路径<= 300 字符
   */
  mini_program_path: string = '';
  /**
   * @description 扩展参数
   */
  mini_program_ext: string = '';
}

/**
 * @description 商品列表信息
 */
export class VHGoodsListData {
  /**
   * @description 商品ID
   */
  goods_id: number = 0;
  /**
   * @description 商品名称
   */
  name: string = '';
  /**
   * 折扣价
   */
  discount_price: number = 0;
  /**
   * 覆盖状态,隐藏价格（0-不覆盖，1-覆盖原有价格/配置）
   */
  covered_status: number = 0;
  /**
   * 覆盖价格（特殊场景下的自定义价格展示，如"免费"、"议价"）
   */
  covered_price: string = "";
  /**
   * @description 购买类型(1.平台购买 2.外链购买 3.自定义购买(APP嵌入) 4.自定义购买(小程序嵌入))
   */
  buy_type: number = 0;
  /**
   * @description 原价
   */
  price: number = 0;
  /**
   * @description 商品描述
   */
  description: string = '';
  /**
   * @description 活动商品ID
   */
  webinar_goods_id: number = 0;
  /**
   * @description 排序
   */
  order_num: number = 0;
  /**
   * @description 上架状态(0.下架 1.上架 2.推送上架)
   */
  status: number = 0;
  /**
   * @description 推送状态(0.未推送 1.推送中 2.已推送)
   */
  push_status: number = 0;
  /**
   * @description 封面图片
   */
  cover_img: string = '';
  /**
   * @description 商品链接
   */
  url: string = '';
  /**
   * @description 二维码链接
   */
  qr_code_url: string = '';
  /**
   * @description 扩展字段
   */
  ext_data: string = '';
  /**
   * @description 显示店铺
   */
  shop_show: number = 0;
  /**
   * @description 店铺链接
   */
  shop_url: string = '';
  /**
   * @description 三方商品ID
   */
  third_goods_id: string = '';
  /**
   * @description 图片集合
   */
  images: WebinarGoodsImgInfo[] = [];
  /**
   * @description schemeTemplate
   */
  scheme_template: string = '';
  /**
   * @description 是否自动弹窗 默认值: 0
   */
  auto_pop: number = 0;
  /**
   * @description 推送时间
   */
  push_time: number = 0;
  /**
   * @description 售卖状态(0=售罄，1=销售中（默认）、2=其他...)
   */
  sale_status: number = 0;
  /**
   * @description 小程序配置
   */
  mini_program_config: MiniProgramConfig = new MiniProgramConfig();
}

/***
 * 活动回放列表信息
 * **/
export class VHWebinarRecordWatch {
  /**
   * 时长
   * */
  duration: string = "";
  /**
   *
   * */
  encrypt_status: number = 0;
  /**
   * 回放id
   * */
  id: number = 0;
  /**
   * 图片地址
   * */
  img_url: string = "";
  /**
   *
   * */
  is_union_screen: number = 0;
  /**
   * 活动名称
   * */
  name: string = "";
  /**
   * 活动回放id
   * */
  paas_record_id: string = "";
  /**
   *
   * */
  record_remark_layout: number = 0;
}


export class PrivacyAgreementInfo {
  /**
   * @description 隐私ID
   */
  id: number = 0;
  /**
   * @description 活动ID
   */
  webinar_id: number = 0;
  /**
   * @description 是否使用自定义隐私协议
   */
  statement_status: number = 0;
  /**
   * @description 隐私协议内容
   */
  statement_content: string = '';
  /**
   * @description 隐私协议关键词链接
   */
  statement_info: StatementInfo[] = [];
}

export class TextStatementInfo {
  /**
   * @description 协议内容
   * **/
  public content: string | undefined = "";
  /**
   * @description 协议链接
   * **/
  public link: string = "";
  /**
   * @description 是否链接
   */
  public isLink: boolean = false;
}

/**
 * @description 可用优惠券信息实体类
 */
export class VHCouponInfo {
  /**
   * @description 用户领取优惠券ID
   */
  coupon_user_id: number = 0;
  /**
   * @description 优惠券id
   */
  coupon_id: number = 0;
  /**
   * @description 优惠券名称
   */
  coupon_name: string = '';
  /**
   * @description 优惠券类型 0-满减优惠 1-无门槛优惠
   */
  coupon_type: number = 0;
  /**
   * @description 门槛金额
   */
  threshold_amount: number = 0;
  /**
   * @description 减免金额
   */
  deduction_amount: number = 0;
  /**
   * @description 有效期类型 0-固定日期 1-固定天数
   */
  validity_type: number = 0;
  /**
   * @description 有效期天数
   */
  validity_day: number = 0;
  /**
   * @description 有效期开始时间
   */
  validity_start_time: string = '';
  /**
   * @description 有效期结束时间
   */
  validity_end_time: string = '';
  /**
   * 使用说明
   */
  use_desc: string = '';
  /**
   * 适用商品类型 0-全部商品 1-指定商品可用 2-指定商品不可用
   */
  applicable_product_type: number = 0;
  /**
   * @description 商品数量
   */
  goods_num: number = 0;
  /**
   * @description 操作人id
   */
  business_uid: number = 0;
  /**
   * @description 操作人昵称
   */
  nick_name: string = '';
  /**
   * @description 更新时间
   */
  updated_at: string = '';
}

/**
 * @description 不可用优惠券信息实体类
 */
export class VHNotAvailableCouponInfo {
  /**
   * @description 不可用原因 0-未达条件 1-已失效-2-已使用
   */
  unavailable_type: number = 0;
  /**
   * @description 使用时间
   */
  use_time: number = 0;
  /**
   * @description 用户领取优惠券ID
   */
  coupon_user_id: number = 0;
  /**
   * @description 优惠券id
   */
  coupon_id: number = 0;
  /**
   * @description 优惠券名称
   */
  coupon_name: string = '';
  /**
   * @description 优惠券类型 0-满减优惠 1-无门槛优惠
   */
  coupon_type: number = 0;
  /**
   * @description 门槛金额
   */
  threshold_amount: number = 0;
  /**
   * @description 减免金额
   */
  deduction_amount: number = 0;
  /**
   * @description 有效期类型 0-固定日期 1-固定天数
   */
  validity_type: number = 0;
  /**
   * @description 有效期天数
   */
  validity_day: number = 0;
  /**
   * @description 有效期开始时间
   */
  validity_start_time: string = '';
  /**
   * @description 有效期结束时间
   */
  validity_end_time: string = '';
  /**
   * 使用说明
   */
  use_desc: string = '';
  /**
   * 适用商品类型 0-全部商品 1-指定商品可用 2-指定商品不可用
   */
  applicable_product_type: number = 0;
  /**
   * @description 商品数量
   */
  goods_num: number = 0;
  /**
   * @description 操作人id
   */
  business_uid: number = 0;
  /**
   * @description 操作人昵称
   */
  nick_name: string = '';
  /**
   * @description 更新时间
   */
  updated_at: string = '';
}

export class VHGoodsActivitySettings {
  /**
   * @description 活动ID
   * * **/
  public webinar_id: number = 0;
  /**
   * @description 开启姓名;0.否 1.是
   * * **/
  public enable_username: number = 0;
  /**
   * @description 开启手机号;0.否 1.是
   * * **/
  public enable_phone: number = 0;
  /**
   * @description 开启留言;0.否 1.是
   * * **/
  public enable_remark: number = 0;
  /**
   * @description 开启优惠券入口;0.否 1.是
   * * **/
  public enable_coupon: number = 0;
  /**
   * @description 姓名
   * * **/
  public username: string = '';
  /**
   * @description 手机号
   * * **/
  public phone: string = '';
  /**
   * @description 自定义按钮文案
   * * **/
  public btn_description: string = '';
  /**
   * @description 推送显示商品数量
   * * **/
  public push_show_num: number = 0;
  /**
   * @description 是否开启观看端购买特效消息(0=不开启，1=开启)
   * * **/
  public enable_buy_notice: number = 0;
  /**
   * @description 是否开启详情页直接跳转: 0=不开启(默认），1=开启
   * * **/
  public enable_direct_view: number = 0;
  /**
   * @description 是否开启热卖提示(默认0=不开启,1=开启)
   * * **/
  public enable_hot_sale: number = 0;
}

export class VHMenuInfo {
  //目录列表
  public components: MenuInfoItem[] = [];
}

export class MenuInfoItem {
  /**
   * @description 组件ID（1:图文，2：二维码，3：直播，4：专题，5：文字链，6：图片链，7：标题，8：分割线， 9：排行榜,10: 外链嵌入）
   * **/
  public component_id: number = 0;
  /**
   * @description 内容
   * **/
  public content: string = "";
  /**
   * @description 活动ID,用于3直播
   */
  public webinars: string[] = [];
  /**
   * @description 专题ID，用于：4专题
   */
  public subjects: string[] = [];
  /**
   * @description 图片地址，用于二维码
   */
  public imageSrc: string = "";
  /**
   * @description 文字：用于5文字链接
   */
  public text: string = "";
  /**
   * @description 链接：用于5文字链接
   */
  public src: string = "";
  /**
   * @description 标题：用于7标题
   */
  public title: string = "";
  /**
   * @description 组件类型：用于10外链嵌入
   */
  public compType: string = "";
  /**
   * @description 页面链接 :用于10外链嵌入
   */
  public url: string = "";
  /**
   * @description 页面高度:用于10外链嵌入
   */
  public pageHeight: string = "";
  /**
   * @description 绑定参数:用于10外链嵌入
   */
  public checkedUrlParams: string[] = [];
  /**
   * @description 排行榜内容，用于9排行榜
   */
  public inContent: string = "";
  /**
   * @description 排行榜开关 1：打开，0关闭，用于9排行榜
   */
  public inSwitch: number = 0;
}

//创建订单返回的数据
export class VHCreateOrderInfo {
  /**
   * @description 订单号
   * **/
  public order_no: string = "";
  /**
   * @description 订单状态
   * **/
  public order_status: string = "";
  /**
   * @description 订单支付扩展属性
   */
  public ext: ESObject = {};
  /**
   * @description 引用
   */
  public referer: string = "";
}


/**
 * @description 定义提示配置接口
 * */
export class VHPromptConfig {
  /**
   * @description
   * */
  trigger_list: string[] = [];
  /**
   * @description
   * */
  custom_qr_code_url: string = ""
  /**
   * @description
   * */
  show_on_navi: number = 0;
  /**
   * @description
   * */
  auto_prompt: number = 0;
}

/**
 * @description
 * */
export class VHForceConfig {
  /**
   * @description
   * */
  trigger_list: string[] = [];
  /**
   * @description
   * */
  custom_qr_code_url: string = "";
  /**
   * @description 已开启，在顶部导航栏展示 0关闭 1开启
   * */
  show_on_navi: number = 0;
  /**
   * @description
   * */
  auto_prompt: number = 0;
}

/**
 * @description 公众号引导预约自动回复
 * */
export class VHAutoReplyConfig {
  /**
   * @description 标题
   * */
  title: string = "";
  /**
   * @description 简介
   * */
  summary: string = "";
  /**
   * @description 二维码
   * */
  icon_url: string = "";
  /**
   * @description 二维码
   * */
  target_url: string = "";
}

/**
 * @description
 * */
export interface VHMarketingPublicAccount {
  /**
   * @description
   * */
  source_type: number;

  /**
   * @description
   * */
  source_id: number;

  /**
   * @description 是否开启了公众号
   * */
  enable: number;

  /**
   * @description
   * */
  prompt_enable: number;

  /**
   * @description
   * */
  force_enable: number;

  /**
   * @description
   * */
  auto_reply_enable: number;

  /**
   * @description
   * */
  prompt_config: VHPromptConfig;

  /**
   * @description
   * */
  force_config: VHForceConfig;

  /**
   * @description
   * */
  auto_reply_config: VHAutoReplyConfig;

  /**
   * @description
   * */
  qr_id: string;

  /**
   * @description
   * */
  updated_at: string;

  /**
   * @description 0开屏提示关注 1 引导预约关注 2报名强制关注
   * */
  follow_type: number;

  /**
   * @description 预约引导关注与报名强制关注文案
   * */
  head_tip: string;

  /**
   * @description 预约引导关注与报名强制关注文案
   * */
  bottom_tip: string;

  /**
   * @description 文案是否开启
   * */
  tip_status: number;
}

export class VHSubjectList {
  /**
   * @description 专题列表
   */
  public list: VHSubjectInfo[] = [];
}

export class VHSubjectInfo {
  /**
   * @description 专题id
   */
  id: number = 0;
  /**
   * @description 专题标题
   */
  title: string = '';
  /**
   * @description 封面图片
   */
  cover: string = '';
  /**
   * @description 创建时间
   */
  created_at: string = '';
  /**
   * @description 专题类型：1.普通专题，2.老系统双语（按普通专题处理），3.双语专题
   */
  type: number = 0;
  /**
   * @description 预约人数
   */
  pv: number = 0;
  /**
   * @description 是否显示pv 1:显示 0:不显示
   */
  hide_pv: number = 0;
  /**
   * @description 是否显示预约人数 1:显示 0:不显示
   */
  hide_appointment: number = 0;
  /**
   * @description 活动数
   */
  webinar_num: number = 0;
  /**
   * @description 0:无统一观看限制 1:统一观看限制 2:统一报名表单
   */
  subject_verify: string = '';
}

export class VHWebinarList {
  /**
   * @description 活动列表
   */
  public list: VHWebinarDetail[] = [];
}

export class PaymentData {
  /**
   * @description 订单号
   */
  public order_no: string = "";
  /**
   * @description 订单状态
   */
  public order_status: string = "";
  /**
   * @description 订单支付扩展属性
   */
  public ext: ESObject = {};
  public referer: string = "";
}

export class VHInviteTopList {
  /**
   * @description 活动列表
   */
  public list: VHInviteTopListDetails[] = [];
  /**
   * @description 数据总量
   */
  public total: number = 0;
  /**
   * @description 当前用户数据
   */
  public my: VHCurrentInviterData = new VHCurrentInviterData();
}

export class VHInviteTopListDetails {
  /**
   * @description 昵称
   */
  nick_name: string = '';
  /**
   * @description 邀请人数
   */
  num: number = 0;
  /**
   * @description 邀请id
   */
  invite_id: string = '';
  /**
   * @description 邀请id类型
   */
  invite_id_type: string = '';
  /**
   * @description 头像url
   */
  img_url: string = '';
  /**
   * @description 邀请人填写的名称
   */
  invite_name: string = '';
}

export class VHCurrentInviterData {
  /**
   * @description 昵称
   */
  nick_name: string = '';
  /**
   * @description 邀请人数
   */
  num: number = 0;
  /**
   * @description 头像url
   */
  img_url: string = '';
  /**
   * @description 位置
   */
  position: string = '';
}

export class VHInviteCard {
  /**
   * @description 复制链接文本内容开头部分
   */
  copy_url_beginning: string = "";
  /**
   * @description 复制链接开关
   */
  copy_url_switch: number = 0;
  /**
   * @description 封面图
   */
  cover_img: string = "";
  /**
   * @description 活动时间
   */
  date_time: string = "";
  /**
   * @description 邀请人头像
   */
  head_url: string = "";
  /**
   * @description 简介
   */
  introduction: string = "";
  /**
   * @description 邀请码
   */
  invite_code: string = "";
  /**
   * @description 邀请明细开关，0-关 1-开
   */
  invite_detail_switch: number = 0;
  /**
   * @description 邀请页面url
   */
  invite_url: string = "";
  /**
   * @description 语言类型 0:中文 1:英文
   */
  language_type: number = 0;
  /**
   * @description 地点
   */
  location: string = "";
  /**
   * @description 邀请人昵称
   */
  nick_name: string = "";
  /**
   * @description 下载自己的邀请明细开关，0-关 1-开
   */
  self_download_switch: number = 0;
  /**
   * @description 主办方
   */
  sponsor: string = "";
  /**
   * @description 模板信息
   */
  templates: VHInviteCardTemplate[] = [];
  /**
   * @description 标题
   */
  title: string = "";
  /**
   * @description 欢迎语
   */
  welcome_text: string = "";
}

export class VHInviteCardTemplate {
  /**
   * @description 背景图片
   */
  img_url: string = "";
  /**
   * @description 是否删除 0.不删除 1.删除
   */
  is_delete: number = 0;
  /**
   * @description 是否选中： 0否 1是
   */
  is_selected: number = 0;
  /**
   * @description 是否观看端展示 0.不展示 1.展示
   */
  is_show: number = 0;
  /**
   * @description 是否展示头像：0不展示 1展示
   */
  is_show_avatar: number = 0;
  /**
   * @description 是否展示二维码 0.不显示 1.显示
   */
  is_show_qrcode: number = 0;
  /**
   * @description 是否展示用户信息 0.不显示 1.显示
   */
  is_show_userinfo: number = 0;
  /**
   * @description 排序
   */
  order_num: number = 0;
  /**
   * @description 模板id
   */
  template_id: number = 0;
  /**
   * @description 模板样式 json
   * /
   template_json: string = "";
   /*
   * @description 模板类型 0.系统模板 1.自定义模板
   */
  template_type: number = 0;
  /**
   * @description 系统模版前端定义ID
   */
  theme_remark: number = 0;
  /**
   * @description 主题样式类型 0.深色 1.浅色
   */
  theme_type: number = 0;
}

/**
 * 活动权限配置
 * **/
export class VHConfigList {
  /**
   * 登录设置:预约/观看直播强制登录  1强制 0非强制
   * */
  hard_login: number = 0;
  /**
   * 点赞功能:观看端-隐藏点赞 1隐藏 0不隐藏
   * */
  watch_hide_like: number = 0;
  /**
   * 点赞功能:观看端-隐藏点赞数据 1隐藏 0不隐藏
   * */
  hidden_watch_like_data: number = 0;
  /**
   * 直播隐藏原画  1隐藏 0不隐藏
   * */
  live_hidden_same: number = 0;
  /**
   * 聊天欢迎语 1支持 0不支持
   * */
  live_chat_welcome: number = 0;
  /**
   * 聊天欢迎语 eg：欢迎{user_nickname}进入直播间。其中{user_nickname}为占位符，需要用户自行进行替换
   * */
  live_chat_welcome_msg : string = "";
  /**
   * 观看端-回放禁言  1禁言 0不禁言
   * */
  watch_record_no_chatting: number = 0;
  /**
   * 回放/点播观看端显示文档章节  1显示 0不显示
   * */
  watch_record_chapter: number = 0;
  /**
   * 回放过期时间(回放有效期)
   * **/
  record_watch_expire_config: VHRecordWatchExpire = new VHRecordWatchExpire;
  /**
   * 观看端-礼物功能   1隐藏 0不隐藏
   * */
  hide_gifts: number = 0;
  /**
   * 聊天昵称加密。0 不加密 1 加密
   * **/
  chat_nickname_encryption: number = 0;
}

/**
 * 回放过期时间。需要根据过期时间自行处理回放是否可以继续观看
 * **/
export class VHRecordWatchExpire {
  /**
   * 类型：1 开启 0 关闭
   * **/
  status: number = 0;
  /**
   * 类型：1 全天 2部分时段
   * **/
  type: string = "1";
  /**
   * 开始日期
   * **/
  start_date: string = ""; // "2025-10-14",
  /**
   * 结束日期
   * **/
  end_date: string = ""; // "2025-10-30",
  /**
   * 开始时间
   * **/
  start_time: string = ""; // "14: 55: 12",
  /**
   * 结束时间
   * **/
  end_time: string = ""; // "15: 55: 12"
}

export class VHUploadFileInfo {
  file_url: string = "";
  lines: string = "";
  domain_url: string = "";
}

export class VHMyInviteDetailList {
  /**
   * @description 我的邀请明细
   */
  public list: VHMyInviteDetail[] = [];
  /**
   * @description 数据总量
   */
  public total: number = 0;
}

export class VHMyInviteDetail {
  /**
   * @description 昵称
   */
  nickname: string = '';
  /**
   * @description 进入时间，格式：yyyy-MM-dd HH:mm:ss
   */
  enter_time: string = '';
}

export class VHSurveyAnswerReplayList {
  /**
   * @description 消息内容
   */
  answer_replay_list: VHSurveyAnswerReplayInfo[] = [];
}

export class VHSurveyAnswerReplayInfo {
  /**
   * @description 问卷ID
   */
  id: string = "";
  /**
   * @description 答案ID
   */
  question_answer_id: number = 0;
  /**
   * @description 用户ID
   */
  third_party_user_id: string = "";
  /**
   * @description 问题ID
   */
  question_id: number = 0;
  /**
   * @description 答案
   */
  answer: string = "";
}

export class VHQaRecommendList {
  /**
   * @description 问答推荐列表
   */
  list: VHQaRecommendInfo[] = [];
}


/**
 * 最后一次推送的问卷信息
 * **/
export class VHWebinarSurvey {
  /**
   * 发送用户id
   * */
  account_id: string = "";
  /**
   * 别称
   * */
  alias: string = "";
  /**
   * app_id
   * */
  app_id: string = "";
  /**
   * category
   * */
  category: number = 1;
  /**
   * 遮罩
   * */
  cover: string = "";
  /**
   * 创建时间
   * */
  created_at: string = "";
  /**
   * 描述
   * */
  description: string = "";
  /**
   * 拓展信息
   * */
  extend: string = "";
  /**
   * 拓展信息
   * */
  is_public: number = 0;
  /**
   *问卷id
   * */
  question_id: number = 0;
  /**
   *问卷序号
   * */
  question_no: string = "";
  /**
   *标题
   * */
  title: string = "";
  /**
   *标题
   * */
  topic_num: number = 0;
}

/**
 * 问卷扩展信息
 * **/
export class VHWebinarSurveyExtend {
  /**
   *是否开启强制提交 0：否  1：是
   * */
  mandatory_filling: number = 0;
  /**
   * 开启隐私协议
   * */
  privacy_agreement: number = 0;
  /**
   * 是否开启回放填写问卷
   * */
  playback_filling: number = 0;
  /**
   * 是否有模板
   * */
  has_tpl: number = 0;
  /**
   * 是否开启手机验证
   * */
  phone_verification_switch: number = 0;
  /**
   * 是否开启banner
   * */
  enable_banner: number = 0;
}


export class VHQaRecommendInfo {
  /**
   * @description ID
   */
  id: number = 0;
  /**
   * @description 内容
   */
  content: string = '';
  /**
   * @description 创建时间
   */
  created_at: string = '';
  /**
   * @description 回复
   */
  answer: VHQaRecommendAnswerInfo[] = [];
}

export class VHQaRecommendAnswerInfo {
  /**
   * @description ID
   */
  id: number = 0;
  /**
   * @description 内容
   */
  content: string = '';
  /**
   * @description 创建时间
   */
  created_at: string = '';
}

/**
 * 商品图片信息子模型
 * 用于存储商品的图片列表数据
 */
export class VHGoodsImages {
  /**
   * 图片URL地址
   */
  img_url: string = '';
  /**
   * 是否为封面图（1-是，0-否）
   */
  is_cover: number = 0;
}

/**
 * 商品信息主模型
 * 完整映射商品相关的所有字段，包含业务状态、价格、图片等信息
 */
export class VHGoodsInfo {
  /**
   * 是否启用多配置（0-否，1-是）
   */
  enable_multi_config: number = 0;
  /**
   * 购买类型
   */
  buy_type: number = 0;
  /**
   * 原价
   */
  price: number = 0;
  /**
   * 折扣价
   */
  discount_price: number = 0;
  /**
   * 覆盖状态（0-不覆盖，1-覆盖原有价格/配置）
   */
  covered_status: number = 0;
  /**
   * 覆盖价格（特殊场景下的自定义价格展示，如"免费"、"议价"）
   */
  covered_price: string = "";
  /**
   * 商品描述信息
   */
  description: string = "";
  /**
   *  webinar关联商品ID（用于关联直播场次的商品）
   */
  webinar_goods_id: number = 0;
  /**
   * 已售订单数量
   */
  order_num: number = 0;
  /**
   * 商品状态（1-正常，0-下架，2-待上架等）
   */
  status: number = 1;
  /**
   * 推送状态（0-未推送，1-推送中，2-已推送）
   * 用于控制商品是否在直播中推送展示
   */
  push_status: number = 2;
  /**
   * 商品封面图URL（主图）
   */
  cover_img: string = "";
  /**
   * 商品跳转链接（如电商详情页、购买页）
   */
  url: string = "";
  /**
   * 扩展数据（存储额外的业务配置，JSON格式字符串）
   */
  ext_data: string = "";
  /**
   * 店铺展示状态（0-不在店铺展示，1-在店铺展示）
   */
  shop_show: number = 0;
  /**
   * 店铺跳转链接
   */
  shop_url: string = "";
  /**
   * 商品图片列表（包含封面图和详情图）
   */
  images: Array<VHGoodsImages> = [];
  /**
   * 自动弹窗状态（0-不自动弹窗，1-进入页面自动弹窗展示商品）
   */
  auto_pop: number = 0;
  /**
   * 推送时间（时间戳，单位：毫秒）
   */
  push_time: number = 0;
  /**
   * 销售状态（1-在售，2-售罄）
   */
  sale_status: number = 0;
  /**
   * 商品ID（唯一标识）
   */
  goods_id: number = 0;
  /**
   * 第三方商品ID（对接外部电商平台的商品ID）
   */
  third_goods_id: string = "";
  /**
   * 商品名称
   */
  name: string = "";
}
