/**
 * @description 快问快答(考试)推送消息
 */
export class VHExaminationModel {
  /*
  * @description 角色名称
  * */
  role_name: string = '';
  /*
  * @description发送时间
  * */
  send_time: string = "";
  /*
  * @description 配置信息
  * */
  answer_condition: AnswerRecord | null = null;
  /*
  * @description 试卷标题
  * */
  paper_title: string = '';
  /*
  * @description 活动id
  * */
  webinar_id: string = "";
  /*
  * @description 创建人昵称
  * */
  nick_name: string = '';
  /*
  * @description消息类型
  * */
  type: string = '';
  /*
  * @description 考试ID
  * */
  paper_id: string = '';
  /*
  * @description 当前时间
  * */
  send_time_stamp: number = 0;
}

/**
 * @description 快问快答成绩公布
 */
export class VHExamRank{
  /**
   * @description 标题名称
   */
  public paper_title: string = "";
  /**
   * @description 活动id
   */
  public webinar_id: string = "";
  /**
   * @description 公布者角色
   */
  public role_name: string = "";
  /**
   * @description 公布者昵称
   */
  public nick_name: string = "";
  /**
   * @description 消息类型
   */
  public type: string = "";
  /**
   * @description 快问快答id
   */
  public paper_id: string = "";
  /***
   * 配置信息
   * **/
  answer_condition: AnswerRecord | null = null;
}

export class VHExamReportList{
  /**
   *总数量
   * **/
  total:number = 0;
  /**
   *总数量
   * **/
  list:VHExamReport[] = [];
}

/**
 * 快问快答 个人成绩
 * **/
export class VHExamPersonalReport{
  /**
   *账户id
   * **/
  account_id:string | null= "";
  /**
   *默认 0
   * **/
  account_type:string | null= "";
  /**
   *是否可重新作答，0-否（默认） 1-是
   * **/
  can_re_answer:number= 0;
  /**
   *邮箱
   * **/
  email:string | null= "";
  /**
   *邮箱
   * **/
  error_num:number= 0;
  /**
   *头像地址
   * **/
  head_img:string | null= "";
  /**
   *是否主动交卷 0.否 1.是
   * **/
  is_initiative:number | null= 0;
  /**
   *手机号
   * **/
  mobile:string | null= null;
  /**
   *答题详情
   * **/
  question_detail:string | null= null;
  /**
   * 个人排名 ，0 为无成绩
   * */
  rank:number | null = 0;
  /**
   * 排行榜总数
   * */
  rank_all:number | null = 0;
  /**
   * 正确数
   * */
  right_num:number | null = 0;
  /**
   * 正确数
   * */
  right_rate:string | null = "";
  /**
   * 得分
   * */
  score:number | null = 0;
  /**
   * 问卷总分
   * */
  total_score:number | null = 0;
  /**
   * 未答数
   * */
  unanswer_num:number = 0;
  /**
   * 标题
   * */
  title:string = "";
  /**
   * 用时 秒
   * */
  use_time:string = "";
  /**
   * 题型
   * */
  user_form:string = "";
  /**
   * 题型
   * */
  user_info:string = "";
  /**
   * 用户名
   * */
  user_name:string = "";

}


export class VHExamUserAnswerStatus{
  /*
  * @description 配置信息
  * */
  answer_condition: AnswerRecord | null = null;
  /**
   * 是否显示成绩和答案，0-否 1-是
   * **/
  display_score:number = 0;
  /**
   * 答题是否已结束，0-否 1-是
   * **/
  is_end:number = 0;
  /**
   * 限制时长
   * **/
  limit_time:number = 0;
  /**
   * 限制时长开关，0-关 1-开
   * **/
  limit_time_switch:number = 0;
  /**
   * 限制时长类型，0-分 1-秒
   * **/
  limit_time_type:number = 0;
  /**
   * 是否强制填写，0-否（默认） 1-是
   * **/
  mandatory_filling:number = 0;
  /**
   *快问快答id
   * **/
  paper_id:string = "";
  /**
   *推送时间，格式：yyyy-MM-dd HH:mm:ss
   * **/
  push_time:string = "";
  /**
   * 题目数量
   * **/
  question_num:number = 0;
  /**
   * 正确率
   * **/
  right_rate:string = "";
  /**
   * 得分
   * **/
  score:number = 0;
  /**
   * 答题状态，0-未作答 1-已作答
   * **/
  status:number = 0;
  /**
   * 标题
   * **/
  title:string ="";
  /**
   * 试卷总分
   * **/
  total_score:number = 0;
}

export class VHExamReport{
  /**
   * @description 快问快答id
   */
  public id: number = 0;
  /**
   * @description 账户id
   */
  public account_id: string = "";
  /**
   * @description 默认 0
   */
  public account_type: number = 0;
  /**
   * @description 姓名
   */
  public user_name: string = "";
  /**
   * @description 头像地址
   */
  public head_img: string = "";
  /**
   * @description 排名
   */
  public rank_no: number = 0;
  /**
   * @description 总分
   */
  public total_score: number = 0;
  /**
   * @description right_rate
   */
  public right_rate: string = "";
  /**
   * @description 得分
   */
  public score: number = 0;
  /**
   * @description 用时 秒
   */
  public use_time: number = 0;
  /**
   * @description 是否主动交卷 0.否 1.是
   */
  public is_initiative: number = 0;
  /**
   * @description 是否有效 0.否 1.是
   */
  public status: number = 0;
  /**
   * @description 手机号
   */
  public mobile: string = "";
  /**
   * @description 邮箱
   */
  public email: string = "";
  /**
   * @description 参与答题时间 格式：yyyy-MM-dd HH:mm:ss
   */
  public join_time: string = "";
}



// 定义查看者记录接口
export class AnswerRecord {
  /*
  * @description 累计观看时长可参与答题
  * */
  viewing_minutes: number = 0;
  /*
 * @description 类型
 * */
  type: number = 0;
}