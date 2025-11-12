
@Builder
export function createLoadingView( ){
  LoadingDialog();
}

/**
 * 常用设置底部弹窗视图
 */
@Component
export struct LoadingDialog {
  build() {
    Column() {
      LoadingProgress()
        .color(Color.White)
        .width(80)
        .height(80)
      Text('努力加载中')
        .fontSize(16)
        .fontColor(Color.White)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }
}