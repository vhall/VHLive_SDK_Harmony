import { VHPlayerConfig, VHSurveyInternal, VHWebinarData } from "@vhall/vhall_live";
import { webview } from "@kit.ArkWeb";
import web_webview from '@ohos.web.webview';
import { abilityAccessCtrl } from "@kit.AbilityKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { ToastUtil } from "../../../../src/main/ets/action/ToastUtil";

const pageInfos: NavPathStack = new NavPathStack() // 导航

@Builder
export function ExamPageBuilder(name: string, param: object) {
  ExamPage({
    ExamUrl: param['ExamUrl'],
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
          this.pageInfos.pop();
        }
      }
    } catch (e) {
      console.log('Web async string');
    }
  }
}


@Component
export struct ExamPage {
  // @Consume ExamUrl: string
  private ExamUrl?: string;
  // Web控制器，用于管理Web组件
  webController: webview.WebviewController = new webview.WebviewController();
  webObj: HarmonyObj = new HarmonyObj();


  //快问快答Web
  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Web({
            src: this.ExamUrl,
            controller: this.webController
          })
            .backgroundColor(Color.Orange)//拦截资源请求，优化游戏流畅
            .domStorageAccess(true)
            .onlineImageAccess(true)
            .imageAccess(true)
            .onControllerAttached(() => {
              this.webController.registerJavaScriptProxy(this.webObj, "harmonyObj", ["onWebEvent"]);
              this.webController.refresh();
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
        .position({ x: 0, y: 50 })
      }
      .onClick(() => {
        this.webController
      })
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Transparent)
    }
    .padding({ top: 30 })
    .hideToolBar(true)
    .hideTitleBar(true)
    .hideBackButton(true)
    .onReady((context: NavDestinationContext) => {
      this.webObj.pageInfos = context.pathStack;
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .id('ExamPagePage')
    .backgroundColor("#48000000")
  }
}