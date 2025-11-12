import { webview } from "@kit.ArkWeb";
import { PromptActionClass } from "../util/PromptActionClass";
import { common, Want } from "@kit.AbilityKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { bundleManager } from "@kit.AbilityKit";
import { promptAction } from "@kit.ArkUI";

const pageInfos: NavPathStack = new NavPathStack()

export class GoodsWebViewParams {
  title: string;
  loadUrl: string;

  constructor(title: string, loadUrl: string) {
    this.title = title;
    this.loadUrl = loadUrl;
  }
}

@Builder
export function GoodsWebViewPageBuilder(parm: GoodsWebViewParams) {
  GoodsWebViewPage({ title: parm.title, loadUrl: parm.loadUrl })
}

class HarmonyObj {
  constructor() {
  }

  onWebEvent(info: object): void {
    console.log('Web async string');
  }
}

function startBrowsableAbility(context: common.UIAbilityContext, url?: string): void {
  let want: Want = {
    action: 'ohos.want.action.viewData',
    entities: ['entity.system.browsable'],
    uri: url || 'https://www.baidu.com/',
    parameters: {
      'ohos.ability.params.showDefaultPicker': true
    }
  };
  context.startAbility(want)
    .then(() => {
      console.error('Start browsableAbility successfully.');
    })
    .catch((err: BusinessError) => {
      console.error(`Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
    });
}

@Entry
@Component
struct GoodsWebViewPage {
  @State title: string = '';
  @State loadUrl: string = "";
  @State isLoading: boolean = false;
  webController: webview.WebviewController = new webview.WebviewController();
  pageInfos: NavPathStack = new NavPathStack();
  webObj: HarmonyObj = new HarmonyObj();
  private hasCustomHeader: Set<string> = new Set()

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
              this.webController.setCustomUserAgent('Mozilla/5.0 (Linux; Android 9; VRD-AL10; HMSCore 6.3.0.331) ' +
                'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.88 HuaweiBrowser/12.0.4.1 Mobile Safari/537.36')
            })
            .zoomAccess(false)
            .javaScriptAccess(true)
            .geolocationAccess(true)
            .mediaPlayGestureAccess(true)
            .databaseAccess(true)
            .onLoadIntercept((event) => {
              if (!event) {
                return
              }
              let url = event.data.getRequestUrl()
              url = event.data.getRequestUrl()
              url = event.data.getRequestUrl()
              if (url.includes("weixin://")) {
                let link: string = url

                try {
                  let data = bundleManager.canOpenLink(link);
                  if (data) {
                    let context: common.UIAbilityContext =
                      this.getUIContext().getHostContext() as common.UIAbilityContext;
                    // 仅以App Linking的方式打开应用
                    context.openLink(link, { appLinkingOnly: false }, (err, result) => {

                    })
                  } else {

                  }

                } catch (err) {
                  let message = (err as BusinessError).message;
                  promptAction.openToast({ message: `打开失败: ${message}` })
                }
                this.webController.loadUrl(
                  'about:blank', [{
                  headerKey: 'Referer',
                  headerValue: 'vhall.com'
                }])
                return true // 拦截原始请求
              }
              // if (this.isLoading) {
              //   const url = event.data.getRequestUrl()
              //   const context: common.UIAbilityContext =
              //     this.getUIContext().getHostContext()! as common.UIAbilityContext;
              //   startBrowsableAbility(context, url);
              //   return true
              // }
              if (event) {
                const url = event.data.getRequestUrl()
                // 判断是否已处理过该URL
                if (this.hasCustomHeader.has(url)) {
                  this.hasCustomHeader.delete(url)
                  return false // 放行已处理请求
                }
                // 重新加载URL并添加header
                this.webController.loadUrl(url, [{
                  headerKey: 'Referer',
                  headerValue: 'vhall.com'
                }])
                this.hasCustomHeader.add(url)
                this.isLoading = true
                return true // 拦截原始请求
              }
              return false
            })
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