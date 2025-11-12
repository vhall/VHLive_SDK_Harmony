
import { webview } from '@kit.ArkWeb';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { scanCore, scanBarcode } from '@kit.ScanKit';
// 导入默认界面需要的日志模块和错误码模块
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { bundleManager } from '@kit.AbilityKit';
import { JSON } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { VHSaaSDK, VHWebinarData } from '@vhall/vhall_live';


@Builder
export function H5LivePageBuilder(name: string, param: object) {
  VHH5LivePage({
    webinar_info: param['webinars']
  })
}

@Entry
@Component
struct VHH5LivePage {
  @State loadUrl: string ="";
  private webinar_info?: VHWebinarData;
  pageInfos: NavPathStack = new NavPathStack() // 导航
  controller: webview.WebviewController = new webview.WebviewController();
  aboutToAppear() {
    // 配置Web开启调试模式
    webview.WebviewController.setWebDebuggingAccess(true);
    this.loadUrl = VHSaaSDK.getInstance().getH5WebViewUrl(this.webinar_info?.webinar?.id.toString()!);
  }

  build() {
    NavDestination(){
      Web({ src:this.loadUrl, controller: this.controller })
        .domStorageAccess(true)
        .onlineImageAccess(true)
        .imageAccess(true)
        .onOverrideUrlLoading((webResourceRequest: WebResourceRequest) => {
          let url:string = webResourceRequest.getRequestUrl();
          //非当前观看页面，直接返回。如果是外链购买等需要进行页面跳转需要自行进行url解析。
          if(url.indexOf("https://live.vhou.tv/v3/lives/embedclientfull/watch") == 0
            || url.indexOf("https://live.vhou.tv/v3/lives/embedclient/watch") ){
            return false;
          }
          let index = url.indexOf("http");
          setInterval(() => {
            console.log('do every 1s.');
          }, 1000);
          AlertDialog.show({
            title: '外链购买地址',
            message: url,
            primaryButton: {
              value: 'confirm',
              action: () => {
                if(index == 0){
                  let link: string = "alipays://platformapi/startapp";
                  try {
                    if (link === 'imeituan') {//
                      // 美团的URL Scheme后面必须加上域名才能拉起美团
                      link += 'www.meituan.com'
                    } else {
                      // 已验证的其他URL Scheme后面加上home都可以拉起
                      link += 'home';
                    }
                    let data :boolean = bundleManager.canOpenLink(link);
                    if (data) {
                      let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
                      // 仅以App Linking的方式打开应用
                      context.openLink(link, { appLinkingOnly: false })
                        .then(() => {
                          hilog.info(0x0000, 'Testlog', 'openlink success.');
                        })
                        .catch((error: BusinessError) => {
                          promptAction.showDialog({ message: `打开失败: ${error.name}` })
                          console.error(`openlink failed. error:${JSON.stringify(error)}`);
                        });
                    } else {
                      promptAction.showDialog({ message: `暂无可用打开方式` })
                    }
                    hilog.info(0x0000, 'testTag', 'canOpenLink successfully: %{public}s', JSON.stringify(data));
                  } catch (err) {
                    let message = (err as BusinessError).message;
                    promptAction.showDialog({ message: `打开失败: ${message}` })
                    hilog.error(0x0000, 'testTag', 'canOpenLink failed: %{public}s', message);
                  }
                }
              }
            },
            secondaryButton: {
              value: 'cancel',
              action: () => {

              }
            },
            cancel: () => {

            }
          })
          return true;
        })
        .zoomAccess(false)
        .javaScriptAccess(true)
        .geolocationAccess(true)
        .mediaPlayGestureAccess(true)
        .databaseAccess(true)
        .onPermissionRequest((event) => {
          let atManager = abilityAccessCtrl.createAtManager();
          atManager.requestPermissionsFromUser(getContext(this), ['ohos.permission.CAMERA', 'ohos.permission.MICROPHONE'])
            .then((data) => {
              console.info('data:' + JSON.stringify(data));
              console.info('data permissions:' + data.permissions);
              console.info('data authResults:' + data.authResults);
              if (event) {
                event.request.grant(event.request.getAccessibleResource());
              }
            }).catch((error: BusinessError) => {
            console.error(`Failed to request permissions from user. Code is ${error.   code}, message is ${error.  message}`);
          })
        })
    }
    .width('100%')
    .height('100%')
    .hideToolBar(true)
    .hideTitleBar(true)
    .hideBackButton(true)
    .id('H5Page')
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack
    })

  }
}