import { it } from "@ohos/hypium"
import {
  VHQuestionnairePushModel,
  VHHistoryQuestionnaire,
  VHInteractMyAward,
  VHInteractWinnerInfo,
  VHSaaSDK,
  VHSurveyInternal,
  VHWebinarData,
  VHHistoryQuestionnaireInfo,
  VHWebinarSurvey,
  VHWebinarSurveyExtend
} from "@vhall/vhall_live"
import { ToastUtil } from "../action/ToastUtil";
import { ComponentContent } from "@kit.ArkUI";
import { createMyAwardView, MyAwardParams } from "./InteractMyAwardListBuilder";
import { PromptActionClass } from "../util/PromptActionClass";
import { WebViewPageBuilder, WebViewParams } from "../pages/WebViewPage";

@CustomDialog
export struct QuestionnaireBuilder {
  @Consume questionnairePush: VHQuestionnairePushModel | null
  @Consume questionnaireList: VHHistoryQuestionnaire[]
  @Consume questionnaireAward: number;
  @State questionnaireUrl: string = "";
  pageInfos: NavPathStack = new NavPathStack() // 导航
  controller: CustomDialogController
  private contentNode: ComponentContent<Object> | null = null;
  @Prop webinar: VHWebinarData = new VHWebinarData();
  @Prop surId:number;


  aboutToAppear(): void {
    this.QuestionnaireListHttp(false)
  }

  //获取到问卷地址
  SurveyQuestionnaire(id: string) {
    this.questionnaireUrl =
      VHSurveyInternal.getSurveyUrl(this.webinar!, id) as string
    return this.questionnaireUrl
  }

  //进行日期的转换
  formatDate(dateStr: string): string {
    // 正则匹配日期时间结构，捕获月日和时分部分
    const regex = /\d{4}-(\d{2}-\d{2}) (\d{2}:\d{2})(:\d{2})?/;
    const match = dateStr.match(regex);
    if (match && match[1] && match[2]) {
      // 拼接月日和时分
      return `${match[1]} ${match[2]}`;
    }
    // 格式不匹配时返回原字符串
    return dateStr;
  }

  // 获取历史问卷列表
  QuestionnaireListHttp(openDialog: boolean) {
    VHSaaSDK.getInstance()
      .performQuestionnaireListIn(this.webinar?.interact?.room_id!, this.webinar?.webinar?.id.toString()!,
        this.webinar?.switch_info?.switch_id.toString()!, {
          onSucceed: (data: VHHistoryQuestionnaireInfo) => {
            this.questionnaireList = data.list;
            if(this.surId > 0){
              this.SurveyQuestionnaire(this.surId.toString())
            }else{
              if (data.total > 0) {
                this.SurveyQuestionnaire(this.questionnaireList[0].question_id.toString())
              }
            }

            this.questionnaireAward = data.my_award_status;
            if (openDialog) {
              if (this.questionnaireList.length > 0) {
              } else {
                ToastUtil.showToast("没有更多数据");
              }
            } else {
              this.initWebinarSurvey();
            }
            console.log(`获取问卷列表成功： ${JSON.stringify(this.questionnaireList)}`);
          },
          onFailure: (errorCode: number, errorMsg: string) => {
            console.log(`获取问卷列表失败： ${errorMsg}`);
            ToastUtil.showToast(errorMsg);
          }
        })
  }

  initWebinarSurvey() {
    VHSaaSDK.getInstance().getLastPublishWebinarSurvey(this.webinar?.interact?.room_id!, this.webinar?.switch_info?.start_time!,
        "",this.webinar?.webinar?.type! == 1 ? 0 : 1, {
          onSuccess: (data: VHWebinarSurvey) => {
            let extend: VHWebinarSurveyExtend = JSON.parse(data.extend) as VHWebinarSurveyExtend;
            if (extend.mandatory_filling == 1) {
              this.questionnaireList.forEach((value: VHHistoryQuestionnaire, index: number,
                array: VHHistoryQuestionnaire[]) => {
                if (data.question_id == value.question_id && value.is_answered == "0") {
                  this.SurveyQuestionnaire(value.question_id.toString())
                  this.openSurveyView();
                }
              })
            }
          },
          onFailure: (errorCode: number, errorMsg: string) => {

          }
        });
  }

