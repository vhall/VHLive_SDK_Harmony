import {
  VHErrorInfo,
  VHPlayerState,
  VHPlayerPipState,
  VHWebinarData,
  VHPipControlPanelStatus,
  VHWatchLivePlayerView,
  VHWatchLivePlayer,
  VHPlayDefinition,
  VHCastPickerDevice,
  VHCastMediaSource,
  VHCastPickerState,
  VHPlayerConfig,
  VHPlayerVideoScalingMode,
  VHSaaSDK,
  VHConfigList
} from "@vhall/vhall_live";
import { BarrageItem, BarrageView, BarrageController } from '@esky/barrage';
import { definitions, definitionsPopup } from '../../builder/DefinitionsPopup'
import { ComponentContent, display, promptAction, window } from "@kit.ArkUI";
import { AVCastPicker } from "@kit.AVSessionKit";
import { PromptActionClass } from '../../util/PromptActionClass'
import { createPlayerSettingView } from '../../builder/PlayerSettingBuilder'
import { VolumeSlider } from './VHPlayerVolume'
import { hilog } from "@kit.PerformanceAnalysisKit";
import { popItemValueObj } from '../../builder/SpeedPopup'
import { VHMarqueeViews } from "./VHMarqueeView";
import { VHBarrageViews } from "./VHBarrageView";
import { VHWatchInfo } from "../watch/VHWatchInfo";
import { VHPlayerWaterMark } from "./VHPlayerWaterMark";
import { VHConstants } from "@vhall/vhall_live/src/main/ets/VHConstants";
import { ToastUtil } from "../../action/ToastUtil";


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
let BARRAGE_VIEW = 'BarrageView'
let VOICE_PLAY = 'voice_play'
let playerZIndex: Array<string> =
  [PLAYER_INDEX, PLAYER_MASK_INDEX,VOICE_PLAY, BARRAGE_VIEW, MARQUEE, LOADING_PROGRESS, CAST_MASK, EXIT_CAST, PLAYER_CONTROLLER];
let BIG_MASK = 150;
let MID_MASK = 130;
let SMALL_MASK = 110;

let AlignRus: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
  'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
  'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
}

@Component
export struct VHWatchLivePlayerComponent {
  @State message: string = 'Hello World';
  /**
   * 播放器控制类
   * */
  public livePlayer?: VHWatchLivePlayer = new VHWatchLivePlayer(this.getUIContext().getHostContext() as Context);
  @State public webinars: VHWebinarData | null = null;
  @Link openSettingBtn: boolean;
  @State public playerConfig: VHPlayerConfig | null = null;
  @State is_expand: boolean = false;
  @State private expandTypes: SafeAreaType[] = [SafeAreaType.SYSTEM];
  @State private expandEdges: SafeAreaEdge[] = [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM];
  @State isCasting: boolean = false; //是否正在投屏
  @State is_playing: boolean = false;
  @State isPlayError: boolean = false; //是否播放成功，如果没有播放成功再次播放时就重新播放。
  @State isLoading: boolean = false;
  @State flagValue: number = 0; // 拖拽时时间
  @State is_start: boolean = true; //是否开始播放
  @State playerVol: number = 100; //播放器音量
  @State isShowVol: boolean = false;
  @State definitions_list: VHPlayDefinition[] = [];
  @State playDefinition: string = '高清720p'; // 倍速大小
  @State currentPlayDefinition: VHPlayDefinition = VHPlayDefinition.VH_ORIGIN; //
  @State playDefinitionList: Array<definitions> = [];
  @Link isLandscapeStart: boolean; //全屏
  @State isDefinition: boolean = false; // 是否显示清晰度
  @State castPickDevice: string = ''; // 投屏设备
  private source: VHCastMediaSource | undefined = undefined;
  private screenHeight: number = 0;
  private contentNode: ComponentContent<Object> | null = null;
  private barrageController: BarrageController = new BarrageController;
  @State playerMaskWidth: number = 0;
  @State playerMaskHeight: number = 0;
  @State configList: VHConfigList = new VHConfigList;
  playerState: VHPlayerState = VHPlayerState.VH_PLAYER_RELEASE;
  @State isStartPip:boolean = false;

