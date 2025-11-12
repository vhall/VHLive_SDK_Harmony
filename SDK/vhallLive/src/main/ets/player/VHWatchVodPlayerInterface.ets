import {VHVodSupportSpeed,VHErrorInfo,VHPlayerState,VHPlayerPipState,
  VHPipControlPanelStatus,VHPlayDefinition,VHCastPickerDevice,VHCastPickerState} from './../model/VHWatchWebinarInfo'
export interface VHWatchVodPlayerCallback{
  /**
   * @description 组件加载成功.成功后可以调用播放
   */
  onPlayerViewInitCompleted(): void;

  /**
   * 播放器播放失败事件
   */
  onPlayerError(error: VHErrorInfo): void;
  /**
   * 观看状态回调
   * @param player  播放器实例
   * @param state   状态类型 详见 VHPlayerStatus 的定义.
   */
  onStatusDidChange(state: VHPlayerState): void;
  /**
   * 画中画状态
   * @param state: 画中画播放状态
   */
  onPipStatusChange(state: VHPlayerPipState): void;

  /**
   * 画中画控制中心播放状态
   * @param state: VHPlayerPipControlPanelStatus
   */
  onPipControlPanelStatusChange(state: VHPipControlPanelStatus): void;

  /**
   * 播放器音量
   * @param volume :当前播放器音量值
   */
  onPlayerVolume(volume: number): void;
  /**
   * 当前房间支持的清晰度列表
   * @param definitions   支持的清晰度列表
   */
  onValidDefinitions(definitions: VHPlayDefinition[]): void;
  /**
   * 视频流播放成功后，回调视频流的宽髙。用户可根据视频流实际宽高，调整播放容器大小。
   * @param width   视频帧宽度
   * @param height  视频帧高度
   */
  onVideoFrameSize(width: number, height: number): void;
  /**
   * 投屏设备状体事件回调。
   * @param state. 0 设备已准备好可以播放。1：设备已断开
   */
  onCastPlayDeviceState(state: number): void;
  /**
   * 已连接的投屏设备。
   * @param state. 0 设备已准备好可以播放。1：设备已断开
   */
  onCastPlayDeviceConnected(device: VHCastPickerDevice): void;
  /**
   * 投屏事件回调。
   * @param state:VHCastPlayState
   */
  onCastPlayState(state: VHCastPickerState): void;
  /**
   * 投屏播放时长。
   * @param duration:number  播放总时长 ，单位ms
   */
  onCastPlayDuration(duration: number): void;
  /**
   * 投屏播放当前位置。
   * @param position:number  播放当前进度 ，单位ms
   */
  onCastPlayPosition(position: number): void;
  /**
   * 投屏操作失败。
   * @param state:VHCastPlayState。执行相关操作失败。包括开播、暂停、设置进度
   */
  onCastPlayError(state: VHCastPickerState): void;

  /**
   * @description 监听资源播放资源的时长，单位为毫秒（ms），用于刷新进度条长度
   * @param duration  回放时长，单位为毫秒（ms）。
   */
  onVodTotalDuration(duration: number): void;
  /**
   * @description 当前播放时长，单位为毫秒（ms），用于刷新进度条长度
   * @param currentDuration  当前播放时长，单位为毫秒（ms）。
   */
  onVodCurrentDuration(current: number): void;
  /**
   * @description 监听SeekTime，用于刷新进度条长度
   * @param duration  当前时长，单位为毫秒（ms）。
   */
  onVodSeekDuration(duration: number): void;
  /**
   * @description 监听倍速切换，表示切换倍速成功。
   * @param speed  当前倍速
   */
  onVodSpeedDone(speed: VHVodSupportSpeed): void;

}