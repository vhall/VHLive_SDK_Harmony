import {
  VHDataDownloadUpdateMsg,
  VHFileConfigMsg,
  VHFilesInfo,
  VHFilesList,
  VHRoomEventType,
  VHSaaSDK,
  VHSurveyAnswerReplayInfo,
  VHSurveyAnswerReplayList,
  VHSurveyInternal,
  VHWebinarData
} from '@vhall/vhall_live';
import { ToastUtil } from '../../action/ToastUtil';
import ChatTools from '../../util/ChatTools';
import { EmitterMsgData, EmitterUtil } from '../../util/EmitterUtil';
import { VHQuestionnaireDialog } from './VHQuestionnaireDialog';

@Component
export struct VHDownLoadFileComponent {
  @Require webinars: VHWebinarData;
  @Require menusId:string;
  @State filesList: VHFilesInfo[] = [];
  @State answerReplayInfoList:  VHSurveyAnswerReplayInfo[] = []
  @State fileDownLoadUrl:string='';
  @State config: VHFileConfigMsg = new VHFileConfigMsg;
  private scroller: Scroller = new Scroller();
  @State questionnaireUrl: string='';
  @State resultMessage: string = '';
  @State selectedFileId: string = '';
  private pageInfos: NavPathStack = new NavPathStack();
  aboutToAppear(): void {
   this.getFilesList();
   this.subscribeDataDownloadUpdateMsg();
  }

  aboutToDisappear(): void {

  }

  VHQuestionnaireDialog = new CustomDialogController({
    builder: VHQuestionnaireDialog({
      surveyQuestionnaireUrl: this.questionnaireUrl,
      onResult: (result: string) => {
        // 从子页面传递回来的结果数据
        console.log("提交问答接收到的结果数据:", result);
        if (result == "success") {
          ToastUtil.showToast("问答提交成功！")
          this.getFileDownLoadUrl(this.selectedFileId);
        } else {
          ToastUtil.showToast("问答提交失败！");
        }
      }
    }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })

  surveyQuestionnaire(surveyId: string,fileId: string) {
    this.questionnaireUrl = VHSurveyInternal.getSurveyUrl(this.webinars!, surveyId) as string;
    this.VHQuestionnaireDialog.open();
  }

  // 处理问卷返回结果
  private handleQuestionnaireResult(popInfo: PopInfo, fileId: string) {
    // 从PopInfo的result属性获取返回数据
    const result = popInfo.result as string;
    console.log("问卷提交结果:", result);
    if (result === 'success') {
      ToastUtil.showToast("问答提交成功！");
      // 执行成功后的逻辑
      this.getFileDownLoadUrl(fileId);
    } else {
      ToastUtil.showToast("问答提交失败！");
    }
  }

  subscribeDataDownloadUpdateMsg() {
    EmitterUtil.subscribe(VHRoomEventType.DATA_DOWNLOAD_UPDATE, (msgData: EmitterMsgData) => {
      console.log(`收到文件下载更新消息，类型：${VHRoomEventType.DATA_DOWNLOAD_UPDATE}`);
      let updateMsg: VHDataDownloadUpdateMsg = msgData.data as VHDataDownloadUpdateMsg;
      if (updateMsg!) {
        if (typeof updateMsg === 'string') {
          const parsedMessage: VHDataDownloadUpdateMsg = JSON.parse(updateMsg) as VHDataDownloadUpdateMsg;
          this.menusId = parsedMessage.menu_id;
          this.config = parsedMessage.config;
          this.getFilesList();
        } else {
          this.menusId = updateMsg.menu_id;
          this.config = updateMsg.config;
          this.getFilesList();
        }
      }
    });
  }

  getFilesList() {
    VHSaaSDK.getInstance()
      .getFilesList(this.webinars?.webinar!.id.toString(), this.menusId, {
        onSucceed: (data: VHFilesList) => {
          this.filesList = data?.list;
          if (data != null && data.config !== undefined) {
            this.config = data.config as VHFileConfigMsg;
          }
        },
        onFailure: (errorCode, errorMsg) => {
          console.log("获得聊天列表失败：", errorMsg)
          ToastUtil.showToast(errorMsg);
        }
      });
  }

  getSurveyAnswerReplay(surveyId: string,fileId: string, formAllowDownload: number) {
    VHSaaSDK.getInstance()
      .getSurveyAnswerReplay(surveyId, {
        onSuccess: (data: VHSurveyAnswerReplayList) => {
          this.answerReplayInfoList = data?.answer_replay_list;
          if (this.answerReplayInfoList.length > 0 && formAllowDownload == 1) {
            // 如果有用户提交答案，及设置了已填写表单无需重复填写，则直接下载文件
            this.getFileDownLoadUrl(fileId);
          } else {
            // 如果没有用户提交答案，则开启webview让用户填写问卷，完成后再下载文件
            this.surveyQuestionnaire(surveyId, fileId);
          }
        },
        onFailure: (errorCode, errorMsg) => {
          console.log("获得获取用户提交的答案列表失败：", errorMsg)
          ToastUtil.showToast(errorMsg);
        }
      });
  }

  getFileDownLoadUrl(fileId: string) {
    VHSaaSDK.getInstance()
      .getFileDownLoadUrl(this.webinars?.webinar!.id.toString(), this.menusId, fileId,
        this.webinars?.join_info!.user_id.toString(), {
          onSuccess: (data: string | object) => {
            this.fileDownLoadUrl = data as string;
            ToastUtil.showToast("下载文件URL:" + this.fileDownLoadUrl);
          },
          onFailure: (errorCode, errorMsg) => {
            console.log("获得下载url失败：", errorMsg);
            ToastUtil.showToast("下载文件失败:" + errorMsg);
          }
        });
  }

  build() {
    Navigation(this.pageInfos) {
    Column() {
      List({ scroller: this.scroller }) {
        ForEach(this.filesList, (item: VHFilesInfo, index) => {
          ListItem() {
            Row() {
              Text(ChatTools.getLimitString(item.file_name, 10)).fontSize(12)
              Text(item.file_size + "/" + item.file_ext).fontSize(12)
            }
            .padding({ left: 8, right: 8 })
            .width('100%')
            .height(40)
            .justifyContent(FlexAlign.SpaceBetween)
            .backgroundColor('#FAFAFA')
            .onClick(() => {
              if (this.config !== null) {
                this.selectedFileId = item.file_id;
                if (this.config.where == '1') {
                  // 下载条件 0:无条件 1:问卷 2:登入 3:设置观看时长  目前只限制问卷
                  this.getSurveyAnswerReplay(this.config.where_content, item.file_id, this.config.form_allow_download)
                } else {
                  this.getFileDownLoadUrl(item.file_id);
                }
              }
            })
          }

          // 分隔线
          if (index <= this.filesList.length - 1)
            Divider()
              .height(1)
              .color('#555555')
              .margin({ left: 8, right: 8 })
        }, (item: VHFilesInfo) => item.file_id)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
   }
  }
}

