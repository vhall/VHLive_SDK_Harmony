/**
 * @description 商品推送变更相关数据
 */
export class VHPushGoodsChangeData {
  /**
   * @description CDN地址
   */
  cdn_url: string = '';
  /**
   * @description 商品ID
   */
  goods_id: number = 0;
  /**
   * @description 商品名称
   */
  goods_name: string = '';
  /**
   * @description 推送状态
   */
  push_status: number = 0;
  /**
   * @description 推送者昵称
   */
  pusher_nickname: string = '';
  /**
   * @description 角色名称
   */
  role_name: number = 0;
  /**
   * @description 房间ID
   */
  room_id: string = '';
  /**
   * @description 类型（商品推送变更）
   */
  type: string = '';
}

/**
 * @description 创建商品订单请求参数
 */
export class VHProductOrderRequestsData {
  /**
   * @description 商品ID
   */
  goods_id: number = 0;
  /**
   * @description 数量
   */
  quantity: number = 0;
  /**
   * @description 购买类型
   */
  buy_type: number = 0;
}
