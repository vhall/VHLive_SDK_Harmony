import { ToastUtil } from "../action/ToastUtil";
import {
  VHIMServer,
  VHLotteryCarryOut,
  VHLotteryCondition,
  VHLotteryList,
  VHLotteryResultNoticeModel,
  VHSaaSDK,
  VHWinnerInformation,
  VHWinnerInformationItem
} from '@vhall/vhall_live';
import { JSON } from '@kit.ArkTS';
import { EmitterMessage } from "../components/common/EmitterMessage";
import MsgType from "../constants/MsgType";
import { EmitterMsgData, EmitterUtil } from "../util/EmitterUtil";

/*
 *抽奖弹窗
 * */
@Component
export struct LotteryDialog {
  @State icon: ResourceStr = ''
  //关闭弹窗
  @State closeDialog: boolean = true
  @State lottery_status: number = 0
  @State type: string = 'lottery_result_notice'
  @Consume lotteryPush: VHLotteryResultNoticeModel | null
  @Prop LotteryCarryOut: VHLotteryCarryOut = new VHLotteryCarryOut();
  @Link LotteryStatus: boolean
  @Prop room_id: string = ''

  // aboutToAppear(): void {
  //   LotteryData()
  // }
  aboutToDisappear(): void {
    this.lotteryPush = null
  }

  Participation(lottery_id: string) {
    VHSaaSDK.getInstance().lotteryJoin(this.room_id, lottery_id, {
      onSuccess: (data) => {
        ToastUtil.showToast('参与抽奖成功')
      },
      onFailure: (errorCode, errorMsg) => {
        console.log(`参与抽奖失败：${errorMsg}`)
      }
    })
  }

