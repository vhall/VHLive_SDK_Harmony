import { VHCardInfo, VHPushScreenCardMsg, VHSaaSDK, VHWebinarData } from "@vhall/vhall_live";
import { PromptActionClass } from "../util/PromptActionClass";
import { common, Want } from "@kit.AbilityKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { bundleManager } from "@kit.MDMKit";
import { WebViewPageBuilder, WebViewParams } from "../pages/WebViewPage";
import { ComponentContent } from "@kit.ArkUI";
import { ToastUtil } from "../action/ToastUtil";

// 自定义参数类型
export class PushCardParams {
  card: VHCardInfo;
  webinar: VHWebinarData;

  constructor(card: VHCardInfo, webinar: VHWebinarData) {
    this.card = card;
    this.webinar = webinar;
  }
}

@Builder
export function createPushCardView(parm: PushCardParams) {
  VHPushCardView({ card: parm.card, webinar_info: parm.webinar });
}

/**
 * 常用设置底部弹窗视图
 */
@Component
export struct VHPushCardView {
  @Require @State card: VHCardInfo;
  @Require webinar_info: VHWebinarData;
  @State imgWidth: number = 200;
  @State imagHeight: number = 200;
  @State timeClose: string = ''
  @State timeCount: number = 0;
  @State url: string = ""
  private timeId: number = 0;
  private contentNode: ComponentContent<Object> | null = null;

  aboutToAppear(): void {
    if (this.card.show_mode == 0) {
      if (this.card.img_rate == 0) {
        this.imgWidth = 165;
        this.imagHeight = 220;
      } else if (this.card.img_rate == 1) {
        this.imgWidth = 220;
        this.imagHeight = 165;
      }
      if (this.card.img_rate == 2) {
        this.imgWidth = 165;
        this.imagHeight = 165;
      }
    } else if (this.card.show_mode == 1) {
      this.imgWidth = 118;
      this.imagHeight = 153;
    }

    if (this.card.timer_enable == 1) {
      this.timeClose = this.card.timer_interval.toString() + "s 后关闭";
      this.timeCount = this.card.timer_interval;
      this.timeId = setInterval(() => {
        this.timeCount--;
        this.timeClose = this.timeCount.toString() + "s 后关闭";
        if (this.timeCount <= 0) {
          PromptActionClass.closeDialog();
          clearInterval(this.timeId);
        }
      }, 1000);
    }
  }

  aboutToDisappear(): void {
    if (this.timeId != 0) {
      clearInterval(this.timeId);
    }
  }

  startBrowsableAbility(context: common.UIAbilityContext, uri: string): void {
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: uri,
      parameters: {
        'ohos.ability.params.showDefaultPicker': true
      }
    };
    context.startAbility(want)
      .then(() => {
        console.error('Start browsableAbility successfully.');
      })
      .catch((err: BusinessError) => {
        console.error(`Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
      });
  }

  build() {
    Column({ space: 10 }) {
      if (this.card.timer_enable == 1) {
        if (this.card.show_mode == 0) {
          Text(this.timeClose)
            .padding(6)
            .fontSize(10)
            .fontColor(Color.White)
            .borderRadius(10)
            .backgroundColor("#AA000000")
            .alignSelf(ItemAlign.End) // 覆盖父容器对齐方式
            .margin({ right: 100 }) // 右侧留白
            .onClick(() => {
              PromptActionClass.closeDialog();
              clearInterval(this.timeId);
            })
        } else {
          Text(this.timeClose)
            .padding(6)
            .fontSize(10)
            .fontColor(Color.White)
            .borderRadius(10)
            .backgroundColor("#AA000000")
            .alignSelf(ItemAlign.End) // 覆盖父容器对齐方式
            .margin({ right: 40 }) // 右侧留白
            .onClick(() => {
              PromptActionClass.closeDialog();
              clearInterval(this.timeId);
            })
        }

      }

      Image(this.card?.img_url)
        .width(this.imgWidth)
        .height(this.imagHeight)
        .borderRadius(10)
        .objectFit(ImageFit.Cover)
      // .onClick(() => {
      //   if (this.card.href_enable == 1) {
      //     let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      //     let wantInfo: Want = {
      //       "action": 'ohos.want.action.viewData',
      //       "entities": ['entity.system.browsable'],
      //       "uri": this.card.href,
      //     }
      //     context.startAbility(wantInfo).then(() => {
      //       // ...
      //     }).catch((err: BusinessError) => {
      //       // ...
      //     })
      //
      //     VHSaaSDK.getInstance()
      //       .cardClicked(this.webinar_info.webinar?.id.toString()!,
      //         this.webinar_info.switch_info?.switch_id.toString()!, this.card.id.toString(), {
      //           // 成功
      //           onSuccess: (data: string | object) => {
      //           },
      //           // 失败
      //           onFailure: (errorCode: number, errorMsg: string) => {
      //             ToastUtil.showToast(errorMsg);
      //           }
      //         });
      //   }
      // })

      if (this.card.show_mode == 0) {
        Text(this.card?.remark)
          .fontColor(Color.White)
          .width(this.imgWidth)
          .textAlign(TextAlign.Center)
          .maxLines(1)  // 限制最大行数
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }

      if (this.card?.href_enable == 1) {
        if (this.card.show_mode == 0) {
          Button(this.card?.href_btn_label)
            .height(30)
            .borderRadius(15)
            .backgroundColor(Color.Red)
            .onClick(() => {
              PromptActionClass.closeDialog();
              clearInterval(this.timeId);
              const context: common.UIAbilityContext = this.getUIContext().getHostContext()! as common.UIAbilityContext;
              this.startBrowsableAbility(context, this.card.href);
            })
        } else {
          Button(this.card?.href_btn_label)
            .height(30)
            .width(this.imgWidth)
            .backgroundColor(Color.Red)
            .onClick(() => {
              PromptActionClass.closeDialog();
              clearInterval(this.timeId);
              const context: common.UIAbilityContext = this.getUIContext().getHostContext()! as common.UIAbilityContext;
              this.startBrowsableAbility(context, this.card.href);
            })
        }
      }


      if (this.card.show_mode == 0) {
        Image($r('app.media.close_gray'))
          .width(24)
          .height(24)
          .onClick(() => {
            PromptActionClass.closeDialog();
            clearInterval(this.timeId);
          })
      } else {
        if (this.card.timer_enable == 0) {
          Image($r('app.media.close_gray'))
            .width(24)
            .height(24)
            .offset({ x: (this.imgWidth / 2 - this.imgWidth * 0.1), y: -(this.imagHeight + this.imagHeight * 0.2) })
            .onClick(() => {
              PromptActionClass.closeDialog();
              clearInterval(this.timeId);
            })
        }

      }
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width(this.card.show_mode == 0 ? '100%' : 120)
    .height(this.card.show_mode == 0 ? '100%' : 200)
    .onDisAppear(() => {
      clearInterval(this.timeId);
    })
  }
}