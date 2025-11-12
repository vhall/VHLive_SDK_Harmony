import {
  MenuInfoItem,
  VHCurrentInviterData,
  VHInviteCard,
  VHInviteTopList,
  VHInviteTopListDetails,
  VHMenuInfo,
  VHSaaSDK,
  VHSubjectInfo,
  VHSubjectList,
  VHWebinarData,
  VHWebinarDetail,
  VHWebinarList
} from '@vhall/vhall_live';
import { PromptActionClass } from '../../util/PromptActionClass';
import { ComponentContent } from '@kit.ArkUI';
import { WebViewPageBuilder, WebViewParams } from '../../pages/WebViewPage';
import { webview } from '@kit.ArkWeb';
import { VHInviteDialog } from './VHInviteDialog';
import { VHInviteDetailDialog } from './VHInviteDetailDialog';
import { VHIntroductionView } from '../introduction/VHIntroductionView';
import { ToastUtil } from '../../action/ToastUtil';

// 在组件外部或内部定义接口
interface Offset {
  dx: number;
  dy: number;
}
/**
 * 自定义菜单
 * */
@Component
export struct VHCustomMenu{
  @Require webinars: VHWebinarData;
  @Require menu_id: string;
  @State componentList: MenuInfoItem[] = [];
  @State subjectList: VHSubjectInfo[] = [];
  @State webinarList: VHWebinarDetail[] = [];
  @State topListDetails: VHInviteTopListDetails[] = [];
  @State currentInviterData: VHCurrentInviterData| null = null;
  @Provide inviteCard:VHInviteCard| null = null;
  @State isInvite: boolean = false;
  @State showInviteTopList: boolean = false;
  @State ruleContent: string = "";
  @State isShowRule: boolean = false;
  @State defaultAvatar: string = '';
  @State dialogOffset: Offset = { dx: 0, dy: 130 };
  private scroller: Scroller = new Scroller();
  private contentNode: ComponentContent<Object> | null = null;
  @Require @Prop enableInviteCard:number = 0;
  controller: webview.WebviewController = new webview.WebviewController();

  aboutToAppear() {
    this.getMenuInfo();
    this.getDefaultAvatar();
  }

  // 获取默认头像
  getDefaultAvatar(){
    this.defaultAvatar = VHSaaSDK.getInstance() .getDefaultAvatar();
  }
  //邀请底部弹窗视图
  VHInviteDialog = new CustomDialogController({
    builder: VHInviteDialog({webinars:this.webinars,inviteCode:this.inviteCard?.invite_code}),
    customStyle: true,
    alignment: DialogAlignment.Center
  })

  VHInviteDetailDialog = new CustomDialogController({
    builder: VHInviteDetailDialog({webinars:this.webinars,selfDownloadSwitch: this.inviteCard?.self_download_switch}),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })

  VHRuleDialog = new CustomDialogController({
    builder: VHRuleDialog({content:this.ruleContent}),
    customStyle: true,
    alignment: DialogAlignment.Top,
    offset: this.dialogOffset,
    cancel: () => {
      this.isShowRule = false;
    }
  })

  // 添加更新方法
  updateVHRuleDialogOffset() {
    this.VHRuleDialog = new CustomDialogController({
      builder: VHRuleDialog({content:this.ruleContent}),
      customStyle: true,
      alignment: DialogAlignment.Top,
      offset: this.dialogOffset,
      cancel: () => {
        this.isShowRule = false;
      }
    });
  }


