import { VHDoc, VHDocType, VHDocView, VHPlayerConfig, VHWebinarData } from "@vhall/vhall_live"

@Component
export struct VHDocPageComponent {
  @Require webinars: VHWebinarData;
  @Require playConfig: VHPlayerConfig;
  //文档id集合
  @State documentViews: Array<string> = new Array();
  //选择文档id
  @State selectCid: string = '';
  private docController: VHDoc = new VHDoc();
  private controller: TabsController = new TabsController()
  @State showDoc: boolean = true;
  private selectDocument: number = 0;
  private contentWidth: number = 0;
  private contentHeight: number = 0;

  @State currentPage:number = 0;
  @State totalPage:number = 0;

  aboutToAppear(): void {
    this.docController.init(this.webinars, this.playConfig?.water!, this);
  }

  aboutToDisappear(): void {
    this.docController.destroy();
  }

  /**
   * @description 文档初始化、创建失败回调
   * @param errorCode 错误码
   * @param errorMsg  错误信息
   * @param id 文档白板标识。
   */
  onDocError(errorCode: number, errorMsg: string, id?: string) {

  }

  /**
   * @description 添加文档或创建文档成功
   * @param id 文档id
   * @param type 文档类型
   */
  onDocAdd(id: string, type: VHDocType,createData: string) {
    if(this.webinars.webinar?.type == 5){
      let add:boolean = true;
      for (let index = 0; index < this.documentViews.length; index++) {
        const element = this.documentViews[index]
        //回放与直播逻辑存在差异。当同一个文档已经存在不需重复加入载入docview。
        if (element == id) {
          add = false;
          break;
        }
      }
      //为了确保文档每次都刷新添加，延迟展示。
      if(add){
        this.selectDocument = setTimeout(() => {
          this.documentViews.push(id);
        }, 1000);
      }
    }
    else{
      //直播回调每次都加载最新的
      this.documentViews = [];
      //为了确保文档每次都刷新添加，延迟展示。
      this.selectDocument = setTimeout(() => {
        this.documentViews.push(id);
      }, 1000);
    }
  }

  /**
   * @description 切换文档
   * @param id 文档id
   */
  onDocSelect(id: string) {
    this.selectCid = id;
  }

  /**
   * @description 删除文档
   * @param id 文档容器id
   */
  onDocRemove(id: string) {
    let deleteDoc: boolean = false;
    for (let index = 0; index < this.documentViews.length; index++) {
      const element = this.documentViews[index]
      if (element == id) {
        this.documentViews.splice(index, 1);
      }
    }
  }

  onDocPageChange(totalPage:number,currentPage:number){
    this.totalPage = totalPage;
    this.currentPage = currentPage;
  }

  /**
   * @description 是否显示文档
   * @param switchStatus 状态
   */
  onDocSwitchStatus(switchStatus: boolean) {
    this.showDoc = switchStatus;
  }

  @Builder
  tabBuilder(cid: string, targetIndex: number) {
    Column() {
      Text(cid)
        .fontColor(Color.White)
        .margin({ top: 17, bottom: 7 })
    }.backgroundColor('#ffcbd9d9')
  }

  build() {
    Stack({alignContent:Alignment.Bottom}) {
      Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
        ForEach(this.documentViews, (doc: string, index: number) => {
          TabContent() {
            VHDocView({ docController: this.docController, docId: doc, isDocPaint: false })
              .width('100%')
              .height('100%')
              .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
                //重置文档视图大小。
                this.contentWidth = newValue.width as number;
                this.contentHeight = newValue.height as number;
                //********  重要：需要重置文档画布大小 ********/
                this.docController.setDocumentViewSize(doc, this.contentWidth, this.contentHeight);
              })
          }
          .tabBar(this.tabBuilder(doc, index))
          .width('100%')
          .height('100%')
        }, (doc: string, index: number) => {
          //this.selectCid 发生改变时刷新文档当前页。需要延刷新。
          if (this.selectCid == doc) {
            if (this.selectDocument != 0) {
              clearInterval(this.selectDocument);
              this.selectDocument = 0;
            }
            this.selectDocument = setInterval(() => {
              this.controller.changeIndex(index);
              if (this.selectDocument != 0) {
                clearInterval(this.selectDocument);
                this.selectDocument = 0;
              }
            }, 100);
          }
          return doc;
        })
      }
      .barHeight(0) //可通过设置此参数隐藏tab
      .opacity(this.showDoc == true ? 100 : 0) //通过设置透明度来显示和隐藏，避免重新加载docview导致的画笔不全问题
      .animationDuration(0)
      .width('100%')
      .height('100%')
      .scrollable(false)
      .zIndex(0)

      Row(){
        //直播
        if(this.webinars.webinar?.type == 1){
          Text(this.currentPage.toString()).fontColor(Color.Gray)
          Text("/").fontColor(Color.Gray)
          Text(this.totalPage.toString()).fontColor(Color.Gray)
        }

        Image($r("app.media.big"))
          .width("30vp")
          .height("30vp")
          .onClick(()=>{
            this.docController.zoomIn();
          })

        Image($r("app.media.small"))
          .width("30vp")
          .height("30vp")
          .onClick(()=>{
            this.docController.zoomOut();
          })

        Image($r("app.media.1_1"))
          .width("30vp")
          .height("30vp")
          .onClick(()=>{
            this.docController.zoomReset();
          })
      }.zIndex(1)
    }
    .width('100%')
    .height('100%')
  }
}

