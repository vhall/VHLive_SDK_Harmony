import { PrivacyAgreementInfo, StatementInfo, TextStatementInfo } from '@vhall/vhall_live';
import { ComponentContent } from '@kit.ArkUI';
import { PromptActionClass } from '../../util/PromptActionClass';
import { WebViewPageBuilder, WebViewParams } from '../../pages/WebViewPage';

@Component
export struct VHLinkTextView {
  @Require privacyAgreementInfo: PrivacyAgreementInfo | null = null;
  private contentNode: ComponentContent<Object> | null = null;

  // 拆分文本为普通文本和链接文本
  splitText(): Array<TextStatementInfo> {
    let result: Array<TextStatementInfo> = [];
    let remainingText = this.privacyAgreementInfo?.statement_content;
    let links: StatementInfo[] = this.privacyAgreementInfo?.statement_info!;
    // 按链接标题长度排序，避免短标题被长标题包含时的匹配问题
    const sortedLinks = links
      ? [...links].sort((a: StatementInfo, b: StatementInfo) => {
      // 确保title存在且为字符串
      const titleA = a.title || '';
      const titleB = b.title || '';
      return titleB.length - titleA.length;
    }):[];

    sortedLinks.forEach(linkInfo => {
      const index = remainingText!.indexOf(linkInfo.title);
      if (index !== -1) {
        // 添加标题前的普通文本
        if (index > 0) {
          let textStatementInfo: TextStatementInfo = new TextStatementInfo();
          textStatementInfo.content = remainingText!.substring(0, index);
          textStatementInfo.isLink = false;
          textStatementInfo.link = '';
          result.push(textStatementInfo);
        }
        // 添加链接文本
        let textStatementInfo: TextStatementInfo = new TextStatementInfo();
        textStatementInfo.content = linkInfo.title;
        textStatementInfo.isLink = true;
        textStatementInfo.link = linkInfo.link;
        result.push(textStatementInfo);
        // 更新剩余文本
        remainingText = remainingText!.substring(index + linkInfo.title.length);
      }
    });
    // 添加剩余的普通文本
    if (remainingText!.length > 0) {
      let textStatementInfo: TextStatementInfo = new TextStatementInfo();
      textStatementInfo.content = remainingText;
      textStatementInfo.isLink = false;
      textStatementInfo.link = '';
      result.push(textStatementInfo);
    }
    return result;
  }

  // 打开链接
  private openLink(url: string) {
    const params=new WebViewParams("e.vhall.com",url);
    this.contentNode = new ComponentContent(this.getUIContext(), wrapBuilder(WebViewPageBuilder),params);
    PromptActionClass.setContext(this.getUIContext());
    PromptActionClass.setContentNode(this.contentNode);
    PromptActionClass.setOptions({alignment: DialogAlignment.Center, offset: { dx: 0, dy: 50 } ,isModal: true,maskRect:{x: 0, y: 0, width: '100%', height: '100%' }});
    PromptActionClass.openDialog();
  }

  build() {
    Column() {
      Row() {
        Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
          ForEach(this.splitText(), (item: TextStatementInfo) => {
            if (item.isLink) {
              Text(item.content)
                .fontColor('#0066CC')
                .fontSize(10)
                .onClick(() => this.openLink(item.link))
                .margin({ left: 1, right: 1 })
            } else {
              Text(item.content)
                .fontColor('#333333')
                .fontSize(10)
                .margin({ left: 1, right: 1 })
            }
          })
        }
      }
    }
    .padding({ left: 30 })
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)

  }
}

