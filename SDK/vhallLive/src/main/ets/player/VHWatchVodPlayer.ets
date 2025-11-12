import { VHVodPlayer, VHVodPlayerView, VHPlayerStatus, VHDefinition, VHCastPlayState,
  VHCastPlayMediaSource,VHCastPlayDevice,  VHPlayerScalingMode,
  WaiterMaskPostion,
  VHPlayerPipStatus,
  VHPlayerPipControlPanelStatus,
  VHPlayStreamType,
  VHErrorCode,
  VHPlayerError,
  VHVodPlayerSpeed,
  VHWaterMarkLocation } from '@vhall/vhallyun-lss-vod'

import {VHErrorInfo, VHPlayDefinition,VHWebinarData,VHCastMediaSource,VHCastPickerState,VHPlayerState,
  VHVodSupportSpeed,VHPlayerVideoScalingMode,VHPipControlPanelStatus,VHCastPickerDevice,VHPlayerPipState,
} from "../model/VHWatchWebinarInfo"
import { VHWatchVodPlayerCallback } from "./VHWatchVodPlayerInterface"
import { List } from '@kit.ArkTS';

export class VHWatchVodPlayer{
  private webinar_info?:VHWebinarData;
  private vodPlayer?:VHVodPlayer | null;
  private callback?:VHWatchVodPlayerCallback;
  private autoStart:boolean = false;
  private navId:string='';

  private scale_mode:VHPlayerVideoScalingMode = VHPlayerVideoScalingMode.VH_ASPECT_FIT;
  constructor(context:Context) {
    this.vodPlayer = new VHVodPlayer(context);
  }

  /*
  * @description
  * 初始化活动信息
  * **/
  public initWebinarInfo(webinarsInfo:VHWebinarData){
    this.webinar_info = webinarsInfo;
  }

  /**
   * @description
   * 设置回调监听
   * */
  public setVodPlayerListener(listener:VHWatchVodPlayerCallback){
    this.callback = listener;
    this.vodPlayer?.setVHLivePlayerInterface(this,this);
  }

  /**
   * @description
   * 初始化投屏能力。
   * */
  public initCastPlay(source: VHCastMediaSource){
    if(this.vodPlayer){
      let initCast: VHCastPlayMediaSource ={name:source.name,title:source.title,description:source.description,headImage:source.headImage};
      this.vodPlayer.initCastPlay(initCast);
    }
  }

  /**
   * @description 初始化画中画.
   * @param autoStart:boolean 退到后台是否自动开启画中画
   * @param navId:string 当前page导航id
   * 1、UIAbility使用Navigation管理页面，需要设置Navigation控件的id属性，并将该id设置给画中画控制器，确保还原场景下能够从画中画窗口恢复到原页面
   * 2、UIAbility使用Router管理页面时（画中画场景不推荐该导航方式），无需设置navigationId。注意：该场景下启动画中画后，不要进行页面切换，否则还原场景可能出现异常
   * 3、UIAbility只有单页面时，无需设置navigationId，还原场景下也能够从画中画窗口恢复到原页面
   * **/
  public initPipController(autoStart:boolean,navId?:string){
    this.autoStart = autoStart;
    if(navId){
      this.navId = navId;
    }
  }
  /**
   * @description
   * 销毁播放器。
   */
  public destroyPlayer(){
    if(this.vodPlayer){
      this.vodPlayer?.destroyPlayer();
      this.vodPlayer = null;
    }
  }

  /**
   * @description
   * 用于直播、回放开始播放视频，进行活动拉流播放。请区分使用暂停、恢复播放.
   * @param def 初始化播放的清晰度
   * */
  public startPlay(def:VHPlayDefinition){
    if(this.vodPlayer){
      switch (def){
        case VHPlayDefinition.VH_ORIGIN:
          this.vodPlayer.startPlay(this.webinar_info?.paas_record_id!,this.webinar_info?.interact?.paas_access_token!,VHDefinition.ORIGIN);
          break;
        case VHPlayDefinition.VH_UHD:
          this.vodPlayer.startPlay(this.webinar_info?.paas_record_id!,this.webinar_info?.interact?.paas_access_token!,VHDefinition.UHD);
          break;
        case VHPlayDefinition.VH_HD:
          this.vodPlayer.startPlay(this.webinar_info?.paas_record_id!,this.webinar_info?.interact?.paas_access_token!,VHDefinition.HD);
          break;
        case VHPlayDefinition.VH_SD:
          this.vodPlayer.startPlay(this.webinar_info?.paas_record_id!,this.webinar_info?.interact?.paas_access_token!,VHDefinition.SD);
          break;
        case VHPlayDefinition.VH_AUDIO:
          this.vodPlayer.startPlay(this.webinar_info?.paas_record_id!,this.webinar_info?.interact?.paas_access_token!,VHDefinition.AUDIO);
          break;
        case VHPlayDefinition.VH_FULL_HD:
          this.vodPlayer.startPlay(this.webinar_info?.paas_record_id!,this.webinar_info?.interact?.paas_access_token!,VHDefinition.FULL_HD);
          break;
      }
    }
  }

