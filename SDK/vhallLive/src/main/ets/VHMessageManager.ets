import { VHMessage } from "@vhall/vhallyun-framework";
import { VHMessageInterface } from "./VHMessageInterface";

export class VHMessageManager{
  // 单例
  private static instance: VHMessageManager;

  private constructor() {
  }

  private messageListener:Map<string,VHMessageInterface> = new Map;

  static getInstance(): VHMessageManager {
    if (!VHMessageManager.instance) {
      VHMessageManager.instance = new VHMessageManager();
    }
    return VHMessageManager.instance;
  }

  public registerServer(name:string,listener:VHMessageInterface){
    if(this.messageListener.has(name)){
      return;
    }
    this.messageListener.set(name,listener);
  }

  public broadCastMsg(name:string,msg:VHMessage){
    let callback:VHMessageInterface = this.messageListener.get(name)!;
    if(callback){
      callback.onRecvMessage(msg);
    }
  }

  public unRegisterServer(name:string){
    if(this.messageListener.has(name)){
      this.messageListener.delete(name);
    }
  }
}