  build() {
    Column() {
      if (this.closeDialog) {
        Column({ space: 10 }) {
          if (this.lotteryPush != null) {
            //展示抽奖动效
            Image(`https:${this.lotteryPush.icon}` ?? $r('app.media.icon_lottery_bg'))
              .width(260)
            if (this.lotteryPush.lottery_type == 8) {
              Button('立即发送口令')
                .backgroundColor('#f40')
                .fontColor(Color.White)
                .onClick(() => {
                  let msgData: EmitterMsgData;
                  msgData = {
                    type: MsgType.LOTTERY_MSG,
                    data: this.lotteryPush?.command
                  } as EmitterMsgData;
                  EmitterUtil.send(msgData);

                  this.Participation(this.lotteryPush!.lottery_id.toString())
                  this.closeDialog = false
                  this.lotteryPush = null
                  this.LotteryStatus = false
                })
            }
            Image($r('app.media.icon_close'))
              .fillColor(Color.White)
              .width(20)
              .height(20)
              .borderRadius('50%')
              .padding(4)
              .border({ width: 1, color: Color.White })
              .onClick(() => {
                //关闭弹窗
                this.closeDialog = false
                this.lotteryPush = null
                this.LotteryStatus = false
              })
          } else if (this.LotteryCarryOut != null) {
            //展示抽奖动效
            Image(`https:${this.LotteryCarryOut.icon}` ?? $r('app.media.icon_lottery_bg'))
              .width(260)
            if (this.LotteryCarryOut.lottery_type == 8) {
              Button('立即发送口令')
                .backgroundColor('#f40')
                .fontColor(Color.White)
                .onClick(() => {
                  let msgData: EmitterMsgData;
                  msgData = {
                    type: MsgType.LOTTERY_MSG,
                    data: this.lotteryPush?.command
                  } as EmitterMsgData;
                  EmitterUtil.send(msgData);

                  this.Participation(this.LotteryCarryOut!.id.toString())
                  this.closeDialog = false
                  this.lotteryPush = null
                  this.LotteryStatus = false
                })
            }
            Image($r('app.media.icon_close'))
              .fillColor(Color.White)
              .width(20)
              .height(20)
              .borderRadius('50%')
              .padding(4)
              .border({ width: 1, color: Color.White })
              .onClick(() => {
                //关闭弹窗
                this.closeDialog = false
                this.lotteryPush = null
                this.LotteryStatus = false
              })
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.62)')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }
    }
  }
}

/*
 * 中奖页面
 * */
@Component
export struct LotteryDetails {
  //关闭弹窗
  @State closeDialog: boolean = true
  @Prop user_id: number
  @Prop room_id: string
  @Prop nickname: string
  @State receive_award_way: number = 0;
  @State bol: boolean = true
  @Consume lotteryResultNotice: VHLotteryResultNoticeModel | null
  @Consume lotteryPush: VHLotteryResultNoticeModel | null
  @State WinnerList: VHWinnerInformationItem[] = []
  @Prop LotteryList: VHLotteryList[] = []
  @Link LotteryStatusEnd: boolean
  @Consume closeLotteryListDialog: boolean

  aboutToAppear(): void {
    this.lotteryPush = null
    this.WinnerInformation()
    this.boll()
    this.closeLotteryListDialog = true;
  }

  boll() {
    this.bol = this.WinnerList.some((item: VHWinnerInformationItem, index: number) => {
      return item.lottery_user_id == this.user_id.toString()
    }) as boolean
  }

  WinnerInformation() {
    if (this.lotteryResultNotice != null) {
      VHSaaSDK.getInstance()
        .lotteryGetWinner(this.room_id,
          this.lotteryResultNotice!.lottery_id.toString(), {
            onSucceed: (data) => {
              this.WinnerList = data.list
              this.boll()
              console.log(`获取中奖用户列表成功：${JSON.stringify(data)}`)
            },
            onFailure: (errorCode, errorMsg) => {
              console.log(`获取中奖用户列表失败：${errorMsg}`)
            },
          })
    } else {
      VHSaaSDK.getInstance()
        .lotteryGetWinner(this.room_id,
          this.LotteryList[0].id.toString(), {
            onSucceed: (data) => {
              this.WinnerList = data.list
              this.boll()
              console.log(`获取中奖用户列表成功112233：${this.WinnerList}`)
            },
            onFailure: (errorCode, errorMsg) => {
              console.log(`获取中奖用户列表失败：${errorMsg}`)
            },
          })
    }

  }

  aboutToDisappear(): void {
    this.lotteryResultNotice = null
    this.LotteryStatusEnd = false
  }

  dialog = new CustomDialogController({
    builder: LotteryListDialog({
      receive_award_way: this.receive_award_way,
      nickname: this.nickname,
      room_id: this.room_id,
      LotteryList: this.LotteryList,
      WinnerList: this.WinnerList,
      lotteryResultNotice: this.lotteryResultNotice,
      LotteryStatusEnd: this.LotteryStatusEnd,
    }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })

  build() {
    Column() {
      if (this.closeDialog) {
        if (this.bol) {
          Column() {
            //抽奖结束后显示结果
            Text(this.nickname)
              .fontColor(Color.White)
              .backgroundColor(Color.Orange)
              .padding({ left: 20, right: 20 })
              .height(30)
              .borderRadius(8)

            Stack() {
              Image($r('app.media.icon_lottery_winer'))
                .width(260)
                .zIndex(0)
              Image(this.lotteryResultNotice?.award_snapshoot?.image_url ||
              this.LotteryList[0].award_snapshoot.image_url)
                .width(180)
                .height(180)
                .borderRadius(90)
                .objectFit(ImageFit.Cover)
                .zIndex(1)
            }

            Button('立即领奖')
              .width('50%')
              .backgroundColor('#ff2d3e')
              .fontWeight(500)
              .margin({ top: 26, bottom: 26 })
              .onClick(() => {
                VHSaaSDK.getInstance().checkLotteryCondition(this.lotteryResultNotice?.lottery_id.toString()!,{
                  onSucceed: (data: VHLotteryCondition) => {
                    //参与签到的观众未签到 仅展示未签到处理
                    if(data.condition == 3 && data.status == 1){
                      this.closeDialog = false
                      this.LotteryStatusEnd = false
                      let msgData: EmitterMsgData;
                      msgData = {
                        type: MsgType.SIGN_CONDITION,
                        data: data.sign_id
                      } as EmitterMsgData;
                      EmitterUtil.send(msgData);
                    }else{
                      //打开列表
                      this.dialog.open()
                      this.closeDialog = false
                      this.LotteryStatusEnd = false
                    }
                  },
                  onFailure: (errorCode: number, errorMsg: string) => {}
                })
              })
            Text(this.lotteryResultNotice?.award_snapshoot?.award_name ||
            this.LotteryList[0].award_snapshoot.award_name)
              .fontColor(Color.White)
              .backgroundColor(Color.Orange)
              .padding({ left: 20, right: 20, bottom: 10 })
              .height(30)
              .borderRadius(8)

            Image($r('app.media.icon_close'))
              .fillColor(Color.White)
              .width(20)
              .height(20)
              .borderRadius('50%')
              .padding(4)
              .border({ width: 1, color: Color.White })
              .onClick(() => {
                if (this.LotteryList.length === 0) {
                  ToastUtil.showToast("暂无中奖名单数据");
                  return;
                }
                //关闭弹窗
                this.closeDialog = false
                this.lotteryResultNotice = null
                this.receive_award_way = 0
                this.LotteryStatusEnd = false
              })
          }
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.62)')
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
        } else {
          Column() {
            //抽奖结束后显示结果
            Image($r('app.media.icon_lottery_no'))
              .width(260)
            Button('查看中奖名单')
              .width('50%')
              .backgroundColor('#ff2d3e')
              .fontWeight(500)
              .margin({ top: 26, bottom: 26 })
              .onClick(() => {
                if (this.LotteryList.length === 0) {
                  ToastUtil.showToast("暂无中奖名单数据");
                  return;
                }
                //打开列表
                this.dialog.open()
                this.closeDialog = false
                this.receive_award_way = 3
                this.LotteryStatusEnd = false
              })
            Image($r('app.media.icon_close'))
              .fillColor(Color.White)
              .width(20)
              .height(20)
              .borderRadius('50%')
              .padding(4)
              .border({ width: 1, color: Color.White })
              .onClick(() => {
                //关闭弹窗
                this.closeDialog = false
                this.lotteryResultNotice = null
                this.LotteryStatusEnd = false
              })
          }
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.62)')
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }

      }
    }
  }
}

@CustomDialog
export struct LotteryListDialog {
  controller: CustomDialogController
  @State name: string = ''
  @State phone: string = ''
  @State address: string = ''
  @Prop lotteryResultNotice: VHLotteryResultNoticeModel | null
  @Prop receive_award_way: number = 0;
  @State title: string = '222';
  @Prop nickname: string
  @Prop WinnerList: VHWinnerInformationItem[] = []
  @Prop LotteryList: VHLotteryList[] = []
  @Prop room_id: string
  @Consume closeLotteryListDialog: boolean
  @Link LotteryStatusEnd: boolean

