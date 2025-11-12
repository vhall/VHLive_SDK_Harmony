import { common, Want } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { VHAgreementModel, VHPlayerConfig, VHSaaSDK, VHWebinarData } from '@vhall/vhall_live';
import { ComponentContent, promptAction } from '@kit.ArkUI';
import { WebViewPageBuilder, WebViewParams } from '../../pages/WebViewPage';
import { PromptActionClass } from '../../util/PromptActionClass';
import { ToastUtil } from '../../action/ToastUtil';
import { VHWebinarWatchModel } from '../model/VHWebinarWatchModel';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { EmitterMsgData, EmitterUtil } from '../../util/EmitterUtil';

@Builder
export function ForcedLoginPageBuilder(param: object) {
  ForcedLoginPage({
    webinar_info: param['webinars'],
    webinar_id: param['webinar_id'],
  })
}

@Component
struct ForcedLoginPage {
  private contentNode: ComponentContent<Object> | null = null;
  private webinar_info?: VHWebinarData;
  private webinar_id: string = ''
  private model: VHWebinarWatchModel = new VHWebinarWatchModel();
  pageInfos: NavPathStack = new NavPathStack() // 导航
  @State UserName: string = ''
  @State Password: string = ''
  @State isChecked: boolean = false

  // 打开链接
  private openLink(url: string) {
    const params = new WebViewParams('协议', url);
    this.contentNode = new ComponentContent(this.getUIContext(), wrapBuilder(WebViewPageBuilder), params);
    PromptActionClass.setContext(this.getUIContext());
    PromptActionClass.setContentNode(this.contentNode);
    PromptActionClass.setOptions({
      alignment: DialogAlignment.Center,
      offset: { dx: 0, dy: 50 },
      isModal: true,
      maskRect: {
        x: 0,
        y: 0,
        width: '100%',
        height: '100%'
      }
    });
    PromptActionClass.openDialog();
  }

  agreeAgreement() {
    VHSaaSDK.getInstance()
      .agreeAgreement(this.webinar_info?.webinar?.id.toString()!, '', '', '', {
        onSuccess: (data) => {
          console.log(data.toString());
        },
        onFailure: (errorCode: number, errorMsg: string) => {
          console.log(errorCode + ':' + errorMsg);
          ToastUtil.showToast(errorMsg);
        },
      });
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Blank()
          .height(200)
        Column({ space: 10 }) {
          Row() {
            Blank()
              .layoutWeight(1)
            Image($r('app.media.icon_close'))
              .width(16)
              .aspectRatio(1)
              .fillColor('#666')
              .onClick(() => {
                PromptActionClass.closeDialog();
                ToastUtil.showToast('取消登录')
              })
          }

          Text('密码登录')
            .fontSize(20)
            .fontWeight(600)
          TextInput({ placeholder: '请输入手机号/邮箱', text: $$this.UserName })
            .width('100%')
            .height(50)
            .backgroundColor(Color.Transparent)
            .border({ width: { bottom: 1 }, color: Color.Gray })
            .borderRadius(0)
          TextInput({ placeholder: '请输入登录密码', text: $$this.Password })
            .width('100%')
            .height(50)
            .backgroundColor(Color.Transparent)
            .borderRadius(0)
            .border({ width: { bottom: 1 }, color: Color.Gray })
          Blank()
            .height(10)
          Button('登录')
            .width('100%')
            .height(50)
            .backgroundColor('#fb2626')
            .borderRadius('50%')
            .onClick(() => {
              this.pageInfos.popToName('LiveEnterPage')
              //账号密码登录
              VHSaaSDK.getInstance().loginByAccount(this.UserName, this.Password, "", {
                onSuccess: (data) => {
                  hilog.debug(1, 'app', '清空上次的文档信息成功 === ' + data.toString());
                  this.getUIContext().getPromptAction().showToast({
                    message: "登录成功",
                    duration: 2000,
                    showMode: promptAction.ToastShowMode.DEFAULT,
                    bottom: 80
                  });
                  //调接口
                  this.agreeAgreement()
                  PromptActionClass.closeDialog();
                  //跳转
                  this.model.doGetPlayerConfig(this.webinar_id, {
                    onSucceed: (data: VHPlayerConfig) => {
                      this.agreeAgreement()
                      if (this.webinar_info?.webinar?.type == 1) {
                        // let param: object = new Object()
                        // param['webinars'] = this.webinar_info
                        // param['player_config'] = data;
                        // this.pageInfos.replacePath({ name: 'WatchLivePage', param: param }, true);
                        // setTimeout(() => {
                        //   PromptActionClass.closeDialog();
                        // }, 500)
                        let msgData: EmitterMsgData;
                        msgData = {
                          type: "toLivePage", // 消息类型
                          enable: true
                        } as EmitterMsgData;
                        // 通过EmitterUtil发送
                        EmitterUtil.send(msgData);
                        PromptActionClass.closeDialog();
                      }
                    },
                    onFailure: (errorCode, errorMsg) => {
                      PromptActionClass.closeDialog();
                      ToastUtil.showToast(errorMsg);
                    }
                  })
                },
                onFailure: (errorCode, errorMsg) => {
                  this.getUIContext().getPromptAction().showToast({
                    message: errorMsg,
                    duration: 2000,
                    showMode: promptAction.ToastShowMode.DEFAULT,
                    bottom: 80
                  });
                }
              })
            })
          Row() {
            Checkbox()
              .borderWidth(0)
              .selectedColor(Color.Red)
              .select($$this.isChecked)
            Text() {
              Span('已阅读并同意')
                .fontColor(Color.Gray)
              Span('《用户协议》')
                .onClick(() => {
                  this.openLink('https://live.vhall.com/v3/privacyUPo')
                })
              Span('《隐私协议》')
                .onClick(() => {
                  this.openLink('https://live.vhall.com/v3/privacyPolicy')
                })
            }
            .fontSize(14)
            .fontColor('#0094ff')
          }
        }
        .width('90%')
        .padding(20)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .hideToolBar(true)
    .hideTitleBar(true)
    .hideBackButton(true)
    .onDisAppear(() => {

    })

    // .position({ x: 0, y: -12 })
  }
}

