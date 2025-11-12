import { VHWatermarkConfig, VHWebinarData } from "@vhall/vhall_live";

@Component
export struct VHTextWaterMark {
  private waterMarkSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private waterMarkContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.waterMarkSettings);
  @Require waterMarkProperties: VHWatermarkConfig | null = null;
  @Require waterWebinar: VHWebinarData | null = null;
  private waterMarkText: string = 'HarmonyOS开发笔记';
  private waterMarkTextWidth: number = 0
  private horizontalSpace:number = 80;// 文字水印中心 水平间距
  private verticalSpace:number = 80;// 文字水印中心 水平间距
  private rotateAngle:number = 0;// 文文字水印中心 旋转角度
  private fontSize:string = '';
  aboutToAppear(): void {
    if(this.waterMarkProperties?.text_watermark?.text_type == 1){
      this.waterMarkText = this.waterMarkProperties?.text_watermark.text_value;
    }else{
      this.waterMarkText = this.waterWebinar?.join_info?.third_party_user_id! + this.waterWebinar?.join_info?.nickname!;
    }
    if(this.waterMarkProperties?.text_watermark.orientation == 1){
      this.rotateAngle = 30;
    }
    if(this.waterMarkProperties){
      this.fontSize =  (this.waterMarkProperties?.text_watermark.size).toString() + "vp";
    }

  }

  draw() {
    this.waterMarkContext.reset()
    this.waterMarkTextWidth = this.getUIContext().getMeasureUtils().measureTextSize({
      textContent: this.waterMarkText,
      fontSize: (this.waterMarkProperties?.text_watermark.size!*2)
    }).width as number;

    if(this.waterMarkProperties){
      // 设置水印文字的填充颜色
      this.waterMarkContext.fillStyle = this.addAlphaToColor(this.waterMarkProperties?.text_watermark.color,this.waterMarkProperties?.text_watermark.alpha);
      // 设置水印文字大小
      this.waterMarkContext.font = this.fontSize;
    }
    // 设置水印对齐方式  文字水平和垂直方向居中
    this.waterMarkContext.textAlign = 'center';
    this.waterMarkContext.textBaseline = 'middle';

    // 外层循环：水平方向遍历（控制水印的水平分布）
    // 循环次数 = Canvas宽度 / 水平间距
    for (let i = 0; i < this.waterMarkContext.width / this.horizontalSpace; i++) {
      // 将Canvas原点（0,0）向右移动一个间距（每次循环右移，实现水平排列）
      this.waterMarkContext.translate(this.horizontalSpace, 0);
      let j = 0;
      // 内层循环：垂直方向遍历（控制水印的垂直分布）
      // 循环次数 = Canvas高度 / 垂直间距
      for (; j < this.waterMarkContext.height / this.verticalSpace; j++) {
        // 文字旋转：将文字逆时针旋转指定角度（公式：Math.PI/180 * 角度）
        this.waterMarkContext.rotate(-Math.PI / 180 * this.rotateAngle);
        this.waterMarkContext.fillText(this.waterMarkText, -this.getUIContext().px2vp(this.waterMarkTextWidth) / 2, 0);
        // 恢复旋转：将Canvas旋转状态还原
        this.waterMarkContext.rotate(Math.PI / 180 * this.rotateAngle);
        // 垂直平移：将Canvas原点向下移动一个间距（每次循环下移，实现垂直排列）
        if(this.waterMarkProperties?.text_watermark.orientation == 1){
          //倾斜、
          this.waterMarkContext.translate(0 , this.verticalSpace);
        }else{
          this.waterMarkContext.translate(40, this.verticalSpace+5);
        }

      }
      // 恢复垂直原点：内层循环结束后，将垂直方向的原点还原到初始高度
      this.waterMarkContext.translate(0, -this.verticalSpace * j);
    }
  }

  private  convertOpacityToHex(opacity: number): string {
  // 限制取值范围为0-100
    const clamped = Math.min(100, Math.max(0, opacity));
    // 将百分比转换为0-255的整数（0对应0x00，100对应0xFF）
    const alphaValue = Math.round((clamped / 100) * 255);
    // 转换为两位十六进制字符串（不足两位补零）
    return alphaValue.toString(16).padStart(2, '0').toUpperCase();
}

  private  addAlphaToColor(color: string, opacity: number): string {
    const alphaHex = this.convertOpacityToHex(opacity);
    // 确保原始颜色是6位HEX格式
    if (!/^#([A-Fa-f0-9]{6})$/.test(color)) {
      throw new Error('Invalid color format, expected #RRGGBB');
    }
    return `#${alphaHex}${color.slice(1)}`;
}

  build() {
    if(this.waterMarkProperties?.text_watermark.line_mode == 2){
      Canvas(this.waterMarkContext)
        .width('100%')
        .height('100%')
        .hitTestBehavior(HitTestMode.None)
        .onReady(() => {
          this.draw()
        })
    }else  if(this.waterMarkProperties?.text_watermark.line_mode == 1){
      Row({space:this.verticalSpace}){
        Text(this.waterMarkText + "    "  + this.waterMarkText +  "    "  + this.waterMarkText)
          .fontColor(this.waterMarkProperties?.text_watermark.color)
          .fontSize(this.fontSize)
          .rotate({angle:-this.rotateAngle})
          .maxLines(1)
          .opacity(this.waterMarkProperties.text_watermark.alpha * 0.01)

      }.width("100%")
      .height("100%")
      .justifyContent(FlexAlign.Center)
    }
  }
}