  @Prop @Watch('onHideState') hideState: number = 0;
  aboutToAppear(): void {
    this.livePlayer?.initWebinarInfo(this.webinars!);
    if (this.playerConfig?.basic?.picture_in_picture == 1) {
      this.livePlayer?.initPipController(false);
    }
    this.livePlayer?.setLivePlayerListener(this);
    this.livePlayer?.setPlayerScalingMode(VHPlayerVideoScalingMode.VH_ASPECT_FIT);
    this.screenHeight = display.getDefaultDisplaySync().height; // 转换为虚拟像素单位
    this.contentNode =
      new ComponentContent(this.getUIContext(), wrapBuilder(createPlayerSettingView), this.playerConfig!);
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
    this.livePlayer?.initCastPlay(this.source);

    VHSaaSDK.getInstance()
      .getConfigList("3", this.webinars?.webinar?.id.toString()!,
        this.webinars?.webinar?.userinfo.user_id.toString()!, {
          onSucceed: (data: VHConfigList) => {
            this.configList = data;
          },
          onFailure: (errorCode: number, errorMsg: string) => {

          }
        });
  }

  aboutToDisappear(): void {
    this.barrageController.pause();
    this.barrageController.clearInScreen();
    this.livePlayer?.destroyPlayer();
  }

  onPlayerViewInitCompleted() {
    this.livePlayer?.startPlay(this.playerConfig?.default_definition!);
    this.currentPlayDefinition = this.playerConfig?.default_definition! as VHPlayDefinition;
    this.isPlayError = true;
  }

  onHideState(propName: string): void {
    if(this.hideState == 1){
      //隐藏
      if(this.playerState == VHPlayerState.VH_PLAYER_PLAYING){
        this.livePlayer?.pausePlay();
      }
    }else{
      //显示
      if(this.playerState == VHPlayerState.VH_PLAYER_PAUSE){
        this.livePlayer?.resumePlay();
      }
    }
  }

