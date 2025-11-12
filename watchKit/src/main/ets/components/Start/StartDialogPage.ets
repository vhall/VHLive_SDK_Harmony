import { common, Want } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { VHAgreementModel, VHConfigList, VHPlayerConfig, VHSaaSDK, VHWebinarData } from '@vhall/vhall_live';
import { ComponentContent, promptAction } from '@kit.ArkUI';
import { WebViewPageBuilder, WebViewParams } from '../../pages/WebViewPage';
import { PromptActionClass } from '../../util/PromptActionClass';
import { ForcedLoginPageBuilder } from './ForcedLogin';
import { ToastUtil } from '../../action/ToastUtil';
import { VHWebinarWatchModel } from '../model/VHWebinarWatchModel';
import { EmitterMsgData, EmitterUtil } from '../../util/EmitterUtil';
import { VHIntroductionView } from '../introduction/VHIntroductionView';

// @Builder
// export function StartDialogPageBuilder(parm: VHAgreementModel,param:VHWebinarData) {
//   StartDialogPage({ agree: parm, webinar_info: param })
// }
@Builder
export function StartDialogPageBuilder(param: object) {
  StartDialogPage({
    agree: param['agree'],
    webinar_info: param['webinar_info'],
    webinar_id: param['webinar_id'],
  })
}

@Component
export struct StartDialogPage {
  // Controller: CustomDialogController
  private agree: VHAgreementModel = new VHAgreementModel
  private contentNode: ComponentContent<Object> | null = null;
  pageInfos: NavPathStack = new NavPathStack() // 导航
  private model: VHWebinarWatchModel = new VHWebinarWatchModel();
  private webinar_id: string = ''
  @State functionConfig: VHConfigList = new VHConfigList();
  private webinar_info?: VHWebinarData;
  @State time: number = 0;
  @State isScrollToBottom: boolean = false;

  aboutToAppear(): void {
    VHSaaSDK.getInstance()
      .permissionsCheck("3", this.webinar_info?.webinar?.id.toString()!,
        this.webinar_info?.webinar?.userinfo.user_id.toString()!, {
          onSucceed: (data: VHConfigList) => {
            this.functionConfig = data;
            console.log('获取功能配置成功: ' + JSON.stringify(data));
          },
          onFailure: (errorCode: number, errorMsg: string) => {
            console.error('获取功能配置失败: ' + JSON.stringify(errorMsg));
            ToastUtil.showToast(errorMsg);
          }
        });
    this.ReadingTime()
  }

  /**
   * 从富文本中提取<p>标签内的内容
   */
  formatContent(richText: string): string {
    // 检查输入是否为空
    if (!richText) {
      return "";
    }
    const startIndex = richText.indexOf("<p>");
    const endIndex = richText.indexOf("</p>");

    // 验证标签是否存在且格式正确（<p>在</p>之前）
    if (startIndex === -1 || endIndex === -1 || startIndex >= endIndex) {
      console.warn("富文本格式不符合要求，无法提取内容");
      return "";
    }
    // 提取<p>和</p>之间的内容（<p>长度为3，所以起始索引+3）
    return richText.substring(startIndex + 3, endIndex);
  }

