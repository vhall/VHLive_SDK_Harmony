import { BeautyFilterComponent } from "./BeautyFilterComponent";
import { BeautyShapeComponent } from "./BeautyShapeComponent";
import emitter from "@ohos.events.emitter";

@CustomDialog
export struct BeautyComponent {
  private ResetDialogController: CustomDialogController = new CustomDialogController({
    builder: ResetDialog(),
  })
  controller: CustomDialogController = new CustomDialogController({
    builder: BeautyComponent(),
  })
  @State currentIndex: number = 0;
  build() {
    Column(){
      Row(){
        Row({space: 20}) {
          Row(){
            Text('美颜')
              .fontColor(this.currentIndex === 0 ? Color.Black : "#999999")
          }
          .padding({ top:15, bottom: 15})
          .border(this.currentIndex === 0 ?{color:{bottom: Color.Red},width: {bottom: 2}}:{ width: 0})
          .onClick(() => {
            this.currentIndex = 0;
          })
          Row(){
            Text("滤镜")
              .fontColor(this.currentIndex === 1 ? Color.Black : "#999999")
          }
          .padding({ top:15, bottom: 15})
          .border(this.currentIndex === 1 ?{color:{bottom: Color.Red},width: {bottom: 2}}:{width: 0})
          .onClick(() => {
            this.currentIndex = 1;
          })
        }
        Row({space:5}){
          Image($r("app.media.icon_reset"))
            .width(14)
          Text("重置")
            .fontColor("#999999")
            .fontSize(14)
            .onClick(() => {
              this.ResetDialogController.open();
            })
        }
      }
      .width("100%")
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({left: 20, right: 20})

      Divider()
        .strokeWidth(1)
      Stack(){
        BeautyShapeComponent()
          .visibility(this.currentIndex === 0 ? Visibility.Visible : Visibility.Hidden)
        BeautyFilterComponent()
          .visibility(this.currentIndex === 1 ? Visibility.Visible : Visibility.Hidden)
      }
    }
    .width("100%")
    .height(250)
    .borderRadius(20)
    .backgroundColor(Color.White)
  }
}

@CustomDialog
struct ResetDialog {
  dialogController: CustomDialogController = new CustomDialogController({
    builder: ResetDialog(),
  })


  build() {
    Column(){
      Text("确认恢复默认效果吗？")
        .width("100%")
        .height(80)
        .textAlign(TextAlign.Center)
      Row(){
        Text("取消")
          .width("50%")
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.dialogController.close();
          })
          .height(50)
          .border({width:{right:1}, color:"#eeeeee"})
        Text("确认")
          .width("50%")
          .textAlign(TextAlign.Center)
          .fontColor(Color.Red)
          .onClick(() => {
            this.dialogController.close();
            emitter.emit("beauty_reset");
          })
          .height(50)
      }
      .width("100%")
      .border({width:{top:1}, color:"#eeeeee"})
    }
  }
}