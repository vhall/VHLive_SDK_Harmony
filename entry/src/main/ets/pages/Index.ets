import { bundleManager } from '@kit.AbilityKit'
import { VHSaaSDK, VHCallBack } from '@vhall/vhall_live'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { promptAction } from '@kit.ArkUI'
import { preferences } from '@kit.ArkData'
import { BUNDLE_NAME } from 'BuildProfile';
import { ToastUtil } from 'watchkit/src/main/ets/action/ToastUtil'

@Entry
@Component
struct Index {
  private dataPreferences: preferences.Preferences | null = null;
  @State loginType: 'password' | 'thirdParty' = 'thirdParty' // 当前登录类型
  @State username: string = '' // 密码登录账号
  @State password: string = '' // 密码登录密码
  @State thirdPartyId: string = '123' // 三方登录ID
  @State thirdPartyPwd: string = '123' // 三方登录密码
  @State thirdPartyNickName: string = '' // 昵称
  @State thirdPartyHead: string =
    'https://cnstatic01.e.vhall.com/upload/user/avatar/57/72/577252bda8f072ef8e4dc680123c1651.jpg' // 三方登录头像 @State version: string = '';
  @State version: string = '';
  //测试

  @State app_key: string = '45d5d4a1b990b839834ac14efe478334';
  @State app_secret_key: string = 'f0b9773be74376ad8902244d13b77366';
  @State sign: string = '0E:E5:2E:78:16:1D:4B:59:13:58:DC:08:0E:43:68:4F:73:06:AB:A0:43:B0:1E:16:72:9C:B6:CD:84:B2:F8:FC';
  @State package: string = 'com.vhall.live';

  //正式
  // @State app_key: string = '338709eaaaa10eb50475333d31e39934';
  // @State app_secret_key: string = 'b0902b84e0c64125211a72d2718261d3';
  // @State sign: string = '0E:E5:2E:78:16:1D:4B:59:13:58:DC:08:0E:43:68:4F:73:06:AB:A0:43:B0:1E:16:72:9C:B6:CD:84:B2:F8:FC';
  // @State package: string = 'com.vhall.live';

