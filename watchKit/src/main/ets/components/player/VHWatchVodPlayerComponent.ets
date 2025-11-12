import {
  VHErrorInfo,
  VHPlayerState,
  VHPlayerPipState,
  VHWebinarData,
  VHPipControlPanelStatus,
  VHWatchVodPlayerView,
  VHWatchVodPlayer,
  VHPlayDefinition,
  VHCastPickerDevice,
  VHCastMediaSource,
  VHCastPickerState,
  VHVodSupportSpeed,
  VHPlayerConfig,
  VHPlayerVideoScalingMode,
  VHSaaSDK,
  VHConfigList
} from "@vhall/vhall_live";
import { faceDetector } from "@kit.CoreVisionKit";

import { getTimeString } from '../../util/TimeTools';
import { popItemValueObj, SpeedPopup } from '../../builder/SpeedPopup'
import { definitions, definitionsPopup } from '../../builder/DefinitionsPopup'

import { ComponentContent, display, promptAction, window } from "@kit.ArkUI";
import { AVCastPicker } from "@kit.AVSessionKit";
import { PromptActionClass } from '../../util/PromptActionClass'
import { createPlayerSettingView } from '../../builder/PlayerSettingBuilder'
import { VolumeSlider } from './VHPlayerVolume'
import { hilog } from "@kit.PerformanceAnalysisKit";
import { VHMarqueeViews } from "./VHMarqueeView";
import { VHPlayerWaterMark } from "./VHPlayerWaterMark";
import { EmitterMsgData, EmitterUtil } from "../../util/EmitterUtil";
import MsgType from "../../constants/MsgType";
import { VHAISummaryView } from "./VHAISummaryView";
import { VHAISubtitleView } from "./VHSubtitles";
import { VHConstants } from "@vhall/vhall_live/src/main/ets/VHConstants";
import { ToastUtil } from "../../action/ToastUtil";
import { VHWatchInfo } from "../watch/VHWatchInfo";


let touchStartX: number = 0;
let touchStartY: number = 0;
let changeWidth: number = 0;
let changeHeight: number = 0;

//播放器顺序
let PLAYER_INDEX = 'player'
let PLAYER_MASK_INDEX = 'player_mask'
let LOADING_PROGRESS = 'loading_progress'
let CAST_MASK = 'cast_mask'
let PLAYER_CONTROLLER = 'player_controller'
let EXIT_CAST = 'exit_cast'
let MARQUEE = 'marquee'
let SUBTITLES = 'subtitles'
let VOICE_PLAY = 'voice_play'
let playerZIndex: Array<string> =
  [PLAYER_INDEX, PLAYER_MASK_INDEX,VOICE_PLAY, MARQUEE, SUBTITLES, LOADING_PROGRESS, CAST_MASK, EXIT_CAST, PLAYER_CONTROLLER];


