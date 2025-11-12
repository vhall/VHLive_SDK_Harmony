import { VHSaaSDK, VHWebinarData } from "../../../../Index";
import { VHDataManager } from "../VHDataManager";

export class VHSurveyInternal {
  public static KEY_SURVEY_ID: string = "survey_id"; // 问卷id
  public static KEY_ROOM_ID: string = "roomId"; // 房间id（lss格式）
  public static KEY_WEBINAR_ID: string = "webinar_id"; // 活动id
  public static KEY_APPID: string = "appId"; // 应用id
  public static KEY_PAAS_ACCESS_TOKEN: string = "paas_access_token"; // 问卷id
  public static KEY_USER_ID: string = "user_id"; // 对应老版本user_id,
  public static KEY_TOKEN: string = "token"; // TokenManger.getToken() 登录之后更新
  public static KEY_INTERACT_TOKEN: string = "interact-token"; // TokenManger.getInteractToken() 获取活动详情之后更新


  public static getSurveyUrl(webinars: VHWebinarData, id: string): string {
    let url: string = "";
    let params = new Map<string, string>();
    params.set(VHSurveyInternal.KEY_SURVEY_ID, id);
    params.set(VHSurveyInternal.KEY_ROOM_ID, webinars?.interact?.room_id!);
    params.set(VHSurveyInternal.KEY_WEBINAR_ID, webinars?.webinar?.id.toString()!);
    params.set(VHSurveyInternal.KEY_APPID, VHSaaSDK.getInstance().getAppId());
    if (webinars.interact && webinars.interact.paas_access_token.length > 0) {
      params.set(VHSurveyInternal.KEY_PAAS_ACCESS_TOKEN, webinars.interact.paas_access_token);
    }
    params.set(VHSurveyInternal.KEY_USER_ID, webinars.join_info?.user_id.toString()!);
    params.set(VHSurveyInternal.KEY_TOKEN, VHDataManager.getInstance().token);
    params.set(VHSurveyInternal.KEY_INTERACT_TOKEN, VHDataManager.getInstance().interact_token);
    return VHSurveyInternal.buildSurveyUrl(params);
  }

  private static buildSurveyUrl(params: Map<string, string>): string {
    // 用于拼接查询参数的数组
    const paramArray: string[] = [];

    // 遍历参数Map，收集所有键值对
    params.forEach((value, key) => {
      paramArray.push(`${key}=${value}`);
    });

    // 拼接参数部分，如果有参数则添加问号前缀
    const queryParams = paramArray.length > 0 ? `?${paramArray.join('&')}` : '';

    // 拼接完整URL并返回
    return VHSaaSDK.getInstance().getHostUrl() + `/v3/lives/question${queryParams}`;
  }
}