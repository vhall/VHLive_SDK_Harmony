export class WaterPostion{
  static getPadding(pos:number):Padding{
    let pad:Padding = {};
    switch (pos){
      case 1:{//左上角
        pad = {left:'10vp',top:'20vp'};
        break;
      }
      case 2:{//右上角
        pad = {right:'10vp',top:'20vp'};
        break;
      }
      case 3:{//左下角度
        pad = {left:'10vp',bottom:'20vp'};
        break;
      }
      case 4:{//右下角
        pad = {right:'10vp',bottom:'20vp'};
        break;
      }
      default:
        break;
    }
    return pad;
  }

  static GetWaterPosTopOrBottom(pos:number):number{
    switch (pos){
      case 1:{
        return VerticalAlign.Top;
      }
      case 2:{
        return VerticalAlign.Top;
      }
      case 3:{
        return VerticalAlign.Bottom;
      }
      case 4:{
        return VerticalAlign.Bottom;
      }
      default :
        break;
    }
    return VerticalAlign.Top;
  }

  static GetWaterPosLeftOrRight(pos:number):number{
    switch (pos){
      case 1:{
        return FlexAlign.Start;
      }
      case 2:{
        return FlexAlign.End;
      }
      case 3:{
        return FlexAlign.End;
      }
      case 4:{
        return FlexAlign.Start;
      }
      default :
        break;
    }
    return FlexAlign.Start;
  }
}