  //私钥
  priKeyStr: string =
    "MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDL1AOACSzvVp6R4lzgvsgVJLQT5b84pCcFVFylgRKaM1Uk9u1C0IzgJ2Zo7g0kHfm6gCHrz33NdBqGsIswNXJtydR3HyI1y+vwjK/WeIdQfrnnQmLbohSoPsHp6g35Md+g07Cdo9C1zF/uIjJfKmpNSBhNRK8h7u66AQRWWwTltVVeZgph7Iwy0xgiNCe+KOiYKbHA0fUN5mFJDA+ag8hDxjYjt7qbOn2YyFsFGsJ5eSa3N9i9zjypJnbxfX2YwJDcVzugj+ngAdpUuMahvkSEMdWUbOq5z/c5aZyMT1X+zUpf3EMXMCjR4NQg6C83JjgnLWWS4Em6xJtV/Kj6LtTBAgMBAAECggEAHYZhWBS8LBJ4LLnv6eQ+IltAidilSYSfBwrF0s7ZYs8dvcQrm8U5gCdk570tLSFPG8tUs+Od8vqm9FddX3HWg1MRkjcceFNzd/2WY52Y6DmQdJBtYSg0utGVuuxFnZEHtjRZKIniq9A7cx4D/ZICIkitBdWgUsIuqsXb8CWwwL8wTYJ3S+6hLtSKuAOJDbiGOdXOdwKYga1w47Z6X6ybvdUC09Ssu+SnXMTVov2hfEFoGgYZUEisLsy9utCs+XMgVQXCq/LZ92k+LynyrlJaCaGTkt87zWjh5w1L8Na0lrkUo4eudcqgBCcPX2n/cuQrX4H/seWWRKxhfpde9RsICwKBgQDQrwYp50KwfjzQWO0tNHUVMl0r4AOMhzU9/hcc2ivUy8xF92PTdJiZUO7ZXira7AP0LJXsUXrfdMrxXTGIoz9mNeidxbpoNo5oKufUTSHsL/BIGCZVpnB9WvySRkDLIEWRWExKFkiTb32pPFu19ntOTkyGgh14baZhOvI/QqqBdwKBgQD6Cyc0+k7lbrk7hhrtN+j/Joi0+d7JIbdf1okvzMxWXvHBAzZdFEjXL5Z0xWzBvBhhtVHq4nxClIAld9zgoI54undFr5L+yP3vifHVD09LuP3o9m1HiIsGAOAG0FMwNXwDkTN8ZTSIrO0LH0NrfTNJSEN6let3LQBKEhmvDtuphwKBgQCxnYZ9e9wDJC7WlhmodBGDLQ6oHU5n+VyTmwRJBlhwEdWXZ2yLuZ14QK5KTB/lnSPwW1JvhRozvtBMhql2Rpvbft6yCm0R7f1fI8WVqODKijLU6dkW5UaxKxP1292iBaGwh5rHJBg5hJdLx5e3VEa262WuxmgW7BzEfMtalH9TGQKBgQColUB37ZOoCMEGquIYsit7a+Wb7yQQA5V5HlIcUj4qtZTVh27tzrFVtBYC4OD0tfbSWcfDT7Rrx2em22umX1nvd/jWmQvIkIb1K9JKzimuail3Gj6PjjX9dDWXInoT9NuKJCnMYwfKZpzjdM6l+CHN9NTaH55EGakqR43dg20CnQKBgHY72yo1f4n24F8Gk6LvL13lTVdoXYgcFmhCJIbsEkgSBUON8z7KanU2a5989WqAwUnjiq4Y8mPQgghvALFCOrsq4Na9xwfHH81HTBOshxh+54E0asQ0dIpkfTpIk2hV5gbIy4eRxB/7HiXhN269B2BdHQ3MptlcaEv4O24DgeDH";
  private isUserLogin: boolean = true;
  pathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      this.version = bundleInfo.versionName
    })

    // let options: preferences.Options = { name: 'room' };
    // this.dataPreferences = preferences.getPreferencesSync(this.getUIContext().getHostContext()?.getApplicationContext(), options);
    // this.app_key = this.dataPreferences.getSync("appKey", "") as string;
    // this.app_secret_key = this.dataPreferences.getSync("appSecretKey", "") as string;
    // this.sign = this.dataPreferences.getSync("sha1", "") as string;
    // this.package = this.dataPreferences.getSync("packageName", "") as string;
    // if (this.package.length == 0) {
    //   this.package = BUNDLE_NAME;
    // }

    //VHSaaSDK.getInstance().setRSAPrivateKey(this.priKeyStr);
    VHSaaSDK.getInstance().getVersion();
    VHSaaSDK.getInstance().init(this.getUIContext().getHostContext()?.getApplicationContext()! as Context, this.app_key,
      this.app_secret_key, this.sign, this.package, {
        // 成功
        onSuccess: (data: string | object) => {
        },

        // 失败
        onFailure: (errorCode: number, errorMsg: string) => {
          ToastUtil.showToast(errorMsg);
        }
      });
  }

  build() {
    Navigation(this.pathStack) {
      Flex({ direction: FlexDirection.Column }) {
        Row({ space: 20 }) {
          Button('签名设置', { type: ButtonType.Normal, stateEffect: true })
            .onClick(() => {
              console.info('Button onClick')
              let param: object = new Object()
              this.pathStack.pushPath({ name: 'KeySettingPage', param: param }, true);
            }).backgroundColor(Color.Red)
        }
        .width('100%')
        .padding(10)
        .justifyContent(FlexAlign.End)
        .flexGrow(1)

        Row({ space: 20 }) {
          Image($r('app.media.icon_login_logo'))
            .width('50%')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .flexGrow(3)

        Column() {
          // 密码登录表单
          if (this.loginType === 'password') {
            Column({ space: 20 }) {
              TextInput({ placeholder: '请输入用户名/手机号' })
                .onChange(val => this.username = val)
              TextInput({ placeholder: '请输入密码' })
                .type(InputType.Password)
                .onChange(val => this.password = val)
            }.margin(15)
          }

          // 三方登录表单
          if (this.loginType === 'thirdParty') {
            Column({ space: 20 }) {
              TextInput({ text: "123", placeholder: '三方用户ID' })
                .onChange(val => this.thirdPartyId = val)
              TextInput({ text: "123", placeholder: '昵称' })
                .onChange(val => this.thirdPartyPwd = val)
              TextInput({
                text: "https://cnstatic01.e.vhall.com/upload/user/avatar/57/72/577252bda8f072ef8e4dc680123c1651.jpg",
                placeholder: '头像地址'
              })
                .onChange(val => this.thirdPartyHead = val)
            }.margin(15)
          }

          // 登录方式切换
          Row() {
            Radio({ value: '密码登录', group: 'radioGroup' })
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  //需要执行的操作
                  this.loginType = 'password'
                }
              })
              .colorBlend(Color.Red)
            Text('密码登录')
            Radio({ value: '三方登录', group: 'radioGroup' })
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  //需要执行的操作
                  this.loginType = 'thirdParty';
                }
              })
              .colorBlend(Color.Red)
              .checked(true)
            Text('三方登录')
          }.margin(20)

          // 登录按钮
          Button('登录', { type: ButtonType.Capsule })
            .onClick(() => this.handleLogin())
            .width('90%')
            .height(40)
            .backgroundColor(Color.Red)
        }
        .flexGrow(6)


        Row({ space: 20 }) {
          Text('VhallSDKDemo ' + this.version).fontColor(Color.Red)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .flexGrow(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)
    }
    .hideToolBar(true)
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .mode(NavigationMode.Stack)
    .id('Login')
  }

  private handleLogin() {
    if (this.loginType === 'password') {
      // 调用密码登录接口
      console.log(`密码登录：${this.username} / ${this.password}`)
      //账号密码登录
      VHSaaSDK.getInstance().loginByAccount(this.username, this.password, "", {
        onSuccess: (data) => {
          hilog.debug(1, 'app', '清空上次的文档信息成功 === ' + data.toString());
          ToastUtil.showToast("登录成功");
          let param: object = new Object()
          this.pathStack.pushPath({ name: 'LiveEnterPage', param: param }, true);
        },
        onFailure: (errorCode, errorMsg) => {
          ToastUtil.showToast(errorMsg);
        }
      });
    } else {
      // 调用三方登录接口
      console.log(`三方登录：${this.thirdPartyId} / ${this.thirdPartyPwd}`)
      VHSaaSDK.getInstance().loginByThirdId(this.thirdPartyId, this.thirdPartyPwd, this.thirdPartyHead, {
        onSuccess: (data) => {
          hilog.debug(1, 'app', '清空上次的文档信息成功 === ' + data.toString());
          ToastUtil.showToast("登录成功");
          let param: object = new Object()
          this.pathStack.pushPath({ name: 'LiveEnterPage', param: param }, true);
        },
        onFailure: (errorCode, errorMsg) => {
          ToastUtil.showToast(errorMsg);
        }
      });
    }
  }
}