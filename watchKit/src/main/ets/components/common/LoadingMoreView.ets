@Extend(Text)
function textStyle() {
  .fontSize(13).fontColor('#999').lineHeight(20)
}

@Component
export default struct LoadingMoreView {
  @Link visible: boolean//组件是否显示
  @Prop status: number = 0 //触底状态 0:初始状态，1：加载状态 2：已到底了
  @Prop isShowTip: boolean = true;

  build() {
    Row() {
      if (this.status === 0) {
        //初始态
        Text('... 下拉加载更多 ...').textStyle()
      } else if (this.status === 1) {
        //加载中
        Row({ space: 5 }) {
          Image($r("app.media.loading"))
            .width(30)
            .transition(TransitionEffect.rotate({ angle: -360 })
              .animation({ duration: 2000, curve: Curve.Linear, iterations: -1 }))
          Text('正在加载...').textStyle()
        }
      } else if (this.status === 2 && this.isShowTip === true) {
        //已到底
        Text('...已到底了...').textStyle()
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding(5)
    .visibility(this.visible ? Visibility.Visible : Visibility.None)
  }
}
