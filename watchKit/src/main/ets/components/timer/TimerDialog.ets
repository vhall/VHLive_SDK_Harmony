import { TimerMsg, TimerPauseMsg, VHRoomEventType } from '@vhall/vhall_live';
import { EmitterMsgData, EmitterUtil } from '../../util/EmitterUtil';


@Component
export struct TimerDialog {
  // 倒计时总时长(秒)，用于递减模式
  @Require totalSeconds: number = 60;
  @Link showTimerDialog: boolean;
  @State statusPrompt: string = '';
  // 当前时间(秒)
  @State currentSeconds: number = 0;
  // 倒计时状态
  @State isRunning: boolean = false;
  // 模式：true为递增，false为递减
  @State isIncrementing: boolean = false;
  // 记录是否是暂停状态（用于区分初始状态和暂停状态）
  @State isPaused: boolean = false;
  @State timerMsg: TimerMsg | null = null;
  @State timerPauseMsg: TimerPauseMsg | null = null;
  @State timerData: TimerMsg | null = null;
  @State minTens: number = 0;
  @State minUnits: number = 0;
  @State secTens: number = 0;
  @State secUnits: number = 0;
  @State isTimeout: string = '0';
  @State remainTime: number = 0;
  @State statusPromptColor: ResourceColor = Color.Green;
  // 计时器ID
  private timerId: number = -1;



  aboutToAppear(): void {
    this.init();
    this.subscribeStartTimer();
    this.subscribeResumeTimer();
    this.subscribeResetTimer();
    this.subscribePauseTimer();
  }

  // 构造方法，允许自定义参数
  init() {
    if (this.totalSeconds && this.totalSeconds > 0) {
      this.currentSeconds = this.totalSeconds;
      this.getTimeDigits(this.currentSeconds);
    }
  }

  // 关闭窗口
  private closeDialog() {
    this.stopTimer();
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
    this.statusPrompt = this.totalSeconds + '秒 ' + "倒计时进行中...";
    this.statusPromptColor=Color.Green;
    this.resumeTimer();
  }

