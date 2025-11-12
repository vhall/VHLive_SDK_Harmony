import { VHCardInfo,
  VHGiftAwardFiled,
  VHGiftAwardItem,
  VHPushScreenCard, VHSaaSDK,
  VHWatchGiftAward,
  VHWatchGiftInfo, VHWatchGiftOpenMsg,
  VHWatchGiftParticipate,
  VHWatchGiftSetting,
  VHWatchGiftWinner,
  VHWatchGiftWinnerDetail,
  VHWebinarData,
  VHWinner} from "@vhall/vhall_live";
import { PromptActionClass } from "../util/PromptActionClass";
import { common, Want } from "@kit.AbilityKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { bundleManager } from "@kit.MDMKit";
import { getTimeString } from "../util/TimeTools";
import { BasicDataSource } from "../util/LazyDataSource";
import { promptAction } from "@kit.ArkUI";
import { ToastUtil } from "../action/ToastUtil";
import { WantUtil } from "../utils/WantUtil";
import { FormatUtil } from "../utils/FormatUtil";

// 自定义参数类型
export class WatchGiftParams {
  gift: VHWatchGiftInfo;
  webinar: VHWebinarData;

  constructor(id: VHWatchGiftInfo, webinar: VHWebinarData) {
    this.gift = id;
    this.webinar = webinar;
  }
}

export class AwardDataSource extends BasicDataSource<VHGiftAwardItem> {
  private listener: VHGiftAwardItem[] = [];

  notifyDataReload(): void {
    super.notifyDataReload();
  }

  totalCount(): number {
    return this.listener.length
  }

  getData(index: number): VHGiftAwardItem {
    return this.listener[index]
  }

  updateData(newList: VHGiftAwardItem[]): void {
    this.listener = newList;
    this.notifyDataAdd(this.listener.length - 1);
  }
}

export class SettingDataSource extends BasicDataSource<VHGiftAwardFiled> {
  private listener: VHGiftAwardFiled[] = [];

  notifyDataReload(): void {
    super.notifyDataReload();
  }

  totalCount(): number {
    return this.listener.length
  }

  getData(index: number): VHGiftAwardFiled {
    return this.listener[index]
  }

  updateData(newList: VHGiftAwardFiled[]): void {
    this.listener = newList;
    this.notifyDataAdd(this.listener.length - 1);
  }

  public getJson():string{
    const listenerJsonStr = JSON.stringify(this.listener);
    return listenerJsonStr;
  }

  public checkEmitEnable():boolean{
    let isEnable:boolean = true;
    this.listener?.forEach((value:VHGiftAwardFiled,index:number,array:VHGiftAwardFiled[])=>{
      if(value.field_value.length <= 0 && value.is_required){
        isEnable = false;
      }
    })
    return isEnable;
  }
}

export class WinnerDataSource extends BasicDataSource<VHWatchGiftWinner> {
  private listener: VHWatchGiftWinner[] = [];

  notifyDataReload(): void {
    super.notifyDataReload();
  }

  totalCount(): number {
    if(this.listener != null){
      return this.listener.length
    }
    return 0;
  }

  getData(index: number): VHWatchGiftWinner {
    return this.listener[index]
  }

  updateData(newList: VHWatchGiftWinner[]): void {
    this.listener = newList;
    this.notifyDataAdd(this.listener.length - 1);
  }

  public getJson():string{
    const listenerJsonStr = JSON.stringify(this.listener);
    return listenerJsonStr;
  }
}

@Builder
export function createWatchGiftView(parm:WatchGiftParams){
  WatchGiftView({watchGiftId:parm.gift, webinar_info:parm.webinar});
}

/**
 * @description ai 精彩回放信息
 */
export class VHAwardModel {
  image_url: string = '';

  title: string = '';

  sub_title: string = '';
}

/**
 * 常用设置底部弹窗视图
 */
@Component
export struct WatchGiftView {

