import { webview } from '@kit.ArkWeb';
import { ToastUtil } from '../../action/ToastUtil';
import { JSON } from '@kit.ArkTS';

class HarmonyObj {
  controller: CustomDialogController;
  onResult?: (result: string) => void;

  constructor(controller: CustomDialogController, onResult?: (result: string) => void) {
    this.controller = controller;
    this.onResult = onResult;
  }

  onWebEvent(info: string): void {
    try {
      console.log('onWebEvent' + info);
      if (info != null) {
        let event: object = JSON.parse(info as string) as object;
        if (event['event'] == 'close') {
          //关闭
          this.controller.close()
        } else if (event['event'] == 'submit') {
          // 调用回调函数传递结果数据
          if (this.onResult) {
            // 假设 event 中包含结果数据，可根据实际结构调整
            let result: string = 'success';
            this.onResult(result);
          }
          this.controller.close()
        }
      }
    } catch (e) {
    }
    console.log('Web async string');
  }
}

/**
 * 问卷弹窗
 */
@CustomDialog
export struct VHQuestionnaireDialog {
  controller: CustomDialogController
  @Require surveyQuestionnaireUrl: string
  webviewController: webview.WebviewController = new webview.WebviewController();
  webObj: HarmonyObj | null = null;
  onResult?: (result: string) => void
  aboutToAppear() {
    if (!this.webObj) {
      this.webObj = new HarmonyObj(this.controller, this.onResult);
    }
  }
 //问答web
  build() {
    Column() {
      Column() {
        Scroll() {
          Web({
            src: this.surveyQuestionnaireUrl,
            controller: this.webviewController
          })
            .domStorageAccess(true)
            .onlineImageAccess(true)
            .imageAccess(true)
            .onControllerAttached(() => {
              this.webviewController.registerJavaScriptProxy(this.webObj, "harmonyObj", ["onWebEvent"]);
              this.webviewController.refresh();
            })
            .zoomAccess(false)
            .javaScriptAccess(true)
            .geolocationAccess(true)
            .mediaPlayGestureAccess(true)
            .databaseAccess(true)
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: '10%' })
      }
      .width('100%')
      .height('100%')
      // .backgroundColor("#48000000")

    }.width('100%')
    .height(500)
    .borderRadius({ topLeft: 10, topRight: 10 })
  }
}
