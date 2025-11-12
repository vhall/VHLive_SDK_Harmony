import {
  VHQaRecommendAnswerInfo,
  VHQaRecommendInfo,
  VHQaRecommendList,
  VHSaaSDK,
  VHWebinarData
} from '@vhall/vhall_live';
import { ToastUtil } from '../../action/ToastUtil';


/**
 * 推荐列表弹窗
 */
@CustomDialog
export struct QaRecommendDialog {
  controller: CustomDialogController
  @Require webinars: VHWebinarData;
  @State qaRecommendList: VHQaRecommendInfo[] = [];
  private scroller: Scroller = new Scroller();

  aboutToAppear() {
    this.getQaRecommendList();
  }

  getQaRecommendList() {
    VHSaaSDK.getInstance()
      .getQaRecommendList(this.webinars?.webinar!.id!.toString(), this.webinars?.interact?.room_id!, {
        onSuccess: (data: VHQaRecommendList) => {
          this.qaRecommendList = data?.list;
        },
        onFailure: (errorCode, errorMsg) => {
          console.log("获得问答推荐列表失败：", errorMsg)
          ToastUtil.showToast(`获得问答推荐列表失败： ${errorMsg}`);
        }
      });
  }

  formatTime(dateTime: string): string {
    let dateTimeStr = dateTime.substring(dateTime.indexOf("-") + 1);
    return dateTimeStr.substring(0, dateTimeStr.lastIndexOf(":"));
  }

  build() {
    Column() {
      Column({ space: 8 }) {
        // 顶部区域
        Stack({ alignContent: Alignment.End }) {
          Text('推荐列表')
            .width('100%')
            .textAlign(TextAlign.Center)
            .fontSize(16)
          // 自定义的关闭
          // Image($r('app.media.icon_close'))
          //   .width(15)
          //   .height(15)
          //   .margin(4)
          //   .fillColor(Color.Red)
          //   .onClick(() => {
          //     this.controller.close()
          //   })
        }
      }.width('100%').height(60).justifyContent(FlexAlign.Center)

      if (this.qaRecommendList.length > 0)
      Column() {
        List({ space: 4, scroller: this.scroller }) {
        ForEach(this.qaRecommendList, (detail: VHQaRecommendInfo, index) => {
          ListItem() {
            Column() {
              Row() {
                Text() {
                  Span('提问： ').fontColor(Color.Orange)
                  Span(detail.content).fontColor(Color.Black)
                }.fontSize(12)
              }.width('100%').padding(2)

              ForEach(detail.answer, (answer: VHQaRecommendAnswerInfo, index) => {
                ListItem() {
                  Column() {
                    Row() {
                      Text() {
                        Span('回复： ').fontColor(Color.Orange)
                        Span(answer.content).fontColor(Color.Black)
                      }.fontSize(12)
                    }.width('100%').padding(6)
                  }

                }
              })

              Text(this.formatTime(detail.created_at))
                .fontSize(12)
                .fontColor(Color.Gray)
                .padding({ top: 4 })
            }
            .width('90%')
            .padding(10)
            .margin(6)
            .backgroundColor(Color.White)
            .alignItems(HorizontalAlign.Start)

          }
        })
        }.width('100%').height('100%')
      .alignListItem(ListItemAlign.Center)

      }.width('100%')
      .height('300')
      .margin({left: 10, right: 10 } )

      if (this.qaRecommendList.length == 0)
      Column() {
        Image($r('app.media.icon_empty'))
      }
      .width(200)
      .height(300)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }.width('100%')
    .backgroundColor('#EEEEEE')
    .borderRadius({ topLeft: 10, topRight: 10 })
    .justifyContent(FlexAlign.Center)
  }
}