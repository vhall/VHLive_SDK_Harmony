import { bundleManager, common } from '@kit.AbilityKit'
import { VHSaaSDK, VHCallBack, VHWatchAuthInfo, VHUploadFileInfo } from '@vhall/vhall_live'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { App, promptAction } from '@kit.ArkUI'
import { preferences } from '@kit.ArkData'
import { BUNDLE_NAME } from 'BuildProfile';
import { ToastUtil } from 'watchkit/src/main/ets/action/ToastUtil'
import { picker } from '@kit.CoreFileKit'
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS'
import { BusinessError } from '@kit.BasicServicesKit'
import { image } from '@kit.ImageKit'

@Entry
@Component
struct Index {
  private dataPreferences: preferences.Preferences | null = null;
  @State loginType: 'password' | 'thirdParty' | 'role' = 'thirdParty' // 当前登录类型
  @State username: string = '' // 密码登录账号
  @State password: string = '' // 密码登录密码
  @State thirdPartyId: string = '' // 三方登录ID
  @State thirdPartyPwd: string = '' // 三方登录密码
  @State roleId: string = '' // 口令登录ID
  @State rolePwd: string = '' // 口令登录密码
  @State roleType: string = '1' // 口令登录类型 角色（1-主持人，2-嘉宾）
  @State webinar_id: string = '' // 活动ID
  @State visitor_id: string = ''
  @State thirdPartyNickName: string = '' // 昵称
  @State thirdPartyHead: string = 'https://cnstatic01.e.vhall.com/upload/user/avatar/57/72/577252bda8f072ef8e4dc680123c1651.jpg'
  // 三方登录头像 @State version: string = '';
  @State roleHead: string = 'https://cnstatic01.e.vhall.com/upload/user/avatar/57/72/577252bda8f072ef8e4dc680123c1651.jpg' // 口令登录头像
  @State uploadHead: string = ''
  @State version: string = '';
  @State roleSelect: boolean = false
  @State envApp:string = "0";
   @State app_key: string = '';
   @State app_secret_key: string = '';
   @State sign: string = '';
   @State package: string = 'com.vhall.vhlive';

