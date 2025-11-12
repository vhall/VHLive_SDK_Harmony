import { VHAdvDefault, VHAdvItem, VHSaaSDK, VHWebinarData } from '@vhall/vhall_live';
import { PromptActionClass } from '../../util/PromptActionClass';
import { ComponentContent } from '@kit.ArkUI';
import { WebViewPageBuilder, WebViewParams } from '../../pages/WebViewPage';
import { ToastUtil } from '../../action/ToastUtil';


/**
 * 推荐
 * */
@Component
export struct VHAdvComponent{
  @Require webinars: VHWebinarData;
  @State advList: VHAdvItem[] = [];
  private scroller: Scroller = new Scroller();
  private contentNode: ComponentContent<Object> | null = null;

  aboutToAppear() {
    this.getAdvList();
  }

  getAdvList() {
    VHSaaSDK.getInstance()
      .getAdvList(this.webinars?.webinar!.id.toString(), '0','10', {
        onSucceed: (data: VHAdvDefault) => {
          this.advList = data?.adv_list;
        },
        onFailure: (errorCode, errorMsg) => {
          console.log("获得推荐广告列表失败：", errorMsg)
          ToastUtil.showToast(errorMsg);
        }
      });
  }
  // 打开链接
  private openLink(url: string) {
    const params=new WebViewParams("e.vhall.com",url);
    this.contentNode = new ComponentContent(this.getUIContext(), wrapBuilder(WebViewPageBuilder),params);
    PromptActionClass.setContext(this.getUIContext());
    PromptActionClass.setContentNode(this.contentNode);
    PromptActionClass.setOptions({alignment: DialogAlignment.Center, offset: { dx: 0, dy: 50 } ,isModal: true,maskRect:{x: 0, y: 0, width: '100%', height: '100%' }});
    PromptActionClass.openDialog();
  }

  @Builder
  renderAdvItem(advItem: VHAdvItem) {
    Row() {
      Image(advItem.img_url)
        .width(120)
        .height(80)
        .objectFit(ImageFit.Cover)
        .padding(10)
      Column() {
        Text(advItem.subject)
          .fontSize(12)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .padding({ bottom: 20 })
        Button('查看')
          .width(60)
          .height(24)
          .fontSize(10)
          .fontColor(Color.Black)
          .backgroundColor(Color.Transparent)
          .border({ width: 1, color: '#555555' })
          .onClick(() => {
            this.openLink(advItem.url);
          })
      }.padding({ left: 8 })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
    }

  }

  build() {
    Column() {
      List({  scroller: this.scroller }) {
        ForEach(this.advList, (advItem: VHAdvItem,index) => {
          ListItem() {
            this.renderAdvItem(advItem);
          }
          // 分隔线
          if (index <= this.advList!.length - 1)
            Divider()
              .height(1)
              .color('#555555')
              .margin({ left: 8, right: 8 })
        }, (item: VHAdvItem) => item.adv_id.toString())
      }
    }
    .width('100%')
    .height('100%')
  }
}