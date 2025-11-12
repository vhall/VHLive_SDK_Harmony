import { VHInviteCard, VHSaaSDK, VHWebinarData } from '@vhall/vhall_live';
import { promptAction } from '@kit.ArkUI';
import ChatTools from '../../util/ChatTools';
import componentSnapshot from '@ohos.arkui.componentSnapshot';
import fs from '@ohos.file.fs';
import image from '@ohos.multimedia.image';
import { BusinessError } from '@ohos.base';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import bundleManager from '@ohos.bundle.bundleManager';
import http from '@ohos.net.http';

// 使用接口定义位置对象类型
interface Position {
  x: number;
  y: number;
}



/**
 * 邀请底部弹窗视图
 */
@CustomDialog
export struct VHInviteDialog {
  controller: CustomDialogController
  @Consume inviteCard: VHInviteCard;
  @Require webinars: VHWebinarData;
  @Require inviteCode: string;
  @State selectedCardId: string = '-1';

  // 选中的图片资源
  @State selectedImage: string ='';
  // 预览图是否显示
  @State showPreview: boolean = true;
  // 操作菜单是否显示
  @State showActionMenu: boolean = false;
  // 操作菜单位置
  @State menuPosition: Position = { x: 0, y: 0 };
  private rqCodeUrl: string = '';
  @State filePath: string = ''; // 保存图片后的文件路径
  private targetId: string = "contentToCapture"; // 目标组件ID

  aboutToAppear() {
    let liveDetailUrl = VHSaaSDK.getInstance()
      .getLiveDetailUrl(this.webinars?.webinar!.id.toString(), this.webinars?.join_info!.user_id.toString(),
        this.inviteCard?.invite_code!);
    this.rqCodeUrl = 'https://aliqr.e.vhall.com/qr.png?s=7&t=' + encodeURIComponent(liveDetailUrl);
  }

  // 关闭弹窗
  private closePopup() {
    this.resetState();
    this.controller.close()
  }

  // 处理长按事件
  private handleLongPress(event: GestureEvent) {
    this.menuPosition = {
      x: event.velocityX,
      y: event.velocityY
    };
    this.showActionMenu = true;
  }

  // 重置状态
  private resetState() {
    this.selectedCardId = '-1';
    this.selectedImage = '';
    this.showPreview = false;
    this.showActionMenu = false;
  }