let AlignRus: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
  'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
  'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
}
@Component
export struct VHWatchVodPlayerComponent {
  @State message: string = 'Hello World';
  /**
   * 播放器控制类
   * */
  public vodPlayer?: VHWatchVodPlayer = new VHWatchVodPlayer(this.getUIContext().getHostContext() as Context);
  @State public webinars: VHWebinarData | null = null;
  @Link openSettingBtn: boolean;
  @State public player_config: VHPlayerConfig | null = null;
  @State is_expand: boolean = false;
  @State private expandTypes: SafeAreaType[] = [SafeAreaType.SYSTEM];
  @State private expandEdges: SafeAreaEdge[] = [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM];
  @State isCasting: boolean = false; //是否正在投屏
  @State is_playing: boolean = false;
  @State isPlayError: boolean = false; //是否播放成功，如果没有播放成功再次播放时就重新播放。
  @State isLoading: boolean = false;
  @State currentTime: number = 0; // 视频当前时间
  @State flagValue: number = 0; // 拖拽时时间
  @State totalDuration: number = 0; // 视频总时长
  @State is_start: boolean = true; //是否开始播放
  @State speed: string = '1.0x'; // 倍速大小
  @State speedSetting: VHVodSupportSpeed = VHVodSupportSpeed.VH_PLAYER_SPEED_1_00_X;
  @State playerVol: number = 100; //播放器音量
  @State isShowVol: boolean = false;
  @State definitions_list: VHPlayDefinition[] = [];
  @State playDefinition: string = '高清720p'; // 倍速大小
  @State playDefinitionList: Array<definitions> = [];
  @Link isLandscapeStart: boolean; //全屏
  @State isDefinition: boolean = false; // 是否显示清晰度
  @State isSpeedShow: boolean = false; // 是否倍速状态
  @State castPickDevice: string = ''; // 投屏设备
  private source: VHCastMediaSource | undefined = undefined;
  @State currentPlayDefinition: VHPlayDefinition = VHPlayDefinition.VH_ORIGIN; //
  private screenHeight: number = 0;
  private contentNode: ComponentContent<Object> | null = null;
  @State configList: VHConfigList = new VHConfigList;
  private subtitleTimer: number = 0;
  @State playerMaskWidth: number = 0;
  @State playerMaskHeight: number = 0;
  playerState: VHPlayerState = VHPlayerState.VH_PLAYER_RELEASE;
  @State isStartPip:boolean = false;
  aboutToAppear(): void {
    this.vodPlayer?.initWebinarInfo(this.webinars!);
    if (this.player_config?.basic?.picture_in_picture == 1) {
      this.vodPlayer?.initPipController(false);
    }
    this.vodPlayer?.setVodPlayerListener(this);
    this.vodPlayer?.setPlayerScalingMode(VHPlayerVideoScalingMode.VH_ASPECT_FIT);

    this.screenHeight = display.getDefaultDisplaySync().height; // 转换为虚拟像素单位
    this.contentNode =
      new ComponentContent(this.getUIContext(), wrapBuilder(createPlayerSettingView), this.player_config!);
    PromptActionClass.setContext(this.getUIContext());
    PromptActionClass.setContentNode(this.contentNode);
    PromptActionClass.setOptions({ alignment: DialogAlignment.BottomEnd, offset: { dx: 0, dy: 50 } });
    this.source = {
      title: this.webinars?.webinar?.subject!,
      name: '微吼SaaS',
      description: this.webinars?.webinar?.subject!,
      headImage: "https://cnstatic01.e.vhall.com/upload/user/avatar/57/72/577252bda8f072ef8e4dc680123c1651.jpg"
    };
    //初始化投屏后，会创建媒体会话绑定播控服务。如果不使用投屏功能不要进行初始化。
    this.vodPlayer?.initCastPlay(this.source);

    // 接收删除问答消息
    EmitterUtil.subscribe(MsgType.VOD_MOMENT_TIME, (msgData: EmitterMsgData) => {
      let seek = msgData.data as number;
      this.vodPlayer?.seek(seek);
    });

    VHSaaSDK.getInstance()
      .permissionsCheck("3", this.webinars?.webinar?.id.toString()!,
        this.webinars?.webinar?.userinfo.user_id.toString()!, {
          onSucceed: (data: VHConfigList) => {
            this.configList = data;
          },
          onFailure: (errorCode: number, errorMsg: string) => {
            ToastUtil.showToast("permissionsCheck:" + errorMsg);
          }
        });
  }

  aboutToDisappear(): void {
    if (this.subtitleTimer != 0) {
      clearInterval(this.subtitleTimer);
      this.subtitleTimer = 0;
    }
    this.vodPlayer?.destroyPlayer();
  }

  onPageShow(): void {
    if(this.playerState == VHPlayerState.VH_PLAYER_PAUSE){
      this.vodPlayer?.resumePlay();
    }
  }

  onPageHide(): void {
    if(this.playerState == VHPlayerState.VH_PLAYER_PLAYING){
      this.vodPlayer?.pausePlay();
    }
  }

