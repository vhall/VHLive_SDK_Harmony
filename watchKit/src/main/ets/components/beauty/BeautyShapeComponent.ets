import { VHBeautyDataService, VHBeautySDK, VHBeautyShapeModel } from "@vhall/vhall_beauty";
import emitter from "@ohos.events.emitter";

@Component
export struct BeautyShapeComponent {
  private viewModel = VHBeautyDataService.getInstance().VHShapeViewModel;
  private dataArray: VHBeautyShapeModel[] = this.viewModel.dataArray;
  @State gridCurrentIndex: number = 0;
  @State defaultValueInMiddle: boolean = false;
  @State sliderValue: number =
    this.defaultValueInMiddle ? (this.dataArray[this.gridCurrentIndex].currentValue * 100.0 - 50) :
      (this.dataArray[this.gridCurrentIndex].currentValue * 100.0);
  @State sliderString: string = this.sliderValue.toString();
  @State needToReset: boolean = true;
  @State isOpen: boolean = this.viewModel.isOpen;

  aboutToAppear(): void {
    emitter.on('beauty_reset', () => {
      this.onAccept();
    })
  }

  aboutToDisappear(): void {
    emitter.off('beauty_reset');
  }

  build() {
    Column({space:20}) {
      Row({space:10}) {
        Slider({
          value: this.sliderValue,
          min: this.defaultValueInMiddle ? -50 : 0,
          max: this.defaultValueInMiddle ? 50 : 100,
          step: 1,
          style: SliderStyle.OutSet,
          direction: Axis.Horizontal,
          reverse: false
        })
          .layoutWeight(1)
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
            let shapeValue = this.defaultValueInMiddle ? ((value + 50) / 100.0) : value / 100.0
            this.viewModel.setShapeValue(model, shapeValue);
          })
        Row(){
          Text(this.sliderString)
        }
        .width(30)
      }
      .width('100%')
      .visibility(this.isOpen ? Visibility.Visible : Visibility.Hidden)
      Row() {
        Grid() {
          GridItem(){
            Image(this.isOpen ? $r('app.media.Switch_open') : $r('app.media.Switch_off'))
              .width(40)
              .objectFit(ImageFit.Contain)
              .onClick(() => {
                this.isOpen = !this.isOpen;
                this.viewModel.isOpen = this.isOpen;
                if (this.isOpen) {
                  this.gridCurrentIndex = 0;
                  this.viewModel.setAllShapeValues();
                } else {
                  this.viewModel.resetToDefault();
                }
              })
          }
          ForEach(this.dataArray, (model: VHBeautyShapeModel, index: number) => {
            GridItemBuilder({
              gridCurrentIndex: this.gridCurrentIndex,
              sliderValue: this.sliderValue,
              sliderString: this.sliderString,
              defaultValueInMiddle: this.defaultValueInMiddle,
              index: index,
              model: model,
              needToReset: this.needToReset,
              isOpen: this.isOpen
            })
          }, (model: VHBeautyShapeModel): string => model.name)
        }
        .scrollBar(BarState.Off)
        .rowsTemplate('1fr')
        .width('100%')
        .height(80)
      }
      .width('100%')
      .height(40)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .padding({left: 10, right: 10})
  }

  private onAccept() {
    this.viewModel.recoverAllShapeValuesToDefault();
    const model = this.dataArray[this.gridCurrentIndex];
    this.sliderValue = this.defaultValueInMiddle ? (model.defaultValue * 100.0 - 50) : (model.defaultValue * 100.0);
    this.sliderString = VHBeautySDK.getInstance().formatNumber(this.sliderValue, 0, true);
    if (this.needToReset) {
      this.needToReset = false;
    }
  }
}

@Component
struct GridItemBuilder {
  @Link gridCurrentIndex: number
  @Link sliderValue: number
  @Link sliderString: string
  @Link defaultValueInMiddle: boolean;
  @Link needToReset: boolean;
  @Link isOpen: boolean;
  index: number = 0;
  model: VHBeautyShapeModel | undefined = undefined;

  build() {
    GridItem() {
      Column({space:10}) {
        Image(this.getImageName())
          .width(20)
          .height(20)
        Text(this.model?.name)
          .fontColor(this.getTextColor())
          .textAlign(TextAlign.Center)
          .fontSize(14)
          .margin({ top: 3 })
      }
    }
    .width(67)
    .height(80)
    .selected(this.gridCurrentIndex === this.index)
    .onClick(() => {
      this.gridCurrentIndex = this.index;
      if (this.model) {
        this.defaultValueInMiddle = this.model.defaultValueInMiddle;
        this.sliderValue =
          this.defaultValueInMiddle ? (this.model.currentValue * 100.0 - 50) : (this.model.currentValue * 100.0);
        this.sliderString = VHBeautySDK.getInstance().formatNumber(this.sliderValue, 0, true);
      }
      if (!this.needToReset) {
        this.needToReset = true;
      }
    })
  }

  private getImageName(): Resource {
    let imaName = '';
    if (this.gridCurrentIndex === this.index && this.isOpen) {
      imaName = `${this.model?.imeName}_select`;
    } else {
      imaName = `${this.model?.imeName}_disable`;
    }
    return $r(`app.media.${imaName}`);
  }

  private getTextColor(): ResourceColor {
    return this.gridCurrentIndex === this.index && this.isOpen ? 'rgb(252,86,89)' : Color.Black;
  }
}