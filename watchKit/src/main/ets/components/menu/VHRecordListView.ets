import { VHSaaSDK, VHWebinarData,
  VHWebinarRecordWatch } from "@vhall/vhall_live";
import { JSON } from "@kit.ArkTS";
import { BasicDataSource } from "../../util/LazyDataSource";
import { ToastUtil } from "../../action/ToastUtil";
import { emitter } from "@kit.BasicServicesKit";


export class RecordDataSource extends BasicDataSource<VHWebinarRecordWatch> {
  private listener: VHWebinarRecordWatch[] = [];

  notifyDataReload(): void {
    super.notifyDataReload();
  }

  totalCount(): number {
    return this.listener.length
  }

  getData(index: number): VHWebinarRecordWatch {
    return this.listener[index]
  }

  updateData(newList: VHWebinarRecordWatch[]): void {
    this.listener = [...newList];
    this.notifyDataAdd(this.listener.length - 1);
  }
}

@Component
export struct VHRecordListView {
  @Require  pageInfos: NavPathStack // 导航
  @Require webinar:VHWebinarData;
  private  highlightDataSource: RecordDataSource = new RecordDataSource();
  aboutToAppear(): void {
    VHSaaSDK.getInstance().getWatchList(this.webinar?.webinar?.id!,{
      onSucceed: (data: VHWebinarRecordWatch[]) => {
        //获取回放列表，懒加载显示回放内容
        this.highlightDataSource.updateData(data);
      },
      // 失败
      onFailure: (errorCode: number, errorMsg: string) => {
        ToastUtil.showToast("getAIWatch:" + errorMsg);
      }
    });
  }



  @Builder
  VodItem(item: VHWebinarRecordWatch) {
    // 半模态的内容
    Row({ space: 10 }) {
      Image(item.img_url)
        .width('112vp')
        .height('63vp')
        .objectFit(ImageFit.Cover)
        .borderRadius(4)

      Column({ space: 10 }) {
        Text(item.name)
          .fontColor(item.id.toString() == this.webinar.record?.record_id ? Color.Red: Color.Black)//如果是当前活动高亮显示
          .maxLines(2)
          .width("60%")
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row({ space: 10 }) {
          Text(item.duration)
            .fontColor(item.id.toString() == this.webinar.record?.record_id ? Color.Red: Color.Black)
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
        (item: VHWebinarRecordWatch) => {
          ListItem() {
            // 左侧：高亮截图
            this.VodItem(item)
          }.onClick((event) => {
            // 当前页面的返回操作
            let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
              console.info(`eventData: ${JSON.stringify(eventData)}`);
            }
            // 接收端事件，跳转到活动
            let eventData: emitter.EventData = {
              data: {
                recordId: item.id.toString()
              }
            };
            emitter.emit("turn_to_record", eventData);
            this.pageInfos.pop();
          })
        },(item: VHWebinarRecordWatch) => `${item.id}_${item.duration}` // 用URL+时间确保唯一性
      );
    }
    .height('100%')
    .alignListItem(ListItemAlign.Center)
    .backgroundColor('#FDF5E7')
    .sticky(StickyStyle.Header) // 设置吸顶，实现粘性标题效果
  }
}