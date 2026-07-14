import {
  VHCallBack,
  VHSaaSDK,
  VHWatchAuthInfo,
  VHWebinarData,
  VHWatchAuthQueryCallback,
  VHWatchWebinarInfoCallback,
  VHPlayerConfigCallback,
  VHPlayerConfig
} from "@vhall/vhall_live";

export class VHWebinarWatchModel {
  private webinar_id: string = ""; //活动id
  private is_auth_check: boolean = true;

  VHWebinarWatchModel() {

  }

  public doGetPlayerConfig(id: string, callback: VHPlayerConfigCallback) {
    VHSaaSDK.getInstance().getPlayerConfig(id, {
      onSucceed: (data: VHPlayerConfig) => {
        if (callback) {
          callback.onSucceed(data);
        }
      },
      onFailure: (errorCode, errorMsg) => {
        if (callback) {
          callback.onFailure(errorCode, errorMsg);
        }
      }
    });
  }
}