  //跳转到web组件页面
  private openSurveyView() {
    let param: object = new Object()
    param['questionnaireUrl'] = this.questionnaireUrl
    param['webinar_info'] = this.webinar
    param['questionnaireList'] = this.questionnaireList
    const pathInfo = new NavPathInfo(
      'QuestionnairePage', // 页面名称
      param, // 传递给子页面的参数
      undefined,
      true
    );
    // 配置导航选项
    const options: NavigationOptions = {
      launchMode: LaunchMode.NEW_INSTANCE // 关键参数
    };
    let count: Array<number> = this.pageInfos.getIndexByName('QuestionnairePage')
    if (count.length > 0) {
      this.pageInfos.pop();
    }
    this.pageInfos.pushPath(pathInfo, options);
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        // 顶部区域
        Stack({ alignContent: Alignment.TopEnd }) {
          Column() {
            Text('问卷')
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

          if (this.questionnaireAward == 1) {
            Button("我的奖品")
              .backgroundColor(Color.Gray)
              .fontColor(Color.White)
              .alignSelf(ItemAlign.End)
              .margin({ top: 20 })
              .onClick(() => {
                VHSaaSDK.getInstance().getInteractAwardList(0, 200, {
                  onSuccess: (data: VHInteractMyAward) => {
                    const params = new MyAwardParams(data, this.webinar);
                    this.contentNode =
                      new ComponentContent(this.getUIContext(), wrapBuilder(createMyAwardView), params);
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
                  },
                  onFailure: (errorCode: number, errorMsg: string) => {
                    ToastUtil.showToast(errorMsg);
                  }
                });
              })
          }

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


        // 历史问卷列表
        List() {
          ForEach(this.questionnaireList, (item: VHHistoryQuestionnaire, index) => {
            ListItem() {
              Row() {
                Column() {
                  Text(item.title)
                    .fontSize(16)
                    .margin({ bottom: 15 })
                  Text(this.formatDate(item.created_at))
                    .fontSize(12)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Text(item.is_answered == '0' ? '填写' : '已填')
                  .fontSize(12)
                  .fontColor(item.is_answered == '0' ? '#ff0881d4' : '#ff6d6d6d')
                  .onClick(() => {
                    // if (item.is_answered == '0') {
                    this.SurveyQuestionnaire(item.question_id.toString())
                    let param: object = new Object()
                    param['questionnaireUrl'] = this.questionnaireUrl
                    param['webinar_info'] = this.webinar
                    param['questionnaireList'] = this.questionnaireList
                    const pathInfo = new NavPathInfo(
                      'QuestionnairePage', // 页面名称
                      param, // 传递给子页面的参数
                      undefined,
                      true
                    );
                    // 配置导航选项
                    const options: NavigationOptions = {
                      launchMode: LaunchMode.NEW_INSTANCE // 关键参数
                    };
                    let count: Array<number> = this.pageInfos.getIndexByName('QuestionnairePage')
                    if (count.length > 0) {
                      this.pageInfos.pop();
                    }
                    this.pageInfos.pushPath(pathInfo, options);
                    // } else {
                    //   ToastUtil.showToast('已填写')
                    // }
                  })
              }
              .padding(14)
              .backgroundColor(Color.White)
              .borderRadius(6)
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Top)
            }
          })
        }
        .width('94%')
        .height(260)
        .divider({ strokeWidth: 10, color: Color.Transparent })
        .scrollBar(BarState.Off)
        .margin({ bottom: 15 })
      }
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