  onPlayerViewInitCompleted() {
    if(this.webinars?.record?.preview_paas_record_id != undefined && this.webinars?.record?.preview_paas_record_id.length > 0){
      this.vodPlayer?.startPlayWithRecordId(this.webinars?.record?.preview_paas_record_id,this.player_config?.default_definition!);
    }else{
      this.vodPlayer?.startPlay(this.player_config?.default_definition!);
    }
    this.currentPlayDefinition = this.player_config?.default_definition! as VHPlayDefinition;
    this.isPlayError = true;
  }

  /**
   * 播放器播放失败事件
   */
  onPlayerError(error: VHErrorInfo) {
    if (error.code == VHConstants.VH_PLAY_CURRENT_DEF_FAILED) {
      //没有可用的清晰度，重新进行播放。
      if(this.webinars?.record?.preview_paas_record_id != undefined && this.webinars?.record?.preview_paas_record_id.length > 0){
        this.vodPlayer?.startPlayWithRecordId(this.webinars?.record?.preview_paas_record_id,this.player_config?.default_definition!);
      }else{
        this.vodPlayer?.startPlay(this.player_config?.default_definition!);
      }
    } else if (error.code == VHConstants.VH_PLAY_STREAM_FAILED || error.code == VHConstants.VH_NETWORK_ERROR ||
      error.code == VHConstants.VH_CAN_NOT_FIND_HOST) {
      this.vodPlayer?.pausePlay();
      this.is_playing = false;
      this.isPlayError = true;
    }
    this.getUIContext().getPromptAction().showToast({
      message: error.code + error.message,
      duration: 4000,
      showMode: promptAction.ToastShowMode.DEFAULT,
      bottom: 80
    });
  }

  /**
   * 观看状态回调
   * @param player  播放器实例
   * @param state   状态类型 详见 VHPlayerStatus 的定义.
   */
  onStatusDidChange(state: VHPlayerState) {
    if (state == VHPlayerState.VH_PLAYER_PLAYING) {
      this.is_start = true;
      this.is_playing = true;
      this.isLoading = false;
      this.isPlayError = false;
    } else if (state == VHPlayerState.VH_PLAYER_PAUSE || state == VHPlayerState.VH_PLAYER_STOP ||
      state == VHPlayerState.VH_PLAYER_RELEASE) {
      this.is_playing = false;
    }
    if (state == VHPlayerState.VH_PLAYER_PREPARED) {
      this.isLoading = true;
      if (this.isPlayError) {
        //播放失败后重新播放监听VH_PLAYER_PREPARED事件，然后重置下播放进度
        this.vodPlayer?.seek(this.currentTime);
      }
    } else if (state == VHPlayerState.VH_PLAYER_BUFFERING_END) {
      this.isLoading = false;
    }
    this.playerState = state;
  }

  /**
   * 画中画状态
   * @param state: 画中画播放状态
   */
  onPipStatusChange(state: VHPlayerPipState) {
    if(state == VHPlayerPipState.VH_PIP_START){
      this.isStartPip = true;
    }else if(state == VHPlayerPipState.VH_PIP_STOP){
      this.isStartPip = false;
    }
  }

  /**
   * 画中画控制中心播放状态
   * @param state: VHPlayerPipControlPanelStatus
   */
  onPipControlPanelStatusChange(state: VHPipControlPanelStatus) {
    if (state == VHPipControlPanelStatus.VH_CONTROL_PAUSE) {
      this.vodPlayer?.pausePlay();
    } else {
      this.vodPlayer?.resumePlay();
    }
  }

  /**
   * 播放器音量
   * @param volume :当前播放器音量值
   */
  onPlayerVolume(volume: number) {

  }

