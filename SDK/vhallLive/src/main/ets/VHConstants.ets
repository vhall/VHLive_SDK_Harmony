export enum  VHConstants{
    /**
   * @description 未知错误
   * **/
  UNKOWN = -2,
  /**
   * @description 成功
   * **/
  VH_OK = 0,
  /**
   * 播放器未创建
   * **/
  VH_PLAYER_NOT_BEEN_CREATE = 1,
  /**
   * @description 参数错误
   * **/
  VH_INPUT_PARAM_ERROR = 2,
  /**
   *@description  调度地址为空
   * **/
  VH_DISPATCH_URL_EMPTY = 3,
  /**
   *@description  不支持的调用
   * **/
  VH_UNSUPPORTED = 4,
  /**
   * @description 没有当前可用清晰度
   * **/
  VH_PLAY_CURRENT_DEF_FAILED = 5,
  /**
   *@description  播放器未创建成功
   * **/
  VH_PLAYER_CREATE_FAILED= 6,
  /**
   *@description  播放器未成功,无法读取视频宽高
   * **/
  VH_READ_VIDEO_SIZE_ERROR = 7,

  /**
   * @description 成功
   * **/
  VH_SUCCEED = 200,
  /**
   *@description  版本不支持播放器API
   * **/
  VH_SYSTEM_API_UNSUPPORTED= 801,
  /**
   * @description 解析失败
   * **/
  VH_ANALYSIS_DATA_ERROR = 10001,
  /**
   * @description 已经初始化
   * **/
  VH_ALREADY_INIT = 10002,
  /**
   * @description 网络异常
   * **/
  VH_NETWORK_ERROR = 2300006,
  /**
   *@description  系统内存不足或播放器数量达到最大上限。
   * **/
  VH_SYSTEM_MEMORY = 5400101,
  /**
   *@description  当前状态不允许或无权执行此操作
   * **/
  VH_PERMISSION_DENIED = 5400102,
  /**
   *@description  数据流异常信息. 播放地址信息错误或播放中拉流失败
   * **/
  VH_PLAY_STREAM_FAILED = 5400103,
  /**
   *@description  系统或网络响应超时。默认网络超时时间为15秒
   * **/
  VH_PLAY_TIMEOUT = 5400104,
  /**
   *@description  系统播放器无法进行异常。
   * **/
  VH_SERVICE_DIED = 5400105,
  /**
   * @description 播放地址失败
   * **/
  PLAY_FORMAT_ERROR = 5400106,
  /**
   *@description  音频焦点被抢占
   * **/
  VH_AUDIO_INTERRUPTED = 5400107,
  /**
   *@description  解析或链接服务端地址错误
   * **/
  VH_CAN_NOT_FIND_HOST = 5411001 ,
}

