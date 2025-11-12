import {VHAIMediaInfo,VHAISubtitleStyle, VHAISummaryModel,VHSaaSDK, VHWebinarData } from "@vhall/vhall_live";
import { util } from "@kit.ArkTS";
import { JSON } from "@kit.ArkTS";
import { EmitterMsgData, EmitterUtil } from "../../util/EmitterUtil";
import MsgType from "../../constants/MsgType";
import { common } from "@kit.AbilityKit";
import { BusinessError, request } from "@kit.BasicServicesKit";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { fileIo as fs } from '@kit.CoreFileKit';
import { ToastUtil } from "../../action/ToastUtil";

export class SrtSubtitle {
  index: number; // 字幕序号
  startTimeMs: number; // 开始时间（毫秒）
  endTimeMs: number; // 结束时间（毫秒）
  content: string; // 字幕内容

  constructor(index: number, startTimeMs: number, endTimeMs: number, content: string) {
    this.index = index;
    this.startTimeMs = startTimeMs;
    this.endTimeMs = endTimeMs;
    this.content = content;
  }
}

@Component
export struct VHAISubtitleView {
  private  subtitles: SrtSubtitle[] = [];
  private filePath:string = "";
  @State subText:string = "";
  @Require webinar_info:VHWebinarData;
  @State model:VHAISummaryModel= new VHAISummaryModel();
  @State  subtitleStyle: VHAISubtitleStyle = new VHAISubtitleStyle();
  aboutToAppear(): void {
    VHSaaSDK.getInstance().getAIWatch(this.webinar_info?.record?.record_id!,{
      onSucceed: (data: VHAIMediaInfo) => {
        this.download(data);
        this.subtitleStyle = data.subtitle_style;
      },
      // 失败
      onFailure: (errorCode: number, errorMsg: string) => {
       // ToastUtil.showToast("getAIWatch:" + errorMsg);
      }
    });

    EmitterUtil.subscribe(MsgType.VOD_SUBTITLE_TIME, (msgData: EmitterMsgData) => {
      const timeMs = msgData.data as number;
      const target = this.subtitles.find(item =>
      timeMs >= item.startTimeMs && timeMs <= item.endTimeMs);
      if (target) {
        this.subText = target.content;
      }
    });
  }

  async parseFromSandboxPath(srtFilePath: string): Promise<SrtSubtitle[]> {
    try {

      // 2. 读取SRT文件内容（文本格式，编码默认UTF-8）
      const fileContent = await this.readTextFile(this.filePath);
      if (!fileContent) {
        throw new Error("SRT文件内容为空");
      }

      // 3. 解析文件内容为SrtSubtitle数组
      return this.parseContent(fileContent);
    } catch (error) {
      const err = error as BusinessError;
      console.error(`解析SRT失败：${err.message}（错误码：${err.code}）`);
      return [];
    }
  }