  private highlightDataSource: AwardDataSource = new AwardDataSource();
  @State winners:WinnerDataSource = new WinnerDataSource();
  // private settingDataSource: SettingDataSource = new SettingDataSource();
  @State settingDataSource: VHGiftAwardFiled[] = [];
  @State models:VHGiftAwardItem[] = [];
  private watchGiftId:VHWatchGiftInfo = new VHWatchGiftInfo();
  @Require webinar_info:VHWebinarData;
  @State imagHeight:number = 200;
  @State imagHeightBackGround:number = 190;
  @State timeClose:string = ''
  @State timeCount:number = 0;
  @State url:string = ""
  @State scaleValue: number = 1; // 初始缩放比例
  @State imageSize:number = 184;
  @State rotateAngle:number = 0;
  @State tips:string = "";
  @State checkTips:string = "查看奖池";
  @State isEnd:boolean = false;
  @State isEnableEmit:boolean = false;
  @State isCheckAwardList:boolean = false;
  @State isShowWinnerList:boolean = false;
  @State awardState:number = 0;
  @State showBtn:boolean = true;
  @State participateGift:VHWatchGiftParticipate = new VHWatchGiftParticipate;
  private winning:number = 0;
  private giftSetting: VHWatchGiftSetting = new VHWatchGiftSetting;
  @State showSetting:boolean = false;
  @State showQRGift:boolean = false;

  private timeId:number = -1;
  aboutToAppear(): void {
    this.timeCount = (this.watchGiftId?.watch_minute!*60 - this.watchGiftId?.online_duration!) *1000;
    this.tips = `连续观看直播${this.watchGiftId.watch_minute}分钟即有机会中将`
    this.timeClose = getTimeString(this.timeCount);
    this.timeId = setInterval(()=>{
      this.timeCount -= 1000;
      if(this.timeCount <= 0){
        if(this.timeId != -1){
          clearInterval(this.timeId);
          this.timeId = -1;
          this.timeClose = "即刻开启"
          this.isEnd = true;
          this.tips = "即刻开启抽惊喜福袋"
        }
      }else{
        this.timeClose = getTimeString(this.timeCount);
      }
    },1000);


    VHSaaSDK.getInstance().getWatchGiftAwardSetting(this.webinar_info?.webinar?.id!,this.watchGiftId.id!,{
      onSucceed: (data: VHWatchGiftSetting)=>{
        this.giftSetting = data;
      },
      onFailure: (errorCode: number, errorMsg: string) =>{
        ToastUtil.showToast(errorMsg);
      }
    });
  }
  aboutToDisappear(): void {
    if(this.timeId != -1){
      clearInterval(this.timeId);
    }
  }

