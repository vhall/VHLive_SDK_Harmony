
//参考 https://hellokit.com.cn/emoji
const EMOJI_MAP: Map<string, string> = new Map([
  ["[微笑]", "\uD83D\uDE0A"],
  ["[撇嘴]", "\uD83D\uDE41"],
  ["[色]", "\uD83D\uDE0D"],
  ["[发呆]", "\uD83D\uDE10"],
  ["[得意]", "\uD83D\uDE04"],
  ["[流泪]", "\uD83D\uDE22"],
  ["[害羞]", "\uD83D\uDE33"],
  ["[闭嘴]", "\uD83D\uDE46"],
  ["[睡]", "\uD83D\uDE34"],
  ["[哭]", "\uD83D\uDE2D"],
  ["[尴尬]", "\uD83D\uDE35"],
  ["[发怒]", "\uD83D\uDE21"],
  ["[调皮]", "\uD83D\uDE1C"],
  ["[呲牙]", "\uD83D\uDE01"],
  ["[惊讶]", "\uD83D\uDE2E"],
  ["[难过]", "\uD83D\uDE14"],
  ["[酷]", "\uD83D\uDE0E"],
  ["[汗]", "\uD83D\uDE13"],
  ["[抓狂]", "\uD83D\uDE24"],
  ["[吐]", "\uD83E\uDD2E"],
  ["[偷笑]", "\uD83D\uDE0F"],
  ["[愉快]", "\uD83D\uDE00"],
  ["[白眼]", "\uD83D\uDE44"],
  ["[傲慢]", "\uD83D\uDE43"],
  ["[饥饿]", "\uD83E\uDD24"],
  ["[困]", "\uD83D\uDE2A"],
  ["[惊恐]", "\uD83D\uDE31"],
  ["[流汗]", "\uD83D\uDE05"],
  ["[憨笑]", "\uD83D\uDE03"],
  ["[悠闲]", "\uD83D\uDE0C"],
  ["[奋斗]", "\uD83D\uDCAA"],
  ["[咒骂]", "\uD83E\uDD2C"],
  ["[疑问]", "\uD83E\uDD14"],
  ["[嘘]", "\uD83E\uDD2B"],
  ["[晕]", "\uD83D\uDCAB"],
  ["[疯了]", "\uD83E\uDD2F"],
  ["[衰]", "\uD83E\uDD74"],
  ["[骷髅]", "\uD83D\uDC80"],
  ["[敲打]", "\uD83D\uDD28"],
  ["[再见]", "\uD83D\uDC4B"],
  ["[擦汗]", "\uD83D\uDE30"],
  ["[抠鼻]", "\uD83E\uDD25"],
  ["[鼓掌]", "\uD83D\uDC4F"],
  ["[糗大了]", "\uD83D\uDE15"],
  ["[坏笑]", "\uD83D\uDE08"],
  ["[左哼哼]", "\uD83D\uDE12"],
  ["[右哼哼]", "\uD83D\uDE12"],
  ["[哈欠]", "\uD83E\uDD71"],
  ["[鄙视]", "\uD83D\uDE44"],
  ["[委屈]", "\uD83E\uDD7A"],
  ["[快哭了]", "\uD83E\uDD79"],
  ["[阴险]", "\uD83D\uDE0F"],
  ["[亲亲]", "\uD83D\uDE19"],
  ["[吓]", "\uD83D\uDE28"],
  ["[可怜]", "\uD83E\uDD7A"],
  ["[菜刀]", "\uD83D\uDD2A"],
  ["[西瓜]", "\uD83C\uDF49"],
  ["[啤酒]", "\uD83C\uDF7A"],
  ["[篮球]", "\uD83C\uDFC0"],
  ["[乒乓]", "\uD83C\uDFBE"],
  ["[咖啡]", "\u2615\uFE0F"],
  ["[饭]", "\uD83C\uDF5D"],
  ["[猪头]", "\ud83c\udf5a"],
  ["[玫瑰]", "\uD83C\uDF39"],
  ["[凋谢]", "\ud83e\udd40"],
  ["[嘴唇]", "\uD83D\uDC8B"],
  ["[爱心]", "\u2764\uFE0F"],
  ["[心碎]", "\uD83D\uDC94"],
  ["[蛋糕]", "\ud83c\udf82"],
  ["[闪电]", "\u26A1\uFE0F"],
  ["[炸弹]", "\ud83d\udca3"],
  ["[刀]", "\uD83D\uDD2A"],
  ["[足球]", "\u26bd"],
  ["[瓢虫]", "\uD83D\uDC1E"],
  ["[便便]", "\uD83D\uDCA9"],
  ["[月亮]", "\uD83C\uDF19"],
  ["[太阳]", "\uD83C\uDF1E"],
  ["[礼物]", "\uD83C\uDF81"],
  ["[拥抱]", "\uD83E\uDD17"],
  ["[强]", "\uD83D\uDC4D"],
  ["[弱]", "\uD83D\uDC4E"],
  ["[握手]", "\ud83e\udd1d"],
  ["[胜利]", "\u270C\uFE0F"],
  ["[抱拳]", "\ud83d\ude4f"],
  ["[勾引]", "\ud83e\udef4"],
  ["[拳头]", "\u270a"],
  ["[差劲]", "\uD83D\uDC4E"],
  ["[爱你]", "\ud83e\udd1f"],
  ["[NO]", "\ud83d\ude45"],
  ["[OK]", "\ud83d\udc4c"]
]);

export class EmojiTool{
  static convertEmojiTags(text: string): string {
    let result = text;
    // 遍历所有表情映射，替换文本中的标签
    EMOJI_MAP.forEach((unicode, tag) => {
      // 使用正则表达式替换所有出现的标签，确保全局替换
      // 转义正则特殊字符
      const escapedTag = tag.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      result = result.replace(new RegExp(escapedTag, 'g'), unicode);
    });
    return result;
  }

  //官方 https://unicode.org/emoji/charts/emoji-list.html#face-neutral-skeptical
  //  codePointToUtf16("1F600") 输出 ”\uxxx\uxxx“ 在EMOJI_MAP增加。
  static codePointToUtf16(codePoint: string): string {
    // 转换为十六进制数字
    const u = parseInt(codePoint, 16);

    // 检查是否为基本平面字符（无需代理对）
    if (u <= 0xFFFF) {
      return `\\u${u.toString(16).padStart(4, '0').toUpperCase()}`;
    }

    // 应用转换公式
    const o = u - 0x10000;
    const h = 0xD800 + (o >> 10);
    const l = 0xDC00 + (o & 0x3FF);

    // 格式化为\uXXXX\uXXXX形式
    return `\\u${h.toString(16).padStart(4, '0').toUpperCase()}\\u${l.toString(16).padStart(4, '0').toUpperCase()}`;
  }

}

