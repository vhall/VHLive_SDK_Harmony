import { VHSaaSDK } from '@vhall/vhall_live';
import { ToastUtil } from '../../action/ToastUtil';

@CustomDialog
export struct DefaultRecordDialog {
  private record_id: string = "";
  private pageInfos: NavPathStack = new NavPathStack() // 导航
  dialogController: CustomDialogController;

  build() {
    Column(){
      Text("自动生成回放成功，是否设置为默认回放?")
        .width("100%")
        .height(80)
        .textAlign(TextAlign.Center)
      Row(){
        Text("取消")
          .width("50%")
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.dialogController.close();
            this.pageInfos.pop();
          })
          .height(50)
          .border({width:{right:1}, color:"#eeeeee"})
        Text("确认")
          .width("50%")
          .textAlign(TextAlign.Center)
          .fontColor(Color.Red)
          .onClick(() => {
            this.dialogController.close();
            VHSaaSDK.getInstance().setDefaultRecord(this.record_id, "1", {
              onSuccess: (data: string | object) => {
                ToastUtil.showToast("设置默认回放成功");
                this.pageInfos.pop();
              },
              onFailure: (code: number, errorMsg: string) => {
                console.info("设置默认回放失败：" + code + " " + errorMsg);
                this.pageInfos.pop();
              }
            })
          })
          .height(50)
      }
      .width("100%")
      .border({width:{top:1}, color:"#eeeeee"})
    }
    .backgroundColor(Color.White)
  }
}