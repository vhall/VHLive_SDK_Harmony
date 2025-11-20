import {
  VHCardInfo, VHPushScreenCardMsg, VHSaaSDK, VHWebinarData
} from "@vhall/vhall_live";
import { PromptActionClass } from "../util/PromptActionClass";
import { ComponentContent } from "@kit.ArkUI";
import { createPushCardView, PushCardParams } from "./VHPushCardBuilder";
import { ToastUtil } from "../action/ToastUtil";

let Announcement_Room_id: string = ''

/*
 *推屏卡片弹窗
 * */
@CustomDialog
export struct VHCardDialog {
  controller: CustomDialogController
  @Consume CardList: VHCardInfo[]
  @State card: VHCardInfo = new VHCardInfo()
  private pushCardContentNode: ComponentContent<Object> | null = null;
  private webinar_info?: VHWebinarData;
  @State isClicking: boolean = false;

  //推屏卡片详细信息
  CardInformationHttp(webinarId: string, Id: string) {
    VHSaaSDK.getInstance().getCardInfo(webinarId, Id, {
      onSucceed: (data: VHCardInfo) => {
        this.card = data
        console.log('卡片信息', data)
      },
      onFailure: (errorCode: number, errorMsg: string) => {
        ToastUtil.showToast(errorMsg);
      }
    })
  }

  build() {
    Column() {
      // 顶部区域
      Stack({ alignContent: Alignment.TopEnd }) {
        Column() {
          Text('卡片列表')
            .width('100%')
            .textAlign(500)
            .fontSize(22)
            .textAlign(TextAlign.Center)
            .zIndex(2)
          Column()
            .width(45)
            .height(10)
            .backgroundColor('#fffcd4cf')
            .borderRadius(6)
        }
        .height(80)
        .justifyContent(FlexAlign.Center)
        .padding({ bottom: 15 })

        // 自定义的关闭
        Image($r('app.media.icon_close'))
          .width(16)
          .fillColor('#666')
          .onClick(() => {
            this.controller.close()
          })
      }
      .width('100%')
      .height(80)

      // 底部的列表
      List() {
        ForEach(this.CardList, (item: VHCardInfo, index) => {
          ListItem() {
            Row({ space: 6 }) {
              Column() {
                Text(item.title)
                  .fontSize(16)
                  .margin({ bottom: 15 })
                  .maxLines(2)  // 限制最大行数
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(item.created_at)
                  .fontSize(12)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text('查看')
                .fontSize(12)
                .fontColor('#ff0881d4')
                .onClick(() => {
                  if (this.isClicking) {
                    return;
                  }
                  this.isClicking = true;
                  if (this.CardList.length != 0) {
                    this.CardInformationHttp(item.webinar_id.toString(), item.id.toString())
                    // 跳转
                    setTimeout(() => {
                      const params = new PushCardParams(this.card, this.webinar_info!);
                      this.pushCardContentNode =
                        new ComponentContent(this.getUIContext(), wrapBuilder(createPushCardView), params);
                      PromptActionClass.setContext(this.getUIContext());
                      PromptActionClass.setContentNode(this.pushCardContentNode);
                      if (item.show_mode == 0) {
                        PromptActionClass.setOptions({
                          alignment: DialogAlignment.Center,
                          isModal: true,
                          maskRect: {
                            x: 0,
                            y: 0,
                            width: '100%',
                            height: '100%'
                          }
                        });
                      } else if (item.show_mode == 1) {
                        PromptActionClass.setOptions({
                          alignment: DialogAlignment.BottomEnd,
                          isModal: false,
                          offset: { dx: -10, dy: -170 },
                          maskRect: {
                            x: 0,
                            y: 0,
                            width: '100%',
                            height: '100%'
                          }
                        });
                      }
                      PromptActionClass.openDialog();
                      this.controller.close()
                    }, 500)
                  } else {
                    this.controller.close()
                  }

                })
              // Text('查看')
              //   .fontSize(12)
              //   .fontColor('#ff0881d4')
              //   .onClick(() => {
              //     if (this.isClicking) {
              //       return;
              //     }
              //     this.isClicking = true;
              //
              //     if (this.CardList.length == 0) {
              //       this.isClicking = false;
              //       this.controller.close();
              //       return;
              //     }
              //
              //     this.CardInformationHttp(item.webinar_id.toString(), item.id.toString());
              //
              //     setTimeout(() => {
              //       try {
              //         const params = new PushCardParams(this.card, this.webinar_info!);
              //         this.pushCardContentNode =
              //           new ComponentContent(this.getUIContext(), wrapBuilder(createPushCardView), params);
              //         PromptActionClass.setContext(this.getUIContext());
              //         PromptActionClass.setContentNode(this.pushCardContentNode);
              //
              //         if (item.show_mode == 0) {
              //           PromptActionClass.setOptions({ /* Center 配置 */ });
              //         } else if (item.show_mode == 1) {
              //           PromptActionClass.setOptions({ /* BottomEnd 配置 */ });
              //         }
              //
              //         PromptActionClass.openDialog();
              //         this.controller.close();
              //       } finally {
              //         this.isClicking = false; // 确保无论如何都会解锁
              //       }
              //     }, 1000);
              //   })
            }
            .padding(14)
            .backgroundColor(Color.White)
            .borderRadius(6)
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
        })
        ListItem() {
          Column() {
            Text('没有更多数据')
              .fontSize(14)
              .fontColor('#ffaeabab')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)

        }
      }
      .width('94%')
      .height(260)
      .divider({ strokeWidth: 10, color: Color.Transparent })
      .scrollBar(BarState.Off)
      .margin({ bottom: 15 })
    }
    .padding(15)
    .borderRadius({ topLeft: 10, topRight: 10 })
    .linearGradient({
      angle: 90,
      colors: [['#fffcf1f7', 0.1], ['#ffe7dbf8', 0.9]]
    })
  }
}