  getMenuInfo() {
    VHSaaSDK.getInstance()
      .getMenuInfo(this.menu_id, {
        onSucceed: (data: VHMenuInfo) => {
          this.componentList = data?.components;
          if (this.componentList.length > 0) {
            for (let index = 0; index < this.componentList.length; index++) {
              const element = this.componentList[index];
              if (element.component_id === 4) {
                this.getSubjectIds(element.subjects);
              }
              if(element.component_id === 3){
                this.getLiveIds(element.webinars);
              }
              if (element.component_id === 9 && element.inSwitch === 1) {
                this.isInvite = element.inSwitch > 0;
                this.ruleContent = element.inContent;
                // 排行榜
                this.getInviteTopList(this.webinars?.webinar!.id.toString(),
                  this.webinars?.join_info!.user_id.toString(), '0', '20');
                this.getInviteCard(this.webinars?.webinar!.id.toString(), this.webinars?.join_info!.user_id.toString(), this.webinars?.webinar!.userinfo.user_id.toString());
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          console.log("获得自定义菜单信息失败：", errorMsg)
        }
      });
  }

  /**
   * 批量获取专题信息
   * @param subjectIds
   */
  getSubjectBatchInfo(subjectIds: string) {
    VHSaaSDK.getInstance()
      .getSubjectBatchInfo(subjectIds, {
        onSucceed: (data: VHSubjectList) => {
          this.subjectList = data?.list;
        },
        onFailure: (errorCode, errorMsg) => {
          console.log("获得主题列表失败：", errorMsg)
        }
      });
  }

  /**
   * 批量获取专题信息
   * @param subjectIds
   */
  getSubjectIds(subjects: string[]) {
    if (subjects.length > 0) {
      let subjectIds: string = subjects.join(",");
      this.getSubjectBatchInfo(subjectIds);
    }
  }

  /**
   * 批量获取活动信息
   * @param webinars
   */
  getLiveIds(webinars: string[]) {
    if (webinars.length > 0) {
      let webinarIds: string = webinars.join(",");
      this.getWebinarBatchInfo(webinarIds);
    }
  }

  /**
   * 批量获取活动信息
   * @param webinarIds
   */
  getWebinarBatchInfo(webinarIds: string) {
    VHSaaSDK.getInstance()
      .getWebinarInfo(webinarIds, {
        onSucceed: (data: VHWebinarList) => {
          this.webinarList = data?.list;
        },
        onFailure: (errorCode, errorMsg) => {
          console.log("获得主题列表失败：", errorMsg)
          ToastUtil.showToast(`获得主题列表失败： ${errorMsg}`);
        }
      });
  }

  getInviteTopList(sourceId: string, inviteId: string,  post: string, limit: string) {
    VHSaaSDK.getInstance()
      .getInviteTopList(sourceId, inviteId, post, limit, {
        onSucceed: (data: VHInviteTopList) => {
          this.topListDetails = data?.list;
          this.currentInviterData = data?.my;
        },
        onFailure: (errorCode, errorMsg) => {
          console.log("获得排行榜列表失败：", errorMsg)
          ToastUtil.showToast(`获得排行榜列表失败： ${errorMsg}`);
        }
      });
  }

  getInviteCard(sourceId: string, inviteId: string, businessUid: string) {
    VHSaaSDK.getInstance()
      .getInviteCard(sourceId, inviteId,  businessUid, {
        onSucceed: (data: VHInviteCard) => {
          this.inviteCard = data as VHInviteCard;
        },
        onFailure: (errorCode, errorMsg) => {
          console.log("获得邀请卡失败：", errorMsg)
          ToastUtil.showToast(`获得邀请卡失败： ${errorMsg}`);
        }
      });
  }


  getTypeName(type: number) {
    // type 活动当前状态 1-直播中，2-预约，3-结束，4-点播，5-回放
    switch (type) {
      case 1:
        return "直播";
      case 2:
        return "预约";
      case 3:
        return "结束";
      case 4:
        return "点播";
      case 5:
        return "回放";
      default:
        return "";
    }
  }


  getWebinarTypeName(type: number) {
    // 1 音频 2 视频 3 互动 5 定时直播
    switch (type) {
      case 1:
        return "音频";
      case 2:
        return "视频";
      case 3:
        return "互动";
      case 4:
        return "直播";
      default:
        return "";
    }
  }

  // 图文类型
  @Builder
  ImageTextItem(menuInfo: MenuInfoItem) {
    Column({ space: 0 }) {
      Scroll() {
        VHIntroductionView({ introduction: menuInfo.content })
          .width('100%')
          .height(200)
          .padding({ top: 8, bottom: 8 })
      }
      .width('100%')
      .height(300)
    }.width('100%')
  }

  // 二维码类型
  @Builder
  QRcodeItem(menuInfo: MenuInfoItem) {
    Column({ space: 8 }) {
      Image(menuInfo.imageSrc)
        .width(200)
        .height(200)
        .align(Alignment.Center)
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }

  // 直播类型
  @Builder
  LiveItem() {
    Column({space: 8}) {
      ForEach(this.webinarList, (webinar: VHWebinarDetail, index: number) => {
        Stack() {
          Row() {
            // 图片部分
            Image(webinar.img_url)
              .objectFit(ImageFit.Cover)
              .width(150)
              .height(80)
            Column() {
              Text(webinar.subject)
                .fontSize(12)
                .layoutWeight(1)
                .textAlign(TextAlign.Start)
                .padding(8)
              Text(webinar.start_time)
                .fontSize(12)
                .fontColor(Color.Gray)
                .layoutWeight(1)
                .textAlign(TextAlign.Start)
                .padding(8)
            }.height(40)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
          }
          .alignItems(VerticalAlign.Top)
          .justifyContent(FlexAlign.Start)
          .width('100%')
          .height(80)
          .zIndex(1)
          .onClick(() => {
            let url = VHSaaSDK.getInstance().getLiveDetailUrl(webinar.id.toString(), this.webinars?.join_info!.user_id.toString(), this.inviteCard?.invite_code!);
            this.openLink(url);
          })

          // PV信息显示在右下角
          Row() {
            Image($r("app.media.pv"))
              .width(20)
              .height(20)
              .visibility(webinar.hide_pv === 1 ? Visibility.Visible : Visibility.Hidden)
            Text(webinar.pv.toString())
              .fontSize(12)
              .fontColor(Color.White)
              .visibility(webinar.hide_pv === 1 ? Visibility.Visible : Visibility.Hidden)
          }
          .position({ x: 5, y: 56 })
          .padding({right: 5, bottom: 5})
          .zIndex(2)

          // 显示视屏状态，左上角
          Row() {
            Text(this.getTypeName(webinar.webinar_state))
              .fontSize(12)
              .fontColor(Color.White)

            Text("|")
              .fontSize(12)
              .fontColor(Color.White)
              .padding({left: 5, right: 5})
              .visibility(this.getTypeName(webinar.webinar_state).length > 0 ? Visibility.Visible : Visibility.Hidden)

            Text(this.getWebinarTypeName(webinar.webinar_type))
              .fontSize(12)
              .fontColor(Color.White)
          }
          .position({ x: 5, y: 8 })
          .padding({right: 5, bottom: 5})
          .zIndex(2)
        }
      })
    }.width('100%') .padding({left: 8,right:8})
  }

  // 专题类型
  @Builder
  SubjectItem() {
    Column({space: 8}) {
      ForEach(this.subjectList, (subjectInfo: VHSubjectInfo, index: number) => {
        Stack() {
          Row() {
            // 图片部分
            Image(subjectInfo.cover)
              .objectFit(ImageFit.Cover)
              .width(150)
              .height(80)

            // 标题文本与图片并排显示
            Text(subjectInfo.title)
              .fontSize(12)
              .layoutWeight(1)  // 占据剩余空间
              .textAlign(TextAlign.Start)
              .padding(8)  // 添加左边距与图片分开
          }
          .alignItems(VerticalAlign.Top)
          .width('100%')
          .height(80)
          .zIndex(1)
          .onClick(() => {
            let url = VHSaaSDK.getInstance().getSubjectDetailUrl(subjectInfo.id.toString());
            this.openLink(url);
          })

          // PV信息显示在右下角
          Row() {
            Image($r("app.media.pv"))
              .width(20)
              .height(20)
              .visibility(subjectInfo.hide_pv === 1 ? Visibility.Visible : Visibility.Hidden)
            Text(subjectInfo.pv.toString())
              .fontSize(12)
              .fontColor(Color.White)
              .visibility(subjectInfo.hide_pv === 1 ? Visibility.Visible : Visibility.Hidden)
          }
          .position({ x: 5, y: 56 })
          .padding({right: 5, bottom: 5})
          .zIndex(2)
        }
      })
    }.width('100%') .padding({left: 8,right:8})
  }



  // 打开链接
  private openLink(url: string) {
    const params=new WebViewParams("e.vhall.com",url);
    this.contentNode = new ComponentContent(this.getUIContext(), wrapBuilder(WebViewPageBuilder),params);
    PromptActionClass.setContext(this.getUIContext());
    PromptActionClass.setContentNode(this.contentNode);
    PromptActionClass.setOptions({alignment: DialogAlignment.Center, offset: { dx: 0, dy: 50 } ,isModal: true,maskRect:{x: 0, y: 0, width: '100%', height: '100%' }});
    PromptActionClass.openDialog();
  }

  // 文字链类型
  @Builder
  TextLinkItem(menuInfo: MenuInfoItem) {
    Column({ space: 8 }) {
      Text(menuInfo.text)
      .fontSize(16)
        .align(Alignment.Center)
        .fontColor(Color.Blue)
      .onClick(() => {
        this.openLink(menuInfo.src);
      })
    }
    .margin({top:20})
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }

  // 图片链类型
  @Builder
  ImageLinkItem(menuInfo: MenuInfoItem) {
    Column({ space: 8 }) {
      Image(menuInfo.imageSrc)
        .width(300)
        .height(300)
        .align(Alignment.Center)
        .onClick(() => {
          this.openLink(menuInfo.src);
        })
    }
    .width('100%')
    .margin({top:20})
    .justifyContent(FlexAlign.Start)
  }

  // 标题类型
  @Builder
  TitleItem(menuInfo: MenuInfoItem) {
    Column({ space: 8 }) {
      Text(menuInfo.title)
        .fontSize(16)
        .align(Alignment.Center)
        .fontColor(Color.Blue)
    }
    .margin({top:20})
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }

  // 分割线类型
  @Builder
  DividerItem() {
    Divider()
      .width('90%')
      .strokeWidth(1)
      .color('#e5e5e5')
      .borderWidth(0.5)
      .borderStyle(BorderStyle.Dashed)
      .margin({top:20,left:8,right:8})
  }

  // 排行榜类型
  @Builder
  RankingListItem(menuInfo: MenuInfoItem) {
    Column({space: 8}) {
      Row() {
        Text('排行榜')
          .fontSize(16)
          .textAlign(TextAlign.Start)
          .padding(8)
        if (this.inviteCard !== null && this.inviteCard?.invite_detail_switch === 1)
        Text('我的邀请明细')
          .fontSize(14)
          .fontColor(Color.Blue)
          .textAlign(TextAlign.Start)
          .onClick(()=>{
            this.VHInviteDetailDialog.open();
          })
        if (menuInfo.inContent.length > 0)
        Row() {
          Text('邀请榜规则')
            .fontSize(14)
            .textAlign(TextAlign.End)
            .padding({ left: 120 })
          Image(this.isShowRule ? $r("app.media.chevron_up") : $r("app.media.chevron_down"))
            .width(24)
            .height(24)
            .onClick((event: ClickEvent) => {
              this.isShowRule = !this.isShowRule;
              console.log("event.windowY:" + event.windowY);
              this.dialogOffset = {
                dx: 0,
                dy: event.windowY + 10
              };
              this.updateVHRuleDialogOffset();
              if (this.isShowRule) {
                this.VHRuleDialog.open();
              } else {
                this.VHRuleDialog.close();
              }
            })
        }.padding({ right: 65 })
      }

        ForEach(this.topListDetails, (detail: VHInviteTopListDetails, index) => {
          ListItem() {
            Row() {
              Row() {
                Text(index < 9 ? '0' + (index + 1).toString() : (index + 1).toString())
                  .fontSize(12)
                  .textAlign(TextAlign.Start)
                  .padding(8)
                Image(detail?.img_url!==null && detail.img_url.length > 0 ? detail.img_url : this.defaultAvatar)
                  .objectFit(ImageFit.Cover)
                  .width(30)
                  .height(30)

                Text(detail?.nick_name.length > 0 ? detail.nick_name : "--")
                  .fontSize(12)
                  .textAlign(TextAlign.Start)
                  .padding(8)
              }

              Row() {
                Text("邀请")
                  .fontSize(12)
                Text(detail.num.toString())
                  .fontSize(12)
                  .fontColor(Color.Red)
                  .padding(4)
                Text("人")
                  .fontSize(12)
              }.padding(8)
            }.width('100%').justifyContent(FlexAlign.SpaceBetween)
          }

          // 分隔线
          if (index <= this.topListDetails!.length - 1) {
            Divider()
              .height(1)
              .color('#555555')
              .margin({ left: 8, right: 8 })
          }
        })


      if(this.isInvite && this.currentInviterData!)
      Row() {
        Row() {
          Image(this.webinars?.join_info!.avatar)
            .objectFit(ImageFit.Cover)
            .width(30)
            .height(30)
          Text( this.webinars?.join_info!.nickname)
            .fontSize(12)
            .textAlign(TextAlign.Start)
            .padding(8)
        }

        if(this.enableInviteCard == 1){
          Row() {
            Text("邀请")
              .fontSize(12)
            Text(this.currentInviterData!.num.toString())
              .fontSize(12)
              .fontColor(Color.Red)
              .padding(4)
            Text("人")
              .fontSize(12)
          }.padding(8)

          Button('去邀请')
            .width(80)
            .height(30)
            .backgroundColor(Color.Red)
            .borderRadius(4)
            .fontSize(12)
            .fontColor(Color.White)
            .onClick(() => {
              this.VHInviteDialog.open()
            })
        }
      }.width('100%').padding(8).margin({ top: 100, bottom: 20 }).justifyContent(FlexAlign.SpaceBetween)
    }.width('100%') .padding({left: 8,right:8}).alignItems(HorizontalAlign.Start)
  }

  // 外链嵌入类型
  @Builder
  EmbedItem(menuInfo: MenuInfoItem) {
    Web({
      src: menuInfo.url,
      controller: this.controller
    })
      .width('90%')
      .height(menuInfo.pageHeight!==''?menuInfo.pageHeight:300)
      .domStorageAccess(true)
      .onlineImageAccess(true)
      .imageAccess(true)
      .zoomAccess(false)
      .javaScriptAccess(true)
      .geolocationAccess(true)
      .mediaPlayGestureAccess(true)
      .databaseAccess(true)
  }

  build() {
    Column() {
      List({ scroller: this.scroller }) {
        ForEach(this.componentList, (menuInfo: MenuInfoItem, index: number) => {
          ListItem() {
            // 1:图文，2：二维码，3：直播，4：专题，5：文字链，6：图片链，7：标题，8：分割线， 9：排行榜,10: 外链嵌入
            if (menuInfo.component_id === 1) {
              this.ImageTextItem(menuInfo);
            } else if (menuInfo.component_id === 2) {
              this.QRcodeItem(menuInfo);
            } else if (menuInfo.component_id === 3) {
              this.LiveItem();
            } else if (menuInfo.component_id === 4) {
              this.SubjectItem();
            } else if (menuInfo.component_id === 5) {
              this.TextLinkItem(menuInfo);
            } else if (menuInfo.component_id === 6) {
              this.ImageLinkItem(menuInfo);
            } else if (menuInfo.component_id === 7) {
              this.TitleItem(menuInfo);
            } else if (menuInfo.component_id === 8) {
              this.DividerItem();
            } else if (menuInfo.component_id === 9) {
              this.RankingListItem(menuInfo);
            } else if (menuInfo.component_id === 10) {
              this.EmbedItem(menuInfo);
            }
          }
          .padding(0)  // 添加这一行
          .margin(0)   // 添加这一行
        })
      }
    }
    .width('100%')
  }
}


@CustomDialog
export struct VHRuleDialog {
  controller: CustomDialogController
  @Require content: string;
  build() {
    Column(){
      VHIntroductionView({introduction:this.content})
        .width('100%')
        .padding({ top: 20, bottom: 20 })
    }.width('96%')
    .height(300)
  }
}