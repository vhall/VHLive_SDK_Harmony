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

  public doInitWatch(id: string,record_id:string, nickname: string, callback: VHWatchWebinarInfoCallback) {
    VHSaaSDK.getInstance().initWatch(id, record_id, "", nickname, {
      onSucceed: (data: VHWebinarData) => {
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