  /**
   * 当前房间支持的清晰度列表
   * @param definitions   支持的清晰度列表
   */
  onValidDefinitions(definitions: VHPlayDefinition[]) {
    let hasDef: boolean = false;
    this.definitions_list = [];
    this.playDefinitionList = [];
    definitions.forEach((item) => {
      //是否隐藏原画
      if (item == VHPlayDefinition.VH_ORIGIN && this.configList.live_hidden_same == 1) {
        return;
      }
      this.definitions_list.push(item);
      if (this.player_config?.default_definition == item) {
        hasDef = true;
      }
      this.resetPlayDef(item);
    })
    if (!hasDef && this.player_config && definitions.length > 0) {
      definitions.forEach((item) => {
        //如果没有默认清晰度，则重新选择一个清晰度
        if (item != VHPlayDefinition.VH_AUDIO && this.player_config) {
          this.resetPlayDef(item);
          this.player_config.default_definition = item as VHPlayDefinition;
          return;
        }
      })
    }
  }

  /**
   * 视频流播放成功后，回调视频流的宽髙。用户可根据视频流实际宽高，调整播放容器大小。
   * @param width   视频帧宽度
   * @param height  视频帧高度
   */
  onVideoFrameSize(width: number, height: number) {

  }

  /**
   * 投屏设备状体事件回调。
   * @param state. 0 设备已准备好可以播放。1：设备已断开
   */
  onCastPlayDeviceState(state: number) {
    this.isCasting = state == 0 ? true : false;
  }

  /**
   * 已连接的投屏设备。
   * @param state. 0 设备已准备好可以播放。1：设备已断开
   */
  onCastPlayDeviceConnected(device: VHCastPickerDevice) {
    this.castPickDevice = device.deviceName;
  }

  /**
   * 投屏事件回调。
   * @param state:VHCastPlayState
   */
  onCastPlayState(state: VHCastPickerState) {
    if (state == VHCastPickerState.VH_CAST_PICKER_STATE_PLAY) {
      this.is_start = true;
      this.is_playing = true;
    } else if (state == VHCastPickerState.VH_CAST_PICKER_STATE_PAUSE ||
      state == VHCastPickerState.VH_CAST_PICKER_STATE_STOP) {
      this.is_playing = false;
    }
  }

  /**
   * 投屏播放时长。
   * @param duration:number  播放总时长 ，单位ms
   */
  onCastPlayDuration(duration: number) {
    this.totalDuration = duration;
  }

  /**
   * 投屏播放当前位置。
   * @param position:number  播放当前进度 ，单位ms
   */
  onCastPlayPosition(position: number) {
    this.currentTime = position;
  }

  /**
   * 投屏操作失败。
   * @param state:VHCastPlayState。执行相关操作失败。包括开播、暂停、设置进度
   */
  onCastPlayError(state: VHCastPickerState) {
    this.getUIContext().getPromptAction().showToast({
      message: '投屏异常' + state.toString(),
      duration: 4000,
      showMode: promptAction.ToastShowMode.DEFAULT,
      bottom: 80
    });
  }

  /**
   * @description 监听资源播放资源的时长，单位为毫秒（ms），用于刷新进度条长度
   * @param duration  回放时长，单位为毫秒（ms）。
   */
  onVodTotalDuration(duration: number) {
    this.totalDuration = duration;

    if(this.webinars?.record?.preview_paas_record_id != undefined && this.webinars?.record?.preview_paas_record_id.length > 0){
      let s = duration / 1000; // 秒
      let m = 0; // 分
      if (s > 59) {
        m = Math.floor(s / 60);
      }

      ToastUtil.showToast("可以试看" + m.toString() + "分钟");
    }
  }

  /**
   * @description 当前播放时长，单位为毫秒（ms），用于刷新进度条长度
   * @param currentDuration  当前播放时长，单位为毫秒（ms）。
   */
  onVodCurrentDuration(current: number) {
    this.currentTime = current;
    //定时每秒同步播放进度。用于同步显示实时字幕
    if (this.subtitleTimer == 0) {
      this.subtitleTimer = setInterval(() => {
        let msgData: EmitterMsgData;
        msgData = {
          type: MsgType.VOD_SUBTITLE_TIME,
          data: this.currentTime
        } as EmitterMsgData;
        EmitterUtil.send(msgData);
      }, 500)
    }
  }

