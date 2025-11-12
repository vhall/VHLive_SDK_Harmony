import { scanBarcode, scanCore } from '@kit.ScanKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';
import { preferences } from '@kit.ArkData';
import { BUNDLE_NAME } from 'BuildProfile';
import { DecryptUtil } from '../utils/DecryptUtil';
import { VHSaaSDK } from '@vhall/vhall_live';

@Builder
export function KeySettingPageBuilder(name: string, param: object) {
  KeySettingPage()
}

@Entry
@Component
struct KeySettingPage {
  private dataPreferences: preferences.Preferences | null = null;
  @State message: string = 'Hello World';
  pageInfos: NavPathStack = new NavPathStack() // 导航
  @State appKey:string = "";
  @State appSecretKey:string = "";
  @State sha256:string = "";
  @State packageName:string = "";
  private decryptKey:string = "EDaaff63bcB4d4M9";

  aboutToAppear(): void {
    let options: preferences.Options = { name: 'room' };
    this.dataPreferences =
      preferences.getPreferencesSync(this.getUIContext().getHostContext()?.getApplicationContext(), options);
    this.appKey = this.dataPreferences.getSync("appKey", "") as string;
    this.appSecretKey = this.dataPreferences.getSync("appSecretKey", "") as string;
    this.sha256 = this.dataPreferences.getSync("sha1", "") as string;
    this.packageName = this.dataPreferences.getSync("packageName", "") as string;
    if (this.packageName.length == 0) {
      this.packageName = BUNDLE_NAME;
    }
  }

  build() {
    NavDestination() {
      Column({ space: 20 }) {
        Button('点击扫码')
          .fontWeight(FontWeight.Bold)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .onClick(() => {
            // 定义扫码参数options
            let options: scanBarcode.ScanOptions = {
              scanTypes: [scanCore.ScanType.ALL],
              enableMultiMode: true,
              enableAlbum: true
            };
            try {
              // 可调用getContext接口获取当前页面关联的UIAbilityContext
              scanBarcode.startScanForResult(this.getUIContext().getHostContext(), options).then((result: scanBarcode.ScanResult) => {
                // 解析码值结果跳转应用服务页
                hilog.info(0x0001, '[Scan CPSample]',
                  `Succeeded in getting ScanResult by promise with options, result is ${JSON.stringify(result)}`);
                // 解密
                let decryptStr = DecryptUtil.decrypt(this.decryptKey, result.originalValue);
                if (decryptStr.length > 0) {
                  let decryptOjb: object = JSON.parse(decryptStr) as object;
                  this.appKey = decryptOjb["a"].toString();
                  this.appSecretKey = decryptOjb["as"].toString();
                  this.sha256 = decryptOjb["hs"].toString();
                  this.packageName = decryptOjb["hb"].toString();
                }
              }).catch((error: BusinessError) => {
                hilog.error(0x0001, '[Scan CPSample]',
                  `Failed to get ScanResult by promise with options. Code:${error.code}, message: ${error.message}`);
              });
            } catch (error) {
              hilog.error(0x0001, '[Scan CPSample]',
                `Failed to start the scanning service. Code:${error.code}, message: ${error.message}`);
            }
          })

        Text("基本信息: 打开控制台页面，点击 运营设置-》开发设置，可进行二维码扫码")
        Text("AppKey")
        TextInput({ text: this.appKey }).onChange(val => this.appKey = val)
        Text("App SecretKey")
        TextInput({ text: this.appSecretKey }).onChange(val => this.appSecretKey = val)
        Text("安全码")
        TextInput({ text: this.sha256 }).onChange(val => this.sha256 = val)
        Text("包名")
        TextInput({ text: this.packageName }).onChange(val => this.packageName = val)
        Button('确定').onClick((event) => {
          this.dataPreferences?.putSync('appKey', this.appKey);
          this.dataPreferences?.flushSync();
          this.dataPreferences?.putSync('appSecretKey', this.appSecretKey);
          this.dataPreferences?.flushSync();
          this.dataPreferences?.putSync('sha1', this.sha256);
          this.dataPreferences?.flushSync();
          this.dataPreferences?.putSync('packageName', this.packageName);
          this.dataPreferences?.flushSync();


          VHSaaSDK.getInstance().init(this.getUIContext().getHostContext()?.getApplicationContext()! as Context, this.appKey,
            this.appSecretKey,  this.sha256, this.packageName, {
              // 成功
              onSuccess: (data: string | object) => {
              },

              // 失败
              onFailure: (errorCode: number, errorMsg: string) => {
              }
            });

          this.pageInfos.pop();
        })
      }
      .alignItems(HorizontalAlign.Start)
      .width('90%')
      .height('100%')
    }
    .hideToolBar(true)
    // .hideTitleBar(true,false)
    .hideBackButton(true)
    .id('LiveEnterPage')
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack
    })
    .height('100%')
    .width('100%')
  }
}