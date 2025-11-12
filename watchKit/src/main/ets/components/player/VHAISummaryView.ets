import { VHAIMediaInfo, VHAISummaryModel, VHSaaSDK, VHWebinarData } from "@vhall/vhall_live";
import { ToastUtil } from "../../action/ToastUtil";

@Component
export struct VHAISummaryView {
  @Require webinar:VHWebinarData;
  @State model:VHAISummaryModel= new VHAISummaryModel();
  aboutToAppear(): void {
    VHSaaSDK.getInstance().getAIWatch(this.webinar?.record?.record_id!,{
      onSucceed: (data: VHAIMediaInfo) => {
        //获取AI剪辑回放信息
        VHSaaSDK.getInstance().getAISummaryInfo(data.summary.file_url,{
          onSucceed: (data: VHAISummaryModel) => {
            this.model = data
          },
          onFailure: (errorCode: number, errorMsg: string) => {

          }
        });
      },
      // 失败
      onFailure: (errorCode: number, errorMsg: string) => {
        ToastUtil.showToast("getAIWatch:" + errorMsg);
      }
    });
  }

  build() {
    Column({space:20}){
      Column({space:4}){
        Row({space:4}){
          Text(" ").width("6px").backgroundColor(Color.Red)
          Text("主题")
        }
        Text(this.model.subject)
      }.alignItems(HorizontalAlign.Start)

      Column({space:4}){
        Row({space:4}){
          Text(" ").width("6px").backgroundColor(Color.Red)
          Text("关键字")
        }
        //显示关键字
        Flex({ wrap: FlexWrap.Wrap, direction: FlexDirection.Row }){
          ForEach(
            this.model.keywords, // 待遍历的数组
            (keyword: string) => { // 遍历到的单个关键词
              Text(keyword)
                .fontSize(14)
                .fontColor("#0066FF")
                .backgroundColor("#e6f0ff") // 关键词背景色（突出显示）
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .borderRadius(20); // 圆角样式（胶囊形）
            },
            (keyword: string) => keyword // 唯一标识（确保组件复用正确，关键词不重复时可用自身）
          );
        }
      }.alignItems(HorizontalAlign.Start)

      Column({space:4}){
        Row({space:4}){
          Text(" ").width("6px").backgroundColor(Color.Red)
          Text("概要总结")
        }
        Text(this.model.summary)//概要详情
      }.alignItems(HorizontalAlign.Start)
    }
    .padding(10)
    .alignItems(HorizontalAlign.Start)
    .width('90%')
    .height("100%")
  }
}