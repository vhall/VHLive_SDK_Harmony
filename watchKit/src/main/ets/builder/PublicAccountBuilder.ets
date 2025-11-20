import { VHCardInfo, VHCommonConfig, VHPushScreenCardMsg, VHSaaSDK, VHWebinarData } from "@vhall/vhall_live";
import { PromptActionClass } from "../util/PromptActionClass";


@Builder
export function createPublicAccountView(parm:VHCommonConfig){
  VHPublicAccountView({config:parm});
}

/**
 *
 */
@Component
export struct VHPublicAccountView {
  @Require config:VHCommonConfig;
  aboutToAppear(): void {

  }
  aboutToDisappear(): void {

  }

  build() {
    Column({space: 20}) {
      Text(this.config.public_account?.head_tip).fontSize(14)
      Image(this.config.public_account?.img)
        .width('200vp')
        .height('200vp')
        .borderRadius(6)
        .objectFit(ImageFit.Cover)
      Text(this.config.public_account?.bottom_tip).fontSize(10)

      Image($r('app.media.close')).height(12).width(12)
        .onClick(()=>{
          PromptActionClass.closeDialog();
        })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.White)
    .width('80%')
    .height('50%')
    .borderRadius(10)
  }
}