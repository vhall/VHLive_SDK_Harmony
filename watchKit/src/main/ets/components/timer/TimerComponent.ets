import { VHTimerMsg, VHTimerPauseMsg, VHRoomEventType } from '@vhall/vhall_live';
import { EmitterMsgData, EmitterUtil } from '../../util/EmitterUtil';
/**
 * 计时器界面
 *
 */
@Component
export struct TimerComponent {
  // 倒计时总时长(秒)，用于递减模式
  @Prop totalSeconds: number = 60;
  @Link showTimerDialog: boolean;
  @Link isTimerShow: boolean;
  @State statusPrompt: string = '';
  // 当前时间(秒)
  @State currentSeconds: number = 0;
  // 倒计时状态
  @State isRunning: boolean = false;
  // 模式：true为递增，false为递减
  @State isIncrementing: boolean = false;
  // 记录是否是暂停状态（用于区分初始状态和暂停状态）
  @State isPaused: boolean = false;
  @Consume timerMsg: VHTimerMsg;
  @State timerPauseMsg: VHTimerPauseMsg | null = null;
  @State timerData: VHTimerMsg | null = null;
  @State minTens: number = 0;
  @State minUnits: number = 0;
  @State secTens: number = 0;
  @State secUnits: number = 0;
  @State isTimeout: string = '0';
  @State remainTime: number = 0;
  @State statusPromptColor: ResourceColor = Color.Green;
  // 计时器ID
  private timerId: number = -1;


  aboutToAppear() {
    this.init();
    this.subscribeStartTimer();
    this.subscribeResumeTimer();
    this.subscribeResetTimer();
    this.subscribePauseTimer();
    this.subscribeEndTimer();
  }

  /**
   * 界面被销毁时被调用。
   */
  aboutToDisappear() {
    this.stopTimer();
    this.unsubscribeMsg();
  }

  unsubscribeMsg() {
    EmitterUtil.unsubscribe(VHRoomEventType.TIMER_START);
    EmitterUtil.unsubscribe(VHRoomEventType.TIMER_RESUME);
    EmitterUtil.unsubscribe(VHRoomEventType.TIMER_RESET);
    EmitterUtil.unsubscribe(VHRoomEventType.TIMER_PAUSE);
    EmitterUtil.unsubscribe(VHRoomEventType.TIMER_END);
  }

  // 构造方法，允许自定义参数
  init() {
    if (this.totalSeconds && this.totalSeconds > 0) {
      this.currentSeconds = this.totalSeconds;
      this.getTimeDigits(this.currentSeconds);
    }
    if (this.timerMsg != null) {
      this.initTimerMsg(this.timerMsg);
    }
  }

  // 关闭窗口
  private closeDialog() {
    this.stopTimer();
    this.unsubscribeMsg();
    this.showTimerDialog = false;
  }

  // 获取时分秒的各个数字
  // 获取时分秒的各个数字，返回明确接口类型
  getTimeDigits(seconds: number) {
    // 处理超过59分59秒的情况
    const mins = Math.floor(seconds / 60) % 60;
    const secs = seconds % 60;
    this.minTens = Math.floor(mins / 10);
    this.minUnits = mins % 10;
    this.secTens = Math.floor(secs / 10);
    this.secUnits = secs % 10;
  }

  // 开始计时（从初始状态）
  private startTimer() {
    if (this.isRunning) return;
    // 开始是从初始状态启动，需要重置当前时间
    this.currentSeconds = this.isIncrementing ? 0 : this.totalSeconds;
    this.resumeTimer();
  }

  // 继续计时（从暂停状态恢复,根据当前模式决定递增或递减）
  private resumeTimer() {
    if (this.isRunning) {
      return;
    }
    this.isRunning = true;
    this.isPaused = false;
    if (this.isIncrementing) {
      this.statusPrompt = '超时，' + "开始正向计时";
      this.statusPromptColor = Color.Red;
    } else {
      this.statusPrompt = this.getTimePrompt()  + "倒计时进行中...";
      this.statusPromptColor = Color.Green;
    }

    // 计时回调函数
    // 使用ArkTS推荐的计时器实现方式
    const intervalCallback = () => {
      if (this.isIncrementing) {
        this.currentSeconds += 1;
      } else {
        if (this.currentSeconds <= 0) {
          if (this.isTimeout === '0') {
            this.statusPrompt = this.getTimePrompt() + "倒计时已结束";
            this.statusPromptColor = Color.Red;
            this.closeDialog();
            this.isTimerShow=false;
          } else if (this.isTimeout === '1') {
            this.toggleMode();
          }
        } else {
          this.currentSeconds -= 1;
        }
      }
      // 自动触发UI更新
      this.getTimeDigits(this.currentSeconds);
    };
    // 立即执行一次，避免1秒延迟
    // intervalCallback();
    try {
      this.timerId = setInterval(intervalCallback, 1000);
    } catch (error) {
      console.error(`设置计时器失败: ${error.message}`);
      this.isRunning = false;
    }
  }