  @Builder
  AwardItem(item: VHGiftAwardItem) {
    // 半模态的内容
    Row({ space: 10 }) {
      Image(item.award_img_url)
        .width('112vp')
        .height('63vp')
        .objectFit(ImageFit.Cover)
        .borderRadius(4)

      Column({ space: 10 }) {
        Text(item.award_name)
          .fontColor('#333')
          .maxLines(2)
          .width("60%")
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(item.award_desc)
          .fontColor('#333')
          .maxLines(2)
          .width("60%")
          .textOverflow({ overflow: TextOverflow.Ellipsis })

      }
      .width('80%')
      .borderRadius(10)
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .padding(10)
    .backgroundColor("#FFFFFF")
    .borderRadius(10)
  }

  @Builder
  AwardSettingItem(item: VHGiftAwardFiled) {
    // 半模态的内容
    Row({ space: 10 }) {
      TextInput({placeholder:item.placeholder})
        .borderRadius(4)
        .width('90%')
        .onChange((msg: string) => {
          item.field_value = msg;
          if(item.is_required ){
            if(msg.length > 0){
              let enableCheck:boolean = true;
              this.settingDataSource?.forEach((value:VHGiftAwardFiled,index:number,array:VHGiftAwardFiled[])=>{
                if(value.field_value?.length <= 0 && value.is_required){
                  enableCheck = false;
                }
              })
              this.isEnableEmit = enableCheck;
            }else{
              this.isEnableEmit = false;
            }
          }
        })

      if(item.is_required){
        Image($r('app.media.requir')).width(8).height(8)
      }
    }
    .width('80%')
    .justifyContent(FlexAlign.Start)
    .padding(10)
    .backgroundColor("#FFFFFF")
    .borderRadius(10)
  }

  //中奖名单
  @Builder
  WinnerItem(item: VHWatchGiftWinner) {
    // 半模态的内容
    Column({ space: 5 }){
      Row({ space: 5 }) {
        Image(item.winner_avatar.length > 0 ? item.winner_avatar : $r('app.media.icon_avatar')).width(20).height(20).borderRadius(10)
        Text(item.winner_nickname).fontColor(Color.Red)
        Blank()
        Text("获得").fontColor(Color.Red)
        Text(`${FormatUtil.getTruncateText(item.award_name,5)}`).fontColor(Color.Red)
      }
      .width('80%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .padding(10)
      .backgroundColor("#FFFFFF")
      .borderRadius(10)

      Divider()
        .color(Color.Gray)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding(10)
    .backgroundColor("#FDF5E7")
  }



  build() {
    Stack({alignContent:Alignment.Center}){
      Column({space: 20}) {
        Stack({ alignContent: Alignment.Center }){
          if(this.awardState == 0){//倒计时状态
            Image("https://cnstatic01.e.vhall.com/common-static/saas-watch/static/img/ring.644cb008.png").width(this.imagHeightBackGround).height(this.imagHeightBackGround).zIndex(0)
              .onAppear(() => {
                // 使用animateTo显式动画（搜索结果4）
                animateToImmediately({
                  duration: 1000,
                  iterations: -1
                }, () => {
                  this.imagHeightBackGround = 220; // 定义目标尺寸
                })
              })
            Image("https://cnstatic01.e.vhall.com/common-static/saas-watch/static/img/gold.7a02093a.png").width(215).height(160).zIndex(1)
              .onAppear(() => {
                // 使用animateTo显式动画（搜索结果4）
                animateToImmediately({
                  duration: 2000,
                  iterations: -1
                }, () => {
                  this.rotateAngle = 360; // 定义目标尺寸
                })
              })
              .rotate({ angle: this.rotateAngle })
            Image("https://cnstatic01.e.vhall.com/common-static/saas-watch/static/img/line.19de94b8.png").width(220).height(160).zIndex(2)
            Image("https://cnstatic01.e.vhall.com/common-static/saas-watch/static/img/halo.a05e7d7e.png").width(80).height(80)
            Image("https://cnstatic01.e.vhall.com/common-static/saas-watch/static/img/bag.dfa3e828.png")
              .onAppear(() => {
                // 使用animateTo显式动画（搜索结果4）
                animateToImmediately({
                  duration: 2000,
                  iterations: -1
                }, () => {
                  this.imageSize = 220; // 定义目标尺寸
                })
              })
              .width(this.imageSize) // 初始宽度：184px
              .height(this.imageSize) // 初始高度：184px
              .zIndex(4)
          }else if(this.awardState == 1){//没有中奖
            Image($r("app.media.icon_lottery_no")).width(185).height(185).zIndex(2)
          }else if(this.awardState == 2){//领奖
            Image("https://cnstatic01.e.vhall.com/common-static/saas-watch/static/img/gold.7a02093a.png").width(215).height(160).zIndex(1)
            Image("https://cnstatic01.e.vhall.com/common-static/saas-watch/static/img/halo.a05e7d7e.png").width(220).height(220).zIndex(2)
            Image("https://cnstatic01.e.vhall.com/common-static/saas-watch/static/img/ring.644cb008.png").width(185).height(185).zIndex(3)
            Image(this.participateGift.award_img_url)
              .width(140)
              .height(140)
              .zIndex(4)
              .borderRadius(70)
              .objectFit(ImageFit.Cover)

            RelativeContainer(){
              Text(this.participateGift.award_name)
                .fontSize(14)
                .alignRules({
                  middle: { anchor: '__container__', align: HorizontalAlign.Center },
                  bottom: { anchor: '__container__', align:VerticalAlign.Bottom }
                })
                .fontColor(Color.Red)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 }) // 适当增加内边距，让背景更完整
                .linearGradient({
                  direction: GradientDirection.Left, // 水平方向渐变（左右方向）
                  colors: [
                    [0x00FFFF00, 0.0], // 左侧：透明（alpha=00）+ 黄色（FFFF00）
                    [0xFFFFFFFF, 0.5], // 中间：不透明（alpha=FF）+ 黄色（FFFF00）
                    [0x00FFFF00, 1.0]  // 右侧：透明（alpha=00）+ 黄色（FFFF00）
                  ]
                })
            }.zIndex(5)
            .width('100%')
          }else if(this.awardState == 3){//提交领奖成功
            Text('信息提交成功')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')  // 改为白色文字
              .backgroundColor('#E53935') // 主色作为背景
              .padding({ left: 20, right: 20, top: 10, bottom: 10 })
              .borderRadius(20)
              .shadow({
                radius: 8,          // 阴影扩散半径
                color: '#B71C1C',   // 深红色阴影
                offsetX: 3,         // 水平偏移量
                offsetY: 3          // 垂直偏移量
              })
              .border({
                width: 2,           // 边框粗细
                color: '#FFCDD2'    // 浅红色边框
              })
              .rotate({ angle: -3 })// 文字倾斜角度
              .textAlign(TextAlign.Center)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .zIndex(0)
              .width('60%')
              .textAlign(TextAlign.Center) // 文本内容在自身组件内居中
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }.height(230)

        if(this.showBtn){
          Button(this.timeClose)
            .width(100)
            .height(30)
            .borderRadius(15)
            .backgroundColor(this.awardState == 0 ? Color.Orange : Color.Red)
            .onClick(()=>{
              if(this.isEnd){
                if(this.awardState == 2){//立即领奖
                  if(this.giftSetting.receive_award_way == 3){
                    VHSaaSDK.getInstance().getWatchGiftWinnerRank(this.watchGiftId?.id!,0,10,{
                      onSucceed: (data: VHWinner) => {
                        this.isShowWinnerList = true;
                        this.winners.updateData(data.list);
                        this.awardState = 4;
                      },
                      onFailure: (errorCode: number, errorMsg: string) => {
                        ToastUtil.showToast(errorMsg);
                      }
                    });
                  }else{
                    VHSaaSDK.getInstance().getWatchGiftAwardSetting(this.webinar_info?.webinar?.id!,this.watchGiftId.id!,{
                      onSucceed: (data: VHWatchGiftSetting)=>{
                        this.giftSetting = data;
                        if(data.receive_award_way == 1){//地址领取
                          if(data.receive_award_field.length > 0){
                            this.settingDataSource = data.receive_award_field ;//.updateData(data.receive_award_field);
                            this.showSetting = true;
                          }
                        }else if(data.receive_award_way == 2){//私信
                          this.showQRGift = true;
                        }else if(data.receive_award_way == 3){//无需领奖

                        }

                      },
                      onFailure: (errorCode: number, errorMsg: string) =>{
                        ToastUtil.showToast(errorMsg);
                      }
                    });
                  }
                }
                else if(this.awardState == 3){
                  if(this.timeClose == '查看中奖名单'){
                    VHSaaSDK.getInstance().getWatchGiftWinnerRank(this.watchGiftId?.id!,0,10,{
                      onSucceed: (data: VHWinner) => {
                        this.isShowWinnerList = true;
                        this.winners.updateData(data.list);
                        this.awardState = 4;
                      },
                      onFailure: (errorCode: number, errorMsg: string) => {
                        ToastUtil.showToast(errorMsg);
                      }
                    });
                  }else{
                    PromptActionClass.closeDialog();
                  }
                }
                else{
                  //参与中将
                  VHSaaSDK.getInstance().setWatchGiftParticipate(this.webinar_info.webinar?.id!,this.watchGiftId.id!,this.webinar_info?.interact?.room_id!,this.webinar_info?.switch_info?.switch_id!,{
                    onSucceed: (participateData: VHWatchGiftParticipate) => {
                      this.participateGift = participateData;
                      VHSaaSDK.getInstance().getWatchGiftLastInfo(this.webinar_info.webinar?.id!,{
                        onSucceed: (dataGift: VHWatchGiftInfo|null) => {
                          if(dataGift == null){
                            return
                          }
                          let giftInfo = dataGift;
                          if(this.timeId != 0){
                            clearInterval(this.timeId);
                          }
                          if(this.giftSetting.receive_award_way == 1 || this.giftSetting.receive_award_way == 2){//无需领奖
                            if(participateData.winning == 1){//中奖
                              this.timeClose = "立即领奖"
                              this.awardState = 2;
                            }
                            else{
                              this.awardState = 1;//没有中奖
                              this.showBtn = false;
                            }
                          }else{
                            if(this.giftSetting.receive_award_way == 3 || giftInfo.can_look_winner_list == 1){
                              this.timeClose = "查看中将名单"
                              this.awardState = 2;
                            }  else{
                              this.awardState = 1;//没有中奖
                            }
                          }
                        },
                        onFailure: (errorCode: number, errorMsg: string) => {
                          ToastUtil.showToast(errorMsg);
                        }
                      })
                    },
                    onFailure: (errorCode: number, errorMsg: string) => {
                      ToastUtil.showToast(errorMsg);
                    }
                  });
                }
              }
            })
        }

        Row({space:4}){
          if(this.awardState == 0){
            Text(this.tips)
              .fontSize(16)
              .fontColor(Color.White)
            Button(this.checkTips)
              .borderWidth(1)
              .borderColor(Color.White)
              .padding({left:4,top:2,bottom:2,right:4})
              .height(20)
              .borderRadius(10)
              .backgroundColor('#00FFFFFF')
              .onClick(()=>{
                VHSaaSDK.getInstance().getWatchGiftAwardList(this.webinar_info?.webinar?.id!,this.watchGiftId?.id!,{
                  onSucceed: (data: VHWatchGiftAward) => {
                    this.isCheckAwardList = true;
                    if(data.total > 0){
                      this.highlightDataSource.updateData(data.list);
                    }
                  },
                  onFailure: (errorCode: number, errorMsg: string) => {

                  }
                });
              })
          }
        }
        if(!this.isEnd){
          Text("请勿离开直播间，以免失去中奖资格")
            .fontSize(12)
            .fontColor(Color.Gray)
        }
        Image($r("app.media.close")).width(24).height(24)
          .onClick(()=>{
            PromptActionClass.closeDialog();
          })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .borderRadius(10)
      .height(this.awardState == 3 ? '40%' : '100%')
      .backgroundColor(this.awardState == 3 ? '#FDF5E7':'#00000000')
      .zIndex(0)

      if(this.isCheckAwardList){
        Column({space:20}){
          Stack({ alignContent: Alignment.Center}){
            Text('本轮奖品')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')  // 改为白色文字
              .backgroundColor('#E53935') // 主色作为背景
              .padding({ left: 20, right: 20, top: 10, bottom: 10 })
              .borderRadius(20)
              .shadow({
                radius: 8,          // 阴影扩散半径
                color: '#B71C1C',   // 深红色阴影
                offsetX: 3,         // 水平偏移量
                offsetY: 3          // 垂直偏移量
              })
              .border({
                width: 2,           // 边框粗细
                color: '#FFCDD2'    // 浅红色边框
              })
              .rotate({ angle: -3 })// 文字倾斜角度
              .textAlign(TextAlign.Center)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .zIndex(0)
              .width('60%')
              .textAlign(TextAlign.Center) // 文本内容在自身组件内居中
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            RelativeContainer(){
              Image($r('app.media.close')).width(24).height(24)
                .onClick(()=>{
                  this.isCheckAwardList = false;
                })
                .alignRules({
                  middle: { anchor: '__container__', align: HorizontalAlign.Center },
                  right: { anchor: '__container__', align:HorizontalAlign.End }
                })
                .offset({x:50})
            }.zIndex(1)
            .height(20)
            .width('100%')
          }.width('100%')


          List({space:10}) {
            LazyForEach(
              this.highlightDataSource,
              // 渲染单个高亮项
              (item: VHGiftAwardItem) => {
                ListItem() {
                  // 左侧：高亮截图
                  this.AwardItem(item)
                }
                .alignSelf(ItemAlign.Center)
                .align(Alignment.Center)
                .width('90%')
              },(item: VHGiftAwardItem) => `${item.award_id}` // 用URL+时间确保唯一性
            );
          }
          .height('70%')
          .alignListItem(ListItemAlign.Center)
          .backgroundColor('#FDF5E7')
          .sticky(StickyStyle.Header) // 设置吸顶，实现粘性标题效果
        }
        .backgroundColor('#FDF5E7')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .width('80%')
        .height('60%')
        .zIndex(1)
        .borderRadius(20)
      }

      if(this.isShowWinnerList){
        Column({space:20}){
          Stack({ alignContent: Alignment.Center}){
            Text('中奖名单')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')  // 改为白色文字
              .backgroundColor('#E53935') // 主色作为背景
              .padding({ left: 20, right: 20, top: 10, bottom: 10 })
              .borderRadius(20)
              .shadow({
                radius: 8,          // 阴影扩散半径
                color: '#B71C1C',   // 深红色阴影
                offsetX: 3,         // 水平偏移量
                offsetY: 3          // 垂直偏移量
              })
              .border({
                width: 2,           // 边框粗细
                color: '#FFCDD2'    // 浅红色边框
              })
              .rotate({ angle: -3 })// 文字倾斜角度
              .textAlign(TextAlign.Center)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .zIndex(0)
              .width('60%')
              .textAlign(TextAlign.Center) // 文本内容在自身组件内居中
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            RelativeContainer(){
              Image($r('app.media.close')).width(24).height(24)
                .onClick(()=>{
                  PromptActionClass.closeDialog();
                })
                .alignRules({
                  middle: { anchor: '__container__', align: HorizontalAlign.Center },
                  right: { anchor: '__container__', align:HorizontalAlign.End }
                })
                .offset({x:50})
            }.zIndex(1)
            .height(20)
            .width('100%')
          }.width('100%')


          List({space:10}) {
            LazyForEach(
              this.winners,
              // 渲染单个高亮项
              (item: VHWatchGiftWinner) => {
                ListItem() {
                  // 左侧：高亮截图
                  this.WinnerItem(item);
                }
                .alignSelf(ItemAlign.Center)
                .align(Alignment.Center)
                .width('100%')
              },(item: VHWatchGiftWinner) => `${item.winner_join_id}` // 用URL+时间确保唯一性
            );
          }
          .height('70%')
          .alignListItem(ListItemAlign.Center)
          .backgroundColor('#FDF5E7')
          .sticky(StickyStyle.Header) // 设置吸顶，实现粘性标题效果
        }
        .backgroundColor('#FDF5E7')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .width('90%')
        .height('60%')
        .zIndex(1)
        .borderRadius(20)
      }


      if(this.showSetting){
        Column({space:10}){
          Text('领奖信息')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')  // 改为白色文字
            .backgroundColor('#E53935') // 主色作为背景
            .padding({ left: 20, right: 20, top: 10, bottom: 10 })
            .borderRadius(20)
            .shadow({
              radius: 8,          // 阴影扩散半径
              color: '#B71C1C',   // 深红色阴影
              offsetX: 3,         // 水平偏移量
              offsetY: 3          // 垂直偏移量
            })
            .border({
              width: 2,           // 边框粗细
              color: '#FFCDD2'    // 浅红色边框
            })
            .rotate({ angle: -3 })// 文字倾斜角度
            .textAlign(TextAlign.Center)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .zIndex(0)
            .width('60%')
            .textAlign(TextAlign.Center) // 文本内容在自身组件内居中
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          List({space:10}) {
            ForEach(
              this.settingDataSource,
              // 渲染单个高亮项
              (item: VHGiftAwardFiled) => {
                ListItem() {
                  // 左侧：高亮截图
                  this.AwardSettingItem(item)
                }
                .alignSelf(ItemAlign.Center)
                .align(Alignment.Center)
                .width('90%')
              },(item: VHGiftAwardFiled) => `${item.field}${item.field_key}}` // 用URL+时间确保唯一性
            );
          }
          .padding(10)
          .height('70%')
          .alignListItem(ListItemAlign.Center)
          .backgroundColor('#FDF5E7')
          .sticky(StickyStyle.Header) // 设置吸顶，实现粘性标题效果
          .zIndex(3)
          .scrollBar(BarState.Auto) // 自动显示滚动条（可选）

          Button("提交")
            .width(100)
            .height(30)
            .borderRadius(15)
            .enabled(this.isEnableEmit)
            .backgroundColor(this.awardState == 0 ? Color.Orange : Color.Red)
            .onClick(()=>{
              const listenerJsonStr = JSON.stringify(this.settingDataSource);
                let saveData =listenerJsonStr;// this.settingDataSource.getJson();
                VHSaaSDK.getInstance().saveWatchGift(this.watchGiftId.id!,saveData,{
                  // 成功
                  onSuccess: (data: string | object) => {
                      this.awardState = 3;
                      this.showSetting = false;
                      VHSaaSDK.getInstance().getWatchGiftWinnerDetail(this.watchGiftId?.id!,{
                        onSucceed: (giftData: VHWatchGiftWinnerDetail) => {
                          if(giftData.can_look_winner_list == 1){
                            this.timeClose = "查看中奖名单"
                          }else{
                            this.timeClose = "关闭"
                          }

                        },

                        onFailure: (errorCode: number, errorMsg: string) => {

                        }
                      });
                  },
                  // 失败
                  onFailure: (errorCode: number, errorMsg: string) => {
                    this.getUIContext().getPromptAction().showToast({
                      message: errorMsg,
                      duration: 2000,
                      showMode: promptAction.ToastShowMode.DEFAULT,
                      bottom: 80
                    });
                  }
                });
            })

          Row(){
            Text("提交即同意")
            Text("《隐私政策》").fontColor(Color.Blue).onClick(()=>{
              WantUtil.toWebBrowser("https://e.vhall.com/v3/privacyPolicy");
            })
            Text("及")
            Text("《用户保护协议》").fontColor(Color.Blue).onClick(()=>{
              WantUtil.toWebBrowser("https://e.vhall.com/v3/privacyUPo");
            })
          }
        }
        .zIndex(3)
        .backgroundColor('#FDF5E7')
        .justifyContent(FlexAlign.Center)
        .height('60%')
        .borderRadius(10)
      }

      if(this.showQRGift){
        Column({space:10}){
          Text('领奖信息')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')  // 改为白色文字
            .backgroundColor('#E53935') // 主色作为背景
            .padding({ left: 20, right: 20, top: 10, bottom: 10 })
            .borderRadius(20)
            .shadow({
              radius: 8,          // 阴影扩散半径
              color: '#B71C1C',   // 深红色阴影
              offsetX: 3,         // 水平偏移量
              offsetY: 3          // 垂直偏移量
            })
            .border({
              width: 2,           // 边框粗细
              color: '#FFCDD2'    // 浅红色边框
            })
            .rotate({ angle: -3 })// 文字倾斜角度
            .textAlign(TextAlign.Center)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .zIndex(0)
            .width('60%')
            .textAlign(TextAlign.Center) // 文本内容在自身组件内居中
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Image($r('app.media.close')).width(24).height(24)
            .onClick(()=>{
              PromptActionClass.closeDialog();
            })


          ForEach(this.giftSetting.receive_award_field,(item: VHGiftAwardFiled, index: number)=>{
            if(item.field_key == 'private_qrcode'){
              Image(item.placeholder).width(220).height(220)
            }else if(item.field_key == 'tip_note'){
              Text(item.placeholder).fontSize(12)
            }else if(item.field_key == 'private_number'){
              Text(item.placeholder)
            }
          });

        }
        .zIndex(3)
        .backgroundColor('#FDF5E7')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('80%')
        .height('50%')
        .borderRadius(10)
      }
    }
    .width('100%')
    .height(this.watchGiftId.display_of_results == 0 ? '100%' : '50%')

  }
}