  WinnerInformation() {
    if (this.lotteryResultNotice != null) {
      VHSaaSDK.getInstance()
        .lotteryGetWinner(this.room_id, this.lotteryResultNotice!.lottery_id.toString(), {
          onSucceed: (data) => {
            this.WinnerList = data.list as VHWinnerInformationItem[]
            console.log(`获取中奖用户列表成功：${JSON.stringify(data)}`)
          },
          onFailure: (errorCode, errorMsg) => {
            console.log(`获取中奖用户列表失败：${errorMsg}`)
          },
        })
    } else {
      VHSaaSDK.getInstance()
        .lotteryGetWinner(this.room_id, this.LotteryList[0].id.toString(), {
          onSucceed: (data) => {
            this.WinnerList = data.list as VHWinnerInformationItem[]
            console.log(`获取中奖用户列表成功：${JSON.stringify(data)}`)
          },
          onFailure: (errorCode, errorMsg) => {
            console.log(`获取中奖用户列表失败：${errorMsg}`)
          },
        })
    }
  }

  performWinnerInformationIn() {
    VHSaaSDK.getInstance().lotteryCommit(this.lotteryResultNotice!.room_id, this.lotteryResultNotice!.lottery_id.toString(),
        this.name, this.phone,
        {
          onSuccess: (data) => {
            ToastUtil.showToast('提交成功')
            console.log(`中奖人领奖信息成功：${JSON.stringify(data)}`)
          },
          onFailure: (errorCode, errorMsg) => {
            ToastUtil.showToast(`${errorMsg}`)
            console.log(`中奖人领奖信息失败：${errorMsg}`)
          },
        })
  }

  aboutToAppear(): void {
    this.WinnerInformation()
  }

  aboutToDisappear(): void {
    this.lotteryResultNotice = null
  }

