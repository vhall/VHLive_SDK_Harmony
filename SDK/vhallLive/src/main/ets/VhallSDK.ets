import {
  BroadcastMsgModelCallBlack,
  VHAppInfo,
  VHBase,
  VHBaseCommunication,
  VHMessage,
  VHMessageStaticTypes
} from '@vhall/vhallyun-framework';
import { HttpNetRequest, HttpNetRequestWithJson, HttpNetRequestWithJsonHeader } from './UnilityTool/HttpNetRequest';
import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { API_INTERFACE, ApiKeyConstants } from './UnilityTool/ApiKeyConstants';
import { systemDateTime } from '@kit.BasicServicesKit';
import { JSON, util } from '@kit.ArkTS';
import BuildProfile from '../../../BuildProfile';
import { VHConstants } from '../ets/VHConstants';
import {
  VHAdvCallback,
  VHAgreementModelCallback,
  VHAISummaryModelCallback,
  VHAIWatchCallback,
  VHAnnouncementListCallback,
  VHChatMessageListCallback,
  VHCommonConfigCallback,
  VHConfigListCallback,
  VHCouponsAvailableCallback,
  VHCouponsNotAvailableCallback,
  VHCreateOrderCallback,
  VHDoingSignCallback,
  VHDownloadImageCallback,
  VHExamListCallback,
  VHExamPerformanceCallback,
  VHExamPersonalReportCallback,
  VHExamUserAnswerStatusCallback,
  VHFileListCallback,
  VHGetRedPacketCallback,
  VHGiftListCallback,
  VHGoodsActivitySettingsCallback,
  VHGoodsInfoCallback,
  VHGoodsListCallback,
  VHInteractAwardSettingCallback,
  VHInteractMyAwardListCallback,
  VHInteractWinnerInfoCallback,
  VHInviteCardCallback,
  VHInviteTopListCallback,
  VHLastPublishWebinarSurveyCallback,
  VHLotteryCarryOutCallback,
  VHLotteryListCallback,
  VHMenuInfoCallback,
  VHMyInviteDetailListCallback,
  VHPlayerConfigCallback,
  VHPrivacyAgreementCallback,
  VHPushCardCallback,
  VHPushCardInformationCallback,
  VHQaRecommendListCallback,
  VHQuestionHistoryCallback,
  VHQuestionnaireCallback,
  VHRedEnvelopeInfoCallback,
  VHRedEnvelopeUserListInfoCallback,
  VHRoleNameCallback,
  VHRoomLikeCallback,
  VHRoomStatusCallback,
  VHSignInfoCallback,
  VHSubjectInfoCallback,
  VHSurveyAnswerReplayCallback,
  VHUploadFileCallback,
  VHAIHighlightCallback,
  VHVHMarketingPublicAccountCallback,
  VHWatchAuthQueryCallback,
  VHWatchGiftAwardListCallback,
  VHWatchGiftAwardSettingCallback,
  VHWatchGiftCallback,
  VHWatchGiftParticipateCallback,
  VHWatchGiftWinnerDetailCallback,
  VHWatchGiftWinnersCallback,
  VHWatchListCallback,
  VHWatchWebinarInfoCallback,
  VHWebinarInfoCallback,
  VHWebinarStateCallback,
  VHWinnerInformationCallback,
} from './VHCallback';

import {
  FilesList,
  PrivacyAgreementInfo,
  RoomToolsStatusData,
  VHAdvDefault,
  VHAgreement,
  VHAgreementModel,
  VHAIMediaInfo,
  VHAnnouncementNewsList,
  VHBasicConfig,
  VHChatMessageList,
  VHCommonConfig,
  VHConfigList,
  VHCouponInfo,
  VHCreateOrderInfo,
  VHExamList,
  VHGoodsListData,
  VHHistoryQuestionnaireInfo,
  VHInteract,
  VHInviteCard,
  VHInviteTopList,
  VHJoinInfo,
  VHKeyWords,
  VHLotteryCarryOut,
  VHLotteryList,
  VHMarketingPublicAccount,
  VHMarqueeConfig,
  VHMenuInfo,
  VHMenus,
  VHMyInviteDetailList,
  VHNotAvailableCouponInfo,
  VHOnline,
  VHPageView,
  VHPlayDefinition,
  VHPlayerConfig,
  VHPublicAccount,
  VHRecord,
  VHRecordWatchExpire,
  VHRedPacket,
  VHReportData,
  VHRoleName,
  VHScreenPoster,
  VHSignInfo,
  VHSkin,
  VHSso,
  VHSubjectList,
  VHSubscribe,
  VHSwitchInfo,
  VHTextWatermarkType,
  VHTimer,
  VHUploadFileInfo,
  VHUrls,
  VHWarmup,
  VHWatchAuthInfo,
  VHWatermarkConfig,
  VHWebinarData,
  VHWebinarDetail,
  VHWebinarList,
  VHWebinarTag,
  VHWinnerInformation,
  VHSurveyAnswerReplayList,
  VHQaRecommendList,
  VHWebinarSurvey,
  VHAISummaryModel,
  VHGoodsActivitySettings,
  VHWebinarRecordWatch,
  VHRedPacketStatus,
  VHGoodsInfo,
  VHAIHighlightModel
} from './model/VHWatchWebinarInfo';
import { RSA } from './crypto/RSA';
import { CryptoHelper } from './crypto/CryptoHelper';
import { MD5 } from './crypto/MD5';
import { SM3 } from './crypto/SM3';
import { SHA } from './crypto/SHA';
import {
  RoomLikeInfo,
  VHCallBack,
  VHExamPersonalReport,
  VHExamReportList,
  VHExamUserAnswerStatus,
  VHGetSignData,
  VHLotteryResultNoticeModel,
  VHSignData
} from '../../../Index';
import { VHDataManager } from '../ets/VHDataManager';
import { CallBack } from './UnilityTool/HttpNetResponse';
import { VHGiftList } from './model/VHGiftInfo';
import { StrUtil } from './utils/StrUtil';
import {
  VHCardInfo,
  VHDoingSignInfo,
  VHGiftAwardFiled,
  VHInteractAwardSetting,
  VHInteractMyAward,
  VHInteractWinnerInfo,
  VHQuestionHistoryList,
  VHRedEnvelopeInfo,
  VHRedEnvelopeUserListInfo,
  VHWatchGiftAward,
  VHWatchGiftInfo,
  VHWatchGiftParticipate,
  VHWatchGiftSetting,
  VHWatchGiftWinnerDetail,
  VHWinner
} from './model/VHMessageInfo';
import { VHProductOrderRequestsData } from './goods/VHGoodsData';
import { AppUtil } from './utils/AppUtil';

export class VHSaaSDK implements BroadcastMsgModelCallBlack {
  // 单例
  private static instance: VHSaaSDK;

  private constructor() {
    // 私有构造函数，防止外部实例化
  }

  private is_debug: boolean = true;
  private tag: string = "VHSaaSDK";
  private sdk_host: string = "https://open-api.vhall.com"; //化蝶业务层生产域名'
  private saas_host: string = "https://saas-api.vhall.com";
  private yun_app_id: string = "15df4d3f"; //正式
  private yun_host: string = "https://api.vhallyun.com"; //正式
  private live_host: string = "https://live.vhall.com";
  private app_key: string = "";
  private h5_url = "https://live.vhall.com/v3/lives/embedclient/watch/";
  private app_secret_key: string = "";
  //签名
  private app_signature: string = '';
  //包名
  private package_name: string = '';
  private rsaPriKeyStr: string = ''; //私钥
  private sign_type: string = '0' //加密类型 0:MD5 1：RSA 2:SHA256  3:SM3
  private contextMap: Map<string, string> = new Map<string, string>();
  private platform: string = '12'; //鸿蒙平台
  private urls: VHUrls = new VHUrls();

  static getInstance(): VHSaaSDK {
    if (!VHSaaSDK.instance) {
      VHSaaSDK.instance = new VHSaaSDK();
    }
    return VHSaaSDK.instance;
  }

  public getVersion(): string {
    return BuildProfile.HAR_VERSION;
  }

  /**
   * @description
   * 加密方式如果设置为RAS加密，需要在init之前设置私钥参数
   * @param priKey: 私钥。注意需要去掉-----BEGIN PUBLIC KEY-----与  -----END PUBLIC KEY----- 仅保留字符串值
   * */
  public setRSAPrivateKey(priKey: string) {
    this.rsaPriKeyStr = priKey;
    // this.sign_type = "1";
  }

  private formatHexString(input: string): string {
    return input.match(/.{1,2}/g)?.join(':') || '';
  }

  /**
   * @description
   * 微吼直播SDK初始化接口，用于设置appKey与appSecretKey
   * @param appKey 是否必传：是。 从控制台运营设置-开发设置-应用详情获取
   * @param appSecretKey 是否必传：是。 从控制台运营设置-开发设置-应用详情获取
   * @param signature 是否必传：否。 从控制台运营设置-开发设置-应用详情获取。可为空，如果为空SDK内部自动进行获取app应用cer签名文件的SHA256值
   * @param packageName 是否必传：否。 从控制台运营设置-开发设置-应用详情获取。可为空，如果为空SDK内部自动进行获取app应用包名
   * */
  public init(context: Context, appKey: string, appSecretKey: string, signature: string, packageName: string,
    callback: VHCallBack) {
    this.app_key = appKey;
    this.app_secret_key = appSecretKey;

    if (packageName.length == 0) {
      let info = AppUtil.getBundleInfoSync();
      this.package_name = info.name;
    } else {
      this.package_name = packageName;
    }

    if (signature.length == 0) {
      let info = AppUtil.getBundleInfoSync();
      this.app_signature = this.formatHexString(info.signatureInfo.fingerprint);
    } else {
      this.app_signature = signature;
    }


    if (this.is_debug) {
      this.yun_app_id = 'f14ed109';
      this.yun_host = "https://test01-api.vhallyun.com";
      this.sdk_host = "https://test01-open-api.vhou.tv";
      this.saas_host = "https://test01-saas-api.vhou.tv";
      this.live_host = "https://test01-live.vhou.tv";
      this.h5_url = "https://live.vhou.tv/v3/lives/embedclient/watch/";
    }

    VHBase.setPackageCheck('com.vhallsaas.sdk', '241A634279A943313DCF69893E5B079A')
    VHBase.registerApp(context, this.yun_app_id, this.yun_host,
      {
        onSuccess: () => {
          console.log('SDK初始化成功');
        },
        onFailure: (msg: string) => {
          console.log('SDK初始化失败 === ' + msg);
        }
      }
    )
    this.initConfig(callback);
    VHBaseCommunication.getInstance().setBroadcastMsgModelCallBlack(this);
  }

