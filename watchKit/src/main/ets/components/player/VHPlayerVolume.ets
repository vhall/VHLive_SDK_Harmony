@Component
export struct VolumeSlider {
  @Require @Prop progress: number = 50 // 0-100的进度值
  @State private isDragging: boolean = false

  // 图标资源根据实际情况替换
  @State private icon: Resource = $r('app.media.volume_open')
  private readonly maxWidth: number = 200 // 进度条最大宽度

  build() {
    Row() {
      // 左侧图标
      Image(this.progress == 0 ? $r('app.media.volume_close') : this.icon)
        .width(24)
        .height(24)
        .margin({ right: 8 })

      // 进度条容器
      // 滑动条组件
      Slider({
        value: this.progress,
        min: 0,
        max: 100,
        style: SliderStyle.NONE
      })
        .width(200)
        .height(10) // 保持默认触摸区域
        .trackColor('#000000') // 背景轨道颜色
        .selectedColor('#FF1493') // 进度填充颜色
        .onChange((value: number) => {
        })

  }
  .alignItems(VerticalAlign.Center)
  }
}