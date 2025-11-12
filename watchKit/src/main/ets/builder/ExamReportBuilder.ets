import { VHCardInfo,
  VHExamPersonalReport,
  VHExamRank,
  VHExamReport,
  VHExamReportList,
  VHGiftAwardFiled,
  VHGiftAwardItem,
  VHPushScreenCard, VHSaaSDK,
  VHWatchGiftAward,
  VHWatchGiftInfo, VHWatchGiftOpenMsg,
  VHWatchGiftParticipate,
  VHWatchGiftSetting,
  VHWatchGiftWinner,
  VHWatchGiftWinnerDetail,
  VHWebinarData,
  VHWinner} from "@vhall/vhall_live";
import { PromptActionClass } from "../util/PromptActionClass";
import { BasicDataSource } from "../util/LazyDataSource";
import { promptAction } from "@kit.ArkUI";
import { ToastUtil } from "../action/ToastUtil";
import { DateUtil } from "../utils/DateUtil";
import { DATE_FORMAT4, DATE_FORMAT6 } from "../entity/constraint";

// 自定义参数类型
export class reportParams {
  exam: VHExamRank;
  webinar: VHWebinarData;

  constructor(id: VHExamRank, webinar: VHWebinarData) {
    this.exam = id;
    this.webinar = webinar;
  }
}

export class AwardDataSource extends BasicDataSource<VHExamReport> {
  private listener: VHExamReport[] = [];

  notifyDataReload(): void {
    super.notifyDataReload();
  }

  totalCount(): number {
    return this.listener.length
  }

  getData(index: number): VHExamReport {
    return this.listener[index]
  }

  updateData(newList: VHExamReport[]): void {
    this.listener = newList;
    this.notifyDataAdd(this.listener.length - 1);
  }
}


@Builder
export function createExamReportView(parm:reportParams){
  ExamReportView({examRank:parm.exam, webinar_info:parm.webinar});
}


/**
 * 常用设置底部弹窗视图
 */
@Component
export struct ExamReportView {
  private highlightDataSource: AwardDataSource = new AwardDataSource();
  @State settingDataSource: VHGiftAwardFiled[] = [];
  @State models:VHExamReport[] = [];

  @Require webinar_info:VHWebinarData;
  private examRank:VHExamRank = new VHExamRank();


  private timeId:number = -1;
  aboutToAppear(): void {
    //获取前50个成绩
    VHSaaSDK.getInstance().getExamUserPerformanceList(this.examRank.paper_id,50,0,{
      onSucceed: (data: VHExamReportList) =>{
        if(data.total > 0){
          this.highlightDataSource.updateData(data.list);
        }
      },
      onFailure: (errorCode: number, errorMsg: string) => {

      }
    });
    //获取自己的成绩
    VHSaaSDK.getInstance().getExamPersonalReport(this.webinar_info.webinar?.id.toString()!,this.examRank.paper_id, {
      onSucceed: (data: VHExamPersonalReport) =>{

      },
      onFailure: (errorCode: number, errorMsg: string) => {

      }
    });

  }
  aboutToDisappear(): void {

  }


  private changeUseTime(user_time:number){
    let minutes = Math.floor(user_time/60).toString();
    let seconds = Math.floor(user_time % 60).toString();
    if(minutes.length == 1){
      minutes = "0" + minutes;
    }
    if(seconds.length == 1){
      seconds = "0" + seconds;
    }
    return `${minutes}` + ":" + `${seconds}`
  }


  private  formatToPercentage(str: string): string {
    // 将字符串转换为数字
    const num = parseFloat(str);
    // 检查转换是否成功
    if (isNaN(num)) {
      throw new Error("输入不是有效的数字字符串");
    }
    // 保留一位小数并添加百分号
    return num.toFixed(1) + "%";
  }
  //成绩名单
  @Builder
  WinnerItem(item: VHExamReport) {
    // 半模态的内容
    Column({ space: 5 }){
      Row({ space: 10 }) {
        Text(item.rank_no.toString()).fontColor(Color.Red)
        Image(item.head_img.length > 0 ? item.head_img : $r('app.media.icon_avatar')).width(20).height(20).borderRadius(10)
        Text(item.user_name)
        Blank()
        Text(item.score.toString())
        Text(this.formatToPercentage(item.right_rate))
        Text(this.changeUseTime(item.use_time))
        // Text(`${item.award_name}`).fontColor(Color.Red)
      }
      .width('90%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .padding(10)
      .backgroundColor("#FFFFFF")
      .borderRadius(10)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor("#FDF5E7")
  }

  build() {
    Column(){
      Column({space: 10}) {
        Row({space:10}){
          Text(this.examRank.paper_title).fontSize('20vp')
          Blank()
          Image($r('app.media.close_gray'))
            .width(20)
            .height(20)
            .margin({top:20})
            .onClick(()=>{
              PromptActionClass.closeDialog();
            })
        }.justifyContent(FlexAlign.SpaceEvenly)
        .width('80%')

        Row({space:10}){
          Text('用户')
          Blank()
          Text('得分')
          Text('正确率')
          Text('用时')
        }.justifyContent(FlexAlign.SpaceEvenly)
        .width('80%')

        List({space:2}) {
          LazyForEach(
            this.highlightDataSource,
            // 渲染单个高亮项
            (item: VHExamReport) => {
              ListItem() {
                // 左侧：高亮截图
                this.WinnerItem(item)
              }
              // .alignSelf(ItemAlign.Center)
              // .align(Alignment.Center)
              .width('90%')
            },(item: VHExamReport) => `${item.rank_no}` // 用URL+时间确保唯一性
          );
        }
        .height('70%')
        .alignListItem(ListItemAlign.Center)
        .backgroundColor('#FDF5E7')
        .sticky(StickyStyle.Header) // 设置吸顶，实现粘性标题效果
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .borderRadius(10)
      .height('70%')
      .backgroundColor('#FDF5E7')
    }
    .width('100%')
    .height('80%')
  }
}