  // 打开链接
  private openLink(url: string) {
    const params = new WebViewParams(this.agree.statement_info[0].title, url);
    this.contentNode = new ComponentContent(this.getUIContext(), wrapBuilder(WebViewPageBuilder), params);
    PromptActionClass.setContext(this.getUIContext());
    PromptActionClass.setContentNode(this.contentNode);
    PromptActionClass.setOptions({
      alignment: DialogAlignment.Bottom,
      offset: { dx: 0, dy: 40 },
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

  ForcedLoginDialog(param: object) {
    this.contentNode = new ComponentContent(this.getUIContext(), wrapBuilder(ForcedLoginPageBuilder), param);
    PromptActionClass.setContext(this.getUIContext());
    PromptActionClass.setContentNode(this.contentNode);
    PromptActionClass.setOptions({
      alignment: DialogAlignment.Center,
      offset: { dx: 0, dy: 0 },
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
          ToastUtil.showToast(errorMsg);
        },
      });
  }

  ReadingTime() {
    if (this.agree.agree_type == 2) {
      this.time = this.agree.agree_time
      const timer_id = setInterval(() => {
        this.time--
        if (this.time <= 0) {
          // let screenPoster = this.screenPoster as VHScreenPoster
          // screenPoster.status = 1
          clearInterval(timer_id)
        }
      }, 1000)
    }
  }

  startBrowsableAbility(context: common.UIAbilityContext, url?: string): void {
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

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Blank()
          .height(300)
        Column({ space: 10 }) {
          Row() {
            Blank()
              .layoutWeight(1)
            Image($r('app.media.close_gray'))
              .width(14)
              .aspectRatio(1)
              .fillColor('#666')
              .onClick(() => {
                PromptActionClass.closeDialog();
              })
          }
          .width('100%')

          Text(this.agree.title)
            .width('100%')
            .fontSize(18)
            .textAlign(TextAlign.Center)
            .margin({ bottom: 6 })
          // Text(this.formatContent(this.agree.content))
          //   .fontSize(14)
          Scroll() {
            Column({ space: 12 }) {
              VHIntroductionView({ introduction: this.agree.content })
                .width('100%')
              if (this.agree.statement_status == 1) {
                Text() {
                  // 分割文本，前面部分正常显示
                  Span(this.agree.statement_content.split(this.agree.statement_info[0].title)[0])
                    .fontSize(16)
                    .fontColor('#999999')
                  // 特殊文本“观看协议”，设置颜色、下划线并添加点击事件
                  Span(this.agree.statement_info[0].title)
                    .fontSize(16)
                    .fontColor('#007DFF') // 蓝色
                    .onClick(() => {
                      PromptActionClass.closeDialog()
                      const uri: string = this.agree.statement_info[0].link
                      // this.openLink(uri)
                      const context: common.UIAbilityContext =
                        this.getUIContext().getHostContext()! as common.UIAbilityContext;
                      this.startBrowsableAbility(context, uri);
                    })
                  // 后面部分正常显示
                  Span(this.agree.statement_content.split(this.agree.statement_info[0].title)[1])
                    .fontSize(16)
                    .fontColor('#999999')
                }
                .width('100%')
              } else {
                Text()
                  .height(10)
              }
            }
          }
          .width('100%')
          .height(220)
          .scrollBar(BarState.Off)
          .padding({ bottom: 12 })
          .onReachEnd(() => {
            this.isScrollToBottom = true;
          })

          if (this.agree.agree_type != 2) {
            if (this.agree.agree_type == 1) {
              Button('同意并继续')
                .width('100%')
                .backgroundColor(this.isScrollToBottom ? '#fb2626' : '#666')
                .onClick(() => {
                  if (this.isScrollToBottom) {
                    this.pageInfos.popToName('LiveEnterPage')
                    this.model.doGetPlayerConfig(this.webinar_id, {
                      onSucceed: (data: VHPlayerConfig) => {
                        this.agreeAgreement()
                        if (this.webinar_info?.webinar?.type == 1) {
                          // let param: object = new Object()
                          // param['webinars'] = this.webinar_info
                          // param['player_config'] = data;
                          // this.pageInfos.replacePath({ name: 'WatchLivePage', param: param }, true);

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
                  }
                })
            } else {
              Button('同意并继续')
                .width('100%')
                .backgroundColor('#fb2626')
                .onClick(() => {
                  this.pageInfos.popToName('LiveEnterPage')
                  this.model.doGetPlayerConfig(this.webinar_id, {
                    onSucceed: (data: VHPlayerConfig) => {
                      this.agreeAgreement()
                      if (this.webinar_info?.webinar?.type == 1) {
                        // let param: object = new Object()
                        // param['webinars'] = this.webinar_info
                        // param['player_config'] = data;
                        // this.pageInfos.replacePath({ name: 'WatchLivePage', param: param }, true);

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
                })
            }
          } else {
            Button(this.time > 0 ? `同意并继续(${this.time}s)` : `同意并继续`)
              .width('100%')
              .backgroundColor(this.time > 0 ? '#999' : '#fb2626')
              .onClick(() => {
                if (this.time > 0) {
                  ToastUtil.showToast('请阅读协议')
                } else {
                  // if (this.functionConfig.hard_login == 1) {
                  //   PromptActionClass.closeDialog()
                  //   let param: object = new Object()
                  //   param['webinars'] = this.webinar_info
                  //   param['webinar_id'] = this.webinar_id
                  //   this.ForcedLoginDialog(param)
                  // } else {
                  this.model.doGetPlayerConfig(this.webinar_id, {
                    onSucceed: (data: VHPlayerConfig) => {
                      this.agreeAgreement()
                      if (this.webinar_info?.webinar?.type == 1) {
                        let param: object = new Object()
                        param['webinars'] = this.webinar_info
                        param['player_config'] = data;
                        this.pageInfos.replacePath({ name: 'WatchLivePage', param: param }, true);
                      }
                    },
                    onFailure: (errorCode, errorMsg) => {
                      PromptActionClass.closeDialog();
                      this.getUIContext().getPromptAction().showToast({
                        message: errorMsg,
                        duration: 2000,
                        showMode: promptAction.ToastShowMode.DEFAULT,
                        bottom: 80
                      });
                    }
                  })
                }
              })
          }

        }
        .width('90%')
        .padding(20)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('92%')
  }
}

