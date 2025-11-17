import { common, Want, bundleManager } from "@kit.AbilityKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { ToastUtil } from "../../action/ToastUtil";
import { http } from "@kit.NetworkKit";
import { ComponentContent, curves, promptAction } from "@kit.ArkUI";
import {
  VHGoodsInfo,
  VHCouponInfo,
  VHCreateOrderInfo,
  VHGoodsActivitySettings,
  VHGoodsListData,
  VHNotAvailableCouponInfo,
  VHPushGoodsChangeData,
  VHSaaSDK,
  VHWebinarData
} from "@vhall/vhall_live";
import { webview } from "@kit.ArkWeb";
import { WebViewPageBuilder, WebViewParams } from "../../pages/WebViewPage";
import { PromptActionClass } from "../../util/PromptActionClass";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { GoodsWebViewPageBuilder, GoodsWebViewParams } from "../../pages/GoodsPage";

@Component
export struct VHGoodsComponent {
  @Require webinars: VHWebinarData;
  @State refreshing: boolean = false
  @Consume GoodsListData: VHGoodsListData[]
  @State BottomLoading: boolean = false
  @State GoodsData: VHGoodsListData | null = null
  @State Index: number = 0
  @Consume ActivitySettings: VHGoodsActivitySettings
  @Prop PushProductData: VHGoodsInfo[]
  Scroller: Scroller = new Scroller()
  CouponsDialog = new CustomDialogController({
    builder: VHCouponsDialog({ Index: this.Index, webinars: this.webinars, isCoupons: false }),
    customStyle: true,
    alignment: DialogAlignment.Bottom,

  })
  OrderDialog = new CustomDialogController({
    builder: VHOrderDialog({
      GoodsData: this.GoodsData as VHGoodsListData,
      webinars: this.webinars
    }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })

  aboutToAppear(): void {
    this.GoodsListHttp()
    this.GoodsActivitySettings()
  }

  //商品列表
  GoodsListHttp() {
    VHSaaSDK.getInstance().performGoodsIn(0,
      {
        onSucceed: (data) => {
          // this.GoodsListData = data as VHGoodsListData[]
          this.GoodsListData = data.filter(item => item.status === 1);
          console.log(`获取商品列表成功： ${JSON.stringify(this.GoodsListData)}`)
        },
        onFailure: (errorCode, errorMsg) => {
          console.log(`获取商品列表失败： ${errorMsg}`)
          ToastUtil.showToast(errorMsg);
        }
      });
  }

  //用户获取活动商品设置
  GoodsActivitySettings() {
    VHSaaSDK.getInstance().GoodsActivitySettings(this.webinars?.webinar!.id.toString(), '',
      {
        onSucceed: (data) => {
          this.ActivitySettings = data as VHGoodsActivitySettings
        },
        onFailure: (errorCode, errorMsg) => {
          ToastUtil.showToast(errorMsg);
        }
      });
  }

  build() {
    if (this.GoodsListData.length > 0) {
      Column() {
        if (this.ActivitySettings.enable_coupon == 1) {
          Column() {
            Row({ space: 2 }) {
              Image($r('app.media.icon_coupons'))
                .width(14)
                .aspectRatio(1)
                .fillColor('#fff')
              Text('我的优惠卷')
                .fontColor('#fff')
                .fontSize(14)
            }
            .padding({
              left: 8,
              right: 8,
              top: 4,
            })
            .backgroundColor('#999')
            .borderRadius({ topLeft: '50%', bottomLeft: '50%' })
          }
          .width('100%')
          .alignItems(HorizontalAlign.End)
          .margin({ top: 10 })
          .onClick(() => {
            this.CouponsDialog.open()
          })
        }


        Refresh({ refreshing: $$this.refreshing }) {
          List({ scroller: this.Scroller }) {
            ForEach(this.GoodsListData, (item: VHGoodsListData, index) => {
              ListItem() {
                Stack() {
                  Row() {
                    Row({ space: 10 }) {
                      Column() {
                        Image(item.images[0].img_url)
                          .width(100)
                          .aspectRatio(1)
                          .borderRadius(6)
                        Text((index + 1) >= 10 ? `${index + 1}` : `0${index + 1}`)
                          .fontSize(10)
                          .fontColor('#fff')
                          .backgroundColor('#39000000')
                          .padding(4)
                          .borderRadius({ topLeft: 6, bottomRight: 6 })
                          .position({ x: 0, y: 0 })
                        if (item.push_status == 1) {
                          Row({ space: 4 }) {
                            Row({ space: 1 }) {
                              Text()
                                .width(1)
                                .height(2)
                                .backgroundColor('#fff')
                              Text()
                                .width(1)
                                .height(5)
                                .backgroundColor('#fff')
                              Text()
                                .width(1)
                                .height(8)
                                .backgroundColor('#fff')
                              Text()
                                .width(1)
                                .height(5)
                                .backgroundColor('#fff')
                              Text()
                                .width(1)
                                .height(2)
                                .backgroundColor('#fff')
                            }

                            Text('讲解中')
                              .fontSize(10)
                              .fontWeight(600)
                              .fontColor('#fff')
                          }
                          .width('100%')
                          .height(22)
                          .backgroundColor('#39000000')
                          .padding(2)
                          .borderRadius({ bottomLeft: 6, bottomRight: 6 })
                          .position({ x: 0, y: 78 })
                          .justifyContent(FlexAlign.Center)
                        }
                      }
                      .width(100)
                      .aspectRatio(1)


                      Column({ space: 6 }) {
                        Text(item.name)
                          .fontSize(12)
                          .fontColor('#333')
                          .maxLines(2)  // 限制最大行数
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                        Text(item.description)
                          .fontSize(10)
                          .fontColor('#999')
                          .maxLines(1)  // 限制最大行数
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                        Blank()
                          .layoutWeight(1)
                        if (item.discount_price != null) {
                          Row({ space: 4 }) {
                            Text(' 优惠价 ')
                              .fontSize(10)
                              .padding(2)
                              .borderRadius(4)
                              .fontColor('#ffe28080')
                              .backgroundColor('#ffffe4e4')
                            // Text(this.PushProductData[0].covered_status == 0 ? `￥ ${item.discount_price}` :
                            //   `￥ ${this.PushProductData[0].covered_price}`)
                            //   .fontSize(12)
                            //   .fontColor('#ffe28080')
                            Text(item.covered_status == 0 ? `￥ ${item.discount_price}` : `￥ ${item.covered_price}`)
                              .fontSize(12)
                              .fontColor('#ffe28080')
                            Text() {
                              Span('￥')
                                .fontSize(12)
                                .fontColor('#ffb3b3b3')
                              Span(item.covered_status == 0 ? item.price + '' : " 待开价 ")
                                .fontSize(12)
                                .fontColor('#ffb3b3b3')
                                .decoration({
                                  type: TextDecorationType.LineThrough,
                                  color: '#ffb3b3b3',
                                  style: TextDecorationStyle.SOLID
                                })
                            }
                            .fontSize(8)
                            .fontColor('#ffe28080')
                          }
                        } else {
                          Row({ space: 4 }) {
                            Text(item.covered_status == 0 ? `￥ ${item.price}` : `￥ ${item.covered_price}`)
                              .fontSize(12)
                              .fontColor('#ffe28080')
                          }
                        }
                      }
                      .width(200)
                      .height(100)
                      .alignItems(HorizontalAlign.Start)
                    }

                    Button(this.ActivitySettings.btn_description.length > 0 ? this.ActivitySettings.btn_description :
                      '购买')
                      .fontColor('#fff')
                      .fontSize(10)
                      .padding(2)
                      .height(20)
                      .width(50)
                      .enabled(item.covered_status == 0 ? true : false)
                      .backgroundColor('#fb2626')
                      .onClick(() => {
                        // if (item.covered_status == 0) {
                        //点击跳转支付页面,购买类型;1.平台购买 2.外链购买 3.自定义购买(APP嵌入) 4.自定义购买(小程序嵌入)
                        if (item.buy_type == 1) {
                          this.GoodsData = item
                          this.OrderDialog.open()
                        } else if (item.buy_type == 2) {
                          const context: common.UIAbilityContext =
                            this.getUIContext().getHostContext()! as common.UIAbilityContext;
                          startBrowsableAbility(context);
                        } else if (item.buy_type == 3) {
                          ToastUtil.showToast('APP嵌入自定义购买')
                        } else if (item.buy_type == 4) {
                          ToastUtil.showToast('小程序嵌入自定义购买')
                        }
                        // } else {
                        //   ToastUtil.showToast('无法购买')
                        // }
                      })
                  }
                  .width('100%')
                  .padding(14)
                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(VerticalAlign.Bottom)

                  if (item.sale_status == 0) {
                    Column() {
                      Text('-已抢光-')
                        .height(100)
                        .fontColor('#fff')
                    }
                    .width('100%')
                    .padding(14)
                    .backgroundColor('#20000000')
                    .borderRadius(16)
                    .justifyContent(FlexAlign.Center)
                    .alignItems(HorizontalAlign.Center)
                  }
                }
              }
            })
            if (this.BottomLoading) {
              // 加载动效
              ListItem() {
                LoadingProgress()
                  .width(50)
              }
              .width('100%')
              .animation({ curve: curves.springMotion() })
            }

          }
          .scrollBar(BarState.Off)
          .divider({
            strokeWidth: 0.4,
            color: '#ff9f9f9f',
            startMargin: 10,
            endMargin: 10
          })
          .onReachEnd(() => {
            this.BottomLoading = true
            //进行网络请求，请求到数据，添加到列表里

            //请求到数据之后，关闭动效
            this.BottomLoading = false
          })
        }
        .margin({ bottom: 28 })
        //下拉刷新
        .onRefreshing(() => {
          //请求最新的数据
          //请求到数据之后关闭加载
          this.refreshing = false
        })

        Blank()
          .layoutWeight(1)
        // if (this.GoodsListData[0].push_status == 1) {
        //   FloatingWindow({
        //     Floating: true,
        //     GoodsData: this.GoodsData as VHGoodsListData,
        //     GoodsListData: this.GoodsListData,
        //     ActivitySettings: this.ActivitySettings,
        //     webinars: this.webinars
        //   })
        // } else {
        //   FloatingWindow({
        //     Floating: false,
        //     GoodsData: this.GoodsData as VHGoodsListData,
        //     GoodsListData: this.GoodsListData,
        //     ActivitySettings: this.ActivitySettings,
        //     webinars: this.webinars
        //   })
        // }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f5f5f5')

      // .justifyContent(FlexAlign.Start)
      // .alignItems(HorizontalAlign.Start)
    }
  }
}

//悬浮窗
@Component
export struct FloatingWindow {
  @Prop Floating: boolean = true
  @Prop GoodsListData: VHGoodsListData[]
  @Prop GoodsData: VHGoodsListData
  @Prop ActivitySettings: VHPushGoodsChangeData
  @Require webinars: VHWebinarData;
  OrderDialog = new CustomDialogController({
    builder: VHOrderDialog({
      GoodsData: this.GoodsData as VHGoodsListData,
      webinars: this.webinars
    }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })

  build() {
    if (this.Floating) {
      Column() {
        Image(this.GoodsListData[0].images[0].img_url)
          .width('100%')
          .aspectRatio(1)
          .borderRadius({ topLeft: 6, topRight: 6 })
        Image($r('app.media.icon_close'))
          .width(10)
          .aspectRatio(1)
          .fillColor('#fff')
          .position({ x: '85%', y: '4%' })
          .onClick(() => {
            //关闭
            this.Floating = false
          })
        Text(this.GoodsListData[0].name)
          .width('96%')
          .layoutWeight(1)
          .maxLines(2)  // 限制最大行数
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row() {
          Text() {
            Span('￥')
              .fontSize(10)
              .fontColor('#fff')
            if (this.GoodsListData[0].covered_status == 0) {
              Span(this.GoodsListData[0].discount_price != null ? this.GoodsListData[0].discount_price + '' :
                this.GoodsListData[0].price + '')
                .fontSize(12)
                .fontColor('#fff')
            } else {
              Span(this.GoodsListData[0].covered_price)
                .fontSize(12)
                .fontColor('#fff')
            }

          }

          Text('抢')
            .fontSize(16)
            .fontColor('#fff')
            .fontWeight(700)
        }
        .width('96%')
        .height(20)
        .padding(2)
        .margin({ bottom: '4%' })
        .backgroundColor('#fb2626')
        .borderRadius(4)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Bottom)
        .onClick(() => {
          if (this.GoodsListData[0].buy_type == 1) {
            this.GoodsData = this.GoodsListData[0]
            this.OrderDialog.open()
          } else if (this.GoodsListData[0].buy_type == 2) {
            const context: common.UIAbilityContext =
              this.getUIContext().getHostContext()! as common.UIAbilityContext;
            startBrowsableAbility(context);
          } else if (this.GoodsListData[0].buy_type == 3) {
            ToastUtil.showToast('APP嵌入自定义购买')
          } else if (this.GoodsListData[0].buy_type == 4) {
            ToastUtil.showToast('小程序嵌入自定义购买')
          }
        })
      }
      .width(100)
      .height(160)
      .backgroundColor('#ffeaeaea')
      .borderRadius(6)
      .position({ x: '70%', y: '50%' })
      .zIndex(4)
    }

  }
}

function startBrowsableAbility(context: common.UIAbilityContext, url?: string): void {
  let want: Want = {
    action: 'ohos.want.action.viewData',
    entities: ['entity.system.browsable'],
    uri: url || 'https://www.baidu.com/',
    parameters: {
      'ohos.ability.params.showDefaultPicker': true
    }
  };
  context.startAbility(want)
    .then(() => {
      console.error('Start browsableAbility successfully.');
    })
    .catch((err: BusinessError) => {
      console.error(`Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
    });
}

//优惠卷弹窗
@CustomDialog
export struct VHCouponsDialog {
  controller: CustomDialogController
  @State barList: string[] = ['可用优惠券', '不可用优惠券']
  @Consume CouponsAvailable: VHCouponInfo[]
  @Consume CouponsNotAvailable: VHNotAvailableCouponInfo[]
  @Link Index: number
  @Consume CouponsWebinarId: number
  @State private illustrateStates: boolean[] = [];
  @State private selectedIndex: number = -1;
  @Require webinars: VHWebinarData;
  @Prop isCoupons: boolean = true

  aboutToAppear(): void {
    this.getCouponsAvailableHttp()
    this.getCouponsNotAvailableHttp()
    if (this.CouponsAvailable.length > 0) {
      this.illustrateStates = new Array(this.CouponsAvailable.length).fill(false);
    }
  }

  //可用优惠卷列表
  getCouponsAvailableHttp() {
    VHSaaSDK.getInstance()
      .getCouponsAvailable(this.CouponsWebinarId, {
        onSucceed: (data) => {
          this.CouponsAvailable = data as VHCouponInfo[]
          console.log(`获取可用优惠卷列表成功： ${JSON.stringify(data)}`)
        },
        onFailure: (errorCode, errorMsg) => {
          console.log(`获取可用优惠卷列表失败： ${errorMsg}`)
          ToastUtil.showToast(`获取可用优惠卷列表失败： ${errorMsg}`);
        }
      });
  }

  //不可用优惠卷列表
  getCouponsNotAvailableHttp() {
    VHSaaSDK.getInstance()
      .getCouponsNotAvailable(this.CouponsWebinarId, {
        onSucceed: (data) => {
          this.CouponsNotAvailable = data as VHNotAvailableCouponInfo[]
          console.log(`获取不可用优惠卷列表成功： ${JSON.stringify(data)}`)
        },
        onFailure: (errorCode, errorMsg) => {
          console.log(`获取不可用优惠卷列表失败： ${errorMsg}`)
          ToastUtil.showToast(`获取不可用优惠卷列表失败： ${errorMsg}`);
        }
      });
  }

  build() {
    Column() {
      Row() {
        Text()
          .width(20)
          .aspectRatio(1)
        Text('我的优惠卷')
          .fontColor('#333')
        Image($r('app.media.icon_close'))
          .width(20)
          .aspectRatio(1)
          .onClick(() => {
            this.controller.close()
          })
      }
      .padding({ left: 20, right: 20 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 20 })

      Tabs() {
        ForEach(this.barList, (item: string, index) => {
          //可用优惠券列表
          if (index == 0) {
            TabContent() {
              if (this.CouponsAvailable.length != 0) {
                List() {
                  ForEach(this.CouponsAvailable, (item: VHCouponInfo, index) => {
                    ListItem() {
                      Column() {
                        Row() {
                          // 左侧红色优惠信息区域
                          Column() {
                            Text(`¥${item.deduction_amount}`)
                              .fontSize(28)
                              .fontWeight(FontWeight.Bold)
                              .fontColor('#FFFFFF')
                            if (item.coupon_type == 0) {
                              Text(`满${item.threshold_amount}可用`)
                                .fontSize(14)
                                .fontColor('#FFFFFF')
                            } else {
                              Text('无门槛')
                                .fontSize(14)
                                .fontColor('#FFFFFF')
                            }
                          }
                          .width('35%')
                          .height('100%')
                          .backgroundColor('#FF4D4F')
                          .borderRadius({
                            topLeft: 8,
                            bottomLeft: 8,
                            topRight: 8,
                            bottomRight: 8
                          })
                          .justifyContent(FlexAlign.Center)
                          .alignItems(HorizontalAlign.Center)

                          // 右侧信息区域
                          Column() {
                            Text(item.coupon_name)
                              .fontSize(18)
                              .fontWeight(FontWeight.Bold)
                              .fontColor('#FF4D4F')
                              .margin({ bottom: 6 })
                            if (item.applicable_product_type == 0) {
                              Text('全部商品')
                                .fontSize(12)
                                .fontColor('#666666')
                            } else if (item.applicable_product_type == 1) {
                              Text('指定商品可用')
                                .fontSize(12)
                                .fontColor('#666666')
                            } else if (item.applicable_product_type == 2) {
                              Text('指定商品不可用')
                                .fontSize(12)
                                .fontColor('#666666')
                            }
                            Text(`${item.validity_start_time}-${item.validity_end_time}`)
                              .fontSize(12)
                              .fontColor('#999999')
                            if (item.use_desc.length > 0) {
                              Row({ space: 6 }) {
                                Text('使用说明')
                                  .fontSize(12)
                                  .fontColor('#999999')
                                if (this.illustrateStates[index]) {
                                  Image($r('app.media.icon_up'))
                                    .width(12)
                                    .aspectRatio(1)
                                    .fillColor('#999999')
                                } else {
                                  Image($r('app.media.icon_under'))
                                    .width(12)
                                    .aspectRatio(1)
                                    .fillColor('#999999')
                                }
                              }
                              .onClick(() => {
                                this.illustrateStates[index] = !this.illustrateStates[index];
                              })
                            }

                          }
                          .width('65%')
                          .height('100%')
                          .backgroundColor('#FFF5F5')
                          .borderRadius({
                            topRight: 8,
                            bottomRight: 8,
                            topLeft: 8,
                            bottomLeft: 8
                          })
                          .justifyContent(FlexAlign.Center)
                          .alignItems(HorizontalAlign.Start)
                          .padding({ left: 15 })
                        }
                        .width('100%')
                        .height(100)
                        .borderRadius(8)
                        .shadow({
                          radius: 4,
                          color: '#00000014',
                          offsetX: 2,
                          offsetY: 2
                        })
                        .onClick(() => {
                          this.Index = index
                          if (this.isCoupons) {
                            this.controller.close()
                          }
                        })

                        if (item.use_desc.length > 0 && this.illustrateStates[index]) {
                          Text(item.use_desc)
                            .fontSize(12)
                            .fontColor('#666')
                            .margin({ top: 10, bottom: 10 })
                        }
                      }
                      .width('100%')
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                    }
                  })
                  ListItem()
                    .height(40)
                }
                .width('100%')
                .height('90%')
                .padding({ left: 20, right: 20 })
                //设置列表之间的间距
                .margin({ bottom: '8%' })
                .divider({
                  strokeWidth: 8,
                  startMargin: 10,
                  endMargin: 10,
                  color: Color.Transparent
                })
                .scrollBar(BarState.Off)
              } else {
                Text('暂无优惠券')
              }

            }.tabBar(`${item} (${this.CouponsAvailable.length})`)
          } else {
            //不可用优惠券列表
            TabContent() {
              if (this.CouponsNotAvailable.length != 0) {
                List() {
                  ForEach(this.CouponsNotAvailable, (item: VHNotAvailableCouponInfo) => {
                    ListItem() {
                      Row() {
                        // 左侧红色优惠信息区域
                        Column() {
                          Text(`¥${item.deduction_amount}`)
                            .fontSize(28)
                            .fontWeight(FontWeight.Bold)
                            .fontColor('#FFFFFF')
                          Text(`满${item.threshold_amount}可用`)
                            .fontSize(14)
                            .fontColor('#FFFFFF')
                        }
                        .width('35%')
                        .height('100%')
                        .backgroundColor('#999')
                        .borderRadius({
                          topLeft: 8,
                          bottomLeft: 8,
                          topRight: 8,
                          bottomRight: 8
                        })
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.Center)

                        Stack({ alignContent: Alignment.TopEnd }) {
                          // 右侧信息区域
                          Column() {
                            Text(item.coupon_name)
                              .fontSize(18)
                              .fontWeight(FontWeight.Bold)
                              .fontColor('#333')
                              .margin({ bottom: 6 })
                            if (item.applicable_product_type == 0) {
                              Text('全部商品')
                                .fontSize(12)
                                .fontColor('#666666')
                            } else if (item.applicable_product_type == 1) {
                              Text('指定商品可用')
                                .fontSize(12)
                                .fontColor('#666666')
                            } else if (item.applicable_product_type == 2) {
                              Text('指定商品不可用')
                                .fontSize(12)
                                .fontColor('#666666')
                            }
                            Text(`${item.validity_start_time}-${item.validity_end_time}`)
                              .fontSize(12)
                              .fontColor('#999999')
                          }
                          .width('65%')
                          .height('100%')
                          .backgroundColor('#ccc')
                          .borderRadius({
                            topRight: 8,
                            bottomRight: 8,
                            topLeft: 8,
                            bottomLeft: 8
                          })
                          .justifyContent(FlexAlign.Center)
                          .alignItems(HorizontalAlign.Start)
                          .padding({ left: 15 })

                          if (item.unavailable_type == 0) {
                            Image($r('app.media.icon_notMet'))
                              .width(40)
                              .aspectRatio(1)
                          } else if (item.unavailable_type == 1) {
                            Image($r('app.media.icon_hasExpired'))
                              .width(40)
                              .aspectRatio(1)
                          } else if (item.unavailable_type == 2) {
                            Image($r('app.media.icon_used'))
                              .width(40)
                              .aspectRatio(1)
                          }

                        }

                      }
                      .width('100%')
                      .height(100)
                      .borderRadius(8)
                      .shadow({
                        radius: 4,
                        color: '#00000014',
                        offsetX: 2,
                        offsetY: 2
                      })
                    }
                  })
                  ListItem()
                    .height(40)
                }
                .width('100%')
                .height('90%')
                .padding({ left: 20, right: 20 })
                //设置列表之间的间距
                .margin({ bottom: '8%' })
                //设置列表之间的间距
                .divider({
                  strokeWidth: 8,
                  startMargin: 10,
                  endMargin: 10
                })
                .scrollBar(BarState.Off)
              } else {
                Text('暂无优惠券')
              }

            }.tabBar(`${item} (${this.CouponsNotAvailable.length})`)
          }

        })
      }.animationDuration(0)

    }
    .width('100%')
    .height('55%')
    .borderRadius({ topLeft: 12, topRight: 12 })
    .linearGradient({
      angle: 90,
      colors: [['#fffcf1f7', 0.1], ['#ffe7dbf8', 0.9]]
    })
  }
}

//订单弹窗
@CustomDialog
export struct VHOrderDialog {
  @State value: number = 1
  @State pay: string = 'WEIXIN'
  @Prop GoodsData: VHGoodsListData = new VHGoodsListData()
  @Consume CouponsAvailable: VHCouponInfo[]
  @State Index: number = -1 // 初始化为-1，标识未选中优惠券
  @State price: number = 0
  @Consume CouponsWebinarId: number
  @State name: string = ''
  @State phone: string = ''
  @State remark: string = ''
  @State ActivitySettings: VHGoodsActivitySettings = new VHGoodsActivitySettings()
  @Require webinars: VHWebinarData;
  Controller: CustomDialogController
  webController: webview.WebviewController = new webview.WebviewController();
  pathStack: NavPathStack = new NavPathStack();
  CouponsDialog = new CustomDialogController({
    builder: VHCouponsDialog({ Index: this.Index, webinars: this.webinars, isCoupons: true }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })
  OrdersSucceedDialog = new CustomDialogController({
    builder: VHOrdersSucceed(),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })
  private contentNode: ComponentContent<Object> | null = null;

  aboutToAppear(): void {
    this.getCouponsAvailableHttp()
    this.GoodsActivitySettings()
  }

  GoodsActivitySettings() {
    VHSaaSDK.getInstance().GoodsActivitySettings(this.webinars?.webinar!.id.toString(), '',
      {
        onSucceed: (data) => {
          this.ActivitySettings = data as VHGoodsActivitySettings
        },
        onFailure: (errorCode, errorMsg) => {
          ToastUtil.showToast(errorMsg);
        }
      });
  }

  // 打开链接
  private openLink(url: string) {
    const params = new GoodsWebViewParams("支付", url);
    this.contentNode = new ComponentContent(this.getUIContext(), wrapBuilder(GoodsWebViewPageBuilder), params);
    PromptActionClass.setContext(this.getUIContext());
    PromptActionClass.setContentNode(this.contentNode);
    PromptActionClass.setOptions({
      alignment: DialogAlignment.Center,
      offset: { dx: 0, dy: 50 },
      isModal: true,
      maskRect: {
        x: 0,
        y: 0,
        width: '100%',
        height: '0%'
      }
    });
    PromptActionClass.openDialog();
  }

  // 获取可用优惠券列表（核心修复：遍历选中首张满足门槛的优惠券）
  getCouponsAvailableHttp() {
    VHSaaSDK.getInstance()
      .getCouponsAvailable(this.CouponsWebinarId, {
        onSucceed: (data) => {
          this.CouponsAvailable = data || [];
          this.Index = -1; // 重置为未选中状态
          const currentPrice = this.GoodsData.discount_price ?? this.GoodsData.price;
          // 遍历所有优惠券，选中首张满足“金额≥门槛”的券（支持金额＜1）
          for (let i = 0; i < this.CouponsAvailable.length; i++) {
            const coupon = this.CouponsAvailable[i];
            // 用Math.round统一精度，避免0.9999999999999999误判
            if (Math.round(currentPrice * 100) >= Math.round(coupon.threshold_amount * 100)) {
              this.Index = i;
              break;
            }
          }
          console.log(`获取可用优惠卷列表成功： ${JSON.stringify(data)}，选中索引：${this.Index}`)
        },
        onFailure: (errorCode, errorMsg) => {
          this.CouponsAvailable = [];
          this.Index = -1;
          console.log(`获取可用优惠卷列表失败： ${errorMsg}`)
          ToastUtil.showToast(`获取可用优惠卷列表失败： ${errorMsg}`);
        }
      });
  }

  // 工具函数：判断当前是否有可用优惠券（修正索引判断）
  private isCouponUsable(): boolean {
    if (this.CouponsAvailable.length === 0 || this.Index === -1) {
      return false;
    }
    const currentPrice = this.GoodsData.discount_price ?? this.GoodsData.price;
    // 精度统一：乘以100后取整，避免浮点数误差
    return Math.round(currentPrice * 100) >= Math.round(this.CouponsAvailable[this.Index].threshold_amount * 100);
  }

  // 工具函数：计算最终支付金额（修复精度问题）
  private calculateFinalPrice(): number {
    const basePrice = (this.GoodsData.discount_price ?? this.GoodsData.price) * this.value;
    if (this.isCouponUsable()) {
      // 精度处理：避免0.1+0.2=0.30000000000000004这类问题
      const finalPrice = basePrice - this.CouponsAvailable[this.Index].deduction_amount;
      return Math.round(finalPrice * 100) / 100; // 保留2位小数
    }
    return Math.round(basePrice * 100) / 100;
  }

  build() {
    Column({ space: 10 }) {
      Scroll() {
        Column() {
          Row() {
            Text('确认订单')
              .fontSize(20)
            Image($r('app.media.icon_close'))
              .width(16)
              .aspectRatio(1)
              .onClick(() => {
                this.Controller.close()
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            Row({ space: 2 }) {
              Image(this.GoodsData.images[0].img_url)
                .width(100)
                .aspectRatio(1)
                .borderRadius(10)
                .margin({ right: 10 })
              Column({ space: 6 }) {
                Text(this.GoodsData.name)
                  .fontSize(14)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(this.GoodsData.description)
                  .fontSize(12)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Row() {
                  Text() {
                    Span('￥')
                      .fontSize(12)
                      .fontColor('#f40')
                    if (this.GoodsData.covered_status == 0) {
                      Span(((this.GoodsData.discount_price ?? this.GoodsData.price) * 100 / 100).toFixed(2)) // 强制保留2位小数
                        .fontColor('#f40')
                    } else {
                      Span(this.GoodsData.covered_price)
                        .fontColor('#f40')
                    }

                  }

                  Blank()
                    .layoutWeight(1)
                  Counter() {
                    Text(this.value.toString())
                  }
                  .onInc(() => {
                    this.value++
                    // 数量变化后重新校验优惠券可用性
                    this.checkCouponAfterQuantityChange()
                  })
                  .onDec(() => {
                    if (this.value > 1) {
                      this.value--
                      // 数量变化后重新校验优惠券可用性
                      this.checkCouponAfterQuantityChange()
                    }
                  })
                }
                .layoutWeight(1)
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(VerticalAlign.Bottom)
              }
              .height('100%')
              .layoutWeight(1)
              .justifyContent(FlexAlign.Start)
              .alignItems(HorizontalAlign.Start)
            }
          }
          .width('100%')
          .height(100)
          .alignItems(VerticalAlign.Bottom)
          .justifyContent(FlexAlign.SpaceBetween)

          Row({ space: 10 }) {
            Text('优惠卷')
            if (this.CouponsAvailable.length > 0 && this.Index !== -1 && this.isCouponUsable() &&
              this.GoodsData.covered_status == 0) {
              Text('已选优惠券')
                .fontSize(12)
                .fontColor('#f40')
                .padding(1)
                .borderRadius(2)
                .backgroundColor('#ffffede5')
                .border({ width: 1, color: '#ffff7777' })
              Blank()
                .layoutWeight(1)
              Text(`减 ￥${this.CouponsAvailable[this.Index].deduction_amount.toFixed(2)}`)
                .fontColor('#f40')
            } else {
              Blank()
                .layoutWeight(1)
              Text('无可用优惠劵')
                .fontColor('#999')
            }

            Image($r('app.media.icon_right'))
              .width(18)
              .onClick(() => {
                this.CouponsDialog.open()
              })
          }
          .width('100%')
          .padding({ top: 20, left: 20, bottom: 20 })

          Column({ space: 10 }) {
            if (this.ActivitySettings.enable_username == 1)
            Row({ space: 6 }) {
              Text('*')
                .fontSize(14)
                .fontColor('#f40')
              Text('用户信息')
              TextInput({ placeholder: '请填写姓名', text: $$this.name })
                .borderRadius(0)
                .backgroundColor(Color.Transparent)
            }
            if (this.ActivitySettings.enable_phone == 1)
            Row({ space: 6 }) {
              Text('*')
                .fontSize(14)
                .fontColor('#f40')
              Text('联系电话')
              TextInput({ placeholder: '请填写手机号', text: $$this.phone })
                .borderRadius(0)
                .backgroundColor(Color.Transparent)
            }
            if (this.ActivitySettings.enable_remark == 1)
            Row({ space: 6 }) {
              Text('留言备注')
              TextInput({ placeholder: '请输入备注', text: $$this.remark })
                .borderRadius(0)
                .backgroundColor(Color.Transparent)
            }
          }

          Column() {
            Row() {
              Image($r('app.media.icon_wechat'))
                .width(16)
                .aspectRatio(1)
                .margin({ right: 2 })
              Text('微信支付')
              Blank()
                .layoutWeight(1)
              Radio({ value: 'wechat', group: 'pay' })
                .checked(true)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.pay = 'WEIXIN'
                  }
                })
            }
            .width('100%')
            .height('50%')
            .margin({ top: 10 })

            Row() {
              Image($r('app.media.icon_alipay'))
                .width(16)
                .aspectRatio(1)
                .margin({ right: 2 })
              Text('支付宝支付')
              Blank()
                .layoutWeight(1)
              Radio({ value: 'alipay', group: 'pay' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.pay = 'ALIPAY'
                  }
                })
            }
            .width('100%')
            .height('50%')
            .margin({ bottom: 30 })

            Row() {
              // 合计金额展示（修复精度显示）
              Column() {
                Row() {
                  Text('合计 ')
                  if (this.GoodsData.covered_status == 0) {
                    Text(`￥${this.calculateFinalPrice().toFixed(2)}`)
                      .fontColor('#f40')
                  } else {
                    Text(this.GoodsData.covered_price)
                      .fontColor('#f40')
                  }

                }

                // 仅当优惠券可用时展示优惠金额
                if (this.isCouponUsable() && this.GoodsData.covered_status == 0) {
                  Text(`共减￥${this.CouponsAvailable[this.Index].deduction_amount.toFixed(2)}`)
                    .fontColor('#f40')
                    .fontSize(14)
                }
              }

              Button('提交')
                .fontColor('#fff')
                .backgroundColor('#f40')
                .width(80)
                .onClick(() => {
                  const finalPrice = this.calculateFinalPrice();
                  // 优惠券ID列表（仅传递可用的优惠券）
                  const couponIds: number[] = this.isCouponUsable()
                    ? [this.CouponsAvailable[this.Index].coupon_user_id]
                    : [];
                  const username: string = this.name.length > 0 ? this.name : ''
                  const phone: string = this.phone.length > 0 ? this.phone : ''
                  const remark: string = this.remark.length > 0 ? this.remark : ''
                  VHSaaSDK.getInstance().CreateGoodsOrder(
                    finalPrice.toString(), this.pay,
                    {
                      "goods_id": this.GoodsData.goods_id,
                      "quantity": this.value,
                      "buy_type": this.GoodsData.buy_type
                    },
                    couponIds, username, phone, remark, this.webinars.webinar?.id.toString() as string,
                    {
                      onSucceed: (data: VHCreateOrderInfo) => {
                        if (this.pay === 'WEIXIN') {
                          this.openLink(data.ext);
                        } else {
                          const context: common.UIAbilityContext =
                            this.getUIContext().getHostContext()! as common.UIAbilityContext;
                          startBrowsableAbility(context, data.ext);
                        }
                        // setTimeout(() => {
                        //   this.OrdersSucceedDialog.open()
                        //   this.Controller.close()
                        // }, 5000)
                        ToastUtil.showToast('订单创建成功')
                        this.Controller.close()
                      },
                      onFailure: (errorCode: number, errorMsg: string) => {
                        ToastUtil.showToast(`创建失败：${errorMsg}`)
                      }
                    }
                  );
                  this.Controller.close()
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')
          .height(80)
          .border({ width: { top: 1 }, color: '#ffe3e3e3' })
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('70%')
    .padding(20)
    .borderRadius(12)
    .padding(30)
    .backgroundColor('#fff')
  }

  // 新增：数量变化后重新校验优惠券可用性
  private checkCouponAfterQuantityChange() {
    if (this.Index === -1 || this.CouponsAvailable.length === 0) {
      return;
    }
    // 若当前选中的优惠券已不可用，重新查找可用优惠券
    if (!this.isCouponUsable()) {
      const currentPrice = this.GoodsData.discount_price ?? this.GoodsData.price;
      for (let i = 0; i < this.CouponsAvailable.length; i++) {
        const coupon = this.CouponsAvailable[i];
        if (Math.round(currentPrice * 100) >= Math.round(coupon.threshold_amount * 100)) {
          this.Index = i;
          return;
        }
      }
      // 无可用优惠券时重置索引
      this.Index = -1;
    }
  }
}

//订单创建成功页面
@CustomDialog
export struct VHOrdersSucceed {
  Controller: CustomDialogController

  build() {
    Column({ space: 10 }) {
      Image($r('app.media.close_gray'))
        .width(20)
        .aspectRatio(1)
        .position({ x: '90%', y: '5%' })
        .onClick(() => {
          this.Controller.close()
        })
      Image($r('app.media.icon_succeed'))
        .width(50)
        .aspectRatio(1)
      Text('支付成功')
        .fontSize(20)
        .fontWeight(700)
    }
    .width('100%')
    .height('50%')
    .backgroundColor('#fff')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}