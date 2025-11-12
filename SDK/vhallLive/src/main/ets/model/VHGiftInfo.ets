/**
 * @description 聊天礼物列表
 */
export class VHGiftList {
  /**
   * @description 总消息个数
   */
  total: number = 0;
  /**
   * @description 消息内容
   */
  list: VHGiftItem[] = [];
}

/**
 * @description 礼物清单
 */
export class VHGiftItem {
  /**
   * @description 礼物ID
   */
  id: string = "";
  /**
   * @description 名称
   */
  name: string = "";
  /**
   * @description 价格
   */
  price: string = "";
  /**
   * @description 礼物图片
   */
  image_url: string = "";
  /**
   * @description 来源类型：0 web 1 app
   */
  source_type: string = "";
  /**
   * @description 0 系统礼物 1 自定义礼物
   */
  source_status: string = "";
  /**
   * 是否显示 0不显示 1 显示
   * */
  is_show:number = 0;
}