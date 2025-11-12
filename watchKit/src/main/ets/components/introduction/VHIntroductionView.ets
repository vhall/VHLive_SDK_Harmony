import { webview } from '@kit.ArkWeb';
import { WantUtil } from '../../utils/WantUtil';

@Component
export struct VHIntroductionView {
  @Require introduction:string;
  @State title: string = '';
  @State loadUrl: string = "https://e.vhall.com";
  @State isLoading: boolean = false;
  webController: webview.WebviewController = new webview.WebviewController();
  pageInfos: NavPathStack = new NavPathStack();
  private hasCustomHeader: Set<string> = new Set()
  @State textData:string = "";

  private filePath:string = "";


  aboutToAppear(): void {
    this.textData = `data:text/html;charset=utf-8,${encodeURIComponent(`
        <!DOCTYPE html>
        <html>
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
          </head>
          <body>
            ${this.introduction}
          </body>
        </html>
      `)}`;
  }


  build() {
    Column() {
      Web({
        src: this.textData,
        controller: new webview.WebviewController()
      })
        .domStorageAccess(true)
        .onlineImageAccess(true)
        .imageAccess(true)
        .zoomAccess(false)
        .javaScriptAccess(true)
        .geolocationAccess(true)
        .mediaPlayGestureAccess(true)
        .databaseAccess(true)
        .onOverrideUrlLoading((webResourceRequest: WebResourceRequest) => {
          let url:string = webResourceRequest.getRequestUrl();
          //使用浏览器跳转展示隐私协议。
          WantUtil.toWebBrowser(url);
          return true;
        })
        .onErrorReceive(()=>{
        })
        .width('100%')
        .height('100%')
        .forceDisplayScrollBar(false)


    }
    .width('100%')
    .height('100%')
  }
}