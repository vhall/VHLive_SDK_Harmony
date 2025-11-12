import { VHCardInfo,
  VHGiftAwardFiled,
  VHGiftAwardItem,
  VHInteractAwardSetting,
  VHInteractRewardWinning,
  VHPushScreenCard, VHSaaSDK,
  VHStatementInfo,
  VHWatchGiftAward,
  VHWatchGiftInfo, VHWatchGiftOpenMsg,
  VHWatchGiftParticipate,
  VHWatchGiftSetting,
  VHWatchGiftWinner,
  VHWatchGiftWinnerDetail,
  VHWebinarData,
  VHWebinarList,
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
import { webview } from "@kit.ArkWeb";
import { VHIntroductionView } from "../components/introduction/VHIntroductionView";

// 自定义参数类型
export class InteractAwardParams {
  gift: VHInteractRewardWinning;
  webinar: VHWebinarData;

  constructor(id: VHInteractRewardWinning, webinar: VHWebinarData) {
    this.gift = id;
    this.webinar = webinar;
  }
}

// 自定义参数类型
export class InteractAwardParamsFromAwardList {
  settingDataSource: VHInteractAwardSetting;
  webinar: VHWebinarData;
  interact_award_id:number = 0;

  constructor(settings: VHInteractAwardSetting, webinar: VHWebinarData,interact_award_id:number) {
    this.settingDataSource = settings;
    this.webinar = webinar;
    this.interact_award_id = interact_award_id;
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
    return this.listener.length
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
export function createInteractAwardGiftView(parm:InteractAwardParams){
  InteractAwardView({interactReward:parm.gift, webinar_info:parm.webinar});
}

@Builder
export function createInteractAwardGiftViewFromAwardList(parm:InteractAwardParamsFromAwardList){
  InteractAwardView({settting:parm.settingDataSource, webinar_info:parm.webinar,interact_reward_id:parm.interact_award_id});
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
export struct InteractAwardView {
  private highlightDataSource: AwardDataSource = new AwardDataSource();
  @State winners:WinnerDataSource = new WinnerDataSource();
  @State settingDataSource: VHGiftAwardFiled[] = [];
  @State settting: VHInteractAwardSetting = new VHInteractAwardSetting;

  @State models:VHGiftAwardItem[] = [];
  @State interactReward:VHInteractRewardWinning = new VHInteractRewardWinning();
  @Require webinar_info:VHWebinarData;

  private interact_reward_id :number = 0;//从中奖列表获取

  @State imagHeight:number = 200;
  @State imagHeightBackGround:number = 190;

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
  @State showSetting:boolean = false;
  @State showQRGift:boolean = false;
  @State statement:string = "我们根据<a href=\"pages/Privacy1\" style=\"color:#007DFF; text-decoration:underline;\">《隐私声明》</a>和<a href=\"https://example.com/privacy2\" style=\"color:#007DFF; text-decoration:underline;\">《隐私声明2》</a>保护您填写的所有信息\n";
  @State statement_status:boolean = false;

  private timeId:number = -1;
  aboutToAppear(): void {
    if(this.interactReward){
      if(this.interactReward.winner_id == this.webinar_info.join_info?.third_party_user_id){
        this.awardState = 2;//中奖
      }else{
        this.awardState = 1;//未中奖
      }
    }

    if(this.interact_reward_id != 0){
      if(this.settting.receive_award_way == 1){
        this.settingDataSource = this.settting.json_data;
        this.showSetting = true;
      }else if(this.settting.receive_award_way == 2){
        this.settingDataSource = this.settting.json_data;
        this.showQRGift = true;
      }
    }

    //隐私协议
    if(this.settting.statement_status == 1){
      let linkMap: Record<string, string> ={};
      this.settting.statement_info.forEach((value:VHStatementInfo,index:number,array:VHStatementInfo[])=>{
        linkMap[value.title] = value.link;
      })
      this.statement = this.generateHtmlRichText(this.settting.statement_content,linkMap);
      this.statement_status = true;
    }

  }
  aboutToDisappear(): void {

  }


  private  generateHtmlRichText(
    originalText: string,
    linkMap: Record<string, string>
  ): string {
    let htmlContent = originalText;

    // 遍历链接映射（改用数组索引，避免解构）
    Object.entries(linkMap).forEach((item) => {
      const keyword = item[0]; // 键（如"《隐私声明》"）
      const url = item[1];     // 值（如"pages/Privacy1"）

      // 转义关键词中的特殊字符（避免正则匹配错误）
      const escapedKeyword = keyword.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      // 替换规则：关键词 -> <a>标签（带链接和样式）
      const replaceReg = new RegExp(escapedKeyword, 'g');
      const linkHtml = `<a href="${url}" style="color:#007DFF; text-decoration:underline;">${keyword}</a>`;
      htmlContent = htmlContent.replace(replaceReg, linkHtml);
    });

    // 外层包裹span，统一设置字体大小为50px
    return `<span style="font-size:15px;">${htmlContent}</span>`;
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

   private  getClickableRichTextStr(
    originalText: string,
    linkMap: Map<string, string>
  ): string {
    let resultStr = originalText;
    //
    // // 遍历所有关键词，用自定义标记包裹（格式：[a:href=链接]关键词[/a]）
    // Object.entries(linkMap).forEach(([keyword, href]) => {
    //   // 替换规则：将"关键词"替换为"[a:href=链接]关键词[/a]"
    //   const replaceReg = new RegExp(keyword.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g');
    //   const replaceStr = `[a:href=${encodeURIComponent(href)}]${keyword}[/a]`;
    //   resultStr = resultStr.replace(replaceReg, replaceStr);
    // });

    return resultStr;
  }



  build() {
    Stack({alignContent:Alignment.Center}){
      Column({space: 20}) {
          if(this.awardState == 1){//没有中奖
            Image($r("app.media.icon_lottery_no")).width(185).height(185).zIndex(2)
          }else if(this.awardState == 2){//领奖
            Stack({ alignContent: Alignment.Center }){
              Image($r("app.media.icon_lottery_winer")).width(240).height(240).zIndex(1)
              Image(this.interactReward.award_snapshot.award_img_url)
                .width(140)
                .height(140)
                .zIndex(4)
                .borderRadius(70)
                .objectFit(ImageFit.Cover)
            }

            Text("【奖品】" + this.interactReward.award_snapshot.award_name)
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

            if(this.interactReward.receive_award_way == 1|| this.interactReward.receive_award_way == 2 ){
              Button("立即领奖")
                .width(150)
                .height(30)
                .backgroundColor(Color.Red)
                .borderRadius(15)
                .onClick(()=>{
                  VHSaaSDK.getInstance().getReceiveAwardSetting(this.webinar_info?.webinar?.id!,this.interactReward.interact_reward_id,{
                    onSucceed: (data: VHInteractAwardSetting) =>{
                      if(data.receive_award_way == 1){
                        this.settting = data;
                        this.settingDataSource = data.json_data;
                        this.showSetting = true;
                      }else if(data.receive_award_way == 2){
                        this.settting = data;
                        this.settingDataSource = data.json_data;
                        this.showQRGift = true;
                      }
                      if(data.statement_status == 1){
                        let linkMap: Record<string, string> ={};
                        this.settting.statement_info.forEach((value:VHStatementInfo,index:number,array:VHStatementInfo[])=>{
                          linkMap[value.title] = value.link;
                        })
                        this.statement = this.generateHtmlRichText(this.settting.statement_content,linkMap);
                        this.statement_status = true;
                      }

                    },
                    onFailure: (errorCode: number, errorMsg: string) => {
                      ToastUtil.showToast(errorMsg);
                    }
                  })
                })
            }
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


        Image($r("app.media.close")).width(20).height(20)
          .onClick(()=>{
            PromptActionClass.closeDialog();
          })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .borderRadius(10)
      .height('40%')
      .backgroundColor(this.awardState == 3 ? '#FDF5E7':'#00000000')
      .zIndex(0)

      if(this.showSetting){
        Column({space:10}){
          Row({space:10}){
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


            Image($r('app.media.close_gray'))
              .width(20)
              .height(20)
              .margin({top:20})
              .onClick(()=>{
                PromptActionClass.closeDialog();
              })
          }



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
              let lottery_user_name:string = "";
              let lottery_user_phone:string = "";
              this.settingDataSource.forEach((value:VHGiftAwardFiled,index:number,array:VHGiftAwardFiled[])=>{
                  if(value.field_key == "name"){
                    lottery_user_name = value.field_value;
                  }else if(value.field_key == "phone"){
                    lottery_user_phone = value.field_value;
                  }

              })
              //
              VHSaaSDK.getInstance().saveInteractAward(this.webinar_info.interact?.room_id!,
                this.interactReward.interact_reward_id != 0 ? this.interactReward.interact_reward_id : this.interact_reward_id,
                lottery_user_name,lottery_user_phone,listenerJsonStr,{
                // 成功
                onSuccess: (data: string | object) => {
                  ToastUtil.showToast("提交成功");
                  PromptActionClass.closeDialog();
                },

                // 失败
                onFailure: (errorCode: number, errorMsg: string) => {
                  ToastUtil.showToast(errorMsg);
                }
              })
            })

          Row(){
            if(this.settting.statement_status == 1){
              VHIntroductionView({introduction:this.statement})
                .width('100%')
                .height('30%')
            }
            else{
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


        }
        .zIndex(3)
        .backgroundColor('#FDF5E7')
        .justifyContent(FlexAlign.Center)
        .height('60%')
        .borderRadius(10)
      }

      if(this.showQRGift){
        Column({space:10}){
          Row({space:10}){
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


            Image($r('app.media.close_gray'))
              .width(20)
              .height(20)
              .margin({top:20})
              .onClick(()=>{
                PromptActionClass.closeDialog();
              })

          }



          ForEach(this.settingDataSource,(item: VHGiftAwardFiled, index: number)=>{
            if(item.field_key == 'private_qrcode'){
              Image(item.placeholder).width(220).height(220)
            }else if(item.field_key == 'tip_note'){
              Text(item.placeholder).fontSize(12)
            }else if(item.field_key == 'private_number'){
              Text(item.placeholder)
            }
          });

          Image($r('app.media.close')).width(24).height(24)
            .onClick(()=>{
              PromptActionClass.closeDialog();
            })
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
    .height(this.interactReward.display_of_results == 0 ? '100%' : '50%')

  }
}