  build() {
    if (this.closeLotteryListDialog) {
      if (this.lotteryResultNotice != null) {
        Column() {
          Column() {
            Row() {
              Stack({ alignContent: Alignment.Center }) {
                Image($r('app.media.icon_lottery_top'))
                Text(this.lotteryResultNotice!.receive_award_way < 3 && this.receive_award_way != 3 ? '领奖信息' :
                  '中奖名单')
                  .fontSize(18)
                  .fontColor('#f34606')
                  .fontWeight(700)
              }
              .width('70%')
              .position({ x: '15%', y: -6 })

              Image($r('app.media.icon_close'))
                .width(14)
                .position({ x: '90%', y: '35%' })
                .fillColor('#fffab24f')
                .onClick(() => {
                  this.controller.close()
                  this.LotteryStatusEnd = false
                })
            }
            .width('100%')
            .height(40)
            .margin({ bottom: 6 })

            if (this.lotteryResultNotice!.receive_award_way == 1 && this.receive_award_way != 3) {
              Column({ space: 6 }) {
                Row() {
                  Text('*')
                    .fontColor('#ff2d3e')
                  TextInput({ placeholder: '请输入姓名', text: $$this.name })
                    .layoutWeight(1)
                    .borderRadius(0)
                    .backgroundColor(Color.White)
                }
                .width('90%')
                .padding({ left: 10, right: 10 })
                .backgroundColor(Color.White)
                .borderRadius(6)

                Row() {
                  Text('*')
                    .fontColor('#ff2d3e')
                  TextInput({ placeholder: '请输入手机号', text: $$this.phone })
                    .layoutWeight(1)
                    .borderRadius(0)
                    .backgroundColor(Color.White)
                }
                .width('90%')
                .padding({ left: 10, right: 10 })
                .backgroundColor(Color.White)
                .borderRadius(6)

                Row() {
                  Text('*')
                    .fontColor('#fff')
                  TextInput({ placeholder: '请输入地址', text: $$this.address })
                    .layoutWeight(1)
                    .borderRadius(0)
                    .backgroundColor(Color.White)
                }
                .width('90%')
                .padding({ left: 10, right: 10 })
                .backgroundColor(Color.White)
                .borderRadius(6)
              }

              Blank()
                .layoutWeight(1)
              Button('提交')
                .width('60%')
                .backgroundColor('#ff2d3e')
                .margin({ bottom: 20 })
                .onClick(() => {
                  //判断输入
                  if (this.name.length <= 0) {
                    ToastUtil.showToast("请输入姓名");
                    return
                  }
                  const regex = /^1[3-9]\d{9}$/
                  if (!regex.test(this.phone)) {
                    ToastUtil.showToast("输入的手机号不正确");
                    return
                  }
                  //调用接口，上传数据
                  this.performWinnerInformationIn()
                  //关闭弹窗
                  this.controller.close()
                  this.LotteryStatusEnd = false
                })
            } else if (this.lotteryResultNotice!.receive_award_way == 2 && this.receive_award_way != 3) {
              Column() {
                Column() {
                  Text(this.lotteryResultNotice?.command)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Image(this.lotteryResultNotice?.award_snapshoot?.image_url)
                    .height('60%')
                  Text('请截图中奖页面添加客服领取奖品哦')
                    .fontSize(14)
                    .fontColor('#666')
                    .fontWeight(500)
                    .margin({ top: 14 })
                }
                .width('90%')
                .height('80%')
                .backgroundColor(Color.White)
                .justifyContent(FlexAlign.Center)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
            } else if (this.lotteryResultNotice!.receive_award_way == 3 ||
              this.lotteryResultNotice!.receive_award_way == 4 || this.receive_award_way == 3) {
              Column() {
                Column() {
                  if (this.WinnerList.length > 0) {
                    List() {
                      ForEach(this.WinnerList, (item: VHWinnerInformationItem, index) => {
                        ListItem() {
                          Row() {
                            Row({ space: 10 }) {
                              Text(index + 1 > 10 ? `${index + 1}` : `0${index + 1}`)
                                .fontSize(14)
                                .fontColor('#f40')
                              Image(item.lottery_user_avatar || $r('app.media.icon_avatar'))
                                .width(30)
                                .borderRadius('50%')
                              Text(item.lottery_user_nickname)
                                .fontSize(14)
                                .fontColor('#f40')
                                .layoutWeight(1)
                                .maxLines(1)
                                .textOverflow({ overflow: TextOverflow.Ellipsis })
                            }
                            .width(180)

                            Row() {
                              Text(`获得 "${item.lottery_award_name}"`)
                                .fontSize(14)
                                .fontColor('#f40')
                                .maxLines(1)  // 限制最大行数
                                .textOverflow({ overflow: TextOverflow.Ellipsis })
                            }
                          }
                          .width('100%')
                          .justifyContent(FlexAlign.SpaceBetween)
                          .padding(10)
                        }
                      })
                    }
                    .divider({ strokeWidth: 10, color: Color.Transparent })
                  } else {
                    Image($r('app.media.icon_emoji'))
                      .height('60%')
                    Text('当前无中奖用户')
                      .fontSize(14)
                      .fontColor('#666')
                      .fontWeight(500)
                      .margin({ top: 14 })
                  }

                }
                .width('90%')
                .height('80%')
                .padding(10)
                .backgroundColor(Color.White)
                .justifyContent(FlexAlign.Start)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
            }

          }
          .width('100%')
          .height(340)
          .linearGradient({
            angle: 90,
            colors: [['#fffcf1f7', 0.1], ['#ffe7dbf8', 0.9]]
          })
          .borderRadius({ topLeft: 20, topRight: 20 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.62)')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.End)
        .onClick(() => {
          this.controller.close()
        })
      } else if (this.LotteryList.length > 0) {
        Column() {
          Column() {
            Row() {
              Stack({ alignContent: Alignment.Center }) {
                Image($r('app.media.icon_lottery_top'))
                Text(this.LotteryList[0]!.receive_award_way < 3 && this.receive_award_way != 3 ? '领奖信息' :
                  '中奖名单')
                  .fontSize(18)
                  .fontColor('#f34606')
                  .fontWeight(700)
              }
              .width('70%')
              .position({ x: '15%', y: -6 })

              Image($r('app.media.icon_close'))
                .width(14)
                .position({ x: '90%', y: '35%' })
                .fillColor('#fffab24f')
                .onClick(() => {
                  this.controller.close()
                })
            }
            .width('100%')
            .height(40)
            .margin({ bottom: 6 })

            if (this.LotteryList[0]!.receive_award_way == 1 && this.receive_award_way != 3) {
              Column({ space: 6 }) {
                Row() {
                  Text('*')
                    .fontColor('#ff2d3e')
                  TextInput({ placeholder: '请输入姓名', text: $$this.name })
                    .layoutWeight(1)
                    .borderRadius(0)
                    .backgroundColor(Color.White)
                }
                .width('90%')
                .padding({ left: 10, right: 10 })
                .backgroundColor(Color.White)
                .borderRadius(6)

                Row() {
                  Text('*')
                    .fontColor('#ff2d3e')
                  TextInput({ placeholder: '请输入手机号', text: $$this.phone })
                    .layoutWeight(1)
                    .borderRadius(0)
                    .backgroundColor(Color.White)
                }
                .width('90%')
                .padding({ left: 10, right: 10 })
                .backgroundColor(Color.White)
                .borderRadius(6)

                Row() {
                  Text('*')
                    .fontColor('#fff')
                  TextInput({ placeholder: '请输入地址', text: $$this.address })
                    .layoutWeight(1)
                    .borderRadius(0)
                    .backgroundColor(Color.White)
                }
                .width('90%')
                .padding({ left: 10, right: 10 })
                .backgroundColor(Color.White)
                .borderRadius(6)
              }

              Blank()
                .layoutWeight(1)
              Button('提交')
                .width('60%')
                .backgroundColor('#ff2d3e')
                .margin({ bottom: 20 })
                .onClick(() => {
                  //判断输入
                  if (this.name.length <= 0) {
                    ToastUtil.showToast("请输入姓名");
                    return
                  }
                  const regex = /^1[3-9]\d{9}$/
                  if (!regex.test(this.phone)) {
                    ToastUtil.showToast("输入的手机号不正确");
                    return
                  }
                  //调用接口，上传数据
                  this.performWinnerInformationIn()
                  //关闭弹窗
                  this.controller.close()
                })
            } else if (this.LotteryList[0].receive_award_way == 2 && this.receive_award_way != 3) {
              Column() {
                Column({ space: 6 }) {
                  Text(this.LotteryList[0].command)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Image(this.LotteryList[0].award_snapshoot?.image_url)
                    .height('60%')
                  Text('请截图中奖页面添加客服领取奖品哦')
                    .fontSize(14)
                    .fontColor('#666')
                    .fontWeight(500)
                    .margin({ top: 14 })
                }
                .width('90%')
                .height('80%')
                .backgroundColor(Color.White)
                .justifyContent(FlexAlign.Center)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
            } else if (this.LotteryList[0].receive_award_way == 3 ||
              this.LotteryList[0].receive_award_way == 4 || this.receive_award_way == 3) {
              Column() {
                Column() {
                  if (this.WinnerList.length > 0) {
                    // List() {
                    //   ForEach(this.WinnerList, (item: VHWinnerInformationItem, index) => {
                    //     ListItem() {
                    //       Row() {
                    //         Row({ space: 10 }) {
                    //           Text(index + 1 > 10 ? `${index + 1}` : `0${index + 1}`)
                    //             .fontSize(14)
                    //             .fontColor('#f40')
                    //           Image(item.lottery_user_avatar || $r('app.media.icon_avatar'))
                    //             .width(30)
                    //             .borderRadius('50%')
                    //           Text(item.lottery_user_nickname)
                    //             .fontSize(14)
                    //             .fontColor('#f40')
                    //             .layoutWeight(1)
                    //             .maxLines(1)
                    //             .textOverflow({ overflow: TextOverflow.Ellipsis })
                    //         }
                    //         .width(180)
                    //
                    //         Row() {
                    //           Text(`获得 "${item.lottery_award_name}"`)
                    //             .fontSize(14)
                    //             .fontColor('#f40')
                    //             .maxLines(1)  // 限制最大行数
                    //             .textOverflow({ overflow: TextOverflow.Ellipsis })
                    //         }
                    //       }
                    //       .width('100%')
                    //       .justifyContent(FlexAlign.SpaceBetween)
                    //       .padding(10)
                    //     }
                    //   })
                    // }
                    // .divider({ strokeWidth: 10, color: Color.Transparent })

                    Flex({
                      direction: FlexDirection.Column,
                      wrap: FlexWrap.NoWrap,
                    }) {
                      ForEach(this.WinnerList, (item: VHWinnerInformationItem, index) => {
                        // 列表项：与原List Item布局一致
                        Row() {
                          Row({ space: 10 }) {
                            // 排名（01、02...10、11）
                            Text(index + 1 > 10 ? `${index + 1}` : `0${index + 1}`)
                              .fontSize(14)
                              .fontColor('#f40')
                            // 头像（增加默认图）
                            Image(item.lottery_user_avatar || $r('app.media.icon_avatar'))
                              .width(30)
                              .height(30)
                              .borderRadius('50%')
                              .objectFit(ImageFit.Cover)
                            // 昵称（溢出省略）
                            Text(item.lottery_user_nickname || '匿名用户')
                              .fontSize(14)
                              .fontColor('#f40')
                              .layoutWeight(1)
                              .maxLines(1)
                              .textOverflow({ overflow: TextOverflow.Ellipsis })
                          }
                          .width(180)

                          // 中奖奖品
                          Row() {
                            Text(`获得 "${item.lottery_award_name || '未知奖品'}"`)
                              .fontSize(14)
                              .fontColor('#f40')
                              .maxLines(1)
                              .textOverflow({ overflow: TextOverflow.Ellipsis })
                          }
                        }
                        .width('100%')
                        .justifyContent(FlexAlign.SpaceBetween)
                        .padding(10)

                        // 分隔线（替代List divider）
                        Divider()
                          .height(1)
                          .backgroundColor('#f5f5f5')
                          .margin({ left: 10, right: 10 })
                      })
                    }
                    .width('100%')
                    .height('100%') // 占满父容器高度，确保滚动生效
                  } else {
                    Image($r('app.media.icon_emoji'))
                      .height('60%')
                    Text('当前无中奖用户')
                      .fontSize(14)
                      .fontColor('#666')
                      .fontWeight(500)
                      .margin({ top: 14 })
                  }
                }
                .width('90%')
                .height('80%')
                .padding(10)
                .backgroundColor(Color.White)
                .justifyContent(FlexAlign.Start)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
            }

          }
          .width('100%')
          .height(340)
          .linearGradient({
            angle: 90,
            colors: [['#fffcf1f7', 0.1], ['#ffe7dbf8', 0.9]]
          })
          .borderRadius({ topLeft: 20, topRight: 20 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.62)')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.End)
        .onClick(() => {
          this.controller.close()
        })
      }
    }
  }
}