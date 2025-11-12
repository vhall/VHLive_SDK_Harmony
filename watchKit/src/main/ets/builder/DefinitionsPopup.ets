// 倍速对象
export interface definitions {
  text: string,
  value: number
};


export interface GeneratedTypeLiteralInterface {
  onItemSelected: (item: definitions) => void;
}

@Builder
export function definitionsPopup(params: GeneratedTypeLiteralInterface,def:Array<definitions>) {
  List({ space: 5 }) {
    ForEach(def, (item: definitions) => {
      ListItem() {
        Row() {
          Text(item.text)
            .fontColor(Color.White)
            .fontSize(14)
            .onClick(() => {
              params.onItemSelected(item)
            })
        }
        .padding({ left: 4 })
        .width('100%')
        .height(18)
      }
    }, (item: definitions) => {
      return JSON.stringify(item);
    })
  }
  .width(100)
  .padding(5)
}