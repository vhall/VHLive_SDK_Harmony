import { VHSaaSDK, VHSurveyInternal, VHWebinarData } from "../../../../Index";
import { VHDataManager } from "../VHDataManager";

export class VHExamInternal {
  public static KEY_EXAM_ID: string = "exam_id"; // 问卷id
  public static KEY_USER_ID: string = "user_id"; // 对应老版本user_id,
  public static KEY_WEBINAR_ID: string = "webinar_id"; // 活动id
  public static KEY_INTERACT_TOKEN: string = "interact-token"; // TokenManger.getInteractToken() 获取活动详情之后更新
  public static KEY_SWITCH_ID: string = "switch_id"; // 房间id（lss格式）
  public static KEY_TOKEN: string = "token"; // TokenManger.getToken() 登录之后更新
  public static KEY_ROOM_ID: string = "roomId"; // 房间id（lss格式）
  public static KEY_APP_ID: string = "appId"; // 应用id
  public static KEY_PAAS_ACCESS_TOKEN: string = "paas_access_token";
  public static KEY_CHANNEL_ID: string = "channelId";
  public static KEY_NICK_NAME: string = "nickname";
  public static KEY_JOIN_ID: string = "join_id";
  public static KEY_AVATAR: string = "avatar";
  public static KEY_EXAM_TYPE: string = "examType";


  public static getExamUrl(webinars: VHWebinarData, exam_id: string, type: string): string {
    let url: string = "";
    let params = new Map<string, string>();
    params.set(VHExamInternal.KEY_EXAM_ID, exam_id);
    params.set(VHExamInternal.KEY_ROOM_ID, webinars?.interact?.room_id!);
    params.set(VHExamInternal.KEY_WEBINAR_ID, webinars?.webinar?.id.toString()!);
    params.set(VHExamInternal.KEY_SWITCH_ID, webinars?.switch_info?.switch_id.toString()!);
    params.set(VHExamInternal.KEY_EXAM_TYPE, type);
    params.set(VHExamInternal.KEY_APP_ID, VHSaaSDK.getInstance().getAppId());
    if (webinars.interact && webinars.interact.paas_access_token.length > 0) {
      params.set(VHExamInternal.KEY_PAAS_ACCESS_TOKEN, webinars.interact.paas_access_token);
      params.set(VHExamInternal.KEY_CHANNEL_ID, webinars.interact.channel_id)
    }
    params.set(VHExamInternal.KEY_USER_ID, webinars.join_info?.user_id.toString()!);
    params.set(VHExamInternal.KEY_TOKEN, VHDataManager.getInstance().token);
    params.set(VHExamInternal.KEY_INTERACT_TOKEN, VHDataManager.getInstance().interact_token);
    params.set(VHExamInternal.KEY_NICK_NAME, webinars.join_info?.nickname!);
    params.set(VHExamInternal.KEY_JOIN_ID,webinars.join_info?.join_id.toString()!);
    params.set(VHExamInternal.KEY_AVATAR, webinars.join_info?.avatar!);
    return VHExamInternal.buildExamUrl(params);
  }

  private static buildExamUrl(params: Map<string, string>): string {
    // 用于拼接查询参数的数组
    const paramArray: string[] = [];

    // 遍历参数Map，收集所有键值对
    params.forEach((value, key) => {
      paramArray.push(`${key}=${value}`);
    });

    // 拼接参数部分，如果有参数则添加问号前缀
    const queryParams =
      paramArray.length > 0 ? `/${params.get(VHExamInternal.KEY_WEBINAR_ID)}?${paramArray.join('&')}` : '';

    // 拼接完整URL并返回
    return VHSaaSDK.getInstance().getHostUrl() + `/v3/lives/embedclient/exam${queryParams}`;
  }
}