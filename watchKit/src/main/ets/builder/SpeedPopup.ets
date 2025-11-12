// 倍速对象
export interface popItemValueObj {
  text: string,
  value: number
};

class AVPlayerConstants {
  // 倍速
  static readonly SPEED_ARRAY: popItemValueObj[] = [
    {
      text: '0.75x', value: 0
    },
    {
      text: '1.0x', value: 1
    },
    {
      text: '1.25x', value: 2
    },
    {
      text: '1.75x', value: 3
    },
    {
      text: '2.0x', value: 4
    }];
}

export interface GeneratedTypeLiteralInterface {
  onItemSelected: (item: popItemValueObj) => void;
}

@Builder
export function SpeedPopup(params: GeneratedTypeLiteralInterface) {
  List({ space: 10 }) {
    ForEach(AVPlayerConstants.SPEED_ARRAY, (item: popItemValueObj) => {
      ListItem() {
        Row() {
          Text(item.text)
            .fontColor(Color.White)
            .fontSize(14)
            .onClick(() => {
              params.onItemSelected(item)
            })
        }
        .padding({ left: 10 })
        .width('100%')
        .height(18)
      }
    }, (item: popItemValueObj) => {
      return JSON.stringify(item);
    })
  }
  .width(70)
  .padding(10)
}