  //私钥
//  priKeyStr: string = "MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDL1AOACSzvVp6R4lzgvsgVJLQT5b84pCcFVFylgRKaM1Uk9u1C0IzgJ2Zo7g0kHfm6gCHrz33NdBqGsIswNXJtydR3HyI1y+vwjK/WeIdQfrnnQmLbohSoPsHp6g35Md+g07Cdo9C1zF/uIjJfKmpNSBhNRK8h7u66AQRWWwTltVVeZgph7Iwy0xgiNCe+KOiYKbHA0fUN5mFJDA+ag8hDxjYjt7qbOn2YyFsFGsJ5eSa3N9i9zjypJnbxfX2YwJDcVzugj+ngAdpUuMahvkSEMdWUbOq5z/c5aZyMT1X+zUpf3EMXMCjR4NQg6C83JjgnLWWS4Em6xJtV/Kj6LtTBAgMBAAECggEAHYZhWBS8LBJ4LLnv6eQ+IltAidilSYSfBwrF0s7ZYs8dvcQrm8U5gCdk570tLSFPG8tUs+Od8vqm9FddX3HWg1MRkjcceFNzd/2WY52Y6DmQdJBtYSg0utGVuuxFnZEHtjRZKIniq9A7cx4D/ZICIkitBdWgUsIuqsXb8CWwwL8wTYJ3S+6hLtSKuAOJDbiGOdXOdwKYga1w47Z6X6ybvdUC09Ssu+SnXMTVov2hfEFoGgYZUEisLsy9utCs+XMgVQXCq/LZ92k+LynyrlJaCaGTkt87zWjh5w1L8Na0lrkUo4eudcqgBCcPX2n/cuQrX4H/seWWRKxhfpde9RsICwKBgQDQrwYp50KwfjzQWO0tNHUVMl0r4AOMhzU9/hcc2ivUy8xF92PTdJiZUO7ZXira7AP0LJXsUXrfdMrxXTGIoz9mNeidxbpoNo5oKufUTSHsL/BIGCZVpnB9WvySRkDLIEWRWExKFkiTb32pPFu19ntOTkyGgh14baZhOvI/QqqBdwKBgQD6Cyc0+k7lbrk7hhrtN+j/Joi0+d7JIbdf1okvzMxWXvHBAzZdFEjXL5Z0xWzBvBhhtVHq4nxClIAld9zgoI54undFr5L+yP3vifHVD09LuP3o9m1HiIsGAOAG0FMwNXwDkTN8ZTSIrO0LH0NrfTNJSEN6let3LQBKEhmvDtuphwKBgQCxnYZ9e9wDJC7WlhmodBGDLQ6oHU5n+VyTmwRJBlhwEdWXZ2yLuZ14QK5KTB/lnSPwW1JvhRozvtBMhql2Rpvbft6yCm0R7f1fI8WVqODKijLU6dkW5UaxKxP1292iBaGwh5rHJBg5hJdLx5e3VEa262WuxmgW7BzEfMtalH9TGQKBgQColUB37ZOoCMEGquIYsit7a+Wb7yQQA5V5HlIcUj4qtZTVh27tzrFVtBYC4OD0tfbSWcfDT7Rrx2em22umX1nvd/jWmQvIkIb1K9JKzimuail3Gj6PjjX9dDWXInoT9NuKJCnMYwfKZpzjdM6l+CHN9NTaH55EGakqR43dg20CnQKBgHY72yo1f4n24F8Gk6LvL13lTVdoXYgcFmhCJIbsEkgSBUON8z7KanU2a5989WqAwUnjiq4Y8mPQgghvALFCOrsq4Na9xwfHH81HTBOshxh+54E0asQ0dIpkfTpIk2hV5gbIy4eRxB/7HiXhN269B2BdHQ3MptlcaEv4O24DgeDH";
  private isUserLogin: boolean = true;
  pathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      this.version = bundleInfo.versionName
    })



    let options: preferences.Options = { name: 'room' };
    this.dataPreferences = preferences.getPreferencesSync(this.getUIContext().getHostContext()?.getApplicationContext(), options);
    this.app_key = this.dataPreferences.getSync("appKey", "") as string;
    this.visitor_id = this.dataPreferences.getSync("visitor_id", "") as string;
    this.app_secret_key = this.dataPreferences.getSync("appSecretKey", "") as string;
    this.sign = this.dataPreferences.getSync("sha1", "") as string;
    this.package = this.dataPreferences.getSync("packageName", "") as string;
    if (this.package.length == 0) {
      this.package = BUNDLE_NAME;
    }

    VHSaaSDK.getInstance().setEnv(false);
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

          Text("测试环境")
          Toggle({ type: ToggleType.Switch, isOn: this.envApp == "1" ? true : false })
            .onChange((isOn: boolean) => {
              if(isOn) {
                VHSaaSDK.getInstance().setEnv(true);
                this.dataPreferences?.putSync("evn", "1");
                this.dataPreferences?.flushSync();
              }
              else{
                VHSaaSDK.getInstance().setEnv(false);
                this.dataPreferences?.putSync("env", "0") ;
                this.dataPreferences?.flushSync();
              }
              let context = getContext() as common.UIAbilityContext;
              // context.terminateSelf();
            })

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

          // 口令登录表单
          if (this.loginType === 'role') {
            Column({ space: 20 }) {
              Row(){
                Image(this.roleHead)
                  .width(80)
                  .height(80)
                  .borderRadius(40)
              }
              .width(80)
              .height(80)
              .borderRadius(40)
              .backgroundColor("#eeeeee")
              .onClick(() => {
                this.selectImage();
              })
              TextInput({ text: "123gg", placeholder: '姓名' })
                .onChange(val => this.roleId = val)
              TextInput({ text: "111111", placeholder: '口令（6位）' })
                .onChange(val => this.rolePwd = val)
              TextInput({ text: "298183034", placeholder: '活动ID' })
                .onChange(val => this.webinar_id = val)
            }.margin(15)
          }

          // 登录方式切换
          Row() {
            Radio({ value: '密码登录', group: 'radioGroup' })
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  //需要执行的操作
                  this.loginType = 'password';
                  this.roleSelect = false;
                }
              })
              .colorBlend(Color.Red)
            Text('密码登录')
            Radio({ value: '三方登录', group: 'radioGroup' })
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  //需要执行的操作
                  this.loginType = 'thirdParty';
                  this.roleSelect = false;
                }
              })
              .colorBlend(Color.Red)
              .checked(true)
            Text('三方登录')
            Column(){
              Text('口令登录')
                .onClick(() => {
                  this.roleSelect = !this.roleSelect
                })
              if(this.roleSelect){
                Column({space: 10}){
                  Row(){
                    Radio({ value: '主持人登录', group: 'radioGroup' })
                      .onChange((isChecked: boolean) => {
                        if (isChecked) {
                          //需要执行的操作
                          this.loginType = 'role';
                          this.roleType = '1';
                        }
                      })
                      .colorBlend(Color.Red)
                    Text('主持人登录')
                  }
                  Row(){
                    Radio({ value: '嘉宾登录', group: 'radioGroup' })
                      .onChange((isChecked: boolean) => {
                        if (isChecked) {
                          //需要执行的操作
                          this.loginType = 'role';
                          this.roleType = '2';
                        }
                      })
                      .colorBlend(Color.Red)
                    Text('嘉宾登录')
                  }
                }
                .position({top: 30, left: -30})
              }
            }
            .padding({left: 10})
          }.margin(20)




          // 登录按钮
          Button('登录', { type: ButtonType.Capsule })
            .onClick(() => this.handleLogin())
            .width('90%')
            .height(40)
            .margin({top: 60})
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
    } else if(this.loginType === 'role'){
      console.log(`口令登录：${this.roleType} / ${this.roleId} / ${this.rolePwd}`)
      VHSaaSDK.getInstance().loginByRole(this.webinar_id, this.roleType, this.rolePwd, this.roleId, this.uploadHead, this.visitor_id, {
        onSuccess: (data) => {
          this.dataPreferences?.putSync("visitor_id", data);
          this.dataPreferences?.flushSync();
          this.visitor_id = data as string;
          if(this.roleType === '1'){
            let param: object = new Object();
            param['webinar_id'] = this.webinar_id;
            param['nick_name'] = this.roleId;
            this.pathStack.pushPath({ name: 'HostLivePage', param: param }, true);
          } else {
            let param: object = new Object();
            param['webinar_id'] = this.webinar_id;
            param['nick_name'] = this.roleId;
            this.pathStack.pushPath({ name: 'GuestLivePage', param: param }, true);
          }
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

  private async selectImage() {
    // 1. 打开相册选择图片
    try {
      // 1. 打开相册选择图片（异步）
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      const photoPicker = new picker.PhotoViewPicker();
      const res: picker.PhotoSelectResult = await photoPicker.select(photoSelectOptions); // 使用 await 等待结果
      let bufferStr: string = '';
      if (res && res.photoUris && res.photoUris.length > 0) {
        // 读取图片
        const uri = res.photoUris[0];
        const file = fs.openSync(uri)
        const stat = fs.statSync(file.fd)
        const buffer = new ArrayBuffer(stat.size)
        fs.readSync(file.fd, buffer)
        fs.closeSync(file)
        let decodingOptions: image.DecodingOptions = { editable: true };
        let imageSource: image.ImageSource = image.createImageSource(buffer);
        imageSource.createPixelMap(decodingOptions).then(async (originalPixelMap: image.PixelMap) => {
          // 使用scale对图片进行缩放。入参分别为图片宽高的缩放倍数
          originalPixelMap.scaleSync(0.5,0.5)
          let dstBuffer = await this.packing(originalPixelMap,20,"jpeg");
          // 3. 转成base64编码的字符串
          const helper = new util.Base64Helper()
          bufferStr = helper.encodeToStringSync(new Uint8Array(dstBuffer));
          bufferStr = "data:image/png;base64," + bufferStr;
          if (bufferStr.length > 0) {
            VHSaaSDK.getInstance().uploadImage(bufferStr, {
              onSucceed: (data: VHUploadFileInfo) => {
                this.roleHead = data.domain_url;
                this.uploadHead = data.file_url.split('?')[0];
              },
              onFailure: (errorCode: number, errorMsg: string) => {
                console.log("上传图片二进制流失败：", errorMsg);
                ToastUtil.showToast("图片发送失败:" + errorMsg);
              }
            });
          }
        }).catch((err: BusinessError) => {
          console.error("图片选择失败:", JSON.stringify(err));
          ToastUtil.showToast("图片选择失败!");
        });
      }
    } catch (error) {
      console.error("图片选择失败:", error);
      ToastUtil.showToast("图片选择失败!");
    }
  }


  /**
   * packing压缩
   * @param sourcePixelMap 原始待压缩图片的PixelMap
   * @param imageQuality 图片质量参数
   * @param packingFormat 目标格式。当前只支持"image/jpeg"、"image/webp" 和 "image/png"
   * @returns data 返回压缩后的图片数据
   */
  async packing(sourcePixelMap: image.PixelMap, imageQuality: number, packingFormat: string): Promise<ArrayBuffer> {
    const imagePackerApi = image.createImagePacker();
    const packOpts: image.PackingOption = { format: 'image/' + packingFormat, quality: imageQuality };
    const data: ArrayBuffer = await imagePackerApi.packing(sourcePixelMap, packOpts);
    return data;
  }

}