import { VHExamPersonalReport, VHExamReportList, VHExamUserAnswerStatus } from './exam/examData';
import { VHLotteryResultNoticeModel } from './lottery/VHLotteryMessageCallback';
import { VHGiftList } from './model/VHGiftInfo';
import {
  RoomLikeInfo,
  VHCardInfo,
  VHDoingSignInfo,
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
import {
  FilesList,
  PrivacyAgreementInfo,
  RoomToolsStatusData,
  VHAdvDefault,
  VHAgreementModel,
  VHAIMediaInfo,
  VHAnnouncementNewsList,
  VHChatMessageList,
  VHCommonConfig,
  VHConfigList,
  VHCouponInfo,
  VHCreateOrderInfo,
  VHExamList,
  VHGoodsActivitySettings,
  VHGoodsListData,
  VHHistoryQuestionnaireInfo,
  VHInviteCard,
  VHInviteTopList,
  VHLotteryCarryOut,
  VHLotteryList,
  VHMarketingPublicAccount,
  VHMenuInfo,
  VHMyInviteDetailList,
  VHNotAvailableCouponInfo,
  VHPlayerConfig,
  VHQaRecommendList,
  VHRoleName,
  VHSubjectList,
  VHSurveyAnswerReplayList,
  VHUploadFileInfo,
  VHWatchAuthInfo,
  VHWebinarData,
  VHWebinarList,
  VHWebinarSurvey,
  VHWebinarRecordWatch,
  VHWinnerInformation,
  VHRedPacketStatus,
  VHGoodsInfo,
  VHAISummaryModel,
  VHAIHighlightModel,
} from './model/VHWatchWebinarInfo';
import { VHGetSignData, VHSignData } from './sign/VHSignMessageCallback';

export interface VHCallBack {
  // 成功
  onSuccess: (data: string | object) => void;

  // 失败
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHWatchAuthQueryCallback {
  onSucceed: (data: VHWatchAuthInfo) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHWatchWebinarInfoCallback {
  onSucceed: (data: VHWebinarData) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHPlayerConfigCallback {
  onSucceed: (data: VHPlayerConfig) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHConfigListCallback {
  onSucceed: (data: VHConfigList) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHAISummaryModelCallback {
  onSucceed: (data: VHAISummaryModel) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHAIHighlightCallback {
  onSucceed: (data: VHAIHighlightModel[]) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}



export interface VHAgreementModelCallback {
  onSucceed: (data: VHAgreementModel) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHWebinarStateCallback {
  /**
   * @param 1 直播中 2 预约中 3 直播结束 4 当前为点播 5 结束且有回放
   * **/
  onSucceed: (data: number) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHCommonConfigCallback {

  onSucceed: (data: VHCommonConfig) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHRoleNameCallback {
  onSucceed: (data: VHRoleName) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHGetRedPacketCallback {
  onSucceed: (data: VHRedPacketStatus) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHChatMessageListCallback {

  onSucceed: (data: VHChatMessageList) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHGiftListCallback {
  onSucceed: (data: VHGiftList) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHAnnouncementListCallback {
  onSucceed: (data: VHAnnouncementNewsList) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHRoomLikeCallback {

  onSucceed: (data: RoomLikeInfo) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHQuestionHistoryCallback {

  onSucceed: (data: VHQuestionHistoryList) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHQuestionnaireCallback {
  onSucceed: (data: VHHistoryQuestionnaireInfo) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHWinnerInformationCallback {
  onSucceed: (data: VHWinnerInformation) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHLotteryCarryOutCallback {
  onSucceed: (data: VHLotteryCarryOut) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHLotteryListCallback {
  onSucceed: (data: VHLotteryList[]) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHFileListCallback {
  onSucceed: (data: FilesList) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHAIWatchCallback {
  onSucceed: (data: VHAIMediaInfo) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHPushCardCallback {
  onSucceed: (data: VHCardInfo[]) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHPushCardInformationCallback {
  onSucceed: (data: VHCardInfo) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHExamListCallback {
  onSucceed: (data: VHExamList[]) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHWatchListCallback {
  onSucceed: (data: VHWebinarRecordWatch[]) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHPrivacyAgreementCallback {
  onSucceed: (data: PrivacyAgreementInfo) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHExamPerformanceCallback {
  onSucceed: (data: VHExamReportList) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}


export interface VHExamUserAnswerStatusCallback {
  onSucceed: (data: VHExamUserAnswerStatus) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHExamPersonalReportCallback {
  onSucceed: (data: VHExamPersonalReport) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHWatchGiftCallback {
  onSucceed: (data: VHWatchGiftInfo | null) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHWatchGiftAwardListCallback {
  onSucceed: (data: VHWatchGiftAward) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}


export interface VHGoodsListCallback {
  onSucceed: (data: VHGoodsListData[]) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHCouponsAvailableCallback {
  onSucceed: (data: VHCouponInfo[]) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHCouponsNotAvailableCallback {
  onSucceed: (data: VHNotAvailableCouponInfo[]) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHGoodsActivitySettingsCallback {
  onSucceed: (data: VHGoodsActivitySettings) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHWatchGiftParticipateCallback {
  onSucceed: (data: VHWatchGiftParticipate) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHWatchGiftWinnerDetailCallback {
  onSucceed: (data: VHWatchGiftWinnerDetail) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHWatchGiftAwardSettingCallback {
  onSucceed: (data: VHWatchGiftSetting) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHAdvCallback {
  onSucceed: (data: VHAdvDefault) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}


export interface VHWatchGiftWinnersCallback {
  onSucceed: (data: VHWinner) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}


export interface VHMenuInfoCallback {
  onSucceed: (data: VHMenuInfo) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHCreateOrderCallback {
  onSucceed: (data: VHCreateOrderInfo) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHVHMarketingPublicAccountCallback {
  onSucceed: (data: VHMarketingPublicAccount) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHSubjectInfoCallback {
  onSucceed: (data: VHSubjectList) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHWebinarInfoCallback {
  onSucceed: (data: VHWebinarList) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHInteractAwardSettingCallback {
  onSucceed: (data: VHInteractAwardSetting) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHInviteTopListCallback {
  onSucceed: (data: VHInviteTopList) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHInviteCardCallback {
  onSucceed: (data: VHInviteCard) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHDownloadImageCallback {
  onSuccess: (data: Uint8Array | null) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHInteractMyAwardListCallback {
  onSuccess: (data: VHInteractMyAward) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHInteractWinnerInfoCallback {
  onSuccess: (data: VHInteractWinnerInfo) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHRedEnvelopeInfoCallback {
  onSuccess: (data: VHRedEnvelopeInfo) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHRedEnvelopeUserListInfoCallback {
  onSuccess: (data: VHRedEnvelopeUserListInfo) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHUploadFileCallback {
  onSucceed: (data: VHUploadFileInfo) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHDoingSignCallback {
  onSuccess: (data: VHDoingSignInfo) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHSignInfoCallback {
  onSuccess: (data: VHGetSignData) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHMyInviteDetailListCallback {
  onSucceed: (data: VHMyInviteDetailList) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHSurveyAnswerReplayCallback {
  onSuccess: (data: VHSurveyAnswerReplayList) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHQaRecommendListCallback {
  onSuccess: (data: VHQaRecommendList) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHGoodsInfoCallback {
  onSuccess: (data: VHGoodsInfo[]) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHLastPublishWebinarSurveyCallback {
  onSuccess: (data: VHWebinarSurvey) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}

export interface VHRoomStatusCallback {
  onSuccess: (data: RoomToolsStatusData) => void;
  onFailure: (errorCode: number, errorMsg: string) => void;
}




