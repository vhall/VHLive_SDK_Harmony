import { VHDocumentViewModel,VHDocumentPageModel } from "@vhall/vhallyun-doc";
import { VHDocType } from "./VHDocConstant";

export interface VHDocCallbackInterface{
  /**
   * @description 文档初始化、创建失败回调
   * @param errorCode 错误码
   * @param errorMsg  错误信息
   * @param id 文档白板标识。
   */
  onDocError:(errorCode: number, errorMsg: string, id?: string)=>void;
  /**
   * @description 添加文档或创建文档成功
   * @param id 文档id
   * @param type 文档类型
   */
  onDocAdd:(id:string,type:VHDocType,createData:string)=>void;
  /**
   *  @description 切换文档
   * @param id 文档id
   */
  onDocSelect:(id: string)=>void;
  /**
   * @description 删除文档
   * @param id 文档容器id
   */
  onDocRemove:(id: string)=>void;
  /**
   * @description  是否显示文档
   * @param switchStatus 状态
   */
  onDocSwitchStatus:(switchStatus: boolean)=>void;
  /**
   * @description  直播文档翻页消息
   * @param totalPage 文档总页数
   * @param currentPage 当前页数
   */
  onDocPageChange:(totalPage:number,currentPage:number)=>void;

}