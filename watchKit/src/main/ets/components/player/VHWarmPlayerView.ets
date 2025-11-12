
import {VHErrorInfo, VHPlayerState ,VHPlayerPipState,VHWebinarData,VHPipControlPanelStatus,VHWatchVodPlayerView,VHWatchVodPlayer,
  VHPlayDefinition,VHCastPickerDevice,VHCastMediaSource,VHCastPickerState,VHVodSupportSpeed,VHPlayerConfig,VHPlayerVideoScalingMode} from "@vhall/vhall_live";
import {definitions} from '../../builder/DefinitionsPopup'
import { ComponentContent, display, promptAction, window } from "@kit.ArkUI";
import {VolumeSlider} from './VHPlayerVolume'
import { hilog } from "@kit.PerformanceAnalysisKit";
import { VHConstants } from "@vhall/vhall_live/src/main/ets/VHConstants";
import { ToastUtil } from "../../action/ToastUtil";

let touchStartX: number = 0;
let touchStartY: number = 0;
let changeWidth: number = 0;
let changeHeight: number = 0;

//播放器顺序
let PLAYER_INDEX = 'player'
let IMAGE_INDEX = 'image_index'
let PLAYER_MASK_INDEX = 'player_mask'
let LOADING_PROGRESS = 'loading_progress'
let CAST_MASK = 'cast_mask'
let PLAYER_CONTROLLER = 'player_controller'
let EXIT_CAST = 'exit_cast'
let MARQUEE = 'marquee'
let playerZIndex:Array<string> = [PLAYER_INDEX,IMAGE_INDEX,PLAYER_MASK_INDEX,MARQUEE,LOADING_PROGRESS,CAST_MASK,EXIT_CAST,PLAYER_CONTROLLER];


@Component
export struct VHWarmPlayerView {
  /**
   * 播放器控制类
   * */
  public vodPlayer?:VHWatchVodPlayer = new VHWatchVodPlayer(this.getUIContext().getHostContext() as Context);
  public webinars?:VHWebinarData;
  @State public player_config:VHPlayerConfig | null= null;
  @State is_expand:boolean=false;
  @State private expandTypes: SafeAreaType[] = [SafeAreaType.SYSTEM];
  @State private expandEdges: SafeAreaEdge[] = [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM];
  @State isCasting:boolean = false;//是否正在投屏
  @State is_playing:boolean = false;
  @State isPlayError:boolean = false;//是否播放成功，如果没有播放成功再次播放时就重新播放。
  @State isLoading:boolean = false;
  @State isPlayEnd:boolean = false;
  @State currentTime: number = 0; // 视频当前时间
  @State flagValue: number = 0; // 拖拽时时间
  @State totalDuration: number = 0; // 视频总时长
  @State is_start:boolean = false;//是否开始播放
  @State speed: string = '1.0x'; // 倍速大小
  @State speedSetting: VHVodSupportSpeed = VHVodSupportSpeed.VH_PLAYER_SPEED_1_00_X;
  @State playerVol:number = 100;//播放器音量
  @State isShowVol:boolean=false;
  @State definitions_list: VHPlayDefinition[] = [];
  @State playDefinition: string = '高清720p'; // 倍速大小
  @State playDefinitionList:Array<definitions> = [];
  @State isDefinition: boolean = false; // 是否显示清晰度
  @State isSpeedShow: boolean = false; // 是否倍速状态
  @State castPickDevice: string = ''; // 投屏设备
  private source: VHCastMediaSource |undefined = undefined;
  private screenHeight:number = 0;
  private contentNode: ComponentContent<Object> | null = null;
  private playRecords:string[] = [];
  private currentPlayId:string = '';
  private currentPlayIndex:number = 0;


  @State playerMaskWidth:number = 0;
  @State playerMaskHeight:number = 0;

  playerState:VHPlayerState = VHPlayerState.VH_PLAYER_RELEASE;
  aboutToAppear(): void {
    this.vodPlayer?.initWebinarInfo(this.webinars!);
    this.vodPlayer?.setVodPlayerListener(this);
    this.vodPlayer?.setPlayerScalingMode(VHPlayerVideoScalingMode.VH_ASPECT_FIT);
    this.screenHeight = display.getDefaultDisplaySync().height;  // 转换为虚拟像素单位
    if(this.webinars && this.webinars?.warm_up){
      this.getPlayId(true);
    }
  }

  aboutToDisappear(): void {
    this.vodPlayer?.destroyPlayer();
  }

