import { VHAgreement, VHPlayerConfig, VHSaaSDK, VHScreenPoster, VHWebinarData } from "@vhall/vhall_live";
import { common, Want } from "@kit.AbilityKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { PromptActionClass } from "watchkit";
import { promptAction } from "@kit.ArkUI";
import { VHWebinarWatchModel } from "../model/VHWebinarWatchModel";
import { ToastUtil } from "watchkit/src/main/ets/action/ToastUtil";

@Builder
export function InvitationCardBuilder(name: string, param: object) {
  InvitationCard(
    {
      webinar_info: param['webinars'],
      screenPoster: param['screenPoster'],
      webinar_id: param['webinar_id'],
      nick_name: param['nick_name'],
      h5Live: param['h5Live'],
    }
  )
}


@Preview
@Component
export struct InvitationCard {
  private webinar_info?: VHWebinarData;
  @State time: number = 5
  private screenPoster?: VHScreenPoster
  private model: VHWebinarWatchModel = new VHWebinarWatchModel();
  private webinars?: VHWebinarData;
  private webinar_id: string = '';
  private nick_name: string = '';
  private h5Live: boolean = false;
  private contentNode: ComponentContent<Object> | null = null;
  pageInfos: NavPathStack = new NavPathStack() // 导航

  aboutToAppear(): void {
    if (this.screenPoster?.shutdown_type == 1) {
      const timer_id = setInterval(() => {
        this.time--
        if (this.time <= 0) {
          // let screenPoster = this.screenPoster as VHScreenPoster
          // screenPoster.status = 1
          this.initWebinar()
          clearInterval(timer_id)
        }
      }, 1000)
    }
  }

  initWebinar() {
    PromptActionClass.setContext(this.getUIContext());
    PromptActionClass.setContentNode(this.contentNode!);
    PromptActionClass.setOptions({
      alignment: DialogAlignment.Center,
      isModal: true,
      maskRect: {
        x: 0,
        y: 0,
        width: '100%',
        height: '100%'
      }
    });
    PromptActionClass.openDialog();
    this.model.doInitWatch(this.webinar_id, "", this.nick_name, {
      onSucceed: (data: VHWebinarData) => {
        this.webinars = data;
        if (this.webinars.join_info?.is_kick == 1) {
          ToastUtil.showToast("您已被踢出房间");
          return
        }
        this.model.doGetPlayerConfig(this.webinar_id, {
          onSucceed: (data: VHPlayerConfig) => {
            PromptActionClass.closeDialog();
            //预约状态或者有观看验证的情况但是没有通过。则跳到预约页面
            if (this.h5Live) {
              let param: object = new Object()
              param['webinars'] = this.webinars;
              this.pageInfos.replacePath({ name: 'VHH5LivePage', param: param },
                { launchMode: LaunchMode.MOVE_TO_TOP_SINGLETON })
            } else if (this.webinars?.webinar?.type == 2 ||
              ((this.webinars?.webinar?.verify == 1 || this.webinars?.webinar?.verify == 2) &&
                this.webinars.join_info?.verified == 0)) {
              let param: object = new Object()
              param['webinars'] = this.webinars;
              param['player_config'] = data;
              this.pageInfos.replacePath({ name: 'ReservationPage', param: param },
                { launchMode: LaunchMode.MOVE_TO_TOP_SINGLETON })
            } else if (this.webinars?.webinar?.type == 4 || this.webinars?.webinar?.type == 5) {
              let param: object = new Object()
              param['webinars'] = this.webinars;
              param['player_config'] = data;
              this.pageInfos.replacePath({ name: 'WatchVodPage', param: param },
                { launchMode: LaunchMode.MOVE_TO_TOP_SINGLETON })
            } else if (this.webinars?.webinar?.type == 1) {
              let param: object = new Object()
              param['webinars'] = this.webinars
              param['player_config'] = data;
              param['webinar_id'] = this.webinar_id;
              this.pageInfos.replacePath({ name: 'WatchLivePage', param: param }, true);
            } else if (this.webinars?.webinar?.type == 3) {
              ToastUtil.showToast("直播已结束");
            }
          },
          onFailure: (errorCode, errorMsg) => {
            PromptActionClass.closeDialog();
            ToastUtil.showToast(errorMsg);
          }
        })
      },
      onFailure: (errorCode, errorMsg) => {
        PromptActionClass.closeDialog();
        ToastUtil.showToast(errorMsg);
      }
    });
  }

  startBrowsableAbility(context: common.UIAbilityContext): void {
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: this.screenPoster?.url,
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
    NavDestination() { // 必须作为根组件
      if (this.screenPoster?.status != 1) {
        Stack({ alignContent: Alignment.TopEnd }) {
          Image(this.screenPoster?.m_img)
            .width('100%')
            .height('100%')
            .syncLoad(true)
            .onClick(() => {
              const context: common.UIAbilityContext =
                this.getUIContext().getHostContext()! as common.UIAbilityContext;
              this.startBrowsableAbility(context);
            })
          if (this.screenPoster?.shutdown_type == 1) {
            Row() {
              Text(`${this.time} 秒后关闭`)
                .fontSize(14)
                .padding(8)
            }
            .backgroundColor('rgba(160, 160, 160, 0.89)')
            .borderRadius('50%')
            .margin({ top: 20, right: 15 })
            .onClick(() => {
              //关闭
              // let screenPoster = this.screenPoster as VHScreenPoster
              // screenPoster.status = 1
              this.initWebinar();
            })
          } else {
            Row() {
              Text('点击关闭')
                .fontSize(14)
                .padding(8)
            }
            .backgroundColor('rgba(160, 160, 160, 0.89)')
            .borderRadius('50%')
            .margin({ top: 20, right: 15 })
            .onClick(() => {
              //关闭
              // let screenPoster = this.screenPoster as VHScreenPoster
              // screenPoster.status = 1
              this.initWebinar();
            })
          }


        }
      }
    }
    .width('100%')
    .height('100%')
    .hideToolBar(true)
    .hideTitleBar(true)
    .hideBackButton(true)
    .id('InvitationCard')
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack
    })
  }
}