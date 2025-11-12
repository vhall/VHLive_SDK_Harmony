/**
 * 倒计时器工具类
 * 提供开始、暂停、恢复、取消等功能
 */
export class CountDownTimer {
  /**
   *  总倒计时时间(毫秒)
   * */
  private totalTime: number;
  /**
   * 间隔时间(毫秒)，默认1000ms
   * */
  private interval: number = 1000;
  /**
   * 剩余时间(毫秒)
   * */
  private remainingTime: number;
  /**
   *  定时器ID
   * */
  private timerId: number | null = null;
  /**
   * 是否处于暂停状态
   * */
  private isPaused: boolean = false;
  /**
   * 倒计时中回调
   * */
  private onTickCallback?: (millisUntilFinished: number) => void;
  /**
   * 倒计时结束回调
   * */
  private onFinishCallback?: () => void;
  /**
   * 构造函数
   * @param totalTime 总倒计时时间(毫秒)
   * @param interval 间隔时间(毫秒)，默认1000ms
   */
  constructor(totalTime: number, interval: number = 1000) {
    this.totalTime = totalTime;
    this.interval = interval;
    this.remainingTime = totalTime;
  }

  /**
   * 设置倒计时中回调
   * @param callback 回调函数，参数为剩余时间(毫秒)
   */
  onTick(callback: (millisUntilFinished: number) => void): CountDownTimer {
    this.onTickCallback = callback;
    return this;
  }

  /**
   * 设置倒计时结束回调
   * @param callback 回调函数
   */
  onFinish(callback: () => void): CountDownTimer {
    this.onFinishCallback = callback;
    return this;
  }

  /**
   * 开始倒计时
   */
  start(): void {
    // 先取消可能存在的定时器
    this.cancel();
    this.isPaused = false;
    this.remainingTime = this.totalTime;

    // 立即触发一次回调
    this.onTickCallback?.(this.remainingTime);

    this.timerId = setInterval(() => {
      if (this.isPaused) return;

      this.remainingTime -= this.interval;

      if (this.remainingTime <= 0) {
        this.onTickCallback?.(0);
        this.onFinishCallback?.();
        this.cancel();
      } else {
        this.onTickCallback?.(this.remainingTime);
      }
    }, this.interval);
  }

  /**
   * 暂停倒计时
   */
  pause(): void {
    this.isPaused = true;
  }

  /**
   * 恢复倒计时
   */
  resume(): void {
    if (this.isPaused && this.remainingTime > 0) {
      this.isPaused = false;
    }
  }

  /**
   * 取消倒计时
   */
  cancel(): void {
    if (this.timerId) {
      clearInterval(this.timerId);
      this.timerId = null;
    }
    this.isPaused = false;
  }

  /**
   * 获取剩余时间
   * @returns 剩余时间(毫秒)
   */
  getRemainingTime(): number {
    return this.remainingTime;
  }

  /**
   * 重置倒计时
   * @param totalTime 新的总时间(毫秒)，不填则使用初始总时间
   */
  reset(totalTime?: number): void {
    if (totalTime) {
      this.totalTime = totalTime;
    }
    this.remainingTime = this.totalTime;
    this.isPaused = false;
  }
}
