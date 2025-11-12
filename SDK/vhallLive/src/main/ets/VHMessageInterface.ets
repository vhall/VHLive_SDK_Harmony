import { VHMessage } from "@vhall/vhallyun-framework";

export interface VHMessageInterface{
  onRecvMessage(message: VHMessage):void;
}