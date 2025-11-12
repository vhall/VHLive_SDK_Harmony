import {VHLivePlayerView, VHLivePlayer} from '@vhall/vhallyun-lss-vod'
import { VHWatermarkConfig } from '../model/VHWatchWebinarInfo';
import {VHWatchLivePlayer} from '../player/VHWatchLivePlayer'
import { VHWatchLivePlayerCallback } from '../player/VHWatchLivePlayerInterface';

@Component
export struct VHWatchLivePlayerView {
  /**
   * 组件状态更新回调
   */
  @Require public componentListener?: VHWatchLivePlayerCallback;
  /**
   * 播放器控制类
   * */
  @Require public livePlayer?:VHWatchLivePlayer;
  /**
   * 控制是否扩展
   */
  @Prop  public is_expand: boolean = false;
  @State private expandTypes: SafeAreaType[] = [SafeAreaType.SYSTEM];
  @State private expandEdges: SafeAreaEdge[] = [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM];
  /**
   * @description enable_default_water_mask 是否使用默认水印
   * **/
  @Require enableDefaultWaterMask:boolean = false;
  /**
   * @description 水印
   * **/
  @Require water: VHWatermarkConfig | null = null;
  @State private playerMaskWidth:number = 0;
  @State private playerMaskHeight:number = 0;
  private DEFAULT_BIG_MASK:number = 100;
  private DEFAULT_MID_MASK:number  = 80;
  private DEFAULT_SMALL_MASK:number  = 60;
  /**
   * 组件加载成功
   */
  onVHPlayerViewLoaded() {
    if(this.componentListener){
      this.componentListener.onPlayerViewInitCompleted();
    }
  }
  /**
   * 监听水印图片加载成功回调
   * @param width   组件宽
   */
  onVHWaterMaskLoadedSucceed() {


  }
  /**
   * 监听水印图片加载失败回调
   * @param error 失败原因
   */
  onVHWaterMaskLoadedError(error: string) {


  }


  build() {
    Stack({ alignContent: Alignment.Center }){
      Row(){
        // 播放器容器
        VHLivePlayerView({ componentListener: this, isExpand:this.is_expand, livePlayer: this.livePlayer?.getPlayer() as VHLivePlayer})
          .width('100%')
          .height('100%')
          .backgroundColor(Color.Black)
          .expandSafeArea(this.is_expand ? this.expandTypes : [], this.is_expand ? this.expandEdges : [])
      }
      .expandSafeArea(this.is_expand ? this.expandTypes : [], this.is_expand ? this.expandEdges : [])
      .width('100%')
      .height('100%')
      .zIndex(0)

    }
  }
}

