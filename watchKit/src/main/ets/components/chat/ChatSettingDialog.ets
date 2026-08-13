import { ComponentContent, CustomContentDialog, KeyboardAvoidMode, LengthMetrics } from '@kit.ArkUI';

@CustomDialog
export struct ChatSettingDialog{
  controller: CustomDialogController
  // ========== 2. 内部状态，绑定Switch
  @Prop watchHost: boolean ;
  @Prop watchContext: boolean;
  @Prop hideEffect: boolean ;


  @Prop watchHostState: boolean = false;
  @Prop watchContextState: boolean= false;
  @Prop hideEffectState: boolean = false;

  async aboutToAppear() {

  }

  aboutToDisappear(): void {
    if(this.onChatSetting){
      this.onChatSetting(this.watchHost, this.watchContext, this.hideEffect);
    }
  }

  onChatSetting?: (only_watch_host:boolean,only_watch_context:boolean,hide_effect:boolean) => void

  build() {
    Column() {
      if(this.watchHostState){
        Row(){
          Text("只看主办方").width('70%')
          Toggle({ type: ToggleType.Switch, isOn: this.watchHost })
            .id('toggle1')
            .onChange((value: boolean) => {
              this.watchHost = value;
            })
        }.justifyContent(FlexAlign.SpaceAround)
        .width('100%')
        .height("5%")
      }
      if(this.hideEffectState){
        Row(){
          Text("屏蔽特效").width('70%')
          Toggle({ type: ToggleType.Switch, isOn: this.hideEffect })
            .id('toggle2')
            .onChange((value: boolean) => {
              this.hideEffect = value;
            })
        }.justifyContent(FlexAlign.SpaceAround)
        .width('100%')
        .height("5%")
      }

      if(this.watchContextState){
        Row(){
          Text("仅查看聊天内容").width('70%')
          Toggle({ type: ToggleType.Switch, isOn: this.watchContext })
            .id('toggle3')
            .onChange((value: boolean) => {
              this.watchContext = value;
            })
        }.justifyContent(FlexAlign.SpaceAround)
        .width('100%')
        .height("5%")
      }

    }.backgroundColor(Color.White)
  }
}