  private async readTextFile(filePath: string): Promise<string> {
    const file = await fs.open(filePath, fs.OpenMode.READ_ONLY);
    try {
      // 1. 打开文件（只读模式，确保路径正确）
      // 注意：filePath必须是完整路径（如应用沙箱内的绝对路径），不能是相对路径
      console.info(`成功打开文件：${filePath}，文件描述符：${file.fd}`);
      // 2. 初始化分块读取配置
      const bufferSize = 4096; // 缓冲区大小（4KB，可根据文件大小调整，建议1-8KB）
      const buffer = new ArrayBuffer(bufferSize); // 分块读取的缓冲区
      let content = ''; // 存储最终的完整文本
      const textDecoder = util.TextDecoder.create('utf-8', {
        ignoreBOM: true // 忽略UTF-8 BOM头（避免文本开头出现�等乱码）
      });

      // 3. 循环分块读取文件（直到读取完毕）
      while (true) {
        // 关键：fs.read返回的是ReadResult对象，包含bytesRead（实际读取字节数）和buffer（读取到的数据）
        const readResult = await fs.read(file.fd, buffer);
        const actualReadBytes = readResult; // 实际读取到的字节数（0表示读取完毕）

        if (actualReadBytes === 0) {
          break; // 读取完毕，退出循环
        }

        // 4. 将当前分块的ArrayBuffer转为字符串（核心解码步骤）
        // 注意：需截取缓冲区中实际有数据的部分（0 ~ actualReadBytes），避免读取空数据
        const chunkUint8 = new Uint8Array(buffer.slice(0, actualReadBytes));
        // stream: true 表示后续还有分块（避免解码不完整，尤其处理多字节字符如中文）
        const chunkText = textDecoder.decodeToString(chunkUint8, { stream: true });
        content += chunkText; // 累加当前分块文本到总内容中
      }

      // 5. 结束解码（处理最后一个分块的残留数据，确保完整）
      content += textDecoder.decodeToString(new Uint8Array(0), { stream: false });

      console.info(`文件读取完成，总长度：${content.length}字符`);
      this.parseContent(content);
      return content;

    } catch (error) {
      const err = error as BusinessError;
      console.error(`读取文件失败：${err.message}，错误码：${err.code}，文件路径：${filePath}`);
      throw new Error(`文件读取异常：${err.message}`); // 向上抛出错误，让调用者感知
    } finally {
      // 6. 无论成功/失败，都关闭文件（避免文件描述符泄漏）
      await fs.close(file.fd);
    }
  }
  /**
   * 解析SRT文本内容为结构化数据
   */
  private parseContent(srtContent: string): SrtSubtitle[] {


    // 1. 按空行分割字幕块（处理Windows/Mac/Linux换行符差异：\r\n、\n）
    const subtitleBlocks = srtContent.split(/\r?\n\r?\n/).filter(block => block.trim() !== "");

    // 2. 逐个解析字幕块
    subtitleBlocks.forEach(block => {
      // 按换行分割块内内容（序号、时间轴、内容）
      const lines = block.split(/\r?\n/).filter(line => line.trim() !== "");
      if (lines.length < 3) return; // 无效块（至少需序号、时间轴、内容各1行）

      // 3. 提取序号（转为数字）
      const index = parseInt(lines[0].trim(), 10);
      if (isNaN(index)) return;

      // 4. 提取并格式化时间轴（00:00:10,500 --> 00:00:13,000）
      const timeLine = lines[1].trim();
      const timeMatch = timeLine.match(/(\d+:\d+:\d+,\d+) --> (\d+:\d+:\d+,\d+)/);
      if (!timeMatch) return;

      const startTimeMs = this.timeToMs(timeMatch[1]); // 开始时间→毫秒
      const endTimeMs = this.timeToMs(timeMatch[2]);   // 结束时间→毫秒
      if (startTimeMs === -1 || endTimeMs === -1) return;

      // 5. 提取字幕内容（从第3行开始，支持多行内容）
      const content = lines.slice(2).join("\n").trim();

      // 6. 添加到结果数组
      this.subtitles.push(new SrtSubtitle(index, startTimeMs, endTimeMs, content));
    });

    // 按开始时间排序（避免SRT文件序号混乱）
    return this.subtitles.sort((a, b) => a.startTimeMs - b.startTimeMs);
  }

  /**
   * 将SRT时间格式（00:00:10,500）转为毫秒
   * @returns 毫秒数（失败返回-1）
   */
  private timeToMs(timeStr: string): number {
    // 替换逗号为点（统一处理“00:00:10,500”和“00:00:10.500”格式）
    const parts = timeStr.replace(",", ".").split(":");
    if (parts.length !== 3) return -1;

    const hours = parseFloat(parts[0]);
    const minutes = parseFloat(parts[1]);
    const seconds = parseFloat(parts[2]);

    if (isNaN(hours) || isNaN(minutes) || isNaN(seconds)) return -1;

    // 计算总毫秒数（1小时=3600000毫秒，1分钟=60000毫秒）
    return Math.floor(hours * 3600000 + minutes * 60000 + seconds * 1000);
  }

  private async download(data: VHAIMediaInfo){
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    let dir: string = context.filesDir
    this.filePath = dir + "/srt_reference" + Date.now() + ".srt";
    try {
      request.downloadFile(context, {
        url: data.subtitles.file_url,
        filePath: this.filePath
      }).then((downloadTask: request.DownloadTask) => {
        downloadTask.on('complete', () => {
          console.info('下载完成，开始复制到公共目录');
          this.readTextFile(this.filePath);
        });
      });

    } catch (err) {
      hilog.error(0x0000, 'TAG', `Download failed: ${JSON.stringify(err)}`);
    }
  }

  build() {
    RelativeContainer(){
     Text(this.subText)
       .alignRules({
         middle: { anchor: '__container__', align: HorizontalAlign.Center },
         bottom: { anchor: '__container__', align:VerticalAlign.Bottom }
       })
       .padding({bottom:40})
       .fontSize("12vp")
       .fontColor(this.subtitleStyle.font_color)
       .fontWeight(this.subtitleStyle.is_bold == 1 ? FontWeight.Bold : FontWeight.Normal)
       .decoration({
         type: this.subtitleStyle.is_underline == 1 ? TextDecorationType.Underline :  TextDecorationType.None , // 下划线类型
         color: Color.Gray,                  // 下划线颜色
         style: TextDecorationStyle.SOLID  //
       })
       .fontStyle(this.subtitleStyle.is_incline == 1 ? FontStyle.Italic : FontStyle.Normal)
       // .border({
       //   width: this.subtitleStyle.stroke_width,                     // 边框宽度
       //   color: this.subtitleStyle.stroke_color,           // 描边颜色
       //   style: BorderStyle.Solid      // 实线样式
       // })
    }.width("100%").height("100%")
  }
}