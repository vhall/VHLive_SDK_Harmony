export default class HttpNetResponse {
  /**
   * 响应码
   */
  code : number = 0;
  /**
   * 响应消息
   */
  msg : string = '';
  /**
   * 请求id
   */
  request_id : string = '';
  /**
   * 响应数据
   */
  data : string | object = '';

}

export interface CallBack {
  // 成功
  onSuccess: (data: string | object) => void;
  // 失败
  onFailure: (errorCode: number, errorMsg: string) => void;
}