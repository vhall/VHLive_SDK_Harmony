import { promptAction } from "@kit.ArkUI";
import { PromptActionClass } from "../util/PromptActionClass";
import {VHPlayerConfig} from '@vhall/vhall_live'
import { EmitterMsgData, EmitterUtil } from "../util/EmitterUtil";
import { ToastUtil } from "../action/ToastUtil";

@Builder
export function createPlayerSettingView(player_config:VHPlayerConfig ){
  CommonSettingView({config:player_config});
}


/**
 * 操作项信息
 */
export interface ActionItem {
  id: string;
  title: string | Resource;
  subTitle: string | Resource;
  switchType : boolean;
  enable : boolean;
}

@Component
export struct ActionSectionView {

  actionItems: ActionItem[] = [];       // 操作项数组
  onClickItem?: (id: string) => void;   // 操作项点击处理

  build() {
    Column() {
      ForEach(this.actionItems, (actionItem: ActionItem, index: number) => {
        this.createActionItem(actionItem, this.onClickItem)
        if (index < this.actionItems.length - 1) {
          this.createDivider()
        }
      })
    }.sectionStyle()
  }

  /**
   * 创建一条操作栏目的视图
   * @param title
   * @param onClick
   * @param subTitle
   */
  @Builder
  createActionItem(actionItem: ActionItem,
    onClickItem?: (id: string) => void) {
    Row() {
      Image(actionItem.subTitle)
        .margin({
          left: 12
        })
        .width(20)
        .height(20)

      Text(actionItem.title)
        .fontSize(14)
        .margin({left:6})
        .fontColor(actionItem.enable ? Color.Black : Color.Gray)

      Blank()

      if(actionItem.switchType){
        Toggle({ type: ToggleType.Switch,isOn : actionItem.enable ? true : false})
          .onChange((isOn: boolean) => {
            let msgData: EmitterMsgData;
            msgData = {
              type:  actionItem.id, // 消息类型
              enable: isOn
            } as EmitterMsgData;
            // 通过EmitterUtil发送
            EmitterUtil.send(msgData);
          }).margin({right:8})
          .selectedColor(Color.Pink)
          .enabled(actionItem.enable ? true : false)

      }else{
        Image($r('app.media.to_setting'))
          .margin({
            left: 12
          })
          .width(20)
          .height(20)
          .onClick(()=>{
              if(actionItem.enable){

              }
          })
      }
    }
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height(50)
    .onClick(() => {
      if(!actionItem.enable){
        ToastUtil.showToast("此功能已禁用");
      }
      if (onClickItem) {
        onClickItem(actionItem.id)
      }
    })
  }

  /**
   * 创建特定样式的分隔线
   */
  @Builder
  createDivider() {
    Divider()
      .vertical(false)
      .strokeWidth(0.5)
      .color(0xE0E0E0)
      .width('80%')
  }

  /**
   * section的样式
   */
  @Styles
  sectionStyle() {
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(4)
    .padding({
      left: 4,
      right:4
    })
  }

}

/**
 * 常用设置底部弹窗视图
 */
@Component
export struct CommonSettingView {
  public config?:VHPlayerConfig;
  scroller: Scroller = new Scroller();


  getSecondSectionActionItems():ActionItem[]{
    let actionItems:ActionItem[] =
      [{ id: '1001', title: '弹幕', subTitle: $r('app.media.barrage')  ,switchType:true,enable:this.config?.basic?.barrage_button == 1 ? true : false}]
    return actionItems;
  }

  build() {
    Column() {
      RelativeContainer() {
        Text('播放器设置')
          .fontSize(16)
          .fontColor(Color.Black)
          .fontWeight(FontWeight.Bold)
          .alignRules({
            middle: { anchor: '__container__', align: HorizontalAlign.Center },
            center: { anchor: '__container__', align: VerticalAlign.Center }
          })

        Image($r('app.media.close'))
          .width(14)
          .height(14)
          .alignRules({
            middle: { anchor: '__container__', align: HorizontalAlign.End },
            center: { anchor: '__container__', align: VerticalAlign.Center }
          })
          .offset({
            x: -20
          })
          .onClick(() => {
            PromptActionClass.closeDialog();
          })
          .id('close_image')
      }.width('100%')
      .height(48)

      Scroll(this.scroller){
        Column(){
          ActionSectionView({
            actionItems: this.getSecondSectionActionItems()
          })
        }
        // .padding({ bottom: 10})
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius({
          topLeft: 8,
          topRight: 8
        })
        .height('80%')
      }
      .width('90%')
      .scrollable(ScrollDirection.Vertical) // 滚动方向为垂直方向
      // TODO：知识点：使用constraintSize方法可以设置约束尺寸，组件布局时，进行尺寸范围限制。这里设置Scroll组件的高度限制。
      .constraintSize({maxHeight: 400})
      .backgroundColor(Color.White)
      .borderRadius({
        topLeft: 8,
        topRight: 8
      })
    }
    .borderRadius({
      topLeft: 8,
      topRight: 8
    })
    .width('100%')
    .backgroundColor(0xF5F5F5)
  }
}