  /**
   * @description
   * 用于暖场视频播放，请区分使用暂停、恢复播放.
   * @param def 初始化播放的清晰度
   * */
  public startPlayWithRecordId(paas_record_id:string,def:VHPlayDefinition){
    if(this.vodPlayer){
      switch (def){
        case VHPlayDefinition.VH_ORIGIN:
          this.vodPlayer.startPlay(paas_record_id,this.webinar_info?.interact?.paas_access_token!,VHDefinition.ORIGIN);
          break;
        case VHPlayDefinition.VH_UHD:
          this.vodPlayer.startPlay(paas_record_id,this.webinar_info?.interact?.paas_access_token!,VHDefinition.UHD);
          break;
        case VHPlayDefinition.VH_HD:
          this.vodPlayer.startPlay(paas_record_id,this.webinar_info?.interact?.paas_access_token!,VHDefinition.HD);
          break;
        case VHPlayDefinition.VH_SD:
          this.vodPlayer.startPlay(paas_record_id,this.webinar_info?.interact?.paas_access_token!,VHDefinition.SD);
          break;
        case VHPlayDefinition.VH_AUDIO:
          this.vodPlayer.startPlay(paas_record_id,this.webinar_info?.interact?.paas_access_token!,VHDefinition.AUDIO);
          break;
        case VHPlayDefinition.VH_FULL_HD:
          this.vodPlayer.startPlay(paas_record_id,this.webinar_info?.interact?.paas_access_token!,VHDefinition.FULL_HD);
          break;
      }
    }
  }

  /**
   *@description
   * 停止播放。
   */
  public stopPlay(){
    this.vodPlayer?.stopPlay();
  }

  /**
   * @description
   * 暂停播放。
   */
  public pausePlay(){
    this.vodPlayer?.pausePlay();
  }

  /**
   * @description
   * 恢复播放。
   */
  public resumePlay(){
    this.vodPlayer?.resumePlay();
  }

  /**
   * @description
   * 切换清晰度。
   */
  public changeDefinition(def:VHPlayDefinition){
      this.vodPlayer?.changeDefinition(def.valueOf() as VHDefinition);
  }

  /**
   * @description
   * 设置当前播放器播放倍速能力。播放成功之后进行设置
   * */
  public setSpeed(speed:VHVodSupportSpeed){
    if(this.vodPlayer){
      this.vodPlayer.setPlayerSpeed(speed.valueOf() as VHVodPlayerSpeed);
    }
  }

  /**
   * @description 设置播放器视频画面填充模式。
   * @param mode:VHPlayerVideoScalingMode 图像拉伸，等比例缩放，平铺
   */
  public setPlayerScalingMode(mode:VHPlayerVideoScalingMode){
    this.scale_mode = mode;
    if(this.vodPlayer){
      this.vodPlayer.setPlayerScalingMode(mode.valueOf() as VHPlayerScalingMode);
    }
  }

  /**
   * @description  设置播放器播放位置
   *  @param currentTime:播放位置 (ms)
   * */
  public seek(currentTime:number){
    this.vodPlayer?.setPlayerSeek(currentTime);
  }

  /**
   * @description 开始投屏 初始化投屏后可以进行投屏操作
   * */
  public startCastingPlay(){
    this.vodPlayer?.StartCastPlay();
  }

  /**
   * @description 结束投屏 初始化投屏后可以进行投屏操作
   * */
  public stopCastingPlay(){
    this.vodPlayer?.StopCastPlay();
  }

  /**
   *  @description 设置投屏进度，成功监听回调。
   * @param duration: 播放进度，单位ms.
   * **/
  public seekCasting(seekTime: number) {
    this.vodPlayer?.SeekCastPlay(seekTime);
  }

  /**
   * @description
   * 开启画中画
   ***/
  public startPiP(){
    this.vodPlayer?.startPiP();
  }

  /**
   *  @description 更新画中画播放按键状态
   * @param status: VHPipControlPanelStatus
   ***/
  public updatePipControlStatus(status:VHPipControlPanelStatus){
    this.vodPlayer?.updatePipControlStatus(status.valueOf() as VHPlayerPipControlPanelStatus);
  }


  /**
   *  @description
   * 结束画中画
   ***/
  public stopPiP(){
    this.vodPlayer?.stopPip();
  }

  /**
   *  @description 设置播放音量.
   * @param vol：number 范围：0.01 ~ 1.0
   * @returns -1: 播放器未创建成功，-2 参数错误
   */
  public setPlayerVolume(vol:number): number{
    if(this.vodPlayer){
      return this.vodPlayer?.setPlayerVolume(vol);
    }
    return -1;
  }


  public getPlayer():object|null{
    if(this.vodPlayer){
      return this.vodPlayer;
    }
    return null;
  }