  /**
   * @description 监听SeekTime，用于刷新进度条长度
   * @param duration  当前时长，单位为毫秒（ms）。
   */
  onVodSeekDuration(duration: number) {

  }

  /**
   * @description 监听倍速切换，表示切换倍速成功。
   * @param speed  当前倍速
   */
  onVodSpeedDone(speed: VHVodSupportSpeed) {

  }

  resetPlayDef(item: VHPlayDefinition) {
    if (item == VHPlayDefinition.VH_ORIGIN) {
      if (this.player_config?.default_definition == item) {
        this.playDefinition = '原画';
      }
      this.playDefinitionList.push({ text: '原画', value: VHPlayDefinition.VH_ORIGIN })
    } else if (item == VHPlayDefinition.VH_UHD) {
      if (this.player_config?.default_definition == item) {
        this.playDefinition = '高清720p';
      }
      this.playDefinitionList.push({ text: '高清720p', value: VHPlayDefinition.VH_UHD })
    } else if (item == VHPlayDefinition.VH_HD) {
      if (this.player_config?.default_definition == item) {
        this.playDefinition = '标清480p';
      }
      this.playDefinitionList.push({ text: '标清480p', value: VHPlayDefinition.VH_HD })
    } else if (item == VHPlayDefinition.VH_SD) {
      if (this.player_config?.default_definition == item) {
        this.playDefinition = '流畅360p';
      }
      this.playDefinitionList.push({ text: '流畅360p', value: VHPlayDefinition.VH_SD })
    } else if (item == VHPlayDefinition.VH_AUDIO && this.player_config?.basic?.record_audio == 1) {
      if (this.player_config?.default_definition == item) {
        this.playDefinition = '纯音频';
      }
      this.playDefinitionList.push({ text: '纯音频', value: VHPlayDefinition.VH_AUDIO })
    } else if (item == VHPlayDefinition.VH_FULL_HD) {
      if (this.player_config?.default_definition == item) {
        this.playDefinition = '超清1080p';
      }
      this.playDefinitionList.push({ text: '超清1080p', value: VHPlayDefinition.VH_FULL_HD })
    }
  }

  @Builder
  castPickBuilder() {
    Image($r('app.media.cast_picker'))
      .width(30)
      .height(30)
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 播放器容器
      VHWatchVodPlayerView({
        componentListener: this,
        vodPlayer: this.vodPlayer,
        is_expand: this.is_expand,
        enable_default_water_mask: true,
        water: this.player_config?.water
      })
        .width('100%')
        .height('100%')
        .expandSafeArea(this.is_expand ? this.expandTypes : [], this.is_expand ? this.expandEdges : [])
        .backgroundColor(Color.Black)
        .align(Alignment.Center)
        .zIndex(playerZIndex.indexOf(PLAYER_INDEX))

      RelativeContainer() {
        VHWatchInfo({ webinarInfo: this.webinars! }).alignRules(AlignRus).padding(10);
      }

      if (this.player_config?.water?.watermark_open || this.player_config?.water?.text_watermark_open) {
        VHPlayerWaterMark({ water: this.player_config?.water, webinars: this.webinars })
          .width('100%')
          .height('100%')
          .zIndex(playerZIndex.indexOf(PLAYER_MASK_INDEX))
      }

      if (this.player_config?.marquee?.scrolling_open) {
        VHMarqueeViews({ playerConfig: this.player_config, webinarInfo: this.webinars! })
          .width('100%')
          .height('100%')
          .zIndex(playerZIndex.indexOf(MARQUEE))
      }

      VHAISubtitleView({ webinar_info: this.webinars! })
        .width('100%')
        .height('100%')
        .zIndex(playerZIndex.indexOf(SUBTITLES))

      if (this.isLoading) {
        Column() {
          // TODO: 知识点：创建加载进展组件，除支持通用属性外，还支持设置加载进度条前景色和设置动画显示或者不显示。
          LoadingProgress()
            .color(Color.White)
            .width(80)
            .height(80)
          Text('努力加载中')
            .fontSize(16)
            .fontColor(Color.White)
        }
        .justifyContent(FlexAlign.Center)
        .zIndex(playerZIndex.indexOf(LOADING_PROGRESS))
        .width('100%')
      }

      if(this.currentPlayDefinition == VHPlayDefinition.VH_AUDIO){
        Image($r('app.media.voice_play'))
          .width('100%')
          .height('100%')
          .zIndex(playerZIndex.indexOf(VOICE_PLAY))
      }

      //投屏时用于遮挡播VHWatchVodPlayerView放器容器
      if (this.isCasting) {
        Column() {
        }
        .zIndex(this.isCasting ? playerZIndex.indexOf(CAST_MASK) : 0)
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Black)
      }

