import { VHGiftItem, VHGiftList, VHSaaSDK, VHWebinarData } from '@vhall/vhall_live';
import { ToastUtil } from "../../action/ToastUtil";
import { PromptActionClass } from '../../util/PromptActionClass';


@Builder
export function createGiftView(webinars: VHWebinarData) {
  GiftComponent({ webinars: webinars });
}

/**
 * 礼物底部弹窗视图
 */
@Component
export struct GiftComponent {
  @State giftList: VHGiftItem[] | null = null;
  // 选中的礼物ID
  @State selectedGiftId: string = '-1';
  public webinars?: VHWebinarData;
  private giftItem: VHGiftItem | null = null;
  private scroller: Scroller = new Scroller();

  aboutToAppear() {
    this.getGiftList();
  }

  getGiftList() {
    VHSaaSDK.getInstance().getGiftList(this.webinars?.interact?.room_id!, {
      onSucceed: (data: VHGiftList) => {
        this.giftList = data?.list;
      },
      onFailure: (errorCode, errorMsg) => {
        console.log("礼物列表失败：", errorMsg)
        ToastUtil.showToast(errorMsg);
      }
    });
  }

  sendGift(giftItem: VHGiftItem) {
    if (giftItem.price === '0') {
      VHSaaSDK.getInstance().sendGift(this.webinars?.interact?.room_id!, giftItem.id, "WEIXIN", "H5_PAY", "", {
        onSuccess: (data) => {
          this.selectedGiftId = '-1';
          ToastUtil.showToast("赠送成功" + giftItem.name);
        },
        onFailure: (errorCode, errorMsg) => {
          console.log("发送礼物失败：", errorMsg)
          ToastUtil.showToast(errorMsg);
        }
      });
    } else {
      ToastUtil.showToast("自行接入付费系统");
    }
    PromptActionClass.closeDialog();
  }

  // 切换礼物选中状态
  private toggleGiftSelection(giftId: string) {
    this.selectedGiftId = this.selectedGiftId === giftId ? '-1' : giftId;
  }

  // 渲染礼物项
  @Builder
  renderGiftItem(gift: VHGiftItem) {
    Column({ space: 6 }) {
      // 礼物图片（带红色边框选中效果）
      Image(gift.image_url)
        .width(60)
        .height(60)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)
        .backgroundColor('#f0f0f0')
        // 选中时显示红色边框
        .border({ width: this.selectedGiftId === gift.id ? 2 : 0, color: '#ff4d4f' })
        .onClick(() => this.toggleGiftSelection(gift.id))

      // 礼物名称/赠送按钮（选中时切换为红色背景的"赠送"文本）
      if (this.selectedGiftId === gift.id) {
        // 选中状态：显示"赠送"文本（红色背景）
        Text('赠送')
          .fontSize(12)
          .fontColor('#ffffff')
          .backgroundColor('#ff4d4f')
          .padding({
            left: 8,
            right: 8,
            top: 2,
            bottom: 2
          })
          .borderRadius(4)
          .onClick(() => this.sendGift(gift))
      } else {
        // 未选中状态：显示礼物名称
        Text(gift.name)
          .fontSize(12)
          .fontColor('#333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .textAlign(TextAlign.Center)
      }
    }
    .width('25%') // 每行4个
    .padding(8)
    .onClick(() => this.handleSendGift(gift))
    .justifyContent(FlexAlign.Center)
  }

  // 关闭弹窗
  private closePopup() {
    this.selectedGiftId = '-1'
    PromptActionClass.closeDialog();
  }

  // 发送礼物（触发事件传递给父组件）
  private handleSendGift(gift: VHGiftItem) {
    this.closePopup();
  }

  build() {
    // 礼物弹窗（底部弹出）
    Column() {
      // 弹窗标题栏
      Flex({ justifyContent: FlexAlign.End, alignItems: ItemAlign.Start }) {
        Image($r('app.media.close'))
          .width(16)
          .height(16)
          .margin({ right: 6, top: 6 })
          .onClick(() => {
            this.closePopup()
          })
      }

      // 礼物列表（网格布局）
      Scroll() {
        Column() {
          Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.giftList, (gift: VHGiftItem) => {
                if(gift.is_show == 1){
                  this.renderGiftItem(gift);
                }
              }, (gift: VHGiftItem) => gift.id.toString())
          }
          .width('100%')
        }
        .width('100%')
        .padding(12)
      }
      .flexGrow(1)
      .height('80%')
      .scrollBar(BarState.On)
    }
    .width('100%')
    .height('30%')
    .padding({ bottom: 10 })
    .backgroundColor('#f0f0f0')
    .onAppear(() => {
      this.getGiftList();
    })
  }
}