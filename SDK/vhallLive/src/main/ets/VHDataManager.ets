import { VHMessage } from '@vhall/vhallyun-framework';
import { VHIMMessageModel } from './im/VHIMCallback';
import {VHInteract,VHReportData,VHRecord,VHWarmup} from './model/VHWatchWebinarInfo'

export class VHDataManager{

  private default_interact_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqaWQiOjE3NDgxNTEsInVpZCI6MCwidmlkIjoidjEzNDUzMjQyNDI3MzE5Mjk2MDAiLCJ0cHVpZCI6InZpc2l0X3YxMzQ1MzI0MjQyNzMxOTI5NjAwIiwid2lkIjo4ODc5NDY3OTEsInJvb21faWQiOiJsc3NfNTA1ZTVlOWIiLCJjdCI6MTYwOTU4NTI3MH0.2WODxqmxGdeXzCKuSOZS4xI0xsRI4ECWhtWDjQpK04g";
  public user_id:string = "";
  public visitor_id:string = "";
  public token:string = "";
  public gray_id:number = 0;
  public interact_token = this.default_interact_token;
  private static manager:VHDataManager;

  public interact:VHInteract | null = null;
  public report:VHReportData | null = null;

  public clear(){
    this.user_id = "";
    this.token= "";
    this.gray_id = 0;
    this.visitor_id = "";
    this.interact_token = this.default_interact_token;
  }

  static getInstance():VHDataManager{
    if(VHDataManager.manager==null){
      VHDataManager.manager = new VHDataManager();
    }
    return VHDataManager.manager;
  }

  private VHDataManager(){}


  public getVHIMMessage(message: VHMessage):VHIMMessageModel{
    let imMsg:VHIMMessageModel = new VHIMMessageModel();
    imMsg.msg_id = message.msg_id;
    imMsg.channel = message.channel;
    imMsg.event = message.event;
    imMsg.date_time = message.date_time;
    imMsg.third_party_user_id = message.third_party_user_id;
    imMsg.connection_online_num = message.connection_online_num;
    imMsg.user_online_num = message.user_online_num;
    imMsg.avatar = message.avatar;
    imMsg.client = message.client;
    imMsg.dataJson = message.dataJson;
    imMsg.nick_name = message.nick_name;
    imMsg.sender_id = message.sender_id;
    imMsg.context = message.context;
    imMsg.pv = message.pv;
    imMsg.uv = message.uv;
    try {
      imMsg.data = JSON.parse(message.data) as object;
    }catch (e) {
    }
    return imMsg;
  }
}