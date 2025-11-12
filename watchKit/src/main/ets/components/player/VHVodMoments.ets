import { VHAIHighlightModel, VHAIMediaInfo, VHSaaSDK, VHWatermarkConfig, VHWebinarData } from "@vhall/vhall_live";
import { util } from "@kit.ArkTS";
import { http } from "@kit.NetworkKit";
import { JSON } from "@kit.ArkTS";
import { BasicDataSource } from "../../util/LazyDataSource";
import { getTimeString } from "../../util/TimeTools";
import { EmitterMsgData, EmitterUtil } from "../../util/EmitterUtil";
import MsgType from "../../constants/MsgType";


export class AIDataSource extends BasicDataSource<VHAIHighlightModel> {
  private listener: VHAIHighlightModel[] = [];

  notifyDataReload(): void {
    super.notifyDataReload();
  }

  totalCount(): number {
    return this.listener.length
  }

  getData(index: number): VHAIHighlightModel {
    return this.listener[index]
  }

  updateData(newList: VHAIHighlightModel[]): void {
    this.listener = newList;
    this.notifyDataAdd(this.listener.length - 1);
  }
}


@Component
export struct VHVodMoments {

  private  highlightDataSource: AIDataSource = new AIDataSource();
  @Require webinar:VHWebinarData;
  @State models:VHAIHighlightModel[] = [];
  @State selectItem:string = "";

  aboutToAppear(): void {
    VHSaaSDK.getInstance().getAIWatch(this.webinar?.record?.record_id!, {
      onSucceed: (data: VHAIMediaInfo) => {
        VHSaaSDK.getInstance().getVHAIHighlightInfo(data.moments.file_url,{
          onSucceed: (data: VHAIHighlightModel[]) => {
            this.models = data;
            this.highlightDataSource.updateData(this.models);
          },
          onFailure: (errorCode: number, errorMsg: string) => {}
        })
      },
      // 失败
      onFailure: (errorCode: number, errorMsg: string) => {

      }
    });
  }

  @Builder
  VodItem(item: VHAIHighlightModel) {
    // 半模态的内容
    Row({ space: 10 }) {
      Image(item.image_url)
        .width('112vp')
        .height('63vp')
        .objectFit(ImageFit.Cover)
        .borderRadius(4)

      Column({ space: 10 }) {
        Text(item.subject)
          .fontColor(this.selectItem == item.subject ? Color.Red : '#333')
          .maxLines(2)
          .width("60%")
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row({ space: 10 }) {
          Image($r('app.media.icon_close'))
            .width("10vp")
            .height("10vp")

          Text(getTimeString(item.start_time) )
            .fontColor(this.selectItem == item.subject ? Color.Red : '#333')
            .maxLines(2)
            .width("60%")
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }.justifyContent(FlexAlign.Start)
      }.justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
    }
    .width('90%')
    .margin(10)
    .padding(10)
    .backgroundColor("#EEDCDCDC")
    .borderRadius(6)
  }

  build() {
    List() {
      LazyForEach(
        this.highlightDataSource,
        // 渲染单个高亮项
        (item: VHAIHighlightModel) => {
          ListItem() {
            // 左侧：高亮截图
            this.VodItem(item)
          }.onClick((event) => {
            let msgData: EmitterMsgData;
            msgData = {
              type: MsgType.VOD_MOMENT_TIME,
              data: item.start_time
            } as EmitterMsgData;
            EmitterUtil.send(msgData);
            this.selectItem = item.subject;
          })
        },(item: VHAIHighlightModel) => `${item.image_url}_${item.start_time}` // 用URL+时间确保唯一性
      );

    }.sticky(StickyStyle.Header) // 设置吸顶，实现粘性标题效果
  }
}