  onPlayerViewInitCompleted(){
    if( this.currentPlayId.length > 0){
      this.vodPlayer?.startPlayWithRecordId(this.currentPlayId,this.player_config?.default_definition!);
      this.isPlayError = true;
    }
  }

  private initPlayRecords(){
    this.webinars?.warm_up?.warmup_paas_record_id.forEach((value:string,index:number,array:string[])=>{
      this.playRecords.push(value);
    })
  }

  private getPlayId(init:boolean):string{
    this.currentPlayId = ""
    if(this.playRecords.length > 0){
      this.currentPlayId = this.playRecords[0];
      this.playRecords.shift();
    }else if(this.playRecords.length == 0){
      if(init || this.webinars?.warm_up?.warmup_player_type == 2){
        this.initPlayRecords();
        if(this.playRecords.length > 0){
          this.currentPlayId = this.webinars?.warm_up?.warmup_paas_record_id[0]!;
        }
        this.playRecords.shift();
      }
    }
    return this.currentPlayId;
  }

  /**
   * 播放器播放失败事件
   */
  onPlayerError(error: VHErrorInfo) {
    if(error.code == VHConstants.VH_PLAY_CURRENT_DEF_FAILED){
      //没有可用的清晰度，重新进行播放。
      this.vodPlayer?.startPlayWithRecordId(this.currentPlayId,this.player_config?.default_definition!);
    }else if(error.code == VHConstants.VH_PLAY_STREAM_FAILED || error.code ==  VHConstants.VH_NETWORK_ERROR || error.code == VHConstants.VH_CAN_NOT_FIND_HOST){
      this.vodPlayer?.pausePlay();
      this.is_playing = false;
      this.isPlayError = true;
      ToastUtil.showToast( error.code + error.message);
    }

  }
  /**
   * 观看状态回调
   * @param player  播放器实例
   * @param state   状态类型 详见 VHPlayerStatus 的定义.
   */
  onStatusDidChange(state: VHPlayerState){
    if(state == VHPlayerState.VH_PLAYER_PLAYING){
      this.is_start = true;
      this.is_playing = true;
      this.isLoading = false;
      this.isPlayError = false;
    }else if(state == VHPlayerState.VH_PLAYER_PAUSE || state == VHPlayerState.VH_PLAYER_STOP || state == VHPlayerState.VH_PLAYER_RELEASE){
      this.is_playing = false;
    }
    if(state == VHPlayerState.VH_PLAYER_PREPARED){
      this.isLoading = true;
      if(this.isPlayError){
        //播放失败后重新播放监听VH_PLAYER_PREPARED事件，然后重置下播放进度
        this.vodPlayer?.seek(this.currentTime);
      }
    }else if(state == VHPlayerState.VH_PLAYER_BUFFERING_END){
      this.isLoading = false;
    }else if(state == VHPlayerState.VH_PLAYER_COMPLETE){
      this.getPlayId(false);
      if(this.currentPlayId.length > 0){
        this.vodPlayer?.startPlayWithRecordId(this.currentPlayId,this.player_config?.default_definition!);
      }else{
        this.isPlayEnd = true;
        this.is_start = false;
      }
    }
    this.playerState = state;
  }
  /**
   * 画中画状态
   * @param state: 画中画播放状态
   */
  onPipStatusChange(state: VHPlayerPipState){

  }

  /**
   * 画中画控制中心播放状态
   * @param state: VHPlayerPipControlPanelStatus
   */
  onPipControlPanelStatusChange(state: VHPipControlPanelStatus){
    if(state == VHPipControlPanelStatus.VH_CONTROL_PAUSE){
      this.vodPlayer?.pausePlay();
    }else{
      this.vodPlayer?.resumePlay();
    }
  }

  /**
   * 播放器音量
   * @param volume :当前播放器音量值
   */
  onPlayerVolume(volume: number){

  }


