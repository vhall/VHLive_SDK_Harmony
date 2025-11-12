import { webview } from "@kit.ArkWeb";
import { PromptActionClass } from "../util/PromptActionClass";

const pageInfos: NavPathStack = new NavPathStack()

export class WebViewParams {
  title: string;
  loadUrl: string;

  constructor(title: string, loadUrl: string) {
    this.title = title;
    this.loadUrl = loadUrl;
  }
}

@Builder
export function WebViewPageBuilder(parm: WebViewParams) {
  WebViewPage({ title: parm.title, loadUrl: parm.loadUrl })
}

class HarmonyObj {
  constructor() {
  }

  onWebEvent(info: object): void {
    console.log('Web async string');
  }
}

@Entry
@Component
struct WebViewPage {
  @State title: string = '';
  @State loadUrl: string = "";
  webController: webview.WebviewController = new webview.WebviewController();
  pageInfos: NavPathStack = new NavPathStack();
  webObj: HarmonyObj = new HarmonyObj();

  build() {
    NavDestination() {
      Column() {
        // 顶部导航栏
        Row() {
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Image($r('app.media.close'))
              .width(24)
              .height(24)
          }
          .onClick(() => {
            PromptActionClass.closeDialog();
          })
          .backgroundColor('#F5F5F5')

          Text(this.title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .flexGrow(1)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        .shadow({ radius: 2, color: '#00000010' })

        Scroll() {
          Web({
            src: this.loadUrl,
            controller: this.webController
          })
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
        }
        .width('100%')
        .height('100%')
      }
      .onClick(() => {
        this.webController
      })
      .width('100%')
      .height('100%')
    }
    .hideToolBar(true)
    .hideTitleBar(true)
    .hideBackButton(true)
    .id('WebViewPage')
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack
    })
  }
}

    