  /**
   * 播放器播放失败事件
   */
  onPlayerError(error: VHPlayerError) {
    let err:VHErrorInfo = {code:error.code,name:error.name,message:error.message};
    this.callback?.onPlayerError(err);
  }
  /**
   * 观看状态回调
   * @param player  播放器实例
   * @param state   状态类型 详见 VHPlayerStatus 的定义.
   */
  onStatusDidChange(state: VHPlayerStatus) {
    if(state == VHPlayerStatus.PREPARED){
      this.vodPlayer?.initPipController(this.autoStart,this.navId);
    }
    if(state == VHPlayerStatus.PLAYING){
      this.vodPlayer?.setPlayerScalingMode(this.scale_mode.valueOf() as VHPlayerScalingMode);
    }
    if(this.callback){
      this.callback.onStatusDidChange(state.valueOf() as VHPlayerState);
    }
  }
  /**
   * 画中画状态
   * @param state: 画中画播放状态
   */
  onPipStatusChange(state: VHPlayerPipStatus){
    this.callback?.onPipStatusChange(state.valueOf() as VHPlayerPipState);
  }
  /**
   * 画中画控制中心播放状态
   * @param state: VHPlayerPipControlPanelStatus
   */
  onPipControlPanelStatusChange(state: VHPlayerPipControlPanelStatus){
    this.callback?.onPipControlPanelStatusChange(state.valueOf() as VHPipControlPanelStatus);
  }
  /**
   * 播放器音量
   * @param volume :当前播放器音量值
   */
  onPlayerVolume(volume: number){
    this.callback?.onPlayerVolume(volume);
  }
  /**
   * 当前房间支持的清晰度列表
   * @param definitions   支持的清晰度列表
   */
  onValidDefinitions(definitions: VHDefinition[]){
    let def:VHPlayDefinition[]=[];
    definitions.forEach(element => {
      def.push(element.valueOf() as VHPlayDefinition);
    });
    this.callback?.onValidDefinitions(def);
  }
  /**
   * streamType 观看流类型
   * @param streamType   观看流类型   1:音频+视频 2:仅视频 3:仅音频
   */
  onStreamType(streamType: VHPlayStreamType){

  }
  /**
   * 视频流播放成功后，回调视频流的宽髙。用户可根据视频流实际宽高，调整播放容器大小。
   * @param width   视频帧宽度
   * @param height  视频帧高度
   */
  onVideoFrameSize(width: number, height: number){
    this.callback?.onVideoFrameSize(width,height);
  }
  /**
   * 投屏设备状体事件回调。
   * @param state. 0 设备已准备好可以播放。1：设备已断开
   */
  onCastPlayDeviceState(state: number){
    this.callback?.onCastPlayDeviceState(state);
  }
  /**
   * 已连接的投屏设备。
   * @param state. 0 设备已准备好可以播放。1：设备已断开
   */
  onCastPlayDeviceConnected(device: VHCastPlayDevice){
    this.callback?.onCastPlayDeviceConnected(device as VHCastPickerDevice);
  }
  /**
   * 投屏事件回调。
   * @param state:VHCastPlayState
   */
  onCastPlayState(state: VHCastPlayState){
    this.callback?.onCastPlayState(state as VHCastPickerState);
  }
  /**
   * 投屏播放时长。
   * @param duration:number  播放总时长 ，单位ms
   */
  onCastPlayDuration(duration: number){
    this.callback?.onCastPlayDuration(duration);
  }
  /**
   * 投屏播放当前位置。
   * @param position:number  播放当前进度 ，单位ms
   */
  onCastPlayPosition(position: number){
    this.callback?.onCastPlayPosition(position);
  }
  /**
   * 投屏操作失败。
   * @param state:VHCastPlayState。执行相关操作失败。包括开播、暂停、设置进度
   */
  onCastPlayError(state: VHCastPlayState){
    this.callback?.onCastPlayError(state as VHCastPickerState);
  }

  /**
   * 监听资源播放资源的时长，单位为毫秒（ms），用于刷新进度条长度
   * @param duration  回放时长，单位为毫秒（ms）。
   */
  onVodTotalDuration(duration: number){
    this.callback?.onVodTotalDuration(duration);
  }
  /**
   * 当前播放时长，单位为毫秒（ms），用于刷新进度条长度
   * @param currentDuration  当前播放时长，单位为毫秒（ms）。
   */
  onVodCurrentDuration(current: number){
    this.callback?.onVodCurrentDuration(current);
  }
  /**
   * 监听SeekTime，用于刷新进度条长度
   * @param duration  当前时长，单位为毫秒（ms）。
   */
  onVodSeekDuration(duration: number){
    this.callback?.onVodSeekDuration(duration);
  }
  /**
   * 监听setSpeed，表示切换倍速成功。
   * @param speed  当前倍速
   */
  onVodSpeedDone(speed: VHVodPlayerSpeed){
    this.callback?.onVodSpeedDone(speed.valueOf() as VHVodSupportSpeed);
  }

}