  /**
   * 当前房间支持的清晰度列表
   * @param definitions   支持的清晰度列表
   */
  onValidDefinitions(definitions: VHPlayDefinition[]){
    let hasDef:boolean = false;
    this.definitions_list = [];
    this.playDefinitionList = [];
    definitions.forEach((item)=>{
      this.definitions_list.push(item);
      if(this.player_config?.default_definition == item){
        hasDef = true;
      }
      this.resetPlayDef(item);
    })
    if(!hasDef && this.player_config && definitions.length > 0){
      definitions.forEach((item)=>{
        //如果没有默认清晰度，则重新选择一个清晰度
        if(item != VHPlayDefinition.VH_AUDIO && this.player_config){
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
  onVideoFrameSize(width: number, height: number){

  }
  /**
   * 投屏设备状体事件回调。
   * @param state. 0 设备已准备好可以播放。1：设备已断开
   */
  onCastPlayDeviceState(state: number){
    this.isCasting = state == 0? true :false;
  }
  /**
   * 已连接的投屏设备。
   * @param state. 0 设备已准备好可以播放。1：设备已断开
   */
  onCastPlayDeviceConnected(device: VHCastPickerDevice){
    this.castPickDevice = device.deviceName;
  }
  /**
   * 投屏事件回调。
   * @param state:VHCastPlayState
   */
  onCastPlayState(state: VHCastPickerState){
    if(state == VHCastPickerState.VH_CAST_PICKER_STATE_PLAY){
      this.is_start = true;
      this.is_playing = true;
    }else if(state == VHCastPickerState.VH_CAST_PICKER_STATE_PAUSE || state == VHCastPickerState.VH_CAST_PICKER_STATE_STOP){
      this.is_playing = false;
    }
  }
  /**
   * 投屏播放时长。
   * @param duration:number  播放总时长 ，单位ms
   */
  onCastPlayDuration(duration: number){
    this.totalDuration = duration;
  }
  /**
   * 投屏播放当前位置。
   * @param position:number  播放当前进度 ，单位ms
   */
  onCastPlayPosition(position: number){
    this.currentTime = position;
  }
  /**
   * 投屏操作失败。
   * @param state:VHCastPlayState。执行相关操作失败。包括开播、暂停、设置进度
   */
  onCastPlayError(state: VHCastPickerState){
  }

  /**
   * @description 监听资源播放资源的时长，单位为毫秒（ms），用于刷新进度条长度
   * @param duration  回放时长，单位为毫秒（ms）。
   */
  onVodTotalDuration(duration: number){
    this.totalDuration = duration;
  }
  /**
   * @description 当前播放时长，单位为毫秒（ms），用于刷新进度条长度
   * @param currentDuration  当前播放时长，单位为毫秒（ms）。
   */
  onVodCurrentDuration(current: number){
    this.currentTime = current;
  }
  /**
   * @description 监听SeekTime，用于刷新进度条长度
   * @param duration  当前时长，单位为毫秒（ms）。
   */
  onVodSeekDuration(duration: number){

  }
  /**
   * @description 监听倍速切换，表示切换倍速成功。
   * @param speed  当前倍速
   */
  onVodSpeedDone(speed: VHVodSupportSpeed) {

  }

  resetPlayDef(item:VHPlayDefinition){
    if(item == VHPlayDefinition.VH_ORIGIN){
      if(this.player_config?.default_definition == item){
        this.playDefinition = '原画';
      }
      this.playDefinitionList.push({text:'原画',value: VHPlayDefinition.VH_ORIGIN})
    }
    else if(item == VHPlayDefinition.VH_UHD){
      if(this.player_config?.default_definition == item){
        this.playDefinition = '高清720p';
      }
      this.playDefinitionList.push({text:'高清720p',value: VHPlayDefinition.VH_UHD})
    }
    else if(item == VHPlayDefinition.VH_HD){
      if(this.player_config?.default_definition == item){
        this.playDefinition = '标清480p';
      }
      this.playDefinitionList.push({text:'标清480p',value: VHPlayDefinition.VH_HD})
    }
    else if(item == VHPlayDefinition.VH_SD){
      if(this.player_config?.default_definition == item){
        this.playDefinition = '流畅360p';
      }
      this.playDefinitionList.push({text:'流畅360p',value: VHPlayDefinition.VH_SD})
    }
    else if(item == VHPlayDefinition.VH_AUDIO && this.player_config?.basic?.record_audio == 1){
      if(this.player_config?.default_definition == item){
        this.playDefinition = '纯音频';
      }
      this.playDefinitionList.push({text:'纯音频',value: VHPlayDefinition.VH_AUDIO})
    }
    else if(item == VHPlayDefinition.VH_FULL_HD){
      if(this.player_config?.default_definition == item){
        this.playDefinition = '超清1080p';
      }
      this.playDefinitionList.push({text:'超清1080p',value: VHPlayDefinition.VH_FULL_HD})
    }
  }

  @Builder
  castPickBuilder() {
    Image($r('app.media.cast_picker'))
      .width(30)
      .height(30)
  }

  build() {
    Stack({ alignContent: Alignment.Center }){
      // 播放器容器
      VHWatchVodPlayerView({ componentListener: this, vodPlayer: this.vodPlayer,is_expand:this.is_expand,enable_default_water_mask:true,water:this.player_config?.water})
        .width('100%')
        .height('100%')
        .expandSafeArea(this.is_expand ? this.expandTypes : [], this.is_expand ? this.expandEdges : [])
        .backgroundColor(Color.Black)
        .align(Alignment.Center)
        .zIndex(playerZIndex.indexOf(PLAYER_INDEX))


      if(this.webinars?.warm_up?.warmup_img_url.length! > 0 && !this.is_start){
        Image(this.webinars?.warm_up?.warmup_img_url)
          .width('100%')
          .height('100%')
          .zIndex(playerZIndex.indexOf(IMAGE_INDEX))
      }else if(!this.is_start){
        Image(this.webinars?.webinar?.img_url)
          .width('100%')
          .height('100%')
          .zIndex(playerZIndex.indexOf(IMAGE_INDEX))
      }


      if(this.isLoading){
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


      if(this.isPlayEnd){
        Image($r("app.media.video_screen_direction_switching_icon_pause"))
          .width(60)
          .height(60)
          .zIndex(10)
          .onClick(()=>{
            this.getPlayId(true);
            if(this.currentPlayId.length > 0){
              this.vodPlayer?.startPlayWithRecordId(this.currentPlayId,this.player_config?.default_definition!);
            }
            this.isPlayEnd = false;
          })
      }


      Flex({
        direction: FlexDirection.Column,
        justifyContent:FlexAlign.SpaceBetween
      }) {
        Row({space:20}){
        }
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .padding({top:4,right:10})
        .justifyContent(FlexAlign.End)


        Row(){
          if(this.isShowVol){
            VolumeSlider({progress:this.playerVol});
          }
        }.justifyContent(FlexAlign.Center)
        .width('100%')

        Row(){
          if(this.is_start){
            // 播放icon
            Image(this.is_playing ? $r("app.media.video_screen_direction_switching_icon_play") :
            $r("app.media.video_screen_direction_switching_icon_pause"))
              .width(24)
              .height(24)
              .margin({
                top: 0,
                bottom: 0,
                left: 8,
                right:8
              })
              .onClick(() => {
                if(this.isPlayError){
                  this.vodPlayer?.startPlay(this.player_config?.default_definition!);
                }
                else{
                  if(this.is_playing){
                    this.vodPlayer?.pausePlay();
                    this.vodPlayer?.updatePipControlStatus(VHPipControlPanelStatus.VH_CONTROL_PAUSE);
                  }else{
                    this.vodPlayer?.resumePlay();
                    this.vodPlayer?.updatePipControlStatus(VHPipControlPanelStatus.VH_CONTROL_PLAY);
                  }
                }

              })
          }
        }
      }
      .width('100%')
      .height('100%')
      .zIndex(playerZIndex.indexOf(PLAYER_CONTROLLER) )
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
                  let seekTime = (this.flagValue + this.totalDuration * (event.offsetX / 3) / 100) > this.totalDuration ?
                  this.totalDuration : (this.flagValue + this.totalDuration * (event.offsetX / 3) / 100);
                  if(seekTime > 0){
                    if(this.isCasting){
                      this.currentTime = seekTime;
                      this.vodPlayer?.seekCasting(this.currentTime);
                    }else{
                      this.currentTime = seekTime;
                      this.vodPlayer?.seek(seekTime);
                    }

                  }
                }
              }
            })
            .onActionEnd((event: GestureEvent | undefined) => {}),
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
                  let v = this.playerVol - (event.offsetY)/3/10;
                  let newVol = this.playerVol + percent;
                  // 严格限制在0-100范围内
                  newVol = Math.max(0, Math.min(100, v));
                  this.playerVol = newVol;
                  this.isShowVol = true;
                  this.vodPlayer?.setPlayerVolume(newVol/100);
                }
                touchStartY = touchY;
              }
            })
            .onActionEnd((event: GestureEvent | undefined) => {
              this.isShowVol = false;
            }),
        )
      )
    }.width('100%')
    .height('100%')
    .onAreaChange((oldValue: Area, newValue: Area) => {
      changeWidth = newValue.width as number;
      changeHeight = newValue.height as number;
    })
    .backgroundColor(Color.Black)
    .expandSafeArea(this.is_expand ? this.expandTypes : [], this.is_expand ? this.expandEdges : [])
  }
}
