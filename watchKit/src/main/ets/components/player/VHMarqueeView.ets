import { BarrageItem, BarrageView, BarrageController } from '@esky/barrage';
import { VHPlayerConfig, VHWebinarData } from '@vhall/vhall_live';
import { EmitterMsgData, EmitterUtil } from '../../util/EmitterUtil';
import { RandomUtil } from '../../utils/RandomUtil';

const numbers: number[] = [2, 3, 4];

//跑马灯
@Preview
@Component
export struct VHMarqueeViews {
  @State private isDragging: boolean = false
  private barrageController: BarrageController = new BarrageController;
  // 图标资源根据实际情况替换
  @State private icon: Resource = $r('app.media.volume_open')
  private readonly maxWidth: number = 200 // 进度条最大宽度
  @Require playerConfig: VHPlayerConfig;
  @Require webinarInfo: VHWebinarData;
  @State comHeight: number = 0;
  @State rollSpeed:number = 1;
  @State postion:FlexAlign = FlexAlign.Start;
  @State paddingValue:number = 0;
  private timeId:number = -1;
  @State  enable:boolean = true;

  @State xPos:number = 0;
  @State yPos:number = 0;

  build() {
    Column({space:10}) {
      //用户测可通过this.playerConfig?.marquee 具体进行配置。
      // 组件库参考https://gitee.com/wuhan-yihai-cloud-peak/barrage-component-library/tree/master/BarrageMaster
      if(this.playerConfig.marquee?.scroll_type == 1){
        BarrageView({
          barrageController: this.barrageController,
          option: {
            maxLine: 1,
            trackLine: 1,
            speed:this.rollSpeed,
            textAlpha: this.playerConfig?.marquee?.alpha! * 0.01,
            isShowFPS: false
          },
          onCanvasReady: () => {
            this.barrageController.start();
            setTimeout(()=>{this.loopShow()},100);
            if(this.timeId == -1){
              this.timeId = setInterval(()=>{this.loopShow()}, this.playerConfig.marquee?.interval! * 1000);
            }
          },
          onTouchBarrage: (item: BarrageItem) => {
            console.log('BarrageMaster', 'click barrage :' + JSON.stringify(item))
          }
        })
          .width('100%')
          .height('30%')
          .onAreaChange((oldValue: Area, newValue: Area) => {
            this.comHeight = newValue.height as number;
          })
      }else{
        Text(this.playerConfig?.marquee?.text_type == 1 ? this.playerConfig?.marquee?.text : this.webinarInfo?.join_info?.third_party_user_id!  + this.webinarInfo?.join_info?.nickname!)
          .fontColor(this.playerConfig?.marquee?.color)
          .fontSize(this.playerConfig?.marquee?.size! < 20 ? this.playerConfig?.marquee?.size : 20)
          .position({x:this.xPos,y:this.yPos})
          .opacity(this.playerConfig?.marquee?.alpha! * 0.01)
      }
    }
    .margin(20)
    .justifyContent(this.postion)
    .padding({bottom:this.paddingValue})
    .width('100%')
    .height('100%')
  }

  aboutToAppear(): void {
    if(this.playerConfig && this.playerConfig?.marquee){
      this.rollSpeed = Math.abs(11 - this.playerConfig?.marquee?.speed / 1000);
    }
    if(this.playerConfig.marquee?.scroll_type == 2){
      this.timeId = setInterval(()=>{
        this.xPos = RandomUtil.getRandomNumber(10,300);
        this.yPos = RandomUtil.getRandomNumber(10,300);
      },2000);
    }
  }

  aboutToDisappear(): void {
    if(this.timeId != -1){
      clearInterval(this.timeId);
    }
  }

  loopShow(){
    if(this.playerConfig?.marquee){
      const barrageItem = new BarrageItem();
      barrageItem.id = "123";
      barrageItem.text = this.playerConfig.marquee.text_type == 1 ? this.playerConfig?.marquee?.text : this.webinarInfo?.join_info?.third_party_user_id!  + this.webinarInfo?.join_info?.nickname!;
      barrageItem.textColor = [this.playerConfig?.marquee?.color];
      barrageItem.isSelf = false;
      barrageItem.textSize = this.playerConfig?.marquee.size < 20 ? this.playerConfig?.marquee?.size : 20;
      if (this.playerConfig?.marquee?.position == 1) {
        const randomIndex: number = Math.floor(Math.random() * numbers.length);
        const randomValue: number = numbers[randomIndex];
        switch (randomValue){
          case 2:
            this.postion = FlexAlign.Start;
            break
          case 3:
            this.postion = FlexAlign.Center;
              break
          case 4:
            this.postion = FlexAlign.End;
            break
          default:
            this.postion = FlexAlign.Start;
        }
      }if( this.playerConfig?.marquee?.position == 2){//上
        this.postion = FlexAlign.SpaceBetween;
      }else if (this.playerConfig?.marquee?.position == 3) {//中
        this.postion = FlexAlign.Center;
        this.paddingValue = 20;
      } else if (this.playerConfig?.marquee?.position == 4) {//下
        this.paddingValue = 20;
        this.postion = FlexAlign.End;
      }
      this.barrageController.addBarrage(barrageItem);
    }
  }
}