  /**
   * 播放器播放失败事件
   */
  onPlayerError(error: VHErrorInfo) {
    if (error.code == VHConstants.VH_PLAY_CURRENT_DEF_FAILED) {
      //没有可用的清晰度，重新进行播放。
      this.livePlayer?.startPlay(this.playerConfig?.default_definition!);
    } else if (error.code == VHConstants.VH_PLAY_STREAM_FAILED || error.code == VHConstants.PLAY_FORMAT_ERROR ||
      error.code == VHConstants.VH_NETWORK_ERROR || error.code == VHConstants.VH_CAN_NOT_FIND_HOST ||
      error.code == VHConstants.VH_PLAY_TIMEOUT) {
      this.livePlayer?.pausePlay();
      this.is_playing = false;
      this.isPlayError = true; //监听到播放异常时，为了点击播放按键时使用startPlay重新进行拉流
    }
    ToastUtil.showToast(error.code.toString() + error.message);
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
      this.livePlayer?.pausePlay();
    } else {
      this.livePlayer?.resumePlay();
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
      if (this.playerConfig?.default_definition == item) {
        hasDef = true;
      }
      this.resetPlayDef(item);
    })
    if (!hasDef && this.playerConfig && definitions.length > 0) {
      definitions.forEach((item) => {
        //如果没有默认清晰度，则重新选择一个清晰度
        if (item != VHPlayDefinition.VH_AUDIO && this.playerConfig) {
          this.resetPlayDef(item);
          this.playerConfig.default_definition = item as VHPlayDefinition;
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

  }

  /**
   * 投屏播放当前位置。
   * @param position:number  播放当前进度 ，单位ms
   */
  onCastPlayPosition(position: number) {

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

  resetPlayDef(item: VHPlayDefinition) {
    if (item == VHPlayDefinition.VH_ORIGIN) {
      if (this.playerConfig?.default_definition == item) {
        this.playDefinition = '原画';
      }
      this.playDefinitionList.push({ text: '原画', value: VHPlayDefinition.VH_ORIGIN })
    } else if (item == VHPlayDefinition.VH_UHD) {
      if (this.playerConfig?.default_definition == item) {
        this.playDefinition = '高清720p';
      }
      this.playDefinitionList.push({ text: '高清720p', value: VHPlayDefinition.VH_UHD })
    } else if (item == VHPlayDefinition.VH_HD) {
      if (this.playerConfig?.default_definition == item) {
        this.playDefinition = '标清480p';
      }
      this.playDefinitionList.push({ text: '标清480p', value: VHPlayDefinition.VH_HD })
    } else if (item == VHPlayDefinition.VH_SD) {
      if (this.playerConfig?.default_definition == item) {
        this.playDefinition = '流畅360p';
      }
      this.playDefinitionList.push({ text: '流畅360p', value: VHPlayDefinition.VH_SD })
    } else if (item == VHPlayDefinition.VH_AUDIO && this.playerConfig?.basic?.record_audio == 1) {
      if (this.playerConfig?.default_definition == item) {
        this.playDefinition = '纯音频';
      }
      this.playDefinitionList.push({ text: '纯音频', value: VHPlayDefinition.VH_AUDIO })
    } else if (item == VHPlayDefinition.VH_FULL_HD) {
      if (this.playerConfig?.default_definition == item) {
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
      VHWatchLivePlayerView({
        componentListener: this,
        livePlayer: this.livePlayer,
        is_expand: this.is_expand,
        enableDefaultWaterMask: true,
        water: this.playerConfig?.water!
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

      if (this.playerConfig?.water?.watermark_open || this.playerConfig?.water?.text_watermark_open) {
        VHPlayerWaterMark({ water: this.playerConfig?.water, webinars: this.webinars })
          .width('100%')
          .height('100%')
          .zIndex(playerZIndex.indexOf(PLAYER_MASK_INDEX))
      }

      if(this.currentPlayDefinition == VHPlayDefinition.VH_AUDIO){
        Image($r('app.media.voice_play'))
          .width('100%')
          .height('100%')
          .zIndex(playerZIndex.indexOf(VOICE_PLAY))
      }

      //跑马灯
      if (this.playerConfig?.marquee?.scrolling_open) {
        VHMarqueeViews({ playerConfig: this.playerConfig, webinarInfo: this.webinars! })
          .width('100%')
          .height('100%')
          .zIndex(playerZIndex.indexOf(MARQUEE))
      }
      //弹幕
      if (this.playerConfig?.basic?.barrage_button == 1) {
        VHBarrageViews()
          .width('100%')
          .height('100%')
          .zIndex(playerZIndex.indexOf(BARRAGE_VIEW))
      }

      if (this.isLoading) {
        Column() {
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
          //画中画
          if (this.is_start && !this.isCasting) {
            if (this.playerConfig?.basic?.picture_in_picture == 1) {
              Image($r("app.media.pip"))
                .onClick(() => {
                  if(this.isStartPip){
                    this.livePlayer?.stopPiP();
                  }else{
                    this.livePlayer?.startPiP();
                  }
                })
                .width(26)
                .height(26)
            }
            //投屏
            AVCastPicker({
              customPicker: (): void => this.castPickBuilder(),
              normalColor: Color.Black
            })
              .width(30)
              .height(30)

            //设置
            Image($r("app.media.setting"))
              .onClick(() => {
                this.openSettingBtn = !this.openSettingBtn;
                PromptActionClass.setContext(this.getUIContext());
                PromptActionClass.setContentNode(this.contentNode!);
                PromptActionClass.setOptions({ alignment: DialogAlignment.BottomEnd, offset: { dx: 0, dy: 50 } });
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


        //播放音量
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
                this.livePlayer?.stopCastingPlay();
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
                  this.livePlayer?.startPlay(this.playerConfig?.default_definition!);
                } else {
                  if (this.is_playing) {
                    this.livePlayer?.pausePlay();
                    this.livePlayer?.updatePipControlStatus(VHPipControlPanelStatus.VH_CONTROL_PAUSE);
                  } else {
                    this.livePlayer?.resumePlay();
                    this.livePlayer?.updatePipControlStatus(VHPipControlPanelStatus.VH_CONTROL_PLAY);
                  }
                }
              })
          }
          Blank()
          Row({ space: 10 }) {
            if (this.is_start) {
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
                        this.isLoading = true;
                        this.livePlayer?.changeDefinition(item.value as VHPlayDefinition)
                        this.isPlayError = true;
                        this.currentPlayDefinition = item.value as VHPlayDefinition;
                      }
                      this.playDefinition = item.text;
                      this.isDefinition = false;
                    }
                  }, this.playDefinitionList),
                  placement: Placement.TopLeft,
                  popupColor: "rgba(0,0,0,0.6)",
                  backgroundBlurStyle: BlurStyle.NONE
                })

              //全屏
              if (this.playerConfig?.basic?.show_full_screen_entry == 1) {
                Image($r("app.media.full"))
                  .onClick(() => {
                    this.isLandscapeStart = !this.isLandscapeStart;
                    this.isLandscapeStart ? this.is_expand = true : this.is_expand = false;
                  })
                  .width(16)
                  .height(16)
              }
            }
          }
          .padding({ bottom: 4, right: 10 })
          .alignItems(VerticalAlign.Top)
        }
        .width('100%')
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

            })
            .onActionUpdate((event?: GestureEvent) => {

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

                } else {
                  let v = this.playerVol - (event.offsetY) / 3 / 10;
                  let newVol = this.playerVol + percent;
                  // 严格限制在0-100范围内
                  newVol = Math.max(0, Math.min(100, v));
                  this.playerVol = newVol;
                  this.isShowVol = true;
                  this.livePlayer?.setPlayerVolume(newVol / 100);
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