  // 图片分享
  private async shareImage() {
    this.showActionMenu = false;
    const uiContext: UIContext = this.getUIContext();
    if(this.filePath === ''){
      try {
        // 等待截图完成并保存文件
        await new Promise<void>((resolve, reject) => {
          componentSnapshot.get(this.targetId)
            .then(async (pixmap: image.PixelMap) => {
              if (pixmap !== null) {
                // 处理获取到的快照
                const context = getContext(this) as common.UIAbilityContext;
                this.filePath = await this.saveFile(context, pixmap);
                resolve();
              } else {
                reject(new Error("未能获取到截图"));
              }
            }).catch((err: Error) => {
            console.log("错误: " + err);
            reject(err);
          });
        });
      } catch (error) {
        promptAction.showToast({ message: "截图保存失败" });
        return;
      }
    }

    let utdTypeId = utd.getUniformDataTypeByFilenameExtension('.jpg', utd.UniformDataType.IMAGE);

    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utdTypeId,
      uri: this.filePath,
      title: this.inviteCard.title,
      description: '分享图片' + this.inviteCard.title,
    });

    let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
    controller.show(context, {
      selectionMode: systemShare.SelectionMode.SINGLE,
      previewMode: systemShare.SharePreviewMode.DETAIL,
    }).then(() => {
      console.info('分享成功.');
      promptAction.showToast({ message: "分享成功！" });
    }).catch((error: BusinessError) => {
      console.error(`ShareController show error. code: ${error?.code}, message: ${error?.message}`);
      promptAction.showToast({
        message: '分享失败，请重试',
        duration: 2000
      });
    });
  }


  // 保存图片到本地像册
  private async saveImage() {
    this.showActionMenu = false;
    componentSnapshot.get(this.targetId)
      .then(async (pixmap: image.PixelMap) => {
        if (pixmap !== null) {
          // 处理获取到的快照
          const context = getContext(this) as common.UIAbilityContext;
          this.filePath = await this.saveFile(context, pixmap);
          console.log('保存路径:', this.filePath);
          promptAction.showToast({ message: "保存路径！" + this.filePath });
        }
      }).catch((err: Error) => {
      console.log("错误: " + err);
    })
  }

  /**
   * packing获取图片的ArrayBuffer数据，再使用fs库将图片写入文件
   */
  async saveFile(context: Context, pixelMap: PixelMap): Promise<string> {
    // 添加权限检查
    let hasPermission = await this.requestMediaPermission();
    if (!hasPermission) {
      promptAction.showToast({ message: '未获得相册访问权限，无法保存图片' });
      throw new Error('Permission denied');
    }
    // 创建图像编码ImagePacker对象
    const imagePackerApi = image.createImagePacker();
    // 设置编码输出流和编码参数。format为图像的编码格式；quality为图像质量，范围从0-100，100为最佳质量
    const options: image.PackingOption = { format: 'image/jpeg', quality: 100 };
    // 图片写入的沙箱路径
    const filePath: string = `${context.filesDir}/${this.inviteCard.title}.jpg`;
    // 使用packing打包获取图片的ArrayBuffer
    const data: ArrayBuffer = await imagePackerApi.packing(pixelMap, options);
    // 保存相册获得URI
    let helper = photoAccessHelper.getPhotoAccessHelper(context);
    let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg');
    // 写入相册
    let file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    await fs.write(file.fd, data);
    await fs.close(file.fd);
    return uri;
  }

  /**
   * 获取当前时间的拼接字符串，用于图片命名
   */
  private getTimeStr(): string {
    const now: Date = new Date();
    const year: number = now.getFullYear();
    const month: number = now.getMonth() + 1;
    const day: number = now.getDate();
    const hours: number = now.getHours();
    const minutes: number = now.getMinutes();
    const seconds: number = now.getSeconds();
    return `${year}${month}${day}_${hours}${minutes}${seconds}`;
  }

  // 检查并请求媒体库权限
  async requestMediaPermission() {
    let atManager = abilityAccessCtrl.createAtManager();
    // 2. 获取应用Bundle信息（含令牌相关信息）
    const bundleInfo =
      await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    const tokenId = bundleInfo.appInfo.accessTokenId; // 从应用信息中获取tokenID
    let result = atManager.verifyAccessTokenSync(tokenId, 'ohos.permission.WRITE_MEDIA');
    if (result === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      // 已获得权限，可以进行媒体库操作
      return true;
    } else {
      // 申请权限
      let requestResult = await atManager.requestPermissionsFromUser(
        getContext(),
        ['ohos.permission.WRITE_MEDIA']
      );

      return requestResult.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    }
  }



  // 使用示例
  async accessMediaLibrary() {
    let hasPermission = await this.requestMediaPermission();
    if (hasPermission) {
      // 执行媒体库操作
      console.log("已获得媒体库访问权限");
    } else {
      console.log("未获得媒体库访问权限，无法执行操作");
    }
  }

  build() {
    Column(){
      Column() {
        Row(){
          Image($r('app.media.fingerprint'))
            .width(24)
            .height(24)
          Text('按图片保存或分享')
            .fontSize(14)
            .fontColor(Color.White)
        }
      }
      .width('100%')
      .height(20)
      .margin({ bottom: 10 })
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)

      Column({ space: 8 }) {
        Column() {
          Row() {
            Image(this.webinars?.join_info?.avatar)
              .width(30)
              .height(30)
              .borderRadius(20)
              .margin(10)
            Column() {
              Text(ChatTools.getLimitString(this.webinars?.join_info?.nickname!, 8))
                .fontSize(12)
              Text('邀请您一起参与')
                .fontSize(12)
            }.width('100%').alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.Center)
          }.width('100%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Start)
        }

        Column({ space: 4 }) {
          Image(this.inviteCard.cover_img)
            .width(260)
            .height(130)
            .objectFit(ImageFit.Cover)
            .borderRadius(2)

          Text(this.inviteCard.title)
            .margin({top:20,bottom:20})
            .fontSize(20)
            .textAlign(TextAlign.Center)
          Text('时间')
            .fontSize(12)
            .textAlign(TextAlign.Center)

          Text(this.inviteCard.date_time)
            .fontSize(12)
            .textAlign(TextAlign.Center)

          Divider()
            .strokeWidth(0.5)
            .color('#e5e5e5')
            .borderWidth(0.5)
            .borderStyle(BorderStyle.Dashed)
            .margin({top:40,bottom:8,left:12,right:12})

          Image(this.rqCodeUrl)
            .width(80)
            .height(80)
            .margin({ top:12})

          Text('扫码观看直播')
            .fontSize(12)
            .fontColor(Color.Gray)
            .textAlign(TextAlign.Center)
        }.width(280)
        .height(450)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .borderRadius(8)
        .backgroundColor(Color.White)
      }
      .id(this.targetId)
      .width(300)
      .height(550)
      .borderRadius(8)
      .backgroundImage($r('app.media.poster_bg'))
      .backgroundImageSize(ImageSize.Cover)
      .gesture(
        LongPressGesture()
          .onAction((event) => {
            this.handleLongPress(event);
          })
      )


      // 长按操作菜单
      if (this.showActionMenu)
      Column()
      {
        Text('保存图片')
          .width('100%')
          .padding(12)
          .fontSize(16)
          .textAlign(TextAlign.Center)
          .onClick(() => this.saveImage())
        Divider().height(1).color('#EEEEEE')
        Text('分享')
          .width('100%')
          .padding(12)
          .fontSize(16)
          .textAlign(TextAlign.Center)
          .onClick(() => this.shareImage())
        Divider().height(1).color('#EEEEEE')
        Text('关闭')
          .width('100%')
          .padding(12)
          .fontSize(16)
          .textAlign(TextAlign.Center)
          .onClick(() => this.showActionMenu=false)
      }
      .width(160)
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
      .shadow({ radius: 10, color: '#44000000' })
      .zIndex(14)
      .position({
        x: (this.menuPosition.x ?? 0) + 50,
        y: (this.menuPosition.y ?? 0) + 100
      })
    }
  }
}