import {
  VHAnnouncementData,
  VHAnnouncementNewsItem,
  VHAnnouncementServer,
  VHIMMessageModel,
  VHRoomEventType,
  VHSaaSDK
} from "@vhall/vhall_live";
import { ToastUtil } from "../action/ToastUtil";

import { EmitterMsgData, EmitterUtil } from "../util/EmitterUtil";

let Announcement_Room_id: string = ''

/*
 *公告UI弹窗
 * */
@Preview
@CustomDialog
  // @Component
export struct VHAnnouncementDialog {
  controller: CustomDialogController
  @Require server?: VHAnnouncementServer;
  @Consume AnnouncementList: VHAnnouncementNewsItem[]
  @Link announcementValue: string

  async aboutToAppear() {
    this.AnnouncementListHttp()
  }

  AnnouncementListHttp() {
    let total: number = 0
    VHSaaSDK.getInstance().performAnnouncementIn(Announcement_Room_id, total, 0, {
      onSucceed: (data) => {
        total = data.total
        this.AnnouncementList = data.list
      },
      onFailure: (errorCode, errorMsg) => {
        ToastUtil.showToast(errorMsg);
      }
    })
  }

  build() {
    Column() {
      // 头部标题
      Stack({ alignContent: Alignment.TopEnd }) {
        Column() {
          Text('公告')
            .width('100%')
            .textAlign(500)
            .fontSize(22)
            .textAlign(TextAlign.Center)
            .zIndex(2)
          Column()
            .width(45)
            .height(10)
            .backgroundColor('#fffcd4cf')
            .borderRadius(6)
        }
        .height(80)
        .justifyContent(FlexAlign.Center)
        .padding({ bottom: 15 })

        // 自定义的关闭
        Image($r('app.media.icon_close'))
          .width(16)
          .fillColor('#666')
          .onClick(() => {
            this.controller.close()
          })
      }
      .width('100%')
      .height(80)

      // 公告列表的展示
      List() {
        ForEach(this.AnnouncementList, (item: VHAnnouncementNewsItem, index) => {
          ListItem() {
            Column() {
              Text(item.content?.content || this.announcementValue)
                .fontSize(16)
                .margin({ bottom: 15 })
              Text(item.created_at)
                .fontSize(12)
            }
            .padding(14)
            .backgroundColor(Color.White)
            .borderRadius(6)
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
        })
        ListItem() {
          Column() {
            Text('没有更多数据')
              .fontSize(14)
              .fontColor('#ffaeabab')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)

        }
      }
      .width('94%')
      .height(260)
      .divider({ strokeWidth: 10, color: Color.Transparent })
      .scrollBar(BarState.Off)
      .margin({ bottom: 15 })
    }
    .padding(15)
    .borderRadius({ topLeft: 10, topRight: 10 })
    .linearGradient({
      angle: 90,
      colors: [['#fffcf1f7', 0.1], ['#ffe7dbf8', 0.9]]
    })
  }
}


//公告栏
@Component
export struct VHAnnouncementPopup {
  @State Animator: boolean = true;
  @Prop Announcement: string = ''
  @Consume announcementValue: string

  aboutToAppear(): void {
    this.AnnouncementText()
  }

  //获取公告信息
  AnnouncementText() {
    EmitterUtil.subscribe(VHRoomEventType.ROOM_ANNOUNCEMENT, (msgData: EmitterMsgData) => {
      console.log(`收到文本消息，类型：${VHRoomEventType.ROOM_ANNOUNCEMENT}`);
      let messageModel: VHIMMessageModel = msgData as VHIMMessageModel;
      if (messageModel.data!) {
        const parsedMessage: VHAnnouncementData = messageModel.data as VHAnnouncementData;
        //获取公告信息
        this.Announcement = parsedMessage.room_announcement_text
        Announcement_Room_id = parsedMessage.room_join_id
        //控制页面显示
        this.Animator = true
      }
    });
  }

  build() {
    if (this.Animator) {
      if (this.Announcement || this.announcementValue) {
        Row({ space: 10 }) {
          Image($r("app.media.icon_announcement"))
            .width(18)
            .fillColor('#f40')
          TextGradientView({ Announcement: this.Announcement || this.announcementValue })
            .layoutWeight(1)
          Image($r('app.media.icon_close'))
            .width(14)
            .onClick(() => {
              this.Animator = false
            })
        }
        .width('100%')
        .padding({ left: 10, right: 10 })
        .justifyContent(FlexAlign.SpaceBetween)
        .linearGradient({
          angle: 90,
          colors: [['#fffcf1f7', 0.1], ['#ffe7dbf8', 0.9]]
        })
        .position({ x: 0, y: 40 })
        .zIndex(99)
      }


    }

  }
}

//公告文字滚动
@Component
struct TextGradientView {
  @Prop Announcement: string = ''

  build() {
    Column() {
      Marquee({
        start: true,
        step: 6,
        loop: -1,
        fromStart: true,
        src: '                                                                        ' +
        this.Announcement + '              '
      })
        .marqueeUpdateStrategy(MarqueeUpdateStrategy.PRESERVE_POSITION)
        .width('auto')
        .fontColor('#666')
        .fontSize(14)
        .fontWeight(700)
        .backgroundColor(Color.Transparent)
    }
    .width('100%')
    .height(30)
    .justifyContent(FlexAlign.Center)
  }
}