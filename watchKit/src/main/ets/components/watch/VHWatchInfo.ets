import { BarrageItem, BarrageView, BarrageController } from '@esky/barrage';
import {
  VHBaseNumUpdate,
  VHContent, VHIMMessageModel, VHMsgData, VHPlayerConfig, VHRoomEventType,
  VHUserData,
  VHWebinarData } from '@vhall/vhall_live';
import { EmitterMsgData, EmitterUtil } from '../../util/EmitterUtil';
import { EmojiTool } from '../chat/EmojiTool';


@Preview
@Component
export struct VHWatchInfo {
  @Require webinarInfo:VHWebinarData;
  @State pv:number = 0;//观看次数
  @State uv:number = 0;//在线人数. 上下线消息，聊天消息中都会同步当前在线人数。可根据实际需求同步
  @State virtualPv:number = 0;//虚拟热度
  @State virtualUv:number = 0;//虚拟人数

  @State showUV:string = '0';
  @State showHot:string = '0';
  aboutToAppear(): void {
    this.pv = this.webinarInfo?.pv?.real!;
    this.virtualPv = this.webinarInfo?.pv?.virtual!;
    this.uv = this.webinarInfo.online?.real!;
    this.virtualUv = this.webinarInfo.online?.virtual!;

    EmitterUtil.subscribe(VHRoomEventType.USER_JOIN, (msgData: EmitterMsgData) => {
      let messageModel: VHUserData = msgData.data as VHUserData;
      this.uv = messageModel.uv!;
      this.pv++;
      this.update();
    });

    EmitterUtil.subscribe(VHRoomEventType.USER_LEAVE, (msgData: EmitterMsgData) => {
      let messageModel: VHUserData = msgData.data as VHUserData;
      this.uv = messageModel.uv!;
      this.update();
    });

    EmitterUtil.subscribe(VHRoomEventType.BASE_NUM_UPDATE, (msgData: EmitterMsgData) => {
      let messageModel: VHBaseNumUpdate = msgData.data as VHBaseNumUpdate;
      this.virtualUv += Number(messageModel.update_online_num);
      this.virtualPv += Number(messageModel.update_pv);
      this.update();
    });
    this.update();
  }

  aboutToDisappear(): void {

  }

  private  formatNumberWithW(num: number): string {
  // 如果数值大于等于1万，转换为带w的格式
  if (num >= 10000) {
    // 除以1万，保留一位小数
    const value = num / 10000;
    // 处理小数点后是否需要显示
    return value % 1 === 0 ? `${value.toFixed(0)}w` : `${value.toFixed(1)}w`;
  }
  // 小于1万的数值直接返回
  return num.toString();
}

  private update(){
    this.showUV = this.formatNumberWithW(this.uv+this.virtualUv);
    this.showHot = this.formatNumberWithW(this.pv+this.virtualPv);
  }

  build() {

    Row({space:10}){
      Image(this.webinarInfo?.webinar?.userinfo.avatar)
        .borderRadius(15)
        .width(30)
        .height(30)
        .padding({left:4})

      Column({space:4}){
        Text(this.webinarInfo?.webinar?.userinfo.nickname)
          .fontSize(10)
          .fontColor(Color.White)

        Row({space:4}){
          if(this.webinarInfo.online?.show){
            Image($r("app.media.uv"))
              .width(10)
              .height(10)
            Text(this.showUV)
              .fontSize(10)
              .fontColor(Color.White)
          }
          if(this.webinarInfo.pv?.show){
            Image($r("app.media.pv"))
              .width(10)
              .height(10)
            Text(this.showHot)
              .fontSize(10)
              .fontColor(Color.White)
          }
        }
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      .margin({right:6,left:6})
    }
    .justifyContent(FlexAlign.SpaceAround)
    .height(36)
    .borderRadius(18)
    .backgroundColor('#77000000')
  }
}