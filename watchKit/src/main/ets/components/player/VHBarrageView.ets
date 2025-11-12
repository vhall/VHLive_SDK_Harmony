import { BarrageItem, BarrageView, BarrageController } from '@esky/barrage';
import { VHContent, VHIMMessageModel, VHMsgData, VHPlayerConfig, VHRoomEventType } from '@vhall/vhall_live';
import { EmitterMsgData, EmitterUtil } from '../../util/EmitterUtil';
import { EmojiTool } from '../chat/EmojiTool';

//弹幕
@Preview
@Component
export struct VHBarrageViews {
  private barrageController: BarrageController = new BarrageController;
  @State comHeight: number = 0;
  @State enable:boolean=true;

  aboutToAppear(): void {
    EmitterUtil.subscribe(VHRoomEventType.IM_TEXT, (msgData: EmitterMsgData) => {
      console.log(`收到文本消息，类型：${VHRoomEventType.IM_TEXT}`);
      let messageModel: VHIMMessageModel = msgData as VHIMMessageModel;
      if (messageModel.data!) {
        // if (typeof messageModel.data === 'string') {
        //   const parsedMessage: VHIMMessageModel = JSON.parse(messageModel.data) as VHIMMessageModel;
        //   this.handleTextMessage(parsedMessage);
        // } else {
        //
        // }
        this.handleTextMessage(messageModel.data);
      }
    });

    EmitterUtil.subscribe("1001", (msgData: EmitterMsgData) => {
      this.enable = msgData.enable!;
      if(!this.enable ){
        this.barrageController.clearInScreen();
      }
    });
  }

  private handleTextMessage(messageModel?: VHIMMessageModel){
    if(messageModel && this.enable){
      let imMsg:VHContent= messageModel as VHContent;
      imMsg.nickname= messageModel.nick_name;
      imMsg.data = messageModel.data as VHMsgData;
      const barrageItem = new BarrageItem();
      barrageItem.id = "123";
      barrageItem.text = EmojiTool.convertEmojiTags(imMsg.data.text_content)
      barrageItem.isSelf = false;
      barrageItem.speed = 1;
      barrageItem.textSize = 14;
      this.barrageController.addBarrage(barrageItem);
    }
  }

  aboutToDisappear(): void {

  }

  build() {
    Column({space:10}) {
      //用户测可通过this.playerConfig?.marquee 具体进行配置。
      // 组件库参考https://gitee.com/wuhan-yihai-cloud-peak/barrage-component-library/tree/master/BarrageMaster
      BarrageView({
        barrageController: this.barrageController,
        option: {
          maxLine: 5,
          trackLine: 5,
          textAlpha:1,
          isShowFPS: false
        },
        onCanvasReady: () => {
          this.barrageController.start();
        },
        onTouchBarrage: (item: BarrageItem) => {
          console.log('BarrageMaster', 'click barrage :' + JSON.stringify(item))
        }
      })
        .width('100%')
        .height('100%')
        .onAreaChange((oldValue: Area, newValue: Area) => {
          this.comHeight = newValue.height as number;
        })
    }
    .width('100%')
    .height('100%')
  }
}