import { VHCardInfo,
  VHGiftAwardFiled,
  VHGiftAwardItem,
  VHInteractAwardSetting,
  VHInteractMyAward,
  VHInteractMyAwardDetails,
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
import { ComponentContent, promptAction } from "@kit.ArkUI";
import { ToastUtil } from "../action/ToastUtil";
import { createInteractAwardGiftViewFromAwardList, InteractAwardParamsFromAwardList } from "./InteractAwardBuilder";

// 自定义参数类型
export class MyAwardParams {
  gift: VHInteractMyAward;
  webinar_info:VHWebinarData;
  constructor(id: VHInteractMyAward,info:VHWebinarData) {
    this.gift = id;
    this.webinar_info = info;
  }
}

export class AwardDataSource extends BasicDataSource<VHInteractMyAwardDetails> {
  private listener: VHInteractMyAwardDetails[] = [];

  notifyDataReload(): void {
    super.notifyDataReload();
  }

  totalCount(): number {
    return this.listener.length
  }

  getData(index: number): VHInteractMyAwardDetails {
    return this.listener[index]
  }

  updateData(newList: VHInteractMyAwardDetails[]): void {
    this.listener = newList;
    this.notifyDataAdd(this.listener.length - 1);
  }
}

@Builder
export function createMyAwardView(parm:MyAwardParams){
  WatchGiftView({gift:parm.gift,webinar_info:parm.webinar_info});
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
  @State gift:VHInteractMyAward = new VHInteractMyAward();
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
  @State showSetting:boolean = false;
  @State showQRGift:boolean = false;
  @State webinar_info:VHWebinarData = new VHWebinarData();
  @State settingDataSource: VHGiftAwardFiled[] = [];
  private interactAwardContentNode: ComponentContent<Object> | null = null;
  private timeId:number = -1;
  aboutToAppear(): void {


  }
  aboutToDisappear(): void {

  }

  @Builder
  AwardItem(item: VHInteractMyAwardDetails) {
    // 半模态的内容
    Column({ space: 5 }){
      Row({ space: 10 }) {
        Image(item.award_img_url)
          .width(60)
          .height(60)
          .objectFit(ImageFit.Cover)
          .borderRadius(4)

        Column(){
          Text(item.award_name)
          Text(item.winning_time)
        }.justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)

        if(item.status == 0){
          Button("领取").fontColor(Color.White).backgroundColor(Color.Red)
            .onClick(()=>{
              VHSaaSDK.getInstance().getReceiveAwardSetting(this.webinar_info?.webinar?.id!,item.interact_reward_id,{
                onSucceed: (data: VHInteractAwardSetting) =>{
                  if(data.receive_award_way == 3){
                    //直接显示中奖内容。
                  }else {
                    this.settingDataSource = data.json_data;
                  }
                  PromptActionClass.closeDialog();
                  const params = new InteractAwardParamsFromAwardList(data,this.webinar_info,item.interact_reward_id);
                  this.interactAwardContentNode = new ComponentContent(this.getUIContext(), wrapBuilder(createInteractAwardGiftViewFromAwardList), params);
                  PromptActionClass.setContext(this.getUIContext());
                  PromptActionClass.setContentNode(this.interactAwardContentNode);
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

                },
                onFailure: (errorCode: number, errorMsg: string) => {
                  ToastUtil.showToast(errorMsg);
                }
              })
            })
        }else if(item.status == 1){
          Button("已领取").fontColor(Color.Gray).backgroundColor(Color.White)
        }else if(item.status == 2){
          Button("已中奖").fontColor(Color.Gray).backgroundColor(Color.White)
        }

      }.width('100%')
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding(10)
    .backgroundColor(Color.White)
  }



  build() {
    Column({space:10}){
      Stack({alignContent:Alignment.Center}){
        Image($r("app.media.icon_lottery_top"))
        Text("我的礼品").fontColor(Color.Red)
      }.height(50)

      List({space:10}) {
        ForEach(
          this.gift.list,
          // 渲染单个高亮项
          (item: VHInteractMyAwardDetails) => {
            ListItem() {
              // 左侧：高亮截图
              this.AwardItem(item)
            }
            .alignSelf(ItemAlign.Center)
            .align(Alignment.Center)
            .width('90%')
          },(item: VHInteractMyAwardDetails) => `${item.id}${item.interact_reward_id}}` // 用URL+时间确保唯一性
        );
      }
      .padding(10)
      .height('70%')
      .alignListItem(ListItemAlign.Center)
      .backgroundColor('#FDF5E7')
      .sticky(StickyStyle.Header) // 设置吸顶，实现粘性标题效果
      .zIndex(3)
      .scrollBar(BarState.Auto) // 自动显示滚动条（可选）

      Image($r("app.media.close")).width(20).height(20)
        .onClick(()=>{
          PromptActionClass.closeDialog();
        })
    }
    .backgroundColor('#FDF5E7')
    .width('100%')
    .height('50%')
  }
}