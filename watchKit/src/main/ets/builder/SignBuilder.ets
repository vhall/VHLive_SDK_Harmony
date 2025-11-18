import {
  VHSignData, VHSignInfo, VHSignServer,
} from '@vhall/vhall_live'
import { ToastUtil } from "../action/ToastUtil";
import { EmitterMsgData, EmitterUtil } from '../util/EmitterUtil';

/*
 *签到UI弹窗
 * */
@Preview
@CustomDialog
export struct VHSignDialog {
  controller: CustomDialogController
  @Require server?: VHSignServer;
  @State minute: number | string = 0
  @State second: number | string = 0
  @State timeId: number = 0
  @Link SignPush: VHSignData
  @Consume signInfo: VHSignInfo
  @Consume room_id: string
  @Consume signTime:number
  //时间显示
  startTime(time: number) {
    let m: string | number = Math.floor(time / 60) // 分
    let s: string | number = Math.floor(time % 60) // 秒
    //补零操作
    m = m < 10 ? '0' + m : m
    s = s < 10 ? '0' + s : s
    this.minute = m
    this.second = s
    this.signTime = time;
    //判断倒计时结束
    if (time <= 0) {
      clearInterval(this.timeId)
      if(this.signInfo.auto_kick_unsigned == 1){
        let msgData: EmitterMsgData;
        msgData = {
          type: 'sign_kick_out',
        } as EmitterMsgData;
        EmitterUtil.send(msgData);
      }
      this.minute = '00'
      this.second = '00'
      this.controller.close()
    }
  }

  build() {
    Column() {
      // 半模态的内容
      if (this.SignPush.sign_show_time != 0) {
        Column() {
          // 顶部区域
          Stack({ alignContent: Alignment.End }) {
            Text(this.SignPush.title)
              .width('100%')
              .textAlign(500)
              .fontSize(16)
              .textAlign(TextAlign.Center)
          }
          .width('100%')

          // 底部的列表
          Row({ space: 10 }) {
            Text(this.minute.toString())
            Text(':')
            Text(this.second.toString())
          }
          .width('100%')
          .height(200)
          .margin({ top: 30 })
          .justifyContent(FlexAlign.Center)


          Button('立即签到')
            .onClick(() => {
              clearInterval(this.timeId)
              this.server?.signJoin(this.SignPush.sign_id.toString(), this.SignPush.room_id, {
                onSuccess(data: string | object) {
                  ToastUtil.showToast(`${this.SignPush.sign_in_success_tips}`);
                },
                // 失败
                onFailure(errorCode: number, errorMsg: string) {
                  ToastUtil.showToast(`${errorCode}: ${errorMsg}`);
                }
              })
              ToastUtil.showToast(`${this.SignPush.sign_in_success_tips}`);
              this.controller.close()
            })
            .backgroundColor(Color.Red)
            .width(200)
            .height(40)
        }
        .padding(15)
        .onAppear(() => {
          clearInterval(this.timeId)
          this.timeId = 0
          if (this.SignPush.sign_show_time > 0) {
            this.startTime(this.SignPush.sign_show_time)
            this.timeId = setInterval(() => {
              (this.SignPush.sign_show_time)--
              this.startTime(this.SignPush.sign_show_time)
              if (this.SignPush.sign_show_time <= 0) {
                this.SignPush.sign_show_time = 0
                clearInterval(this.timeId)
                this.timeId = 0
                this.controller.close()
                this.minute = '00'
                this.second = '00'
                if (this.SignPush.auto_kick_unsigned == 1) {
                  ToastUtil.showToast("您未进行签到，自动被踢出直播间")
                  let msgData: EmitterMsgData;
                  msgData = {
                    type: "sign_kick_out", // 消息类型
                    enable: true
                  } as EmitterMsgData;
                  // 通过EmitterUtil发送
                  EmitterUtil.send(msgData);
                }
              }
            }, 1000)
          }
        })
        .onDisAppear(() => {
          clearInterval(this.timeId)
          this.timeId = 0
        })
      } else {
        Column() {
          // 顶部区域
          Stack({ alignContent: Alignment.End }) {
            Text(this.signInfo.sign_tips)
              .width('100%')
              .textAlign(500)
              .fontSize(16)
              .textAlign(TextAlign.Center)
          }
          .width('100%')

          // 底部的列表
          Row({ space: 10 }) {
            Text(this.minute.toString())
            Text(':')
            Text(this.second.toString())
          }
          .width('100%')
          .height(200)
          .margin({ top: 30 })
          .justifyContent(FlexAlign.Center)


          Button('立即签到')
            .onClick(() => {
              clearInterval(this.timeId)
              this.server?.signJoin(this.signInfo.id, this.room_id as string, {
                onSuccess(data: string | object) {
                  ToastUtil.showToast(`${this.signInfo.sign_in_success_tips}`);
                },
                // 失败
                onFailure(errorCode: number, errorMsg: string) {
                  ToastUtil.showToast(`${errorCode}: ${errorMsg}`);
                }
              })
              ToastUtil.showToast(`${this.signInfo.sign_in_success_tips}`);
              this.controller.close()
            })
            .backgroundColor(Color.Red)
            .width(200)
            .height(40)
        }
        .padding(15)
        .onAppear(() => {
          clearInterval(this.timeId)
          this.timeId = 0
          if (this.signInfo.auto_sign_time_ttl > 0) {
            this.timeId = setInterval(() => {
              (this.signInfo.auto_sign_time_ttl)--
              this.startTime(this.signInfo.auto_sign_time_ttl)
              if (this.signInfo.auto_sign_time_ttl <= 0) {
                this.signInfo.auto_sign_time_ttl = 0
                clearInterval(this.timeId)
                this.timeId = 0
                this.controller.close()
                this.minute = '00'
                this.second = '00'
              }
            }, 1000)
          }
        })
        .onDisAppear(() => {
          clearInterval(this.timeId)
          this.timeId = 0
        })
      }

    }
    .width('%100')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 10, topRight: 10 })
    .justifyContent(FlexAlign.Center)
  }
}