  private initConfig(callback: VHCallBack) {
    let params = this.getBaseBodyParam();
    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_VERSION_INIT_CONFIG, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          hilog.debug(1, this.tag, '清空上次的文档信息成功 === ' + data.toString());
          this.sign_type = data["sign_type"];
        },
        onFailure: (errorCode, errorMsg) => {
          hilog.error(1, this.tag, '清空上次的文档信息失败 === ' + errorCode + errorMsg);
        }
      }
    )
  }

  /**
   * @description
   * 子账号用户登录接口,
   * @param accountId saas账号 或者手机号 或者邮箱
   * @param password accountId为账号时对应账号密码
   * @param dynamicCode accountId为手机号或邮箱时对应的动态码
   */
  public loginByAccount(accountId: string, password: string, dynamicCode: string, callback: VHCallBack) {
    if (accountId.length <= 0) {
      if (callback) {
        callback.onFailure(VHConstants.VH_INPUT_PARAM_ERROR, 'accountId is empty');
        return;
      }
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ACCOUNT, accountId.trim());
    if (password.length > 0) {
      params.set(ApiKeyConstants.KEY_PASSWORD, password.trim());
      params.set(ApiKeyConstants.KEY_REMEMBER, "1");
    }
    if (dynamicCode.length > 0) {
      params.set(ApiKeyConstants.KEY_DYNAMIC_CODE, dynamicCode.trim());
    }
    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);

    HttpNetRequest(this.sdk_host + API_INTERFACE.API_USER_LOGIN, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          hilog.debug(1, this.tag, '清空上次的文档信息成功 === ' + data.toString());
          if (callback) {
            callback.onSuccess("login success");
            VHDataManager.getInstance().gray_id = data['user_id'] as number;
            VHDataManager.getInstance().token = data['token'];
            // 设置
            let contextMap: Map<string, string> = new Map();
            let id: string = data["user_id"] as string;
            contextMap["nickname"] = data["nick_name"];
            contextMap["avatar"] = data["avatar"];
            contextMap["role_name"] = "1";
            contextMap["accountId"] = data["user_id"];
            contextMap["device_type"] = 3;
            contextMap["device_status"] = 1;
            VHBase.setUserIdAndContext(data["user_id"], contextMap);

          }
        },
        onFailure: (errorCode, errorMsg) => {
          hilog.error(1, this.tag, '清空上次的文档信息失败 === ' + errorCode + errorMsg);
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * @description
   * 三方用户登录接口,用于观看端用户登录
   * @param thirdId 必填参数 第三方账号id（max：255字符）
   * @param nickName 非必填参数 昵称
   * @param avatar 非必填参数 头像地址
   */
  public loginByThirdId(thirdId: string, nickName: string, avatar: string, callback: VHCallBack) {
    if (thirdId.length <= 0 || thirdId.length > 255) {
      if (callback) {
        callback.onFailure(VHConstants.VH_INPUT_PARAM_ERROR, 'third id length error');
        return;
      }
    }
    if (nickName.length > 0 && nickName.length > 50) {
      if (callback) {
        callback.onFailure(VHConstants.VH_INPUT_PARAM_ERROR, 'userName length error');
        return;
      }
    }
    if (avatar.length > 0 && avatar.length > 255) {
      if (callback) {
        callback.onFailure(VHConstants.VH_INPUT_PARAM_ERROR, 'headNetUrl length error');
        return;
      }
    }

    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_THIRD_USER_ID, thirdId);
    params.set(ApiKeyConstants.KEY_NICK_NAME, nickName);
    params.set(ApiKeyConstants.KEY_HEAD_NET_URL, avatar);
    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);

    HttpNetRequest(this.sdk_host + API_INTERFACE.API_USER_LOGIN_THIRD_ID, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          hilog.debug(1, this.tag, '清空上次的文档信息成功 === ' + data.toString());
          if (callback) {
            callback.onSuccess("login success");
            VHDataManager.getInstance().gray_id = data['user_id'] as number;
            VHDataManager.getInstance().token = data['token'];
            // 设置
            let contextMap: Map<string, string> = new Map();
            let id: string = data["user_id"] as string;
            contextMap["nickname"] = nickName;
            contextMap["avatar"] = avatar;
            contextMap["role_name"] = "2";
            contextMap["accountId"] = thirdId;
            contextMap["device_type"] = 3;
            contextMap["device_status"] = 1;
            VHBase.setUserIdAndContext(thirdId, contextMap);

          }
        },
        onFailure: (errorCode, errorMsg) => {
          hilog.error(1, this.tag, '清空上次的文档信息失败 === ' + errorCode + errorMsg);
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * @description
   * 用户登出
   */
  public logout(callback: VHCallBack) {
    let params = this.getBaseBodyParam();
    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_USER_LOGOUT, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            callback.onSuccess("");
            VHDataManager.getInstance().clear();
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * @description
   * 获取H5观看地址
   * @param webinarId
   */
  public getH5WebViewUrl(webinarId: string): string {
    return this.h5_url + webinarId;
  }


  /**
   * @description
   * 查询观看授权
   * 没有type、verifyValue时，校验用户历史是否已经校验过，校验过则直接通过校验，否则返回错误提示信息及当前观看限制类型
   * @param webinarId
   */
  public queryWatchAuth(webinarId: string, callback: VHWatchAuthQueryCallback) {
    if (webinarId.length == 0) {
      if (callback) {
        callback.onFailure(VHConstants.VH_INPUT_PARAM_ERROR, 'webinarId is empty');
        return;
      }
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId);
    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_WEBINAR_WATCH_AUTH, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            let info: string = JSON.stringify(data);
            let watchAuth: VHWatchAuthInfo = JSON.parse(info) as VHWatchAuthInfo;
            VHDataManager.getInstance().visitor_id = watchAuth.visitor_id;
            callback.onSucceed(watchAuth);
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * 校验观看授权
   * @param webinarId   活动id
   * @param type        0:免费（默认），1:密码.
   * @param verifyCode type对应的值,比如密码或手机号
   */
  public checkWatchAuth(webinarId: string, type: string, verifyCode: string, callback: VHWatchAuthQueryCallback) {
    if (webinarId.length == 0) {
      if (callback) {
        callback.onFailure(VHConstants.VH_INPUT_PARAM_ERROR, 'webinarId is empty');
        return;
      }
    }
    if (type.length == 0) {
      if (callback) {
        callback.onFailure(VHConstants.VH_INPUT_PARAM_ERROR, 'type is empty');
        return;
      }
    }
    if (callback == null) {
      return
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId);
    params.set(ApiKeyConstants.KEY_TYPE, type);
    params.set(ApiKeyConstants.KEY_VERIFY_VALUE, verifyCode);
    if (VHDataManager.getInstance().visitor_id.length > 0) {
      params.set(ApiKeyConstants.KEY_VISITOR_ID, VHDataManager.getInstance().visitor_id);
    }
    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_WEBINAR_WATCH_AUTH, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            let info: string = JSON.stringify(data);
            let watchAuth: VHWatchAuthInfo = JSON.parse(info) as VHWatchAuthInfo;
            callback.onSucceed(watchAuth);
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * @description
   * 观看端-获取用户观看协议
   * @param webinarId 活动id 是否必填：是
   * @param visitor_id 游客ID 是否必填：否
   * @param email 邮箱  是否必填：否
   * @param third_user_id 第三方用户ID 是否必填：否
   * @param callback
   */
  public getAgreement(webinarId: string, third_user_id: string, visitor_id: string, email: string,
    callback: VHAgreementModelCallback) {
    if (webinarId.length == 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error');
        return;
      }
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId);
    if (third_user_id.length > 0) {
      params.set(ApiKeyConstants.KEY_THIRD_USER_ID, third_user_id);
    }
    if (visitor_id.length > 0) {
      params.set(ApiKeyConstants.KEY_VISITOR_ID, visitor_id);
    }
    if (email.length > 0) {
      params.set(ApiKeyConstants.KEY_E_MAIL, email);
    }
    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_AGREEMENT, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            let value = JSON.stringify(data);
            try {
              let agree: VHAgreementModel = data as VHAgreementModel;
              callback.onSucceed(agree);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * @description
   * 观看端-同意观看协议
   * @param webinarId 活动id 是否必填：是
   * @param visitor_id 游客ID 是否必填：否
   * @param email 邮箱  是否必填：否
   * @param third_user_id 第三方用户ID 是否必填：否
   * @param callback
   */
  public agreeAgreement(webinarId: string, third_user_id: string, visitor_id: string, email: string,
    callback: VHCallBack) {
    if (webinarId.length == 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error');
        return;
      }
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId);
    if (third_user_id.length > 0) {
      params.set(ApiKeyConstants.KEY_THIRD_USER_ID, third_user_id);
    }
    if (visitor_id.length > 0) {
      params.set(ApiKeyConstants.KEY_VISITOR_ID, visitor_id);
    }
    if (email.length > 0) {
      params.set(ApiKeyConstants.KEY_E_MAIL, email);
    }
    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_SET_USER_AGREE_AGREEMENT, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            let value = JSON.stringify(data);
            callback.onSuccess('success');
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }


  /**
   * @description
   * 观看端-同意观看协议
   * @param webinarId 活动id 是否必填：是
   * @param callback
   */
  public getWebinarState(webinarId: string, callback: VHWebinarStateCallback) {
    if (webinarId.length == 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error');
        return;
      }
    }
    let params = this.getBaseBodyParam();
    params.set('webinar_ids', webinarId);
    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_WEBINAR_STATE, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let value = JSON.stringify(data);
              if (JSON.has(data as object, 'list')) {
                let stateList = data['list'] as Array<object>;
                stateList.forEach((item, index) => {
                  if (JSON.has(item as object, 'state')) {
                    callback.onSucceed(item['state']);
                  }
                })
              }
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * @description
   * 初始化观看活动信息
   * @param webinarId 活动id 是否必填：是
   * @param record_id 回放id 是否必填：否
   * @param email 邮箱  是否必填：否
   * @param nickname 昵称  是否必填：否
   * @param watchAuth 观看验证 是否必填：否
   * @param callback
   */
  public initWatch(webinarId: string, record_id: string, email: string, nickname: string,
    callback: VHWatchWebinarInfoCallback) {
    if (webinarId.length == 0) {
      if (callback) {
        callback.onFailure(VHConstants.VH_INPUT_PARAM_ERROR, 'webinarId is empty');
        return;
      }
    }
    if (callback == null) {
      return
    }
    this.initBefore(webinarId, {
      onSuccess: (data) => {
        this.doInitWatch(webinarId, record_id, email, nickname, "", true, callback);
      },
      onFailure: (errorCode, errorMsg) => {
        if (callback) {
          callback.onFailure(errorCode, errorMsg);
        }
      }
    });
  }


  /**
   * @description
   * 初始化观看活动信息
   * @param webinarId 活动id 是否必填：是
   * @param recordId 指定回放id 是否必填：否
   * @param email 邮箱  是否必填：否
   * @param nickname 昵称  是否必填：否
   * @param watchAuth 观看验证 是否必填：否
   * @param callback
   */
  public initWatchWithRecordId(webinarId: string, recordId: string, email: string, nickname: string, watchAuth: boolean,
    callback: VHWatchWebinarInfoCallback) {
    if (webinarId.length == 0) {
      if (callback) {
        callback.onFailure(VHConstants.VH_INPUT_PARAM_ERROR, 'webinarId is empty');
        return;
      }
    }
    if (recordId.length == 0) {
      if (callback) {
        callback.onFailure(VHConstants.VH_INPUT_PARAM_ERROR, 'recordId is empty');
        return;
      }
    }
    if (callback == null) {
      return
    }

    this.initBefore(webinarId, {
      onSuccess: (data) => {
        this.doInitWatch(webinarId, recordId, email, nickname, "", true, callback);
      },
      onFailure: (errorCode, errorMsg) => {
        if (callback) {
          callback.onFailure(errorCode, errorMsg);
        }
      }
    });
  }

  /**
   * @description
   * 初始化观看活动信息
   * @param webinarId 活动id 是否必填：是
   * @param recordId 指定回放id 是否必填：否
   * @param email 邮箱  是否必填：否
   * @param nickname 昵称  是否必填：否
   * @param pwd 密码 是否必填：是
   * @param callback
   */
  public initWatchWithPwd(webinarId: string, recordId: string, pwd: string, authMode: boolean, email: string,
    nickname: string, callback: VHWatchWebinarInfoCallback) {
    if (webinarId.length == 0) {
      if (callback) {
        callback.onFailure(VHConstants.VH_INPUT_PARAM_ERROR, 'webinarId is empty');
        return;
      }
    }
    if (pwd.length == 0) {
      if (callback) {
        callback.onFailure(VHConstants.VH_INPUT_PARAM_ERROR, 'recordId is empty');
        return;
      }
    }
    if (callback == null) {
      return
    }
    this.initBefore(webinarId, {
      onSuccess: (data) => {
        this.doInitWatch(webinarId, recordId, email, nickname, pwd, authMode, callback);
      },
      onFailure: (errorCode, errorMsg) => {
        if (callback) {
          callback.onFailure(errorCode, errorMsg);
        }
      }
    });
  }

  public doInitWatch(webinarId: string, record_id: string, email: string, nickname: string, password: string,
    authMode: boolean, callback: VHWatchWebinarInfoCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId);
    if (record_id.length > 0) {
      params.set(ApiKeyConstants.KEY_RECORD_ID, record_id);
    }
    if (email.length > 0) {
      params.set(ApiKeyConstants.KEY_E_MAIL, email);
    }
    if (nickname.length > 0) {
      params.set(ApiKeyConstants.KEY_NICKNAME, nickname);
    }
    if (password.length > 0) {
      params.set(ApiKeyConstants.KEY_PASS, password);
    }
    if (authMode) {
      params.set(ApiKeyConstants.KEY_AUTH_MODE, authMode ? "1" : "0");
    }
    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_WEBINAR_WATCH_INFO, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          try {
            let jsonData = JSON.stringify(data);
            if (jsonData.length > 0) {
              let webinar: VHWebinarDetail = data['webinar'] as VHWebinarDetail;
              let switchInfo: VHSwitchInfo = data['switch'] as VHSwitchInfo;
              let join: VHJoinInfo = data['join_info'] as VHJoinInfo;
              let interact: VHInteract = data['interact'] as VHInteract;
              let report_data: VHReportData = data['report_data'] as VHReportData;
              let record: VHRecord = data['record'] as VHRecord;
              let warmUp: VHWarmup = data['warmup'] as VHWarmup;
              let pv: VHPageView = data['pv'] as VHPageView;
              let agreement: VHAgreement = data['agreement'] as VHAgreement;
              let sso: VHSso = data['sso'] as VHSso;
              let online: VHOnline = data['online'] as VHOnline;
              let subscribe: VHSubscribe = data['subscribe'] as VHSubscribe;
              let urls: VHUrls = data['urls'] as VHUrls;
              this.urls = urls;
              VHDataManager.getInstance().interact = interact;
              VHDataManager.getInstance().report = report_data;
              VHDataManager.getInstance().interact_token = interact.interact_token;
              VHAppInfo.getInstance().report_extra = report_data.report_extra;
              // 设置
              let contextMap: Map<string, string> = new Map();
              contextMap["nickname"] = join.nickname;
              contextMap["avatar"] = join.avatar;
              contextMap["role_name"] = join.role_name;
              contextMap["accountId"] = join.third_party_user_id;
              contextMap["device_type"] = 3;
              contextMap["device_status"] = 1;
              contextMap["privacies"] = join.privacies;
              VHBase.setUserIdAndContext(join.third_party_user_id, contextMap);

              let webinars: VHWebinarData = new VHWebinarData;
              webinars.webinar = webinar;
              webinars.switch_info = switchInfo;
              webinars.subscribe = subscribe;
              webinars.join_info = join;
              webinars.sso = sso;
              webinars.record = record;
              webinars.warm_up = warmUp;
              webinars.interact = interact;
              webinars.pv = pv;
              webinars.agreement = agreement;
              webinars.urls = urls;
              webinars.online = online;
              webinars.system_time = data["system_time"];
              webinars.paas_record_id = data["paas_record_id"];
              webinars.record_remark_layout = data["record_remark_layout"];
              webinars.live_type = data["live_type"];
              webinars.status = data["status"];
              webinars.cast_screen = data["cast_screen"];
              webinars.cheat_num = data["cheat_num"];
              webinars.webinar_show_type = data["webinar_show_type"];
              webinars.visitor_id = data["visitor_id"];
              webinars.likeCount = data["like"];

              if (callback) {
                callback.onSucceed(webinars);
              }
            }
          } catch (e) {
            if (callback) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    );
  }

  /**
   * @description
   * 获取播放器设置、防录屏跑马灯及水印设置信息
   * @param webinarId 活动id 是否必填：是
   * @param callback
   */
  public getPlayerConfig(webinarId: string, callback: VHPlayerConfigCallback) {
    if (webinarId.length == 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error');
        return;
      }
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId);
    params.set("tags", "basic-config,definition,screen-config,water-mark");
    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_PLAYER_CONFIG, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let config: VHPlayerConfig = new VHPlayerConfig();
              if (JSON.has(data as object, 'definition')) {
                let definition: object = data['definition'];
                if (JSON.has(definition, "data")) {
                  let data: object = definition['data'];
                  if (JSON.has(data, "default_definition")) {
                    config.default_definition = this.getDispatch(data['default_definition']);
                  }
                }
              }

              if (JSON.has(data as object, 'basic-config')) {
                let basic: object = data['basic-config'];
                if (JSON.has(basic, "data")) {
                  let basic_data: VHBasicConfig = basic['data'] as VHBasicConfig;
                  config.basic = basic_data;
                }
              }
              if (JSON.has(data as object, 'screen-config')) {
                let screen: object = data['screen-config'];
                if (JSON.has(screen, "data")) {
                  let screen_data: VHMarqueeConfig = screen['data'] as VHMarqueeConfig;
                  config.marquee = screen_data;
                }
              }

              if (JSON.has(data as object, 'water-mark')) {
                let water: object = data['water-mark'];
                if (JSON.has(water, "data")) {
                  let water_data: VHWatermarkConfig = water['data'] as VHWatermarkConfig;
                  if (JSON.has(water['data'], "text_watermark")) {
                    let text_watermark = water['data']["text_watermark"] as string;
                    if (text_watermark.length > 0) {
                      water_data.text_watermark = JSON.parse(water['data']["text_watermark"]) as VHTextWatermarkType;
                    }
                  }
                  config.water = water_data;
                }
              }
              callback.onSucceed(config);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * @description
   * 互动配置聚合接口. 用用进入房间进行初始化时获取，可以获取标签列表等信息。参考VHCommonConfig
   * @param webinarId 活动id 是否必填：是
   * @param switchId 活动场次id  是否必填：否
   * @param callback
   */
  public commonConfig(webinarId: string, switchId: string, callback: VHCommonConfigCallback) {
    if (webinarId.length == 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error');
        return
      }
    }

    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId);
    if (switchId.length > 0) {
      params.set(ApiKeyConstants.KEY_SWITCH_ID, switchId);
    }
    params.set(ApiKeyConstants.KEY_TAGS,
      "skin,screen-poster,room-tool,webinar-tag,menu,goods-default,adv-default,public-account,invite-card,keywords,like,announcement,sign,timer,push-screen-card,red-packet,pwd-red-packet");

    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_COMMON_CONFIG, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let value = JSON.stringify(data);
              let commonConfig = new VHCommonConfig();
              let menus: VHMenus[] = [];
              //菜单
              if (JSON.has(data as object, 'menu')) {
                let jsonObj: object = data['menu'];
                if (JSON.has(jsonObj, "data")) {
                  let data_obj: object = jsonObj['data'];
                  if (JSON.has(data_obj, "list")) {
                    let listData = data_obj['list'] as Array<object>;
                    listData.forEach((item, index) => {
                      let menuInfo: VHMenus = item as VHMenus;
                      menus.push(menuInfo);
                    })
                    commonConfig.menus = menus;
                  }
                }
              }
              //点赞,初始化数据不准确，通过接口获取数据
              // if (JSON.has(data as object, 'like')) {
              //   let jsonObj: object = data['like'];
              //   if (JSON.has(jsonObj, "data")) {
              //     let data_obj: object = jsonObj['data'];
              //     commonConfig.like_total = data_obj['total'];
              //   }
              // }
              //互动工具
              if (JSON.has(data as object, 'room-tool')) {
                let jsonObj: object = data['room-tool'];
                if (JSON.has(jsonObj, "data")) {
                  let data_obj: object = jsonObj['data'];
                  let roomTool: RoomToolsStatusData = jsonObj['data'] as RoomToolsStatusData;
                  commonConfig.room_tool = roomTool;
                }
              }
              //签到
              if (JSON.has(data as object, 'sign')) {
                let jsonObj: object = data['sign'];
                if (JSON.has(jsonObj, "data")) {
                  let sign: VHSignInfo = jsonObj['data'] as VHSignInfo;
                  commonConfig.sign = sign;
                }
              }
              //计时器
              if (JSON.has(data as object, 'timer')) {
                let jsonObj: object = data['timer'];
                if (JSON.has(jsonObj, "data")) {
                  let timer: VHTimer = jsonObj['data'] as VHTimer;
                  commonConfig.timer = timer;
                }
              }

              //邀请卡
              if (JSON.has(data as object, 'invite-card')) {
                let jsonObj: object = data['invite-card'];
                if (JSON.has(jsonObj, "data")) {
                  let data_obj: object = jsonObj['data'];
                  commonConfig.invite_card = data_obj['status'];
                }
              }
              //皮肤
              if (JSON.has(data as object, 'skin')) {
                let jsonObj: object = data['skin'];
                if (JSON.has(jsonObj, "data")) {
                  let skin: VHSkin = jsonObj['data'] as VHSkin;
                  commonConfig.skin = skin;
                }
              }
              //推屏卡片
              if (JSON.has(data as object, 'push-screen-card')) {
                let jsonObj: object = data['push-screen-card'];
                if (JSON.has(jsonObj, "data")) {
                  let data_obj: object = jsonObj['data'];
                  commonConfig.push_screen_card = data_obj["id"];
                }
              }
              //推屏卡片
              if (JSON.has(data as object, 'screen-poster')) {
                let jsonObj: object = data['screen-poster'];
                if (JSON.has(jsonObj, "data")) {
                  let screen: VHScreenPoster = jsonObj['data'] as VHScreenPoster;
                  commonConfig.screen_poster = screen;
                }
              }
              //公众号配置
              if (JSON.has(data as object, 'public-account')) {
                let jsonObj: object = data['public-account'];
                if (JSON.has(jsonObj, "data")) {
                  let pAccount: VHPublicAccount = jsonObj['data'] as VHPublicAccount;
                  commonConfig.public_account = pAccount;
                }
              }

              //广告
              if (JSON.has(data as object, 'adv-default')) {
                let jsonObj: object = data['adv-default'];
                if (JSON.has(jsonObj, "data")) {
                  let adv: VHAdvDefault = jsonObj['data'] as VHAdvDefault;
                  commonConfig.adv = adv;
                }
              }
              //关键词
              if (JSON.has(data as object, 'keywords')) {
                let jsonObj: object = data['keywords'];
                if (JSON.has(jsonObj, "data")) {
                  let words: VHKeyWords = jsonObj['data'] as VHKeyWords;
                  commonConfig.keywords = words;
                }
              }
              //活动标识
              if (JSON.has(data as object, 'webinar-tag')) {
                let jsonObj: object = data['webinar-tag'];
                if (JSON.has(jsonObj, "data")) {
                  let tag: VHWebinarTag = jsonObj['data'] as VHWebinarTag;
                  commonConfig.webinar_tag = tag;
                }
              }
              //红包
              if (JSON.has(data as object, 'red-packet')) {
                let jsonObj: object = data['red-packet'];
                if (JSON.has(jsonObj, "data")) {
                  let packet: VHRedPacket = jsonObj['data'] as VHRedPacket;
                  commonConfig.red_packet = packet;
                }
              }
              // //商品
              // if(JSON.has(data as object,'goods-default')){
              //   let jsonObj:object = data['goods-default'];
              //   if(JSON.has(jsonObj,"data")){
              //     let goods:VHGoodsData = jsonObj['data'] as VHGoodsData;
              //     commonConfig.goods = goods;
              //   }
              // }

              callback.onSucceed(commonConfig);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * @description
   * 获取活动角色配置名称，可用于在聊天内显示对应角色名称。。比如主持人、嘉宾、助理 对应的新名称（主持人=》本场主讲人 ，嘉宾=》大中华区经理 ，助理=》活动助理）
   * @param webinarId 活动id 是否必填：是
   */
  public getRoleName(webinarId: string, callback: VHRoleNameCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId);
    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_ROLE_NAME, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let role: VHRoleName = data as VHRoleName;
              callback.onSucceed(role);
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * @description 获取当前房间聊天列表
   *
   * @param roomId     房间id
   * @param pos         获取条目节点，默认为0
   * @param limit       获取条目数量，最大100
   * @param msgId      获取条目数量，聊天记录 锚点消息id,此参数存在时anchor_path 参数必须存在
   * @param anchorPath 锚点方向，up 向上查找，down 向下查找,此参数存在时 msg_id 参数必须存在
   * @param isRole     0：不筛选主办方 1：筛选主办方 默认是0
   * @param msgType   0: 全部消息（text,image,system_notice）1: 互动消息,提示类消息(system_notice) 2: 图文消息(text,image) 默认是图文消息（兼容app，sdk）
   * @param keyword   搜索关键字 支持昵称和聊天内容 控制台互动统计生效
   * @param chatAuditStatus 审核状态， 1 审核通过，2 审核拒绝，3 待审核，不传默认为 1
   */
  public chatGetList(roomId: string, pos: number, limit: number, startTime: string, msgId: string, anchorPath: string,
    isRole: number, msgType: number, keyword: string, callback: VHChatMessageListCallback) {
    if (roomId.length == 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error');
        return;
      }
    }

    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ROOM_ID, roomId);

    limit = limit == 0 ? 10 : limit;
    params.set(ApiKeyConstants.KEY_LIMIT, limit.toString());

    if (msgId.length > 0) {
      params.set(ApiKeyConstants.KEY_MSG_ID, msgId);
      params.set(ApiKeyConstants.KEY_ANCHOR_PATH, anchorPath.length == 0 ? "up" : anchorPath);
    } else {
      pos = pos > 0 ? (pos - 1) * limit : 0;
      params.set(ApiKeyConstants.KEY_POS, pos.toString());
    }
    if (startTime.length > 0) {
      params.set(ApiKeyConstants.KEY_START_TIME, startTime);
    }
    params.set(ApiKeyConstants.KEY_IS_ROLE, isRole.toString());
    if (msgType == 0) {
      params.set(ApiKeyConstants.KEY_MSG_TYPE, 'text,image,system_notice');
    } else if (msgType == 1) {
      params.set(ApiKeyConstants.KEY_MSG_TYPE, 'system_notice');
    } else if (msgType == 2) {
      params.set(ApiKeyConstants.KEY_MSG_TYPE, 'text,image');
    }
    if (keyword.length > 0) {
      params.set(ApiKeyConstants.KEY_KEYWORD, keyword);
    }

    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_CHAT_GET_LIST, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let dataValue = JSON.stringify(data);
              let chatMsg: VHChatMessageList = data as VHChatMessageList;
              callback.onSucceed(chatMsg);
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }


  /**
   * @description
   * 获取配置权限信息,包括播放器配置信息（播放清晰度、弹幕开关等），水印配置信息，跑马灯配置信息。参见VHPlayerConfig
   * @param sceneId 使用场景：1权限检测（默认1） 2获取配置项选中值  3 权限检测和配置项值都返回
   * @param webinarId 活动id 是否必填：是
   * @param webinar_user_id 有webinar_id时，必传
   * @param callback
   */
  public permissionsCheck(sceneId: string, webinarId: string, webinar_user_id: string, callback: VHConfigListCallback) {
    if (webinarId.length > 0 && webinar_user_id.length <= 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error');
        return;
      }
    }

    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_SCENE_ID, sceneId);
    if (webinar_user_id.length > 0) {
      params.set(ApiKeyConstants.KEY_WEBINAR_USER_ID, webinar_user_id);
    }
    if (webinarId.length > 0 && webinar_user_id.length > 0) {
      params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId);
      params.set(ApiKeyConstants.KEY_WEBINAR_USER_ID, webinar_user_id);
    }

    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_CONFIG_LIST, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let configData = new VHConfigList;
              let permissions: object = JSON.parse(data["permissions"] as string) as object;
              let permission_value: object = JSON.parse(data["permission_value"] as string) as object;
              if (JSON.has(permission_value, 'ui.watch_hide_like')) {
                configData.watch_hide_like = Number(permission_value['ui.watch_hide_like']);
              }
              if (JSON.has(permission_value, 'ui.hidden_watch_like_data')) {
                configData.hidden_watch_like_data = Number(permission_value['ui.hidden_watch_like_data']);
              }
              if (JSON.has(permission_value, 'chat_nickname_encryption')) {
                configData.chat_nickname_encryption = Number(permission_value['chat_nickname_encryption']);
              }
              if (JSON.has(permission_value, 'welcome_message')) {
                let msg = permission_value['welcome_message'] as string;
                if (msg.length > 0) {
                  let welcome_message: object = JSON.parse(permission_value['welcome_message']) as object;
                  configData.live_chat_welcome = welcome_message["status"];
                  configData.live_chat_welcome_msg = welcome_message["message"];
                } else {
                  configData.live_chat_welcome = 0;
                }
              }

              if (JSON.has(permission_value, 'ui.hide_gifts')) {
                configData.hide_gifts = Number(permission_value['ui.hide_gifts']);
              }
              if (JSON.has(permission_value, 'hard_login')) {
                configData.hard_login = Number(permission_value['hard_login']);
              }
              if (JSON.has(permission_value, 'live_hidden_same')) {
                configData.live_hidden_same = Number(permission_value['live_hidden_same']);
              }
              if (JSON.has(permission_value, 'ui.watch_record_no_chatting')) {
                configData.watch_record_no_chatting = Number(permission_value['ui.watch_record_no_chatting']);
              }
              if (JSON.has(permission_value, 'ui.watch_record_chapter')) {
                configData.watch_record_chapter = Number(permission_value['ui.watch_record_chapter']);
              }
              if (JSON.has(permission_value, 'record_watch_expire')) {
                let recordWatchExpire = permission_value['record_watch_expire'] as string;
                if (recordWatchExpire.length > 0) {
                  let expire: VHRecordWatchExpire =
                    JSON.parse(permission_value['record_watch_expire'] as string) as VHRecordWatchExpire;
                  configData.record_watch_expire_config = expire;
                }
              }

              callback.onSucceed(configData);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /*
   * @description  获取签到详情
   * @param webinarId   活动,是否必填:是
   * @param signId   签到id,是否必填:是
   * */
  public getSignInfo(webinarId: number, signId: string, callback: VHSignInfoCallback) {
    if (webinarId.toString().length == 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error')
        return;
      }
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId.toString());
    params.set(ApiKeyConstants.KEY_SIGN_ID, signId)
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_SIGN_GET_INFO, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let sign: VHGetSignData = new VHGetSignData;
              callback.onSuccess(sign);
            } catch (e) {

            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }


  /*
   * @description获取签到id和当前签到的时间
   * @param signId   签到id,是否必填:是
   * @param roomId   房间id,是否必填:是
   * */
  public performSignIn(signId: string, roomId: string, callback: VHCallBack) {
    if (roomId.length == 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error')
        return;
      }
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ROOM_ID, roomId);
    params.set(ApiKeyConstants.KEY_SIGN_ID, signId)
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_USER_SIGN, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              callback.onSuccess('success');
            } catch (e) {

            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /*
 * @description 获取红包状态
 * @param roomId   房间id,是否必填:是
 * @param redPacketId 红包id,是否必填:是
 * */
  public getRedPacketStatus(roomId: string, redPacketId: string, callback: VHGetRedPacketCallback) {
    if (roomId.length == 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error')
        return;
      }
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ROOM_ID, roomId);
    params.set(ApiKeyConstants.KEY_RED_PACKET_UUID, redPacketId)
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_RED_PACKET_STATUS, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let packet: VHRedPacketStatus = data as VHRedPacketStatus;
              callback.onSucceed(packet);
            } catch (e) {

            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * @description 公告列表接口
   * @param roomId 房间id
   * @param Limit 一页的个数
   * @param pos 当前页面 从0开始
   * */
  public performAnnouncementIn(roomId: string, Limit: number, pos: number, callback: VHAnnouncementListCallback) {
    if (roomId.length == 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error');
        return;
      }
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ROOM_ID, roomId);
    Limit = Limit == 0 ? 10 : Limit
    params.set(ApiKeyConstants.KEY_LIMIT, Limit.toString())
    pos = pos * Limit
    params.set(ApiKeyConstants.KEY_POS, pos.toString())
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_ANNOUNCEMENT_LIST, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let chatMsg: VHAnnouncementNewsList = data as VHAnnouncementNewsList;
              callback.onSucceed(chatMsg)
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * @description中奖人领奖信息接口
   * @param roomId 房间id
   * @param lottery_id 抽奖活动ID
   * @param lottery_user_name 中奖人姓名
   * @param lottery_user_phone 中奖人手机号（根据领奖信息配置做校验）
   * */
  public performWinnerInformationIn(roomId: string, lottery_id: string, lottery_user_name: string,
    lottery_user_phone: string,
    callback: VHCallBack) {
    if (roomId.length == 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error');
        return;
      }
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ROOM_ID, roomId);
    params.set(ApiKeyConstants.KEY_LOTTERY_ID, lottery_id)
    params.set(ApiKeyConstants.KEY_LOTTERY_USER_NAME, lottery_user_name)
    params.set(ApiKeyConstants.KEY_LOTTERY_USER_PHONE, lottery_user_phone)
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_AWARD_LOTTERY, http.RequestMethod.POST, requestParam, headers, {
      onSuccess: (data) => {
        if (callback) {
          callback.onSuccess('success');
        }
      },
      onFailure: (errorCode, errorMsg) => {
        if (callback) {
          callback.onFailure(errorCode, errorMsg);
        }
      }
    })
  }

  /**
   * @description获取中奖用户列表
   * @param roomId 房间id
   * @param lottery_id 抽奖活动ID
   * */
  public performListWinningIn(roomId: string, lottery_id: string, callback: VHWinnerInformationCallback) {
    if (roomId.length == 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error');
        return;
      }
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ROOM_ID, roomId);
    params.set(ApiKeyConstants.KEY_LOTTERY_ID, lottery_id)
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_USER_GET_LOTTERY, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let winner_information: VHWinnerInformation = data as VHWinnerInformation;
              callback.onSucceed(winner_information)
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * @description观看端-检查抽奖进行中
   * */
  public performLotteryCarryOutIn(callback: VHLotteryCarryOutCallback) {
    let params = this.getBaseBodyParam();
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_AWARD_CHECK, http.RequestMethod.GET, requestParam, headers,
      {
        onSuccess: (data) => {
          const LotteryCarry = data as VHLotteryCarryOut;
          callback.onSucceed(LotteryCarry)
        },
        onFailure: (errorCode, errorMsg) => {
          callback.onFailure(errorCode, errorMsg);
        }
      }
    )
  }

  /**
   * @description观看端-检查抽奖列表接口
   * @param show_all 是否需要展示所有抽奖 0-否(默认：仅展示进行中、已中奖抽奖) 1-全部抽奖 2 已中奖抽奖（sdk专用）
   * */
  public performLotteryListIn(show_all: string, callback: VHLotteryListCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_SHOW_ALL, show_all)
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_AWARD_CHECK_LIST, http.RequestMethod.GET, requestParam, headers,
      {
        onSuccess: (data) => {
          const LotteryList = data as VHLotteryList[];
          callback.onSucceed(LotteryList)
        },
        onFailure: (errorCode, errorMsg) => {
          callback.onFailure(errorCode, errorMsg);
        }
      }
    )
  }

  /**
   * @description 抽奖-立即参与
   * @param roomId 房间id
   * @param lottery_id 抽奖活动ID
   * */
  public performLotteryParticipationIn(room_id: string, lottery_id: string, callback: VHCallBack) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ROOM_ID, room_id);
    params.set(ApiKeyConstants.KEY_LOTTERY_ID, lottery_id)
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_JOIN_LOTTERY, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          callback.onSuccess('success');
        },
        onFailure: (errorCode, errorMsg) => {
          callback.onFailure(errorCode, errorMsg);
        }
      }
    )
  }

  /**
   * @description 查询房间历史问卷
   * @param roomId 房间id
   * @param webinar_id 活动id
   * @param switch_id 活动场次id
   * */
  public performQuestionnaireListIn(roomId: string, webinar_id: string, switch_id: string,
    callback: VHQuestionnaireCallback) {
    if (roomId.length == 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error');
        return;
      }
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ROOM_ID, roomId);
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinar_id)
    params.set(ApiKeyConstants.KEY_SWITCH_ID, switch_id)
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_HISTORY_SURVEY, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let info: VHHistoryQuestionnaireInfo = data as VHHistoryQuestionnaireInfo;
              callback.onSucceed(info)
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * @description 快问快答列表接口
   * @param source_id 业务数据id
   * @param source_type 业务数据id类型
   * @param switch_id 场次id
   * @param scene_type 场景类型，0-直播中（默认） 1-回放
   * */
  public performExamIn(source_id: number, source_type: number, switch_id: number, scene_type: number,
    callback: VHExamListCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_SOURCE_ID, source_id.toString());
    params.set(ApiKeyConstants.KEY_SOURCE_TYPE, source_type.toString())
    params.set(ApiKeyConstants.KEY_SWITCH_ID, switch_id.toString())
    params.set(ApiKeyConstants.KEY_SCENE_TYPE, scene_type.toString())
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequestWithJsonHeader(this.sdk_host + API_INTERFACE.API_PAPER_LIST, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let chatMsg: VHExamList[] = data as VHExamList[];
              callback.onSucceed(chatMsg)
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * @description 快问快答 快问快答成绩排名列表
   * @param paper_id 试卷id
   * @param limit 每页数量
   * @param pos 分页数据起始位置 从0开始，下一页自增1
   * */
  public getExamUserPerformanceList(paper_id: string, limit: number, pos: number, callback: VHExamPerformanceCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_PAPER_ID, paper_id.toString());
    params.set(ApiKeyConstants.KEY_LIMIT, limit.toString())
    params.set(ApiKeyConstants.KEY_POS, pos.toString())
    params.set(ApiKeyConstants.KEY_FROM_CONSUMER, "1")
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequestWithJsonHeader(this.sdk_host + API_INTERFACE.API_USER_PERFORMANCE_LIST, http.RequestMethod.POST,
      requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let chatMsg: VHExamReportList = data as VHExamReportList;
              callback.onSucceed(chatMsg)
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * @description 快问快答 指定快问快答的用户答题状态
   * @param paper_id 试卷id
   * @param source_id 每页数量
   * @param switch_id 分页数据起始位置
   * */
  public setExamUserAnswerStatus(paper_id: string, source_id: number, switch_id: number,
    callback: VHExamUserAnswerStatusCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_PAPER_ID, paper_id.toString());
    params.set(ApiKeyConstants.KEY_SWITCH_ID, switch_id.toString())
    params.set(ApiKeyConstants.KEY_SOURCE_ID, source_id.toString())
    params.set(ApiKeyConstants.KEY_SOURCE_TYPE, "1")
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequestWithJsonHeader(this.sdk_host + API_INTERFACE.API_USER_ANSWER_STATUS, http.RequestMethod.POST,
      requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let status: VHExamUserAnswerStatus = data as VHExamUserAnswerStatus;
              callback.onSucceed(status)
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * @description 快问快答 查看个人成绩详情
   * @param webinarId 活动id
   * @param paper_id 试卷id
   * */
  public getExamPersonalReport(webinarId: string, paper_id: string, callback: VHExamPersonalReportCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_PAPER_ID, paper_id);
    params.set(ApiKeyConstants.KEY_ACCOUNT_ID, webinarId)
    params.set(ApiKeyConstants.KEY_ACCOUNT_TYPE, "4")
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequestWithJsonHeader(this.sdk_host + API_INTERFACE.API_GET_PERSONAL_REPORT, http.RequestMethod.POST,
      requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let status: VHExamPersonalReport = data as VHExamPersonalReport;
              callback.onSucceed(status)
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }


  private getDispatch(definition: string): VHPlayDefinition {
    if (definition == 'same') {
      return VHPlayDefinition.VH_ORIGIN;
    } else if (definition == '360p') {
      return VHPlayDefinition.VH_SD;
    } else if (definition == '480p') {
      return VHPlayDefinition.VH_HD;
    } else if (definition == '720p') {
      return VHPlayDefinition.VH_UHD;
    } else if (definition == '1080p') {
      return VHPlayDefinition.VH_FULL_HD;
    } else if (definition == 'a') {
      return VHPlayDefinition.VH_AUDIO;
    }
    return VHPlayDefinition.VH_ORIGIN;
  }

  /**
   * 内部接口。
   * 广播消息回调
   * @param msgModel 数据模型
   */
  broadcastMsgModel(msgModel: VHMessage): void {
    if (msgModel.service_type == VHMessageStaticTypes.MSG_Service_Type_Document) {

    }

    if (msgModel.service_type == VHMessageStaticTypes.MSG_SDK_inside_vod_doc) {

    }
  }

  /**
   * 消息服务连接成功
   * */
  onNetworkConnect(): void {

  }

  /**
   * 消息服务连接正在重新链接
   * */
  onNetworkConnecting(): void {

  }

  /**
   * 消息服务连接断开
   * */
  onNetworkDisconnect(code: number, msg: string): void {

  }


  private initBefore(webinarId: string, callback: CallBack) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId);
    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_INIT_BEFORE, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            VHDataManager.getInstance().gray_id = data["user_id"] as number;
            callback.onSuccess("");
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }


  private getBaseHeaderParam(): Map<string, string> {
    let params = new Map<string, string>();
    let zone = systemDateTime.getTimezoneSync();
    params.set(ApiKeyConstants.KEY_TOKEN, VHDataManager.getInstance().token);
    params.set(ApiKeyConstants.KEY_INTERACT_TOKEN, VHDataManager.getInstance().interact_token);
    params.set(ApiKeyConstants.KEY_ZONE, zone);
    params.set(ApiKeyConstants.KEY_REQUEST_ID, util.generateRandomUUID(true));
    params.set(ApiKeyConstants.KEY_PLATFORM, this.platform);
    if (VHDataManager.getInstance()?.gray_id > 0) {
      params.set(ApiKeyConstants.KEY_GRAY_ID, VHDataManager.getInstance().gray_id.toString());
    }

    // params.set(ApiKeyConstants.KEY_GRAY_ID, VHDataManager.getInstance().gray_id);
    return params;
  }

  private getBaseBodyParam(): Map<string, string> {
    let params = new Map<string, string>();
    let zone = systemDateTime.getTimezoneSync();
    params.set(ApiKeyConstants.KEY_SIGNATURE, this.app_signature);
    params.set(ApiKeyConstants.KEY_PACKAGE_NAME, this.package_name);
    params.set(ApiKeyConstants.KEY_APP_KEY, this.app_key);
    params.set(ApiKeyConstants.KEY_SIGNED_AT, systemDateTime.getTime().toString());
    params.set(ApiKeyConstants.KEY_SIGN_TYPE, this.sign_type);
    params.set(ApiKeyConstants.KEY_CLIENT_VERSION, BuildProfile.HAR_VERSION); //先用安卓替代
    return params;
  }

  private getJsonBaseBodyParam(): Map<string, string | object> {
    let params = new Map<string, string | object>();
    let zone = systemDateTime.getTimezoneSync();
    params.set(ApiKeyConstants.KEY_SIGNATURE, this.app_signature);
    params.set(ApiKeyConstants.KEY_PACKAGE_NAME, this.package_name);
    params.set(ApiKeyConstants.KEY_APP_KEY, this.app_key);
    params.set(ApiKeyConstants.KEY_SIGNED_AT, systemDateTime.getTime().toString());
    params.set(ApiKeyConstants.KEY_SIGN_TYPE, this.sign_type);
    params.set(ApiKeyConstants.KEY_CLIENT_VERSION, BuildProfile.HAR_VERSION); //先用安卓替代
    return params;
  }


  private getRASSign(inputData: string): string {
    if (this.rsaPriKeyStr.length == 0) {
      return '';
    }
    let keyPair = RSA.getConvertKeyPairSync(null, this.rsaPriKeyStr, 'base64');
    let dataBlob = CryptoHelper.strToDataBlob(inputData, 'utf-8');
    let signDataBlob1 = RSA.signSync(dataBlob, keyPair!.priKey, 'RSA1024|PKCS1|MD5');
    let signStr1 = CryptoHelper.dataBlobToStr(signDataBlob1, 'base64');
    let str = signStr1;
    return str;
  }


  private getSignParam(inputParams: Map<string, string | object>): Map<string, string | object> {
    // 1. 转换为数组并处理键的空格
    let withOutExtraParam = '';
    let param = "";
    let mapArray = Array.from(inputParams.entries()).sort((a, b) => {
      // 比较两个键的字符串大小
      if (a[0] < b[0]) {
        return -1;
      }
      if (a[0] > b[0]) {
        return 1;
      }
      return 0;
    });


    mapArray.forEach((item) => {
      const key = item[0]; // 明确获取键
      const value = item[1]; // 明确获取值
      param += key + value;
      if (key === ApiKeyConstants.KEY_SIGNATURE || key === ApiKeyConstants.KEY_PACKAGE_NAME) {
        return;
      }
      withOutExtraParam += key + value;
    });

    if (this.app_secret_key.length > 0 && this.sign_type != "1") {
      param = this.app_secret_key + param + this.app_secret_key;
      withOutExtraParam = this.app_secret_key + withOutExtraParam + this.app_secret_key;
    }

    let sign = "";
    let sign_special = "";
    if (this.sign_type == "1") { ////RSA
      sign = this.getRASSign(MD5.digestSegmentSync(param));
      sign_special = this.getRASSign(MD5.digestSegmentSync(withOutExtraParam));
    } else if (this.sign_type == "2") { //SHA256
      sign = SHA.digestSegmentSync(param);
      sign_special = SHA.digestSegmentSync(withOutExtraParam);
    } else if (this.sign_type == "3") { //SM3
      sign = SM3.digestSegmentSync(param);
      sign_special = SM3.digestSegmentSync(withOutExtraParam);
    } else {
      sign = MD5.digestSegmentSync(param);
      sign_special = MD5.digestSegmentSync(withOutExtraParam);
    }

    inputParams.set(ApiKeyConstants.KEY_SIGN, sign);
    inputParams.set(ApiKeyConstants.KEY_SIGN_SPECIAL, sign_special);
    if (inputParams.has(ApiKeyConstants.KEY_PACKAGE_NAME)) {
      inputParams.delete(ApiKeyConstants.KEY_PACKAGE_NAME)
    }
    if (inputParams.has(ApiKeyConstants.KEY_SIGNATURE)) {
      inputParams.delete(ApiKeyConstants.KEY_SIGNATURE)
    }
    return inputParams;
  }


  private getSignJsonParam(inputParams: Map<string, string | object>): Map<string, string | object> {
    // 1. 转换为数组并处理键的空格
    let withOutExtraParam = '';
    let param = "";
    let mapArray = Array.from(inputParams.entries()).sort((a, b) => {
      // 比较两个键的字符串大小
      if (a[0] < b[0]) {
        return -1;
      }
      if (a[0] > b[0]) {
        return 1;
      }
      return 0;
    });


    mapArray.forEach((item) => {
      const key = item[0]; // 明确获取键
      const value = item[1]; // 明确获取值
      if (typeof value === "object") {
        param += key;
      } else {
        param += key + value;
      }

      if (key === ApiKeyConstants.KEY_SIGNATURE || key === ApiKeyConstants.KEY_PACKAGE_NAME) {
        return;
      }

      if (typeof value === "object") {
        withOutExtraParam += key;
      } else {
        withOutExtraParam += key + value;
      }

    });

    if (this.app_secret_key.length > 0 && this.sign_type != "1") {
      param = this.app_secret_key + param + this.app_secret_key;
      withOutExtraParam = this.app_secret_key + withOutExtraParam + this.app_secret_key;
    }

    let sign = "";
    let sign_special = "";
    if (this.sign_type == "1") { ////RSA
      sign = this.getRASSign(MD5.digestSegmentSync(param));
      sign_special = this.getRASSign(MD5.digestSegmentSync(withOutExtraParam));
    } else if (this.sign_type == "2") { //SHA256
      sign = SHA.digestSegmentSync(param);
      sign_special = SHA.digestSegmentSync(withOutExtraParam);
    } else if (this.sign_type == "3") { //SM3
      sign = SM3.digestSegmentSync(param);
      sign_special = SM3.digestSegmentSync(withOutExtraParam);
    } else {
      sign = MD5.digestSegmentSync(param);
      sign_special = MD5.digestSegmentSync(withOutExtraParam);
    }

    inputParams.set(ApiKeyConstants.KEY_SIGN, sign);
    inputParams.set(ApiKeyConstants.KEY_SIGN_SPECIAL, sign_special);
    if (inputParams.has(ApiKeyConstants.KEY_PACKAGE_NAME)) {
      inputParams.delete(ApiKeyConstants.KEY_PACKAGE_NAME)
    }
    if (inputParams.has(ApiKeyConstants.KEY_SIGNATURE)) {
      inputParams.delete(ApiKeyConstants.KEY_SIGNATURE)
    }
    return inputParams;
  }

  public getGiftList(roomId: string, callback: VHGiftListCallback) {
    if (roomId.length == 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error')
        return;
      }
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ROOM_ID, roomId);
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_GIFT_LIST, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let gitList: VHGiftList = data as VHGiftList
              callback.onSucceed(gitList);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * 观看端_发送礼物给主持人
   *
   * @param room_id      lss
   * @param gift_id      礼物ID
   * @param channel      支付渠道 WEIXIN
   * @param service_code 支付方式 QR_PAY
   * @param open_id      当支付方式为JSAPI的时候必传
   */
  public sendGift(room_id: string, gift_id: string, channel: string, service_code: string, open_id: string,
    callback: CallBack) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ROOM_ID, room_id);
    params.set(ApiKeyConstants.KEY_GIFT_ID, gift_id);
    params.set(ApiKeyConstants.KEY_CHANNEL, channel);
    params.set(ApiKeyConstants.KEY_SERVICE_CODE, service_code);
    if (StrUtil.isNotEmpty(open_id)) {
      params.set(ApiKeyConstants.KEY_OPEN_ID, open_id);
    }

    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_SEND_GIFT, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            // VHDataManager.getInstance().gray_id = data["user_id"];
            callback.onSuccess("礼物推送成功");
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }


  /**
   * 获取房间的点赞数量
   */
  public getRoomLike(roomId: string, callback: VHRoomLikeCallback) {
    if (roomId.length == 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error')
        return;
      }
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ROOM_ID, roomId);
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_ROOM_LIKE, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let roomLike: RoomLikeInfo = data as RoomLikeInfo
              callback.onSucceed(roomLike);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * 观看端-用户点赞
   * 点赞次数，最多500，超过500会强制成为500
   */
  public createUserLikeWithRoomId(roomId: string, num: string, callback: CallBack) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ROOM_ID, roomId);
    params.set(ApiKeyConstants.KEY_Like_COUNT, num);
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_CREATE_USER_LIKE, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            callback.onSuccess("点赞成功");
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * 观看端-发送问答
   *
   */
  public sendQuestion(roomId: string, content: string, callback: CallBack) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ROOM_ID, roomId);
    params.set(ApiKeyConstants.KEY_MSG_CONTENT, content);
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_SUBMIT_QUESTION, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            callback.onSuccess("发送成功");
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * 获取房间的问答历史记录
   */
  public getQuestionHistory(roomId: string, callback: VHQuestionHistoryCallback) {
    if (roomId.length == 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error')
        return;
      }
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ROOM_ID, roomId);
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_QUESTION_HISTORY, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let questionHistory: VHQuestionHistoryList = data as VHQuestionHistoryList;
              callback.onSucceed(questionHistory);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * 获下载文件列表
   */
  public getFilesList(webinar_id: string, menu_id: string, callback: VHFileListCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinar_id);
    params.set(ApiKeyConstants.KEY_MENU_ID, menu_id);
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_FILES_LIST, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let filesList: FilesList = data as FilesList;
              callback.onSucceed(filesList);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * 检测下载
   */
  public getFileDownLoadUrl(webinar_id: string, menu_id: string, file_id: string, visit_id: string,
    callback: VHCallBack) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinar_id);
    params.set(ApiKeyConstants.KEY_MENU_ID, menu_id);

    params.set(ApiKeyConstants.KEY_FILE_ID, file_id);
    params.set(ApiKeyConstants.KEY_VISIT_ID, visit_id);
    // 先用安卓类型
    params.set(ApiKeyConstants.KEY_DOWNLOAD_TYPE, "3");

    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_CHECK_DOWNLOAD, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              callback.onSuccess(data['download_url'] as string);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /***
   * @description 获取AI创造相关配置信息
   * @param recordId 回放id
   * */
  public getAIWatch(recordId: string, callback: VHAIWatchCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_RECORD_ID, recordId);
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_AI_WATCH, http.RequestMethod.GET, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let ai: VHAIMediaInfo = data as VHAIMediaInfo;
              callback.onSucceed(ai);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * @description 解析获取AI摘要详情
   * @param url: 通过getAIWatch获取summary.file_url
   * **/
  public getAISummaryInfo(url:string,callback:VHAISummaryModelCallback){
    try {
      if (url.length > 0) {
        let request = http.createHttp();
        request.request(url,
          {
            method: http.RequestMethod.GET,
            connectTimeout: 60000,
            readTimeout: 60000
          },
          (err, data) => {
            if (err) {
              request.destroy();
              if (callback) {
                callback.onFailure(data.responseCode, data.result.toString());
              }
              return;
            }

            if (data.responseCode !== 200) {
              if (callback) {
                callback.onFailure(data.responseCode, data.result.toString());
              }
              request.destroy();
              return;
            }

            try {
             let summary_data = JSON.parse(data.result.toString()) as VHAISummaryModel;
              callback.onSucceed(summary_data);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
            request.destroy();
          })
      } else{
        if (callback) {
          callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'url error');
        }
      }
    } catch (e) {
      if (callback) {
        callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
      }
    }
  }

  /**
   * @description 获取精彩时刻信息
   * @param url: 通过getAIWatch获取的VHAIMoments file_url
   * **/
  public getVHAIHighlightInfo(url:string,callback:VHAIHighlightCallback){
    try {
      if (url.length > 0) {
        let request = http.createHttp();
        request.request(url,
          {
            method: http.RequestMethod.GET,
            connectTimeout: 60000,
            readTimeout: 60000
          },
          (err, data) => {
            if (err) {
              request.destroy();
              if (callback) {
                callback.onFailure(data.responseCode, data.result.toString());
              }
              return;
            }

            if (data.responseCode !== 200) {
              if (callback) {
                callback.onFailure(data.responseCode, data.result.toString());
              }
              request.destroy();
              return;
            }

            try {
              let moments: object = JSON.parse(data.result.toString()) as object;
              if (JSON.has(moments, "highlight")) {
                let models = moments["highlight"] as VHAIHighlightModel[];
                callback.onSucceed(models);
              }else{
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'highlight is null');
              }
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
            request.destroy();
          })
      } else{
        if (callback) {
          callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'url error');
        }
      }
    } catch (e) {
      if (callback) {
        callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
      }
    }
  }

  /***
   * @description 获取推屏卡片历史列表
   * @param webinarId 活动id
   * @param switchId  场次id
   * @param page  页数 默认1
   * @param limit 每页条数 默认10
   * */
  public getCardList(webinarId: string, switchId: string, page: number, limit: number, callback: VHPushCardCallback) {
    let params = this.getBaseBodyParam();
    limit = limit <= 0 ? 10 : limit;
    page = page < 1 ? 1 : page;

    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId);
    params.set(ApiKeyConstants.KEY_SWITCH_ID, switchId);
    params.set(ApiKeyConstants.KEY_CURR_PAGE, page.toString());
    params.set(ApiKeyConstants.KEY_PAGE_SIZE, limit.toString());

    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_SCREEN_CARD_LIST, http.RequestMethod.GET, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              // let ai:VHAIMediaInfo = data as VHAIMediaInfo;
              // callback.onSucceed(ai);
              let cardInfo: object = data as object;
              if (JSON.has(cardInfo, "total")) {
                let total = cardInfo["total"] as number;
                if (total > 0) {
                  let cardList = data['list'] as Array<VHCardInfo>;
                  callback.onSucceed(cardList);
                } else {
                  callback.onSucceed([]);
                }

              }
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /***
   * @description 获取推屏卡片详细信息
   * @param webinarId 活动id
   * @param switchId  推屏卡片id
   * */
  public getCardInformation(webinarId: string, Id: string, callback: VHPushCardInformationCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId);
    params.set(ApiKeyConstants.KEY_ID, Id);
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_SCREEN_CARD_INFO, http.RequestMethod.GET, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              callback.onSucceed(data as VHCardInfo);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /***
   * @description 获取推屏卡片历史列表
   * @param webinarId 活动id
   * @param switchId  场次id
   * @param cardId  页数 推屏卡片id
   * */
  public cardClicked(webinarId: string, switchId: string, cardId: string, callback: VHCallBack) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId);
    params.set(ApiKeyConstants.KEY_SWITCH_ID, switchId);
    params.set(ApiKeyConstants.KEY_CARD_ID, cardId);

    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_SCREEN_CARD_CLICKED, http.RequestMethod.GET, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              callback.onSuccess("success");
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /***
   * @description 获取推屏卡片历史列表
   * @param webinarId 活动id
   * @param switchId  场次id
   * @param cardId  页数 推屏卡片id
   * */
  public getCardInfo(webinarId: string, cardId: string, callback: VHCallBack) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId);
    params.set(ApiKeyConstants.KEY_CARD_ID, cardId);

    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_SCREEN_CARD_CLICKED, http.RequestMethod.GET, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              callback.onSuccess("success");
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }


  /***
   * @description 参与最后一次观看有礼。
   * 接受的观看有礼推送或进行查询时，需要先调用此接口，否则领奖时会报错参与时长不够
   * @param webinarId 必传，活动id
   * */
  public getWatchGiftLastInfo(webinarId: number, callback: VHWatchGiftCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId.toString());
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_WATCH_GIFT_GET_LAST_INFO, http.RequestMethod.GET, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              if (data) {
                let info: VHWatchGiftInfo = data as VHWatchGiftInfo;
                callback.onSucceed(info);
              } else {
                callback.onSucceed(null);
              }
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /***
   * @description 获取观看有礼奖品列表
   * @param webinarId 必传，活动id
   * @param watchGiftId 必传，观看有礼 ID
   * */
  public getWatchGiftAwardList(webinarId: number, watchGiftId: number, callback: VHWatchGiftAwardListCallback) {

    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId.toString());
    params.set(ApiKeyConstants.KEY_WATCH_GIFT_ID, watchGiftId.toString());
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_WATCH_GIFT_AWARD_LIST, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let info: VHWatchGiftAward = data as VHWatchGiftAward;
              callback.onSucceed(info);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /***
   * @description 参与观看有礼抽奖
   * @param webinarId 必传， 活动id
   * @param watchGiftId 必传，观看有礼 ID
   * @param roomId 必传，房间ID
   * @param switchId 必传，场次ID
   * */
  public setWatchGiftParticipate(webinarId: number, watchGiftId: number, roomId: string, switchId: number,
    callback: VHWatchGiftParticipateCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId.toString());
    params.set(ApiKeyConstants.KEY_WATCH_GIFT_ID, watchGiftId.toString());
    params.set(ApiKeyConstants.KEY_ROOM_ID, roomId);
    params.set(ApiKeyConstants.KEY_SWITCH_ID, switchId.toString());
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_WATCH_GIFT_PARTICIPATE, http.RequestMethod.GET, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let info: VHWatchGiftParticipate = data as VHWatchGiftParticipate;
              callback.onSucceed(info);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }


  /***
   * @description 查询观看有礼用户中奖详情
   * @param watchGiftId 必传，观看有礼 ID
   * */
  public getWatchGiftWinnerDetail(watchGiftId: number, callback: VHWatchGiftWinnerDetailCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WATCH_GIFT_ID, watchGiftId.toString());
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_WATCH_GIFT_WINNER_DETAIL, http.RequestMethod.GET, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let info: VHWatchGiftWinnerDetail = data as VHWatchGiftWinnerDetail;
              callback.onSucceed(info);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /***
   * @description 提交用户领奖信息
   * @param watchGiftId 必传， 观看有礼 ID
   * @param award 必传， 领奖信息json字符串 。在原有VHWatchGiftAwardFiled增加field_value信息
   * * */
  public saveWatchGift(watchGiftId: number, award: string, callback: VHCallBack) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WATCH_GIFT_ID, watchGiftId.toString());
    params.set(ApiKeyConstants.KEY_WINNER_AWARD_REMARK, award);
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_WATCH_GIFT_SAVE_TAKE_AWARD_REMARK, http.RequestMethod.POST,
      requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              callback.onSuccess("success");
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }


  /***
   * @description 查询观看有礼领奖配置
   * @param webinarId 必传， 活动id
   * @param watchGiftId 必传， 观看有礼 ID
   * */
  public getWatchGiftAwardSetting(webinarId: number, watchGiftId: number, callback: VHWatchGiftAwardSettingCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WATCH_GIFT_ID, watchGiftId.toString());
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId.toString());
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_WATCH_GIFT_AWARD_SETTING, http.RequestMethod.GET, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let filed = data['receive_award_field'] as string;
              let filedObj: VHGiftAwardFiled[] = JSON.parse(filed) as VHGiftAwardFiled[];
              let info: VHWatchGiftSetting = data as VHWatchGiftSetting;
              info.receive_award_field = filedObj;
              callback.onSucceed(info);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }


  /***
   * @description 观看端-查询观看有礼的中奖名单
   * @param watchGiftId，必传， 观看有礼 ID
   * @param pos 必传，查询位置，默认 0
   * @param limit 必传， 查询条数，默认 10
   * */
  public getWatchGiftWinnerRank(watchGiftId: number, pos: number, limit: number, callback: VHWatchGiftWinnersCallback) {
    let params = this.getBaseBodyParam();
    if (pos <= 0) {
      pos = 0;
    }
    if (limit <= 0) {
      limit = 10;
    }
    params.set(ApiKeyConstants.KEY_WATCH_GIFT_ID, watchGiftId.toString());
    params.set(ApiKeyConstants.KEY_POS, pos.toString());
    params.set(ApiKeyConstants.KEY_LIMIT, limit.toString());
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_WATCH_GIFT_WINNER_RANK, http.RequestMethod.GET, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let info = data as VHWinner;
              callback.onSucceed(info);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * @description 在线活动商品列表(发起/观看端)
   * @param status 是否上架 1= 上架 2=未上架
   * */
  public performGoodsIn(status: number, callback: VHGoodsListCallback) {
    let params = this.getBaseBodyParam();
    if (status > 0) {
      params.set(ApiKeyConstants.KEY_STATUS, status?.toString());
    }
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_SALE_GOODS_LIST, http.RequestMethod.GET, requestParam, headers, {
      onSuccess: (data) => {
        if (callback) {
          const goodsList: VHGoodsListData[] = data as VHGoodsListData[]
          callback.onSucceed(goodsList);
        }
      },
      onFailure: (errorCode, errorMsg) => {
        if (callback) {
          callback.onFailure(errorCode, errorMsg);
        }
      }
    })
  }

  /**
   * @description 获取上架商品详情
   * @param goods_id 商品id
   * */
  public performProductDetailsIn(goods_id: string, callback: VHGoodsListCallback) {
    if (goods_id.length == 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error');
        return;
      }
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_GOODS_ID, goods_id);
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_SALE_GOODS_INFO, http.RequestMethod.GET, requestParam, headers, {
      onSuccess: (data) => {
        if (callback) {
          const goodsList: VHGoodsListData[] = data as VHGoodsListData[]
          callback.onSucceed(goodsList);
        }
      },
      onFailure: (errorCode, errorMsg) => {
        if (callback) {
          callback.onFailure(errorCode, errorMsg);
        }
      }
    })
  }

  /**
   * @description 获取更新的商品信息
   * @param url：商品url
   * **/
  public getGoodsInfo(url: string, callback: VHGoodsInfoCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_URL, url);
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(url, http.RequestMethod.GET, requestParam, headers, {
      onSuccess: (data) => {
        if (callback) {
          //解析成数组
          const datas: object = JSON.parse(data as string) as object;
          const goodsList: VHGoodsInfo[] = datas as VHGoodsInfo[]
          callback.onSuccess(goodsList);
        }
      },
      onFailure: (errorCode, errorMsg) => {
        if (callback) {
          callback.onFailure(errorCode, errorMsg);
        }
      }
    })
  }

  /**
   * @description
   * 获取公众号引流配置
   * @param webinarId 活动id 是否必填：是
   */
  public getDivertingConfig(webinarId: string, callback: VHVHMarketingPublicAccountCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_SOURCE_ID, webinarId);
    params.set(ApiKeyConstants.KEY_SOURCE_TYPE, "1");
    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequestWithJsonHeader(this.sdk_host + API_INTERFACE.API_GET_DIVERTING_CONFIG, http.RequestMethod.POST,
      requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let role: VHMarketingPublicAccount = data as VHMarketingPublicAccount;
              callback.onSucceed(role);
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  public getAppId(): string {
    return this.yun_app_id;
  }

  /**
   * 获取隐私协议
   * @param webinarId 活动 ID
   * @param module 所属模块： 1 观看限制 2 抽奖 3 互动有礼
   * @param source_id 来源 ID, 所属记录，如抽奖 id, 互动有礼 id, 不存在 id 的情况可以填 0
   * @param type 类型： 0 非活动下模块，无需 webinar_id, 1 活动下模块，必须传 webinar_id
   * @param callback 返回
   */
  public getPrivacyAgreement(webinarId: string, module: string, source_id: string, type: string,
    callback: VHPrivacyAgreementCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId);
    params.set(ApiKeyConstants.KEY_MODULE, module);
    params.set(ApiKeyConstants.KEY_SOURCE_ID, source_id);
    params.set(ApiKeyConstants.KEY_TYPE, type);

    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_PRIVACY_AGREEMENT, http.RequestMethod.GET, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let info: PrivacyAgreementInfo = data as PrivacyAgreementInfo;
              callback.onSucceed(info);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * 获取广告列表
   * @param webinarId 活动 ID
   * @param pos 位置： 1 顶部 2 中间 3 底部
   * @param limit 显示数量
   * @param callback 菜单信息
   */
  public getAdvList(webinarId: string, pos: string, limit: string, callback: VHAdvCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId);
    params.set(ApiKeyConstants.KEY_POS, pos);
    params.set(ApiKeyConstants.KEY_LIMIT, limit);

    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_ADV_LIST, http.RequestMethod.GET, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let info: VHAdvDefault = data as VHAdvDefault;
              callback.onSucceed(info);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * 获取菜单信息
   * @param menu_id 菜单 ID
   * @param callback 菜单信息
   */
  public getMenuInfo(menu_id: string, callback: VHMenuInfoCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_MENU_ID, menu_id);

    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_MENU_INFO, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let info: VHMenuInfo = data as VHMenuInfo;
              callback.onSucceed(info);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * @description 可用优惠券列表
   * @param webinarId 活动 ID
   * @param callback 返回
   */
  public getCouponsAvailable(webinar_id: number, callback: VHCouponsAvailableCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinar_id.toString());
    // params.set(ApiKeyConstants.KEY_GOODS_ID, goods_id);
    // params.set(ApiKeyConstants.KEY_GOODS_NUM, goods_num.toString());
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequestWithJsonHeader(this.sdk_host + API_INTERFACE.API_COUPON_AVAILABLE_LIST, http.RequestMethod.POST,
      requestParam,
      headers, {
        onSuccess: (data) => {
          if (callback) {
            const CouponsAvailable: VHCouponInfo[] = data as VHCouponInfo[]
            callback.onSucceed(CouponsAvailable);
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * @description 不可用优惠券列表
   * @param webinarId 活动 ID
   * @param goods_id 商品ID
   * @param goods_num 商品数量
   * @param callback 返回
   */
  public getCouponsNotAvailable(webinar_id: number, callback: VHCouponsNotAvailableCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinar_id.toString());
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequestWithJsonHeader(this.sdk_host + API_INTERFACE.API_COUPON_UNAVAILABLE_LIST, http.RequestMethod.POST,
      requestParam,
      headers, {
        onSuccess: (data) => {
          if (callback) {
            const CouponsNotAvailable: VHNotAvailableCouponInfo[] = data as VHNotAvailableCouponInfo[]
            callback.onSucceed(CouponsNotAvailable);
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * @description 创建订单
   * @param pay_amount 支付金额
   * @param pay_channel 支付渠道
   * @param coupon_user_ids 优惠券ID
   * @param goods 商品信息
   * @param username 用户名
   * @param phone 手机号
   * @param remark 备注
   * @param callback 返回
   */
  public CreateGoodsOrder(id: string, pay_amount: string, pay_channel: string, goods: VHProductOrderRequestsData,
    coupon_user_ids: Array<number>, username: string, phone: string, remark: string,
    callback: VHCreateOrderCallback) {
    let params = this.getJsonBaseBodyParam();
    params.set(ApiKeyConstants.KEY_PAY_AMOUNT, pay_amount);
    params.set(ApiKeyConstants.KEY_PAY_CHANNEL, pay_channel);
    params.set(ApiKeyConstants.KEY_SERVICE_CODE, "H5_PAY");
    params.set(ApiKeyConstants.KEY_USERNAME, username);
    params.set(ApiKeyConstants.KEY_PHONE, phone);
    params.set(ApiKeyConstants.KEY_REMARK, remark);
    // params.set(ApiKeyConstants.KEY_SHOW_URL, API_INTERFACE.API_GOODS_SHOW_URL + id);
    // params.set("show_url", "https://636760058");
    if (coupon_user_ids != null) {
      params.set(ApiKeyConstants.KEY_COUPON_USER_IDS, coupon_user_ids);
    }

    let good: object = new Object();
    good[ApiKeyConstants.KEY_GOODS_ID] = goods.goods_id;
    good[ApiKeyConstants.KEY_QUANTITY] = goods.quantity;
    good[ApiKeyConstants.KEY_BUY_TYPE] = goods.buy_type;
    let goodsArray: object[] = [];
    goodsArray.push(good);
    params.set(ApiKeyConstants.KEY_GOODS, goodsArray);
    let requestParam = this.getSignJsonParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequestWithJson(this.sdk_host + API_INTERFACE.API_GOODS_ORDER_CREATE, http.RequestMethod.POST,
      requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let info: VHCreateOrderInfo = data as VHCreateOrderInfo;
              callback.onSucceed(info);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * @description 用户获取活动商品设置(对外)
   * @param webinarId 活动 ID
   * @param business_uid b端用户ID
   */
  public GoodsActivitySettings(webinar_id: string, business_uid: string, callback: VHGoodsActivitySettingsCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinar_id);
    params.set(ApiKeyConstants.KEY_BUSINESS_UID, business_uid);
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GOODS_ORDER_SETTING, http.RequestMethod.GET,
      requestParam, headers,
      {
        onSuccess: (data) => {
          const GoodsActivitySettings: VHGoodsActivitySettings = data as VHGoodsActivitySettings
          callback.onSucceed(GoodsActivitySettings);
        },
        onFailure: (errorCode, errorMsg) => {
          callback.onFailure(errorCode, errorMsg);
        }
      })
  }

  /**
   * 获取专题信息
   * @param subject_ids 专题 ID, 多个用英文逗号分隔
   * @param callback 专题信息
   */
  public getSubjectBatchInfo(subject_ids: string, callback: VHSubjectInfoCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_SUBJECT_IDS, subject_ids);

    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_SUBJECT_BATCH_INFO, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let subjectList: VHSubjectList = data as VHSubjectList;
              callback.onSucceed(subjectList);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * 获取活动信息
   * @param webinar_ids 活动 ID, 多个用英文逗号分隔
   * @param callback 专题信息
   */
  public getWebinarInfo(webinar_ids: string, callback: VHWebinarInfoCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_IDS, webinar_ids);

    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_WEBINAR_INFO, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let webinarList: VHWebinarList = data as VHWebinarList;
              callback.onSucceed(webinarList);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * 观看端-领奖页-获取领奖页信息
   * @param webinar_id 活动 ID
   * @param interact_reward_id 互动有礼id
   */
  public getReceiveAwardSetting(webinarId: number, interact_reward_id: number,
    callback: VHInteractAwardSettingCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId.toString());
    params.set(ApiKeyConstants.KEY_INTERACT_REWARD_ID, interact_reward_id.toString());
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_RECEIVE_AWARD_SETTING, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let wards: VHInteractAwardSetting = data as VHInteractAwardSetting;
              wards.json_data = JSON.parse(data["json_data"]) as VHGiftAwardFiled[];
              callback.onSucceed(wards);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * 互动有礼 -保存中奖人领奖信息
   * @param room_id 房间ID
   * @param lottery_user_name 中奖人姓名
   * @param lottery_user_phone 中奖人手机号
   * @param lottery_user_remark 备注
   * @param interact_reward_id 互动有礼id
   */
  public saveInteractAward(room_id: string, interact_reward_id: number, lottery_user_name: string,
    lottery_user_phone: string,
    lottery_user_remark: string, callback: VHCallBack) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ROOM_ID, room_id.toString());
    params.set(ApiKeyConstants.KEY_LOTTERY_USER_NAME, lottery_user_name);
    params.set(ApiKeyConstants.KEY_LOTTERY_USER_PHONE, lottery_user_phone);
    params.set(ApiKeyConstants.KEY_LOTTERY_USER_REMARK, lottery_user_remark);
    params.set(ApiKeyConstants.KEY_INTERACT_REWARD_ID, interact_reward_id.toString());
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_SAVE_AWARD_INFO, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              callback.onSuccess("success");
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * 互动有礼 观看端-抽奖-获取中奖人信息
   * @param room_id 房间ID
   */
  public getInteractAwardWinnerInfo(room_id: string, callback: VHInteractWinnerInfoCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ROOM_ID, room_id.toString());
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_INTERACT_WINNER_INFO, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let info: VHInteractWinnerInfo = data as VHInteractWinnerInfo;
              callback.onSuccess(info);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * 互动有礼 -问卷关联的我的礼品列表
   * @param pos 列表起始位置
   * @param limit 个数
   */
  public getInteractAwardList(pos: number, limit: number, callback: VHInteractMyAwardListCallback) {
    if (pos < 0) {
      pos = 0;
    }
    if (limit < 0) {
      limit = 20;
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_POS, pos.toString());
    params.set(ApiKeyConstants.KEY_LIMIT, limit.toString());
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_MY_AWARD_LIST, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let info: VHInteractMyAward = data as VHInteractMyAward;
              info.pos = pos;
              info.limit = limit;
              callback.onSuccess(info);
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * 获取排行榜列表 v1版本
   * @param source_id 数据来源id
   * @param source_type 数据来源id 类型 1.活动 2.落地页
   * @param invite_id 邀请人id

   * @param post 数据开始位置
   * @param limit 获取的条数
   * @param callback 返回排行榜列表
   */
  public getInviteTopList(sourceId: string, inviteId: string, post: string, limit: string,
    callback: VHInviteTopListCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_SOURCE_ID, sourceId);
    params.set(ApiKeyConstants.KEY_SOURCE_TYPE, "1");
    params.set(ApiKeyConstants.KEY_POS, post);
    params.set(ApiKeyConstants.KEY_LIMIT, limit);
    params.set(ApiKeyConstants.KEY_INVITE_ID, inviteId);
    //   * @param invite_id_type 邀请人id类型 1.C端用户 2.游客 3.B端用户
    params.set(ApiKeyConstants.KEY_INVITE_ID_TYPE, "1");

    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequestWithJsonHeader(this.sdk_host + API_INTERFACE.API_GET_TOP_LIST, http.RequestMethod.POST,
      requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let topList: VHInviteTopList = data as VHInviteTopList;
              callback.onSucceed(topList);
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * 获取邀请卡片 v1版本
   * @param source_id 数据来源id
   * @param source_type 数据来源id 类型 1.活动 2.落地页
   * @param invite_id 邀请人id
   * @param business_uid b端用户id  当前活动所属用户
   * @param callback 邀请卡片
   */
  public getInviteCard(sourceId: string, inviteId: string, businessUid: string,
    callback: VHInviteCardCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_SOURCE_ID, sourceId);
    params.set(ApiKeyConstants.KEY_SOURCE_TYPE, "1");
    params.set(ApiKeyConstants.KEY_LANGUAGE_TYPE, "0");
    params.set(ApiKeyConstants.KEY_INVITE_ID, inviteId);
    //   * @param invite_id_type 邀请人id类型 SDK传1 1.C端用户 2.游客 3.B端用户
    params.set(ApiKeyConstants.KEY_INVITE_ID_TYPE, "1");
    params.set(ApiKeyConstants.KEY_BUSINESS_UID, businessUid);

    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequestWithJsonHeader(this.sdk_host + API_INTERFACE.API_INVITE_CARD, http.RequestMethod.POST,
      requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let inviteCard: VHInviteCard = data as VHInviteCard;
              callback.onSucceed(inviteCard);
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * 上传文件
   * @param resfile 上传的二进制流
   * @param callback 上传文件信息
   */
  public uploadImage(resFile: string, callback: VHUploadFileCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_PATH, "webinars/img_url");
    params.set(ApiKeyConstants.KEY_RESFILE, resFile);
    params.set(ApiKeyConstants.KEY_TYPE, "image");
    params.set(ApiKeyConstants.KEY_METHOD, "base64");

    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequestWithJsonHeader(this.sdk_host + API_INTERFACE.API_UPLOAD_FILE, http.RequestMethod.POST,
      requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let uploadFileInfo: VHUploadFileInfo = data as VHUploadFileInfo;
              callback.onSucceed(uploadFileInfo);
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * 下载图片
   * @param url 图片url
   * @param callback 图片数据
   */
  public downloadImage(url: string, callback: VHDownloadImageCallback) {
    let params = this.getBaseBodyParam();
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(url, http.RequestMethod.GET, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              callback.onSuccess(new Uint8Array(data as ArrayBuffer));
            } catch (e) {
              if (callback) {
                callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
              }
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /***
   * @description 口令红包
   * @param room_id 房间id
   * @param red_packet_uuid  口令红包id
   * */
  public PasswordRedEnvelope(room_id: string, red_packet_uuid: string, callback: VHRedEnvelopeInfoCallback) {
    if (room_id.length == 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error');
        return;
      }
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ROOM_ID, room_id);
    params.set(ApiKeyConstants.KEY_RED_PACKET_UUID, red_packet_uuid);
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_OPEN_REDPACKET, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let redEnvelopeInfo: VHRedEnvelopeInfo = data as VHRedEnvelopeInfo;
              callback.onSuccess(redEnvelopeInfo);
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /***
   * @description 查看获取口令红包的用户详情
   * @param room_id 房间id
   * @param red_packet_uuid  口令红包id
   * @param pos  页码
   * @param limit  每页数量
   * @param order_type  排序方式（创建时间） asc-正序 ， desc-倒序
   * */
  public RedEnvelopeUserList(room_id: string, red_packet_uuid: string,
    callback: VHRedEnvelopeUserListInfoCallback) {
    if (room_id.length == 0) {
      if (callback) {
        callback.onFailure(-1, 'input param error');
        return;
      }
    }
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ROOM_ID, room_id);
    params.set(ApiKeyConstants.KEY_RED_PACKET_UUID, red_packet_uuid);
    // params.set(ApiKeyConstants.KEY_POS, pos);
    // params.set(ApiKeyConstants.KEY_LIMIT, limit);
    // params.set(ApiKeyConstants.KEY_ORDER_TYPE, order_type);
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_REDPACKET_PARTITION_RECORDER, http.RequestMethod.GET, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let redEnvelopeUserListInfo: VHRedEnvelopeUserListInfo = data as VHRedEnvelopeUserListInfo;
              callback.onSuccess(redEnvelopeUserListInfo);
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }


  /**
   * @description 获取直播活动详情地址
   * @param webinarId 直播id
   * @param userId 用户id
   * @param inviteCode 邀请码
   * @returns
   */
  public getLiveDetailUrl(webinarId: string, userId: string, inviteCode: string): string {
    return this.live_host + API_INTERFACE.API_LIVE_DETAIL + webinarId + '?invite_code=' + inviteCode +
      '&invite_way=1&shareId=v-' + userId + '-1';
  }

  /***
   * @description 获取直播活动详情地址
   * @param subjectInfoId 专题id
   * */
  public getSubjectDetailUrl(subjectInfoId: string): string {
    return this.live_host + API_INTERFACE.API_SUBJECT_DETAIL + subjectInfoId + '&delay=0';
  }

  public getHostUrl(): string {
    return this.live_host;
  }


  /**
   * 观看端-我的邀请明细
   * @param sourceId 数据来源id
   * @param inviteId 邀请人id
   * @param businessUid B端用户id
   * @param inviteIdType 邀请人id类型
   * @param callback
   */
  public getMyInviteDetails(sourceId: string, inviteId: string, businessUid: string, inviteIdType: string,
    callback: VHMyInviteDetailListCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_SOURCE_ID, sourceId);
    params.set(ApiKeyConstants.KEY_SOURCE_TYPE, "1");
    params.set(ApiKeyConstants.KEY_BUSINESS_UID, businessUid);
    params.set(ApiKeyConstants.KEY_INVITE_ID, inviteId);
    params.set(ApiKeyConstants.KEY_INVITE_ID_TYPE, inviteIdType);

    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequestWithJsonHeader(this.sdk_host + API_INTERFACE.API_GET_MY_INVITE_DETAILS, http.RequestMethod.POST,
      requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let detailList: VHMyInviteDetailList = data as VHMyInviteDetailList;
              callback.onSucceed(detailList);
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }


  /**
   * 观看端-我的邀请明细下载URL
   * @param sourceId 数据来源id
   * @param inviteId 邀请人id
   * @param businessUid B端用户id
   * @param inviteIdType 邀请人id类型
   * @param callback
   */
  public getMyInviteDetailUrl(sourceId: string, inviteId: string, businessUid: string, inviteIdType: string,
    callback: VHCallBack) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_SOURCE_ID, sourceId);
    params.set(ApiKeyConstants.KEY_SOURCE_TYPE, "1");
    params.set(ApiKeyConstants.KEY_BUSINESS_UID, businessUid);
    params.set(ApiKeyConstants.KEY_INVITE_ID, inviteId);
    params.set(ApiKeyConstants.KEY_INVITE_ID_TYPE, inviteIdType);

    let headers = this.getBaseHeaderParam();
    let requestParam = this.getSignParam(params);
    HttpNetRequestWithJsonHeader(this.sdk_host + API_INTERFACE.API_GET_MY_INVITE_DETAILS_URL, http.RequestMethod.POST,
      requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              callback.onSuccess(data['details_url'] as string);
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }

  /**
   * 观看端-获取用户提交的答案
   * @param surveyId 问卷id
   * @param callback
   */
  public getSurveyAnswerReplay(surveyId: string, callback: VHSurveyAnswerReplayCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_SURVEY_ID, surveyId);
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_SURVEY_ANSWER_REPLAY, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let answerReplayList: VHSurveyAnswerReplayList = data as VHSurveyAnswerReplayList;
              callback.onSuccess(answerReplayList);
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  public getDefaultAvatar() {
    return API_INTERFACE.API_GET_DEFAULT_AVATAR;
  }

  /**
   * 观看端-设置问卷同问
   * @param webinarId 直播id
   * @param questionId 问题id
   * @param likeStatus 1:点赞 0:取消点赞
   * @param callback
   */
  public setQaLike(webinarId: string, questionId: string, likeStatus: string, callback: VHCallBack) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_QUESTION_ID, questionId);
    params.set(ApiKeyConstants.KEY_LIKE_STATUS, likeStatus);
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId);
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_QA_SET_LIKE, http.RequestMethod.POST, requestParam, headers,
      {
        onSuccess: (data) => {
          if (callback) {
            console.log('设置问卷同问成功');
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * 获取最新发布的问卷
   * @param room_id 房间id
   * @param start_time 对应场次的 开始时间。如果直播则为场次开始时间
   * @param end_time 对应场次的 结束时间。如果为直播传入空值
   * @param playback_filling 是否开启 回放填写 是 1 否 0
   * **/
  public getLastPublishWebinarSurvey(room_id: string, start_time: string, end_time: string,playback_filling:number,
    callback: VHLastPublishWebinarSurveyCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_ROOM_ID, room_id);
    params.set(ApiKeyConstants.KEY_START_TIME, start_time);
    params.set(ApiKeyConstants.KEY_PLAYBACK_FILLING, playback_filling.toString());
    if (end_time.length == 0) {
      params.set(ApiKeyConstants.KEY_START_TIME, "0000-00-00 00:00:00");
    } else {
      params.set(ApiKeyConstants.KEY_START_TIME, end_time);
    }
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_WEBINAR_SURVEY, http.RequestMethod.GET, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let survey: VHWebinarSurvey = data as VHWebinarSurvey;
              callback.onSuccess(survey);
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * 观看端-获取问答推荐列表
   * @param webinarId 直播id
   * @param callback
   */
  public getQaRecommendList(webinarId: string, roomId: string,
    callback: VHQaRecommendListCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinarId);
    params.set(ApiKeyConstants.KEY_ROOM_ID, roomId);
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_QA_RECOMMEND_LIST, http.RequestMethod.GET, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let qaRecommendList: VHQaRecommendList = data as VHQaRecommendList;
              callback.onSuccess(qaRecommendList);
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * 观看端-获取房间状态
   * @param webinarSwitchId  场次id
   * @param webinarId 直播id
   * @param callback
   */
  public getRoomStatus(webinarSwitchId: string, roomId: string,
    callback: VHRoomStatusCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_SWITCH_ID, webinarSwitchId);
    params.set(ApiKeyConstants.KEY_ROOM_ID, roomId);
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequest(this.sdk_host + API_INTERFACE.API_GET_ROOM_STATUS, http.RequestMethod.POST, requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let roomToolsStatusData: RoomToolsStatusData = data as RoomToolsStatusData;
              callback.onSuccess(roomToolsStatusData);
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      })
  }

  /**
   * @description 获取回放状态下的回放列表
   * @param webinar_id 活动id
   * */
  public getWatchList(webinar_id: number, callback: VHWatchListCallback) {
    let params = this.getBaseBodyParam();
    params.set(ApiKeyConstants.KEY_WEBINAR_ID, webinar_id.toString());
    let requestParam = this.getSignParam(params);
    let headers = this.getBaseHeaderParam();
    HttpNetRequestWithJsonHeader(this.sdk_host + API_INTERFACE.API_GET_WATCH_LIST, http.RequestMethod.POST,
      requestParam,
      headers,
      {
        onSuccess: (data) => {
          if (callback) {
            try {
              let toData: string = JSON.stringify(data);
              if (data && data !== undefined) {
                if (JSON.has(data as object, "list")) {
                  let callbackData: VHWebinarRecordWatch[] = data["list"] as VHWebinarRecordWatch[];
                  callback.onSucceed(callbackData);
                } else {
                  callback.onSucceed([])
                }
              } else {
                callback.onSucceed([])
              }
            } catch (e) {
              callback.onFailure(VHConstants.VH_ANALYSIS_DATA_ERROR, 'analysis error');
            }
          }
        },
        onFailure: (errorCode, errorMsg) => {
          if (callback) {
            callback.onFailure(errorCode, errorMsg);
          }
        }
      }
    )
  }
}




