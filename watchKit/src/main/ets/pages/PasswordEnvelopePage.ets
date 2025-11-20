import {
  VHPushScreenCardMsg,
  VHPwdRedEnvelopeData,
  VHRedEnvelopeInfo,
  VHRedEnvelopeUserListInfo,
  VHSaaSDK,
  VHWebinarData,
  VHWinningUserListInfo
} from "@vhall/vhall_live";
import { pasteboard } from "@kit.BasicServicesKit";
import { ToastUtil } from "../action/ToastUtil";

@CustomDialog
export struct VHPasswordEnvelopePage {
  controller: CustomDialogController
  @State Overall: boolean = true
  @State CoverEnvelope: boolean = true
  @State OpenEnvelope: boolean = false
  @State WinningList: boolean = false
  @Link RedEnvelope: VHRedEnvelopeInfo | null
  @State RedEnvelopeUserList: VHWinningUserListInfo[] = []
  @Link RedEnvelopeData: VHPwdRedEnvelopeData | null
  RichEditorController: RichEditorController = new RichEditorController();

  aboutToAppear(): void {
    this.Envelope()
  }

  //获取口令中奖者接口
  Envelope() {
    VHSaaSDK.getInstance().getRedEnvelopeUserList(this.RedEnvelopeData?.room_id!, this.RedEnvelopeData?.red_packet_uuid!, {
        onSuccess: (data: VHRedEnvelopeUserListInfo) => {
          this.RedEnvelopeUserList = data.list as VHWinningUserListInfo[]
          console.log("查看口令红包中奖成功", data)
        },
        onFailure: (errorCode: number, errorMsg: string) => {
          console.log("查看口令红包中奖失败", errorCode, errorMsg)
          ToastUtil.showToast("查看口令红包中奖失败:" + errorMsg);
        }
      });
  }

  //复制口令到剪切板
  LongPressTextCustomMenu() {
    let pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.RedEnvelope?.red_code);
    // 获取系统剪贴板对象
    let systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setData(pasteboardData); // 将数据放入剪贴板
    systemPasteboard.getData().then((data) => { // 读取剪贴板内容
      if (data) {
        this.getUIContext().getPromptAction().showToast({ message: '复制成功' });
      } else {
        this.getUIContext().getPromptAction().showToast({ message: '复制失败' });
      }
    })
  }

  formatTime(dateTime: string): string {
    return dateTime.substring(dateTime.lastIndexOf(" "));
  }

  build() {
    Column() {
      if (this.CoverEnvelope) {
        Stack() {
          Image($r('app.media.icon_RedEnvelope'))
            .width('100%')
            .height('100%')
            .borderRadius(20)
            .syncLoad(true)
          Text('开')
            .fontSize(40)
            .fontColor('#ffcb1617')
            .padding(10)
            .position({ x: '38%', y: '26%' })
            .onClick(() => {
              this.OpenEnvelope = true
              this.CoverEnvelope = false
              VHSaaSDK.getInstance().openPasswordRedEnvelope(this.RedEnvelopeData?.room_id!, this.RedEnvelopeData?.red_packet_uuid!,
                {
                  onSuccess: (data: VHRedEnvelopeInfo) => {
                    console.log("接收口令红包成功", data)
                  },
                  onFailure: (errorCode: number, errorMsg: string) => {
                    console.log("接收口令红包失败", errorCode, errorMsg)
                    ToastUtil.showToast(errorMsg);
                  }
                });
            })
        }
        .width('100%')
        .height('90%')
      }
      if (this.OpenEnvelope) {
        Stack() {
          Image($r('app.media.icon_open_red_packet'))
            .width('110%')
            .height('100%')
            .borderRadius(20)
            .syncLoad(true)
          Text('口令红包')
            .fontSize(24)
            .fontWeight(700)
            .fontColor('#ffc10312')
            .offset({ y: -134 })
          Text('支付宝搜“红包”，输入口令')
            .fontSize(16)
            .fontColor('#ffa7680d')
            .offset({ y: -90 })
          Text(this.RedEnvelope?.red_code)
            .fontSize(24)
            .fontWeight(700)
            .fontColor('#ffc10312')
            .offset({ y: -50 })
          Button('一键复制口令')
            .fontColor('#ffe7bc91')
            .width('70%')
            .backgroundColor('#e8401c')
            .onClick(() => {
              this.LongPressTextCustomMenu()
            })
          Text('查看领取名单')
            .position({ x: '30%', y: '92%' })
            .fontColor('#ff7a3e1c')
            .onClick(() => {
              this.Envelope()
              this.WinningList = true
              this.OpenEnvelope = false
            })
        }
        .width('100%')
        .height('90%')
      }
      if (this.WinningList) {
        Stack() {
          Column() {
            Row() {
              Image($r('app.media.icon_left'))
                .width(20)
                .fillColor('#fde1b1')
                .onClick(() => {
                  this.WinningList = false
                  this.OpenEnvelope = true
                })
              Text('领取Top10名单')
                .fontSize(20)
                .fontWeight(700)
                .fontColor('#fde1b1')
              Blank()
                .width(20)
            }.width('100%')
            .height('14%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ left: 4, right: 4 })

            Column() {
              List() {
                ForEach(this.RedEnvelopeUserList, (item: VHWinningUserListInfo) => {
                  ListItem() {
                    Row({ space: 6 }) {
                      Image(item.avatar || $r("app.media.icon_visitorvatar"))
                        .width(26)
                        .aspectRatio(1)
                        .borderRadius('50%')
                      Text(item.nickname)
                        .fontSize(10)
                        .maxLines(1)  // 限制最大行数
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .layoutWeight(1)
                      Blank()
                        .layoutWeight(1)
                      Text(this.formatTime(item.created_at))
                        .fontSize(10)
                        .fontColor('#999')
                    }
                  }
                })
              }
              .divider({ strokeWidth: 8, color: Color.Transparent })
              .scrollBar(BarState.Off)
            }
            .width('100%')
            .layoutWeight(1)
            .backgroundColor('#fde9e9')
            .borderRadius(6)
            .padding(10)
          }
          .width('100%')
          .height('100%')
          .backgroundColor('#ee2121')
          .borderRadius(20)
          .padding(10)
        }
        .width('100%')
        .height('90%')
      }
      Image($r('app.media.icon_close'))
        .fillColor(Color.White)
        .width(30)
        .aspectRatio(1)
        .padding(4)
        .border({ width: 2, color: Color.White })
        .borderRadius('50%')
        .margin({ top: 10 })
        .onClick(() => {
          this.controller.close()
        })
    }
    .width('60%')
    .height('45%')
    .offset({ y: -200 })
  }
}