  // 继续计时（从暂停状态恢复,根据当前模式决定递增或递减）
  private resumeTimer() {
    if (this.isRunning) {
      return;
    }
    this.isRunning = true;
    this.isPaused = false;
    this.statusPrompt = this.totalSeconds + '秒 ' + "倒计时进行中...";
    this.statusPromptColor = Color.Green;
    // 计时回调函数
    // 使用ArkTS推荐的计时器实现方式
    const intervalCallback = () => {
      if (this.isIncrementing) {
        this.currentSeconds += 1;
      } else {
        if (this.currentSeconds <= 0) {
          if (this.isTimeout === '0') {
            this.statusPrompt = this.totalSeconds + '秒 ' + "倒计时已结束";
            this.statusPromptColor = Color.Red;
            this.closeDialog();
          } else if (this.isTimeout === '1') {
            this.statusPrompt = '超时，' + "开始正向计时";
            this.statusPromptColor = Color.Orange;
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
    intervalCallback();
    // 立即执行一次，避免1秒延迟
    intervalCallback();
    // 设置定时器，每秒执行一次
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
    this.statusPrompt = this.totalSeconds + '秒 ' + "倒计时已暂停";
    this.statusPromptColor=Color.Orange;
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
  }


  // 切换模式（递增/递减）
  private toggleMode() {
    this.stopTimer();
    this.isIncrementing = !this.isIncrementing;
    this.isPaused = false;
    // 切换模式时重置时间
    this.currentSeconds = this.isIncrementing ? 0 : this.totalSeconds;
    this.startTimer();
  }

  // 组件销毁时清理计时器
  aboutToDisappear() {
    this.stopTimer();
  }

  initTimerMsg(timerInfo: TimerMsg) {
    if (typeof timerInfo === 'string') {
      this.timerData = JSON.parse(timerInfo) as TimerMsg;
    } else {
      this.timerData = this.timerMsg as TimerMsg;
    }
    this.isTimeout = this.timerData.is_timeout;
    if (this.timerData.remain_time !== undefined) {
      this.remainTime = this.timerData.remain_time;
      this.currentSeconds = Math.abs(this.remainTime);
      if (this.timerData.remain_time < 0) {
        this.isIncrementing = true;
      }
    }
  }

  initTimerPauseMsg(timerInfo: TimerPauseMsg) {
    // 暂停功能
    if (typeof timerInfo === 'string') {
      this.timerPauseMsg = JSON.parse(timerInfo) as TimerPauseMsg;
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
    EmitterUtil.subscribe(VHRoomEventType.TIMER_START, (msgData: EmitterMsgData) => {
      console.log(`启动计时器，类型：${VHRoomEventType.TIMER_START}`);
      let timerInfo: TimerMsg = msgData.data as TimerMsg;
      this.initTimerMsg(timerInfo);
      this.startTimer();
    });
  }

  subscribeResumeTimer() {
    EmitterUtil.subscribe(VHRoomEventType.TIMER_RESUME, (msgData: EmitterMsgData) => {
      console.log(`继续计时器，类型：${VHRoomEventType.TIMER_RESUME}`);
      let timerInfo: TimerMsg = msgData.data as TimerMsg;
      this.initTimerMsg(timerInfo);
      this.resumeTimer();
    });
  }

  subscribeResetTimer() {
    EmitterUtil.subscribe(VHRoomEventType.TIMER_RESET, (msgData: EmitterMsgData) => {
      console.log(`继续计时器，类型：${VHRoomEventType.TIMER_RESET}`);
      let timerInfo: TimerMsg = msgData.data as TimerMsg;
      this.initTimerMsg(timerInfo);
      this.resetTimer();
    });
  }

  subscribePauseTimer() {
    EmitterUtil.subscribe(VHRoomEventType.TIMER_PAUSE, (msgData: EmitterMsgData) => {
      console.log(`继续计时器，类型：${VHRoomEventType.TIMER_PAUSE}`);
      let timerInfo: TimerPauseMsg = msgData.data as TimerPauseMsg;
      this.initTimerPauseMsg(timerInfo);
      this.stopTimer();
    });
  }




  build() {
    Column() {
      // 标题栏：标题 + 模式显示 + 关闭按钮
      Row() {
        Column() {
          Row() {
            Text(this.statusPrompt)
              .fontSize(14)
              .fontColor(this.statusPromptColor)
          }
        }
        .flexGrow(1) // 占满剩余空间，让关闭按钮靠右

        // 关闭按钮
        Text('×')
          .fontSize(25)
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
      .margin({ bottom: 20 })
      .width('100%')
      .alignItems(VerticalAlign.Center)

      // 倒计时显示区域 - 灰色背景
      Row() {
        // 分钟十位
        // this.NumberDisplay(this.minTens)
        Text(this.minTens.toString())
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF0000') // 红色数字
          .backgroundColor(Color.White) // 白色背景
          .width(60)
          .height(80)
          .textAlign(TextAlign.Center)
          .borderRadius(8)
          .shadow({ radius: 2, color: '#33000000' })
          .margin({ right: 4 })
        // this.NumberDisplay(this.minUnits)
        Text(this.minUnits.toString())
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF0000') // 红色数字
          .backgroundColor(Color.White) // 白色背景
          .width(60)
          .height(80)
          .textAlign(TextAlign.Center)
          .borderRadius(8)
          .shadow({ radius: 2, color: '#33000000' })
          .margin({ right: 4 })
        Text(':')
          .fontSize(38)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF0000')
          .margin({ left: 4, right: 4 })
        // this.NumberDisplay(this.secTens)
        Text(this.secTens.toString())
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF0000') // 红色数字
          .backgroundColor(Color.White) // 白色背景
          .width(60)
          .height(80)
          .textAlign(TextAlign.Center)
          .borderRadius(8)
          .shadow({ radius: 2, color: '#33000000' })
          .margin({ right: 4 })
        // this.NumberDisplay(this.secUnits)
        Text(this.secUnits.toString())
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF0000') // 红色数字
          .backgroundColor(Color.White) // 白色背景
          .width(60)
          .height(80)
          .textAlign(TextAlign.Center)
          .borderRadius(8)
          .shadow({ radius: 2, color: '#33000000' })
          .margin({ right: 4 })
      }
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor('#AAAAAA') // 灰色背景
      .borderRadius(12)
      .margin({ bottom: 20 })
      .width('auto')

      // 模式切换按钮
      Button('切换模式')
        .width(120)
        .height(36)
        .fontSize(14)
        .backgroundColor('#AAAAAA')
        .fontColor(Color.White)
        .borderRadius(6)
        .margin({ bottom: 20 })
        .onClick(() => {
          this.toggleMode();
        })

      // 控制按钮区域
      Row({ space: 16 }) {
        // 开始按钮
        Button('开始')
          .width(80)
          .height(40)
          .fontSize(16)
          .backgroundColor('#AAAAAA')
          .fontColor(Color.White)
          .borderRadius(8)
          .enabled(!this.isRunning)
          .onClick(() => {
            this.startTimer();
          })

        // 暂停按钮
        Button('暂停')
          .width(80)
          .height(40)
          .fontSize(16)
          .backgroundColor('#AAAAAA')
          .fontColor(Color.White)
          .borderRadius(8)
          .enabled(this.isRunning)
          .onClick(() => {
            this.stopTimer();
          })

        // 重置按钮
        Button('重置')
          .width(80)
          .height(40)
          .fontSize(16)
          .backgroundColor('#AAAAAA')
          .fontColor(Color.White)
          .borderRadius(8)
          .onClick(() => {
            this.resetTimer();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width(380)
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 10, color: '#33000000', offsetX: 2, offsetY: 2 })
  }
}
