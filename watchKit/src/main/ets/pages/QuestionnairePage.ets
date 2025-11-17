import { webview } from "@kit.ArkWeb";
import { abilityAccessCtrl } from "@kit.AbilityKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { ToastUtil } from "../action/ToastUtil";
import { QuestionnaireBuilder } from "../builder/QuestionnaireBuilder";
import { VHHistoryQuestionnaire, VHHistoryQuestionnaireInfo, VHSaaSDK, VHWebinarData } from "@vhall/vhall_live";
import { WantUtil } from "../utils/WantUtil";


@Builder
export function QuestionnairePageBuilder(name: string, param: object) {
  QuestionnairePage({
    questionnaireUrl: param['questionnaireUrl'],
    webinar_info: param['webinar_info'],
    questionnaireList: param['questionnaireList'],
  })
}

class HarmonyObj {
  constructor() {
  }

  public pageInfos: NavPathStack = new NavPathStack() // 导航
  onWebEvent(info: string): void {
    try {
      console.log('onWebEvent' + info);
      if (info != null) {
        let event: object = JSON.parse(info as string) as object;
        if (event['event'] == 'close') {
          //关闭
          this.pageInfos.pop()
        } else if (event['event'] == 'submit') {
          ToastUtil.showToast("提交成功")
          this.pageInfos.pop()
        }
      }
    } catch (e) {
    }
    console.log('Web async string');

  }
}

@Component
export struct QuestionnairePage {
  // @Consume SurveyQuestionnaireUrl: string
  private questionnaireUrl?: string;
  private webinar_info?: VHWebinarData;
  @Require questionnaireList?: VHHistoryQuestionnaire[]
  // Web控制器，用于管理Web组件
  controller: webview.WebviewController = new webview.WebviewController();
  webObj: HarmonyObj = new HarmonyObj();
  private pageInfos: NavPathStack = new NavPathStack() // 导航
  //问卷弹窗
  VHQuestionnaireDialog = new CustomDialogController({
    builder: QuestionnaireBuilder(),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })

  // 问卷列表
  QuestionnaireListHttp() {
    VHSaaSDK.getInstance()
      .performQuestionnaireListIn(this.webinar_info?.interact?.room_id!, this.webinar_info?.webinar?.id.toString()!,
        this.webinar_info?.switch_info?.switch_id.toString()!, {
          onSucceed: (data: VHHistoryQuestionnaireInfo) => {
            this.questionnaireList = data.list;
            console.log(`获取问卷列表成功： ${JSON.stringify(this.questionnaireList)}`);
          },
          onFailure: (errorCode: number, errorMsg: string) => {
            console.log(`获取问卷列表失败： ${errorMsg}`);
            ToastUtil.showToast(errorMsg);
          }
        })
  }

  SurveyQuestionnaire() {
    throw new Error("Method not implemented.");
  }

  aboutToAppear(): void {
    webview.WebviewController.setWebDebuggingAccess(true);
    this.VHQuestionnaireDialog.close()
    this.QuestionnaireListHttp()
  }

  aboutToDisappear(): void {
    this.VHQuestionnaireDialog.close()
    this.QuestionnaireListHttp()
  }

  // 问卷Web
  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Web({
            // src: this.SurveyQuestionnaireUrl,
            src: this.questionnaireUrl,
            controller: this.controller
          })
            .domStorageAccess(true)
            .onlineImageAccess(true)
            .imageAccess(true)
            .onControllerAttached(() => {
              this.controller.registerJavaScriptProxy(this.webObj, "harmonyObj", ["onWebEvent"]);
              this.controller.refresh();
            })
            .onOverrideUrlLoading((webResourceRequest: WebResourceRequest) => {
              let url: string = webResourceRequest.getRequestUrl();
              //使用浏览器跳转展示隐私协议。
              WantUtil.toWebBrowser(url);
              return true;
            })
            .zoomAccess(false)
            .javaScriptAccess(true)
            .geolocationAccess(true)
            .mediaPlayGestureAccess(true)
            .databaseAccess(true)
            .onPermissionRequest((event) => {
              let atManager = abilityAccessCtrl.createAtManager();
              atManager.requestPermissionsFromUser(getContext(this),
                ['ohos.permission.CAMERA', 'ohos.permission.MICROPHONE'])
                .then((data) => {
                  console.info('data:' + JSON.stringify(data));
                  console.info('data permissions:' + data.permissions);
                  console.info('data authResults:' + data.authResults);
                  if (event) {
                    event.request.grant(event.request.getAccessibleResource());
                  }
                }).catch((error: BusinessError) => {
                console.error(`Failed to request permissions from user. Code is ${error.code}, message is ${error.message}`);
              })
            })
        }
        .width('100%')
        .height('100%')
        // .position({ x: 0, y: 20 })
      }
      .onClick(() => {
        this.controller
      })
      .width('100%')
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .backgroundColor("#48000000")
    }
    .id('QuestionnairePage')
    .onReady((context: NavDestinationContext) => {
      this.webObj.pageInfos = context.pathStack;
    })
    .backgroundColor("#48000000")
  }
}