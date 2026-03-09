import { VHBeautyDataService, VHBeautyFilterModel, VHBeautySDK } from '@vhall/vhall_beauty';
import emitter from '@ohos.events.emitter';

@Component
export struct BeautyFilterComponent {
  private viewModel = VHBeautyDataService.getInstance().VHFilterViewModel;
  private dataArray: VHBeautyFilterModel[] = this.viewModel.dataArray;
  @State @Watch('gridCurrentIndexChanged') gridCurrentIndex: number = this.viewModel.selectedIndex;
  @State sliderValue: number = this.dataArray[this.gridCurrentIndex].filterLevel * 100.0;
  @State sliderString: string = this.sliderValue.toString();
  @State sliderVisibility: Visibility = this.gridCurrentIndex > 0 ? Visibility.Visible : Visibility.Hidden;
  @State needToReset: boolean = true;
  scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    emitter.on('beauty_reset', () => {
      this.onAccept();
    })
  }

  aboutToDisappear(): void {
    emitter.off('beauty_reset');
  }

  build() {
    Column() {
      Row(){
        Slider({
          value: this.sliderValue,
          min: 0,
          max: 100,
          step: 1,
          style: SliderStyle.OutSet,
          direction: Axis.Horizontal,
          reverse: false
        })
          .layoutWeight(1)
          .visibility(this.sliderVisibility)
          .trackThickness(2)
          .blockSize({ width: 13, height: 13 })
          .blockStyle({ type: SliderBlockType.SHAPE, shape: new Circle({ width: 13, height: 13 }) })
          .blockColor('rgb(252,86,89)')// 设置滑块颜色
          .trackColor('#cccccc')// 设置滑轨颜色
          .selectedColor('rgb(252,86,89)')// 设置滑轨的已滑动颜色
          .onChange((value: number, mode: SliderChangeMode) => {
            if (!this.needToReset) {
              this.needToReset = true;
            }
            this.sliderValue = value;
            this.sliderString = VHBeautySDK.getInstance().formatNumber(value, 0, true);
            const model = this.dataArray[this.gridCurrentIndex];
            this.viewModel.setFilterValue(model, value / 100.0, this.gridCurrentIndex);
          })
        Row(){
          Text(this.sliderString)
        }
        .visibility(this.sliderVisibility)
        .width(30)
      }
      .width('100%')

      Row() {
        Grid(this.scroller) {
          ForEach(this.dataArray, (model: VHBeautyFilterModel, index: number) => {
            GridItemBuilder({
              gridCurrentIndex: this.gridCurrentIndex,
              sliderValue: this.sliderValue,
              sliderString: this.sliderString,
              model: model,
              sliderVisibility: this.sliderVisibility,
              index: index,
              needToReset: this.needToReset
            })
          }, (model: VHBeautyFilterModel): string => model.filterPath)
        }
        .width('100%')
        .height(80)
        .onAppear(()=>{
          this.scroller.scrollTo({
            xOffset: this.gridCurrentIndex * 67,
            yOffset: 0
          })
        })
        .scrollBar(BarState.Off)
        .rowsTemplate('1fr')
      }
      .margin({ top: 20 })
      .width('100%')
      .height(40)
    }
    .width('100%')
    .height('100%')
    .padding({right: 10, left: 10})
    .backgroundColor(Color.White)
  }

  gridCurrentIndexChanged() {
    const model = this.dataArray[this.gridCurrentIndex];
    this.viewModel.setFilterValue(model, model.filterLevel, this.gridCurrentIndex);
  }

  private onAccept() {
    this.viewModel.recoverAllFilterValuesToDefault();
    const model = this.dataArray[this.gridCurrentIndex];
    this.sliderValue = model.defaultLevel * 100.0;
    this.sliderString = VHBeautySDK.getInstance().formatNumber(this.sliderValue, 0, true);
    if (this.needToReset) {
      this.needToReset = false;
    }
  }
}

@Component
struct GridItemBuilder {
  @Link gridCurrentIndex: number;
  @Link sliderValue: number;
  @Link sliderString: string;
  @Link sliderVisibility: Visibility;
  @Link needToReset: boolean;
  index: number = 0;
  model: VHBeautyFilterModel | undefined = undefined;

  build() {
    GridItem() {
      Column({space: 3}) {
        if (this.model?.filterPath === 'origin') {
          Row(){
            if (this.gridCurrentIndex === 0) {
              Row(){
                Image($r('app.media.origin_select'))
                  .width(25)
              }
              .width("100%")
              .height("100%")
              .borderRadius(8)
              .justifyContent(FlexAlign.Center)
              .backgroundColor("#cccccc")
            }else {
              Row(){
                Image($r('app.media.origin_disable'))
                  .width(25)
              }
              .width("100%")
              .height("100%")
              .borderRadius(8)
              .justifyContent(FlexAlign.Center)
              .backgroundColor("#cccccc")
            }
          }
          .padding(1)
          .width(50)
          .height(60)
          .borderRadius(10)
          .borderWidth(2)
          .borderColor(this.getBorderColor())
        }else {
          Row(){
            Image($r(`app.media.${this.model?.filterPath}`))
              .borderRadius(8)
          }
          .padding(1)
          .width(50)
          .height(60)
          .borderRadius(10)
          .borderWidth(2)
          .borderColor(this.getBorderColor())
        }
        Text(this.model?.filterName)
          .fontColor(this.getTextColor())
          .textAlign(TextAlign.Center)
          .fontSize(14)
      }
    }
    .width(67)
    .height(80)
    .onClick(() => {
      this.gridCurrentIndex = this.index;
      this.sliderValue = this.model?.filterLevel ? this.model?.filterLevel * 100.0 : 0;
      this.sliderString = VHBeautySDK.getInstance().formatNumber(this.sliderValue, 0, true);
      this.sliderVisibility = this.index == 0 ? Visibility.Hidden : Visibility.Visible;
      if (!this.needToReset) {
        this.needToReset = true;
      }
    })
  }

  private getBorderColor(): ResourceColor {
    return this.gridCurrentIndex === this.index ? 'rgb(252,86,89)' : '#00b81616';
  }

  private getTextColor(): ResourceColor {
    return this.gridCurrentIndex === this.index ? 'rgb(252,86,89)' : Color.Black;
  }
}