import { VHWatermarkConfig, VHWebinarData } from '@vhall/vhall_live';
import { WaterPostion } from '../../util/WaterPostion';
import { VHTextWaterMark } from './VHTextWaterMark';

@Component
export struct VHPlayerWaterMark {
  /**
   * @description 水印
   * **/
  @Require water: VHWatermarkConfig | null = null;
  @Require webinars: VHWebinarData | null = null;
  @State private playerMaskWidth: number = 0;
  @State private playerMaskHeight: number = 0;
  private DEFAULT_BIG_MASK: number = 100;
  private DEFAULT_MID_MASK: number = 80;
  private DEFAULT_SMALL_MASK: number = 60;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Row() {
        //是否开启了图片水印
        if (this.water?.watermark_open) {
          Image(this.water?.img_url)
            .width(this.playerMaskWidth)
            .height(this.playerMaskHeight)
            .objectFit(ImageFit.Contain)
            .padding(WaterPostion.getPadding(this.water?.img_position!))
            .opacity(this.water?.img_alpha! * 0.01)
            .onComplete((event) => {
              this.playerMaskWidth = event?.width as number; //newValue.width as number;
              this.playerMaskHeight = event?.height as number; // newValue.height as number;
              let ratio = this.playerMaskWidth / this.playerMaskHeight;
              if (this.water?.img_size == 1) {
                this.playerMaskWidth = this.DEFAULT_BIG_MASK;
                this.playerMaskHeight = this.playerMaskWidth / ratio;
              } else if (this.water?.img_size == 2) {
                this.playerMaskWidth = this.DEFAULT_MID_MASK;
                this.playerMaskHeight = this.playerMaskWidth / ratio;
              } else if (this.water?.img_size == 3) {
                this.playerMaskWidth = this.DEFAULT_SMALL_MASK;
                this.playerMaskHeight = this.playerMaskWidth / ratio;
              }
            })
            .onError((error) => {
              console.error('图片加载失败', error);
            });
        } else if (this.water?.text_watermark_open) { //使用文本水印
          VHTextWaterMark({ waterWebinar: this.webinars, waterMarkProperties: this.water })
            .width("100%")
            .height("100%")
        }
      }
      .width("100%")
      .height("100%")
      .alignItems(WaterPostion.GetWaterPosTopOrBottom(this.water?.img_position!))
      .justifyContent(WaterPostion.GetWaterPosLeftOrRight(this.water?.img_position!))
      .zIndex(1)
    }
  }
}

