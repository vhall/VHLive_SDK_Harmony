import { VHDocFilType, VHDocument, VHDocumentViewModel, VHDocumentWaterMark,VHDocumentPageModel } from "@vhall/vhallyun-doc";
import { VHWatermarkConfig, VHWebinarData } from "../model/VHWatchWebinarInfo";
import { VHDocCallbackInterface } from "./VHDocCallback";
import { VHDocType } from "./VHDocConstant";
import { JSON } from "@kit.ArkTS";
export class VHDoc {
  private documentController: VHDocument = new VHDocument(new VHDocumentViewModel(VHDocFilType.DOC));
  private isInit: boolean = false;
  private webinarInfo: VHWebinarData | null = null;
  private documentViewsController: Map<string, VHDocument> = new Map();
  private callback: VHDocCallbackInterface | null = null;
  /**
   * @description 播放器配置信息
   * */
  private docWater: VHWatermarkConfig | null = null;

  /**
   * @description 初始化接口， 如果是直播活动类型需要在im.join之后调用
   * @param webinar 活动信息 VHWebinarData
   * @param water 水印信息 VHWatermarkConfig
   * */
  public init(webinar: VHWebinarData, water: VHWatermarkConfig, listener: VHDocCallbackInterface): number {
    this.webinarInfo = webinar;
    this.docWater = water;
    this.callback = listener;
    if (this.webinarInfo.webinar?.type == 1 || this.webinarInfo.webinar?.type == 2 ||
      this.webinarInfo.webinar?.type == 3) {
      this.documentController.initLiveDoc(this.webinarInfo.interact?.room_id, this.webinarInfo.interact?.channel_id,
        this.webinarInfo.interact?.paas_access_token, true, this);
    } else if (this.webinarInfo.webinar?.type == 4 || this.webinarInfo.webinar?.type == 5) {
      this.documentController.initVodDoc(this.webinarInfo.record?.paas_record_id,
        this.webinarInfo.interact?.paas_access_token, this);
    }
    return 0;
  }

  /**
   * @description 销毁
   * */
  public destroy() {
    this.documentController.destroyDoc();
    this.documentViewsController.clear();
  }

  /**
   * @description 设置文档容器大小
   * @param id: 文档id
   * @param width： 容器宽度
   * @param height： 容器高度
   */
  public setDocumentViewSize(id: string, width: number, height: number) {
    if (this.documentViewsController.has(id)) {
      let doc: VHDocument = this.documentViewsController.get(id) as VHDocument;
      doc.setDocumentViewSize(width, height);
    }
  }

  /***
   * @description 获取模型使用，内部使用
   * ****/
  public getDocModel(id: string): object {
    let doc = this.documentViewsController.get(id);
    return doc as object;
  }

  /**
   * @description 放大
   * **/
  public zoomIn(){
    this.documentViewsController.forEach((value:VHDocument,key:string,map:Map<string, VHDocument>)=>{
      value.zoomIn();
    })
  }
  /**
   * @description 缩小
   * **/
  public zoomOut(){
    this.documentViewsController.forEach((value:VHDocument,key:string,map:Map<string, VHDocument>)=>{
      value.zoomOut();
    })
  }
  /**
   * @description 还原
   * **/
  public zoomReset(){
    this.documentViewsController.forEach((value:VHDocument,key:string,map:Map<string, VHDocument>)=>{
      value.zoomReset();
    })
  }

  /**
   * 回调接口：文档初始化、创建失败回调
   * @param errorCode 错误码
   * @param errorMsg  错误信息
   * @param cid 文档白板标识。
   */
  docError(errorCode: number, errorMsg: string, cid?: string) {
    if (this.callback) {
      this.callback.onDocError(errorCode, errorMsg, cid);
    }
  }



  /**
   * 回调接口：观看端是否显示文档
   * 添加文档
   * @param documentView 文档视图
   */
  docAdd(docViewModel: VHDocumentViewModel) {
    if (docViewModel) {
      let document: VHDocument = new VHDocument(docViewModel);
      if (this.docWater?.doc_watermark_open) {
        let waterText = "";
        if (this.docWater.doc_watermark_type.text == 1) {
          waterText = this.docWater?.doc_watermark_type.text_value + "  ";
        }
        if (this.docWater.doc_watermark_type.user_id == 1) {
          waterText += this.webinarInfo?.join_info?.third_party_user_id + "  ";
        }
        if (this.docWater.doc_watermark_type.nick_name == 1) {
          waterText += this.webinarInfo?.join_info?.nickname;
        }

        let mark: VHDocumentWaterMark = new VHDocumentWaterMark(waterText, this.docWater?.doc_font_size);
        mark.color = this.docWater?.doc_font_color;
        mark.opacity = this.docWater.doc_transparency/100;
        mark.angle = 10;
        document.setWaterMark(mark);
      }
      if (this.webinarInfo?.webinar?.type == 1 || this.webinarInfo?.webinar?.type == 2 ||
        this.webinarInfo?.webinar?.type == 3) {
        docViewModel.getLastData = true;
      }
      this.documentViewsController.set(docViewModel.cid, document);
    }
    if (this.callback && docViewModel) {

      if(this.webinarInfo?.webinar?.type == 1){
        if(docViewModel.createData.length > 0){
          try {
            let pageInfo:object = JSON.parse(docViewModel.createData) as object;
            if(JSON.has(pageInfo,"converted_page")){
              let totalPage = pageInfo["converted_page_jpeg"] as number;
              let currentPage = pageInfo["show_page"] as number + 1;
              this.callback.onDocPageChange(totalPage,currentPage);
            }

          }catch (e){

          }
        }
      }

      this.callback.onDocAdd(docViewModel.cid,
        docViewModel.isBoard ? VHDocType.VHDocType_Board : VHDocType.VHDocType_Doc, docViewModel.createData);
    }
  }

  /**
   * 回调接口： 选择文档
   * @param documentView 文档视图
   */
  docSelect(cid: string) {
    if (this.callback) {
      this.callback.onDocSelect(cid);
    }
  }

  /**
   * 回调接口：删除文档
   * @param cid 文档容器id
   */
  docRemove(cid: string) {
    if (this.callback) {
      this.callback.onDocRemove(cid);
    }
    if (this.documentViewsController.has(cid)) {
      let doc = this.documentViewsController.get(cid);
      if (doc) {
        doc.deleteDoc();
      }
      this.documentViewsController.delete(cid);
    }
  }

  /**
   * 回调接口：是否显示文档
   * @param switchStatus 状态
   */
  docSwitchStatus(switchStatus: boolean) {
    if (this.callback) {
      this.callback.onDocSwitchStatus(switchStatus);
    }
  }

  /**
   * 回调接口：翻页消息
   * @param documentView   文档id 为空时没有 文档
   */
  docChangePage(docViewModel: VHDocumentPageModel) {
    if (this.callback) {
      this.callback.onDocPageChange(docViewModel.totalPage,docViewModel.page);
    }
  }

  docViewLoadEnd(doc: VHDocument) {

  }
}