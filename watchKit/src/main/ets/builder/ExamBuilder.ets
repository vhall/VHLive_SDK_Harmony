import {
  VHExaminationModel,
  VHQuestionnairePushModel,
  VHHistoryQuestionnaire,
  VHExamList,
  VHExamInternal,
  VHWebinarData
} from "@vhall/vhall_live"
import { WebViewPageBuilder, WebViewParams } from "../pages/WebViewPage"
import { ComponentContent } from "@kit.ArkUI"
import { PromptActionClass } from "../util/PromptActionClass"


@CustomDialog
export struct ExamBuilder {
  pageInfos: NavPathStack = new NavPathStack() // 导航
  controller: CustomDialogController
  @Consume examData: VHExaminationModel
  @State ExamUrl: string = ''
  private contentNode: ComponentContent<Object> | null = null;
  @Consume ExamList: VHExamList[]
  @Prop webinar_info: VHWebinarData

  // 打开链接
  private openLink(title: string, url: string) {
    const params = new WebViewParams(title, url);
    this.contentNode = new ComponentContent(this.getUIContext(), wrapBuilder(WebViewPageBuilder), params);
    PromptActionClass.setContext(this.getUIContext());
    PromptActionClass.setContentNode(this.contentNode);
    PromptActionClass.setOptions({
      alignment: DialogAlignment.Center,
      offset: { dx: 0, dy: 50 },
      isModal: true,
      maskRect: {
        x: 0,
        y: 0,
        width: '100%',
        height: '100%'
      }
    });
    PromptActionClass.openDialog();
  }

  VHExam(id: string, type: string) {
    this.ExamUrl =
      VHExamInternal.getExamUrl(this.webinar_info!, id, type) as string
    console.log(`获取考试数据成功： ${this.ExamUrl}`)
  }

  formatDate(dateStr: string): string {
    // 正则匹配日期时间结构，捕获月日和时分部分
    const regex = /\d{4}-(\d{2}-\d{2}) (\d{2}:\d{2})(:\d{2})?/;
    const match = dateStr.match(regex);
    if (match && match[2]) {
      // 拼接月日
      return `${match[2]}`;
    }
    // 格式不匹配时返回原字符串
    return dateStr;
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        // 顶部区域
        Stack({ alignContent: Alignment.TopEnd }) {
          Column() {
            Text('快问快答')
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

        if (this.ExamList.length > 0) {
          List({space:10}) {
            ForEach(this.ExamList, (item: VHExamList, index) => {
              //如果是回放活动。并且开启了回放填写才展示快问快答内容
              ListItem() {
                // 左侧：高亮截图
                Row() {
                  Column() {
                    Text(item.title)
                      .fontSize(16)
                      .margin({ bottom: 15 })
                    Row({ space: 10 }) {
                      Text(`推送时间:${this.formatDate(item.push_time)}`)
                        .fontSize(12)

                      if(item.limit_time > 0 && item.limit_time_switch == 1){
                        if(item.limit_time_type == 0){
                          Text("限时:" +item.limit_time.toString() + "分")
                            .fontSize(12)
                        }else if(item.limit_time_type == 2){
                          Text("限时:" +item.limit_time.toString() + "秒")
                            .fontSize(12)
                        }
                      }else{
                        Text(`限时:无`)
                          .fontSize(12)
                      }


                      Text(`总分:${item.total_score}`)
                        .fontSize(12)
                      Text(`题数:${item.question_num}`)
                        .fontSize(12)
                    }

                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  if (item.is_end == 0) {
                    Text(item.status == 0 ? '填写' : '已填写')
                      .fontSize(12)
                      .fontColor(item.status == 0 ? '#ff0881d4' : '#666')
                      .onClick(() => {
                        this.VHExam(item.paper_id.toString(), item.answer_condition?.type.toString() as string)
                        let param: object = new Object()
                        param['ExamUrl'] = this.ExamUrl
                        const pathInfo = new NavPathInfo(
                          'ExamPage', // 页面名称
                          param, // 传递给子页面的参数
                          undefined,
                          true
                        );
                        this.pageInfos.pushPath(pathInfo, true);
                      })
                  } else {
                    Text('已结束')
                      .fontSize(12)
                      .fontColor('#666')
                      .onClick(() => {
                        this.VHExam(item.paper_id.toString(), item.answer_condition?.type.toString() as string)
                        let param: object = new Object()
                        param['ExamUrl'] = this.ExamUrl
                        const pathInfo = new NavPathInfo(
                          'ExamPage', // 页面名称
                          param, // 传递给子页面的参数
                          undefined,
                          true
                        );
                        this.pageInfos.pushPath(pathInfo, true);
                      })
                  }

                }
                .padding(14)
                .backgroundColor(Color.White)
                .borderRadius(6)
                .width('94%')
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(VerticalAlign.Top)
                .margin({ bottom: 10 })
                .onClick(()=>{
                  this.VHExam(item.paper_id.toString(), item.answer_condition?.type.toString() as string)
                  let param: object = new Object()
                  param['ExamUrl'] = this.ExamUrl
                  const pathInfo = new NavPathInfo(
                    'ExamPage', // 页面名称
                    param, // 传递给子页面的参数
                    undefined,
                    true
                  );
                  this.pageInfos.pushPath(pathInfo, true);
                })
              }
              .alignSelf(ItemAlign.Center)
              .align(Alignment.Center)
              .width('90%')


            })
          }
          .padding(10)
          .height('70%')
          .alignListItem(ListItemAlign.Center)
          .backgroundColor('#FDF5E7')
          .sticky(StickyStyle.Header) // 设置吸顶，实现粘性标题效果
          .zIndex(3)
          .scrollBar(BarState.Auto) // 自动显示滚动条（可选）



        }
      }
      .width('100%')
      .height(380)
      .padding(15)
      .position({ x: 0, y: 450 })
      .borderRadius({ topLeft: 10, topRight: 10 })
      .linearGradient({
        angle: 90,
        colors: [['#fffcf1f7', 0.1], ['#ffe7dbf8', 0.9]]
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
  }
}
