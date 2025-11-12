import { VHIMMessageModel } from "../im/VHIMCallback";

/**
 * @description 抽奖奖品数据模型
 */
export class LotteryAwardModel {
  /*
  * @description奖品名称
  * */

  award_name: string = '';
  /*
  * @description奖品总数量
  * */

  quantity: number = 0;
  /*
  * @description奖品剩余数量
  * */

  surplus: number = 0;
  /*
  * @description奖品图片URL
  * */

  image_url: string = '';
  /*
  * @description奖品创建时间
  * */

  created_at: string = '';
  /*
  * @description所属抽奖活动ID
  * */

  lottery_id: number = 0;
  /*
  * @description排序序号
  * */

  sort: number = 0;
  /*
  * @description奖品描述
  * */

  award_desc: string = '';
  /*
  * @description奖品关联链接
  * */

  link_url: string = '';
  /*
  * @description业务用户ID
  * */

  business_uid: string = '';
  /*
  * @description奖品唯一ID
  * */

  id: number = 0;
  /*
  * @description来源ID
  * */
  source_id: string = '';
  /*
  * @description应用ID
  * */
  app_id: string = '';
}

/**
 * @description 用户奖品信息数据模型
 */
export class AwardUserModel {
  /*
   * @description 用户唯一标识
   * */
  uid: string = '';
  /*
   * @description 奖品名称
   * */
  award_name: string = '';
  /*
   * @description 奖品图片URL
   * */
  image_url: string = '';
}

/**
 * @description主模型：抽奖结果通知数据
 */
export class VHLotteryResultNoticeModel {
  /*
  * @description房间ID
  * */
  room_id: string = '';
  /*
  * @description奖品快照
  * */
  award_snapshoot: LotteryAwardModel | null = null;
  /*
  * @description 开奖方式：0：手动开奖 1：倒计时开奖
  * */

  lottery_method: number = 0;
  /*
  * @description是否强制领奖：0：否  1：是,
  * */

  compulsory_award: number = 0;
  /*
  * @description领奖方式 1:寄送奖品 2:私信兑奖 3:无需领奖,4:自定义领奖
  * */

  receive_award_way: number = 0;
  /*
  * @description抽奖图标URL
  * */
  icon: string = '';
  // 中奖用户和奖品
  lottery_winners_award: Array<AwardUserModel> = [];
  /*
  * @description备注信息
  * */

  remark: string = '';
  /*
  * @description 中奖id
  * */

  lottery_id: number = 0;
  /*
  * @description消息类型,中奖结果通知"lottery_result_notice",
  * */

  type: string = '';
  /*
  * @description抽奖标题
  * */

  title: string = '';
  /*
  * @description抽奖创建者头像
  * */

  lottery_creator_avatar: string = '';
  /*
   * @description 是否可查看中奖名单1:可查看0:不可查看
   * */
  can_look_award_pool: number = 0;
  /*
 * @description抽奖创建者昵称
 * */
  lottery_creator_nickname: string = '';
  /*
   * @description 图片排序 1
   * */
  img_order: number = 0;
  /*
   * @description 抽奖命令
   * */
  command: string = ''
  /*
  * @description 奖品数量
  * */

  lottery_number: number = 0;
  /*
  * @description是否公布中奖名单1:公布0:不公布
  * */

  publish_winner: number = 0;
  /*
  * @description抽奖创建者ID
  * */

  lottery_creator_id: string = '';
  /*
  * @description抽奖发布者ID
  * */
  lottery_publisher_id: string = '';
  /*
  * @description抽奖类型,1 全体参会用户，2 参与问卷的参会者，3 参与签到的参会者，7.参与签到的观众，8.口令抽奖，21参与快问快答的参会者
  * */

  lottery_type: number = 0;
  /*
  * @description是否新消息
  * */

  is_new: number = 0;
  /*
  * @description 抽奖状态,0 开始抽奖 1 抽奖完成（结束）
  * */
  lottery_status: number = 0;
  /*
  * @description实际中奖人数
  * */

  actual_lottery_number: number = 0;
  /*
  * @description中奖者信息
  * */

  lottery_winners: string = '';
  /*
  * @description中奖用户过多，分批推送，标记是否是做后一批推送记录1
  * */

  is_last_batch: number = 0;
  /*
  * @description 是否公布中奖名单 1是 0否,
  * */

  display_of_results: number = 0;
  /*
  * @description是否需要领奖, 0-否 1-是
  * */
  need_take_award: number = 0;
}

/**
 * @description抽奖消息
 * */
export class VHLotteryMessage {
  constructor(base: VHIMMessageModel) {
    this.base_data = base;
  }

  //抽奖数据
  lottery_data?: VHLotteryResultNoticeModel;
  // 原始数据
  base_data?: VHIMMessageModel;
}


export interface VHLotteryMessageInterface {
  /**
   * @description 抽奖消息
   * @param msgModel 消息数据模型
   */
  onStartLottery: (msgModel: VHLotteryMessage) => void;

  /**
   * @description 结束抽奖
   * @param msgModel 消息数据模型
   */
  onEndLottery: (msgModel: VHLotteryMessage) => void;
}