import { VHMyInviteDetail, VHMyInviteDetailList, VHSaaSDK, VHWebinarData } from '@vhall/vhall_live';
import { ToastUtil } from '../../action/ToastUtil';


/**
 * 我的邀请明细弹窗
 */
@CustomDialog
export struct VHInviteDetailDialog {
  controller: CustomDialogController
  @Require webinars: VHWebinarData;
  @Require selfDownloadSwitch: number;
  @State inviteDetails: VHMyInviteDetail[] = [];
  @State inviteDetailUrl: string = '';
  aboutToAppear() {
    this.getMyInviteDetails(this.webinars?.webinar!.id.toString(), this.webinars?.join_info!.user_id.toString(),
      this.webinars?.join_info!.user_id.toString(), '2');
  }

  getMyInviteDetails(sourceId: string, inviteId: string, businessUid: string, inviteIdType: string) {
    VHSaaSDK.getInstance()
      .getMyInviteDetails(sourceId, inviteId, businessUid, inviteIdType, {
        onSucceed: (data: VHMyInviteDetailList) => {
          this.inviteDetails = data?.list;
        },
        onFailure: (errorCode, errorMsg) => {
          console.log("获得我的邀请明细列表失败：", errorMsg)
          ToastUtil.showToast(`获得我的邀请明细列表失败： ${errorMsg}`);
        }
      });
  }

  getMyInviteDetailUrl(sourceId: string, inviteId: string, businessUid: string, inviteIdType: string) {
    VHSaaSDK.getInstance()
      .getMyInviteDetailUrl(sourceId, inviteId, businessUid, inviteIdType, {
        onSuccess: (data: string | object) => {
          this.inviteDetailUrl = data as string;
          ToastUtil.showToast("下载明细地址为：" + this.inviteDetailUrl);
        },
        onFailure: (errorCode, errorMsg) => {
          console.log("获得我的邀请明细URL失败：", errorMsg);
          ToastUtil.showToast("获得我的邀请明细URL失败：" + errorMsg);
        }
      });
  }


  build() {
    Column() {
      Column({space: 8}) {
        // 顶部区域
        Stack({ alignContent: Alignment.End }) {
          Text('我的邀请明细')
            .width('100%')
            .textAlign(TextAlign.Center)
            .fontSize(16)
          // 自定义的关闭
          Image($r('app.media.icon_close'))
            .width(15)
            .height(15)
            .margin(4)
            .fillColor(Color.Red)
            .onClick(() => {
              this.controller.close()
            })
        }
      }.width('100%')

      if (this.inviteDetails.length > 0)
      Column({space: 8}) {
        Row(){
          Text('用户名')
            .fontSize(12)
            .textAlign(TextAlign.Start)
            .padding(8)
            .width(150)
          Text('进入时间')
            .fontSize(12)
            .textAlign(TextAlign.Start)
            .padding(8)
            .width(150)
        }.width('100%').padding({left:40})
        ForEach(this.inviteDetails, (detail: VHMyInviteDetail, index) => {
          ListItem() {
            Row() {
              Text(detail.nickname)
                .fontSize(12)
                .textAlign(TextAlign.Start)
                .padding(8)
                .width(150)
              Text(detail.enter_time)
                .fontSize(12)
                .textAlign(TextAlign.Start)
                .padding(8)
                .width(150)
            }.width('100%').padding({left:40})
          }
        })
        Row() {
          if (this.selfDownloadSwitch == 1)
          Button('查看明细')
            .backgroundColor(Color.Red)
            .fontColor(Color.White)
            .fontSize(12)
            .width(80)
            .height(30)
            .onClick(() => {
              this.getMyInviteDetailUrl(this.webinars?.webinar!.id.toString(),
                this.webinars?.join_info!.user_id.toString(), this.webinars?.join_info!.user_id.toString(), '2');
            })
        }.width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({top: 180})
      }.width('100%')
      .height('300')
      .margin(10)

      if (this.inviteDetails.length == 0)
      Column() {
        Image($r('app.media.icon_empty'))
      }
      .width(200)
      .height(300)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }.width('100%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 10, topRight: 10 })
    .justifyContent(FlexAlign.Center)
  }
}