      Flex({
        direction: FlexDirection.Column,
        justifyContent: FlexAlign.SpaceBetween
      }) {
        Row({ space: 20 }) {
          if (this.is_start && !this.isCasting) {
            if (this.player_config?.basic?.picture_in_picture == 1) {
              Image($r("app.media.pip"))
                .onClick(() => {

                  if(this.isStartPip){
                    this.vodPlayer?.stopPiP();
                  }else{
                    this.vodPlayer?.startPiP();
                  }

                })
                .width(26)
                .height(26)
            }

            AVCastPicker({
              customPicker: (): void => this.castPickBuilder(),
              normalColor: Color.Black
            })
              .width(30)
              .height(30)

            Image($r("app.media.setting"))
              .onClick(() => {
                this.openSettingBtn = !this.openSettingBtn;
                PromptActionClass.openDialog();
              })
              .width(26)
              .height(26)
          }
        }
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .padding({ top: 4, right: 10 })
        .justifyContent(FlexAlign.End)


        Row() {
          if (this.isShowVol) {
            VolumeSlider({ progress: this.playerVol });
          }
        }.justifyContent(FlexAlign.Center)
        .width('100%')


        //显示投屏退出页面
        if (this.isCasting) {
          Column({ space: 20 }) {
            Button("停止投屏")
              .fontColor(Color.White)
              .backgroundColor('#333333')
              .onClick(() => {
                this.vodPlayer?.stopCastingPlay();
                this.isCasting = false;
              })
              .margin({
                left: '12vp',
                right: '12vp'
              })
              .borderWidth(1)
              .borderColor(Color.White)
              .borderRadius(10)

            Text(this.castPickDevice)
              .fontColor(Color.White)
          }
          .zIndex(this.isCasting ? playerZIndex.indexOf(EXIT_CAST) : 0)
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height('100%')
          .backgroundColor(Color.Black)
        }

        Column() {
          Row() {
            if (this.is_start) {
              // 播放icon
              Image(this.is_playing ? $r("app.media.video_screen_direction_switching_icon_play") :
              $r("app.media.video_screen_direction_switching_icon_pause"))
                .width(24)
                .height(24)
                .margin({
                  top: 0,
                  bottom: 0,
                  left: 8,
                  right: 8
                })
                .onClick(() => {
                  if (this.isPlayError) {
                    if(this.webinars?.record?.preview_paas_record_id != undefined && this.webinars?.record?.preview_paas_record_id.length > 0){
                      this.vodPlayer?.startPlayWithRecordId(this.webinars?.record?.preview_paas_record_id,this.player_config?.default_definition!);
                    }else{
                      this.vodPlayer?.startPlay(this.player_config?.default_definition!);
                    }
                  } else {
                    if (this.is_playing) {
                      this.vodPlayer?.pausePlay();
                      this.vodPlayer?.updatePipControlStatus(VHPipControlPanelStatus.VH_CONTROL_PAUSE);
                    } else {
                      this.vodPlayer?.resumePlay();
                      this.vodPlayer?.updatePipControlStatus(VHPipControlPanelStatus.VH_CONTROL_PLAY);
                    }
                  }

                })
              if (this.player_config?.basic?.progress_bar == 1) {
                // 时间轴
                Row() {
                  Text(getTimeString(this.currentTime))
                    .fontSize(14)
                    .fontColor(0xFFFFFF)
                    .fontWeight(500)
                    .opacity(0.6)
                  Slider({
                    value: Math.round(this.currentTime / this.totalDuration * 100)
                  })
                    .selectedColor(Color.White)
                    .layoutWeight(1)
                    .trackColor(Color.Gray)
                    .onChange((value: number, mode: SliderChangeMode) => {
                      if (this.is_start) {
                        this.currentTime = this.totalDuration * value / 100;
                        if (this.isCasting) {
                          this.vodPlayer?.seekCasting(this.currentTime);
                        } else {
                          this.vodPlayer?.seek(this.currentTime);
                        }
                      }
                    })
                  Text(getTimeString(this.totalDuration))
                    .fontSize(14)
                    .fontColor(0xFFFFFF)
                    .fontWeight(500)
                    .opacity(0.6)
                }
                .layoutWeight(1)
                .height(25)
                .hitTestBehavior(HitTestMode.Transparent)
              }
            }
          }

          Row({ space: 10 }) {
            if (this.is_start) {
              // 倍速icon
              if (this.player_config?.basic?.speed == 1) {
                Text(this.speed)
                  .fontColor(Color.White)
                  .fontSize(14)
                  .onClick(() => {
                    this.isSpeedShow = !this.isSpeedShow;
                  })
                  .borderWidth(1)
                  .borderColor(Color.White)
                  .borderRadius(8)
                  .padding({ left: 4, right: 4 })
                  .bindPopup(this.isSpeedShow, {
                    builder: SpeedPopup({
                      onItemSelected: (item: popItemValueObj) => {
                        if (this.is_start) {
                          this.vodPlayer?.setSpeed(item.value as VHVodSupportSpeed)
                          this.speedSetting = item.value as VHVodSupportSpeed;
                        }
                        this.speed = item.text;
                        this.isSpeedShow = false;
                      }
                    }),
                    placement: Placement.TopLeft,
                    popupColor: "rgba(0,0,0,0.6)",
                    backgroundBlurStyle: BlurStyle.NONE
                  })
              }

              // 清晰度
              Text(this.playDefinition)
                .fontColor(Color.White)
                .fontSize(14)
                .onClick(() => {
                  this.isDefinition = !this.isDefinition;
                })
                .borderWidth(1)
                .borderColor(Color.White)
                .borderRadius(8)
                .padding({ left: 4, right: 4 })
                .bindPopup(this.isDefinition, {
                  builder: definitionsPopup({
                    onItemSelected: (item: popItemValueObj) => {
                      if (this.is_start) {
                        this.vodPlayer?.changeDefinition(item.value as VHPlayDefinition)
                        this.currentPlayDefinition = item.value as VHPlayDefinition;
                        this.isPlayError = true;
                      }
                      this.playDefinition = item.text;
                      this.isDefinition = false;
                    }
                  }, this.playDefinitionList),
                  placement: Placement.TopLeft,
                  popupColor: "rgba(0,0,0,0.6)",
                  backgroundBlurStyle: BlurStyle.NONE
                })

              if (this.player_config?.basic?.show_full_screen_entry == 1) {
                Image($r("app.media.full"))
                  .onClick(() => {
                    this.isLandscapeStart = !this.isLandscapeStart;
                    this.isLandscapeStart ? this.is_expand = true : this.is_expand = false;
                  })
                  .width(16)
                  .height(16)
              }
            }
          }.justifyContent(FlexAlign.End)
          .width('100%')
          .padding({ bottom: 4, right: 10 })
          .alignItems(VerticalAlign.Top)

        }.justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height('100%')
      .zIndex(playerZIndex.indexOf(PLAYER_CONTROLLER))
      .responseRegion( // 设置多个触摸热区
        [
          {
            x: 0,
            y: 0,
            width: '100%',
            height: '100%'
          }
        ]
      )
      .gesture(
        GestureGroup(GestureMode.Parallel,
          PanGesture(new PanGestureOptions({ direction: PanDirection.Left | PanDirection.Right }))
            .onActionStart(() => {
              this.flagValue = this.currentTime;
            })
            .onActionUpdate((event?: GestureEvent) => {
              if (event) {
                if (this.is_start) {
                  let seekTime =
                    (this.flagValue + this.totalDuration * (event.offsetX / 3) / 100) > this.totalDuration ?
                    this.totalDuration : (this.flagValue + this.totalDuration * (event.offsetX / 3) / 100);
                  if (seekTime > 0) {
                    if (this.isCasting) {
                      this.currentTime = seekTime;
                      this.vodPlayer?.seekCasting(this.currentTime);
                    } else {
                      this.currentTime = seekTime;
                      this.vodPlayer?.seek(seekTime);
                    }

                  }
                }
              }
            })
            .onActionEnd((event: GestureEvent | undefined) => {
            }),
          PanGesture(new PanGestureOptions({ direction: PanDirection.Vertical }))
            .onActionStart((event: GestureEvent | undefined) => {
              if (event && event.fingerList && event.fingerList[0]) {
                touchStartX = event.fingerList[0].localX;
                touchStartY = event.fingerList[0].localY;
              }
            })
            .onActionUpdate((event: GestureEvent | undefined) => {
              if (event && event.fingerList && event.fingerList[0]) {
                const touchY = event.fingerList[0].localY;
                const deltaY = touchY - touchStartY;
                hilog.debug(123321, 'onActionUpdate', 'touchY: %{public}f, deltaY: %{public}f', touchY, deltaY);

                // 移动距离占播放器高度的比例(deltaY取反是因为值的正负与滑动方向相反)
                const percent = (-deltaY / changeHeight);
                const width = changeWidth as number;
                if (touchStartX <= (width / 2)) {
                  // this.showBrightnessUi = true;
                  // let brightness = this.currentBrightness;
                  // brightness += Constants.MAX_BRIGHTNESS * percent;
                  // if (brightness < 0) {
                  //   brightness = 0;
                  // }
                  // if (brightness > Constants.MAX_BRIGHTNESS) {
                  //   brightness = Constants.MAX_BRIGHTNESS;
                  // }
                  // const finalValue = brightness / Constants.MAX_BRIGHTNESS;
                  // if (this.windowClass) {
                  //   this.windowClass.setWindowBrightness(finalValue);
                  // }
                  // this.currentBrightness = brightness;
                } else {
                  let v = this.playerVol - (event.offsetY) / 3 / 10;
                  let newVol = this.playerVol + percent;
                  // 严格限制在0-100范围内
                  newVol = Math.max(0, Math.min(100, v));
                  this.playerVol = newVol;
                  this.isShowVol = true;
                  this.vodPlayer?.setPlayerVolume(newVol / 100);
                }
                touchStartY = touchY;
              }
            })
            .onActionEnd((event: GestureEvent | undefined) => {
              this.isShowVol = false;
            }),
        )
      )
    }
    .width('100%')
    .height('100%')
    .onAreaChange((oldValue: Area, newValue: Area) => {
      changeWidth = newValue.width as number;
      changeHeight = newValue.height as number;
    })
    .backgroundColor(Color.Black)
    .expandSafeArea(this.is_expand ? this.expandTypes : [], this.is_expand ? this.expandEdges : [])
  }
}