  // 暂停计时
  private stopTimer() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    if (this.isIncrementing) {
      this.statusPrompt = '超时，' + "开始正向计时";
      this.statusPromptColor = Color.Orange;
    } else {
      this.statusPrompt = this.getTimePrompt()  + "倒计时已暂停";
      this.statusPromptColor = Color.Orange;
    }
    this.isRunning = false;
    this.isPaused = true; // 标记为暂停状态
  }


  // 重置计时
  private resetTimer() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    this.isRunning = false;
    this.isPaused = false;
    // 根据当前模式重置时间
    this.currentSeconds = this.isIncrementing ? 0 : this.totalSeconds;
    this.getTimeDigits(this.currentSeconds);
    this.closeDialog();
    this.isTimerShow=false;
  }

  getTimePrompt(): string {
    let prompt: string = '';
    let timeMin:number = Math.floor(this.totalSeconds / 60) % 60;
    const secs = this.totalSeconds % 60;
    const minTens = Math.floor(timeMin / 10);
    const minUnits = timeMin % 10;
    const secTens = Math.floor(secs / 10);
    const secUnits = secs % 10;
    // if (minTens != 0) {
    //   prompt = minTens.toString();
    // }
    // if (minUnits != 0) {
    //   prompt = prompt + minUnits + '分'
    // }
    if(timeMin > 0){
      prompt = timeMin.toString() + '分'
    }
    return prompt + secTens + secUnits + '秒 ';
  }

  // 切换模式（递增/递减）
  private toggleMode() {
    this.stopTimer();
    this.isIncrementing = !this.isIncrementing;
    this.isPaused = false;
    if (this.isIncrementing) {
      this.statusPrompt = '超时，' + "开始正向计时";
      this.statusPromptColor = Color.Red;
    }
    // 切换模式时重置时间
    this.currentSeconds = this.isIncrementing ? 0 : this.totalSeconds;
    this.startTimer();
  }

  initTimerMsg(timerInfo: VHTimerMsg) {
    if (typeof timerInfo === 'string') {
      this.timerData = JSON.parse(timerInfo) as VHTimerMsg;
    } else {
      this.timerData = this.timerMsg as VHTimerMsg;
    }
    this.isTimeout = this.timerData.is_timeout;
    if (this.timerData.remain_time !== undefined) {
      this.remainTime = this.timerData.remain_time;
      this.currentSeconds = Math.abs(this.remainTime);
      this.getTimeDigits(this.currentSeconds);
      if (this.timerData.remain_time < 0) {
        this.isIncrementing = true;
      }
    }
    if (this.timerData.type === VHRoomEventType.TIMER_START) {
      this.startTimer();
    }
    if (this.timerData.type === VHRoomEventType.TIMER_PAUSE) {
      let timerInfo: VHTimerPauseMsg = this.timerData as VHTimerPauseMsg;
      this.initTimerPauseMsg(timerInfo);
      this.stopTimer();
    }
    if (this.timerData.type === VHRoomEventType.TIMER_RESUME) {
      this.resumeTimer();
    }
  }

  initTimerPauseMsg(timerInfo: VHTimerPauseMsg) {
    // 暂停功能
    if (typeof timerInfo === 'string') {
      this.timerPauseMsg = JSON.parse(timerInfo) as VHTimerPauseMsg;
    } else {
      this.timerPauseMsg = timerInfo;
    }
    if (this.timerPauseMsg.remain_time !== undefined) {
      this.remainTime = this.timerPauseMsg.remain_time;
      this.currentSeconds = Math.abs(this.remainTime);
      if (this.timerPauseMsg.remain_time < 0) {
        this.isIncrementing = true;
      }
    }
  }

  // 启动计时器
  subscribeStartTimer() {
    EmitterUtil.unsubscribe(VHRoomEventType.TIMER_START);
    EmitterUtil.subscribe(VHRoomEventType.TIMER_START, (msgData: EmitterMsgData) => {
      console.log(`启动计时器，类型：${VHRoomEventType.TIMER_START}`);
      let timerInfo: VHTimerMsg = msgData.data as VHTimerMsg;
      this.initTimerMsg(timerInfo);
      this.startTimer();
    });
  }

  subscribeResumeTimer() {
    EmitterUtil.unsubscribe(VHRoomEventType.TIMER_RESUME);
    EmitterUtil.subscribe(VHRoomEventType.TIMER_RESUME, (msgData: EmitterMsgData) => {
      console.log(`继续计时器，类型：${VHRoomEventType.TIMER_RESUME}`);
      let timerInfo: VHTimerMsg = msgData.data as VHTimerMsg;
      this.initTimerMsg(timerInfo);
      this.resumeTimer();
    });
  }

  subscribeResetTimer() {
    EmitterUtil.unsubscribe(VHRoomEventType.TIMER_RESET);
    EmitterUtil.subscribe(VHRoomEventType.TIMER_RESET, (msgData: EmitterMsgData) => {
      console.log(`重置计时器，类型：${VHRoomEventType.TIMER_RESET}`);
      let timerInfo: VHTimerMsg = msgData.data as VHTimerMsg;
      this.initTimerMsg(timerInfo);
      this.resetTimer();
    });
  }

  subscribePauseTimer() {
    EmitterUtil.unsubscribe(VHRoomEventType.TIMER_PAUSE);
    EmitterUtil.subscribe(VHRoomEventType.TIMER_PAUSE, (msgData: EmitterMsgData) => {
      console.log(`暂停计时器，类型：${VHRoomEventType.TIMER_PAUSE}`);
      let timerInfo: VHTimerPauseMsg = msgData.data as VHTimerPauseMsg;
      this.initTimerPauseMsg(timerInfo);
      this.getTimeDigits(this.currentSeconds);
      this.stopTimer();
    });
  }

  subscribeEndTimer() {
    EmitterUtil.unsubscribe(VHRoomEventType.TIMER_END);
    EmitterUtil.subscribe(VHRoomEventType.TIMER_END, (msgData: EmitterMsgData) => {
      console.log(`结束计时器，类型：${VHRoomEventType.TIMER_END}`);
      let timerInfo: VHTimerPauseMsg = msgData.data as VHTimerPauseMsg;
      this.initTimerPauseMsg(timerInfo);
      this.resetTimer();
    });
  }


  build() {
    Column() {
      Row() {
        Column() {
          Row() {
            Text(this.statusPrompt)
              .fontSize(12)
              .fontColor(this.statusPromptColor)
          }
        }
        .flexGrow(1) // 占满剩余空间，让关闭按钮靠右

        // 关闭按钮
        Text('×')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#666666')
          .width(30)
          .height(30)
          .textAlign(TextAlign.Center)
          .borderRadius(15)
          .onClick(() => {
            this.closeDialog();
          })
          .hoverEffect(HoverEffect.Highlight) // 鼠标悬停效果
      }
      .width('100%')
      .height(30)
      .alignItems(VerticalAlign.Center)

      // 倒计时显示区域 - 灰色背景
      Row() {
        // 分钟十位
        Text(this.minTens.toString())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isIncrementing?'#FF0000':Color.Black)
          .backgroundColor(Color.White)
          .width(30)
          .height(40)
          .textAlign(TextAlign.Center)
          .borderRadius(8)
          .shadow({ radius: 2, color: '#33000000' })
          .margin({ right: 4 })
        Text(this.minUnits.toString())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isIncrementing?'#FF0000':Color.Black)
          .backgroundColor(Color.White)
          .width(30)
          .height(40)
          .textAlign(TextAlign.Center)
          .borderRadius(8)
          .shadow({ radius: 2, color: '#33000000' })
          .margin({ right: 4 })
        Text(':')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isIncrementing?'#FF0000':Color.Black)
          .margin({ left: 4, right: 4 })
        Text(this.secTens.toString())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isIncrementing?'#FF0000':Color.Black)
          .backgroundColor(Color.White)
          .width(30)
          .height(40)
          .textAlign(TextAlign.Center)
          .borderRadius(8)
          .shadow({ radius: 2, color: '#33000000' })
          .margin({ right: 4 })
        Text(this.secUnits.toString())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isIncrementing?'#FF0000':Color.Black)
          .backgroundColor(Color.White)
          .width(30)
          .height(40)
          .textAlign(TextAlign.Center)
          .borderRadius(8)
          .shadow({ radius: 2, color: '#33000000' })
          .margin({ right: 4 })
      }
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor('#AAAAAA')
      .borderRadius(12)
      .margin({ bottom: 10 })
      .width('auto')
    }
    .width(220)
    .height(110)
    .padding(8)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 10, color: '#33000000', offsetX: 2, offsetY: 2 })
  }
}