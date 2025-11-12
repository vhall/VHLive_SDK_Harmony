import { VHDocument, VHDocumentView } from "@vhall/vhallyun-doc"
import { VHDocWatermarkType, } from "../model/VHWatchWebinarInfo";
import { VHDoc } from "./VHDoc"


@Component
export struct VHDocView {
  /**
   * @description  文档控制器
   * */
  @Require docController:VHDoc;
  /**
   * @description 文档id
   * */
  @Require docId:string;
  /**
   *@description 是否响应绘制、涂鸦等事件。发起端时为true 观看端为false
   * */
  @Prop isDocPaint:boolean = false;


  private doc:VHDocument | null = null;

  aboutToAppear(): void {
    this.doc =  this.docController.getDocModel(this.docId) as VHDocument;
  }

  build() {
    Row(){
      VHDocumentView({vhDocInterface:this.docController, vhDocument:this.doc, demonstrateProgress: true, isPaint:this.isDocPaint})
        .width('100%')
        .height('100%')
        .align(Alignment.Bottom)

    }.justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Color.Green)
    .width('100%')
    .height('100%')
  }
}

