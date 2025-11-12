export class VHIntroduction{
  static getIntroduction(data:string):string{
   // let html = "<!DOCTYPE html>" +
   //    "<html>"+
   //    "<body>"+
   //    data +
   //    "</body>"+
   //    "</html>";
   // return html;
//<html><body bgcolor="red"><p><span style="color: #ba372a; font-size: 56px;">子虚曰：&ldquo;可。王车驾千乘，选徒万骑，畋于海滨。列卒满泽，罘罔弥山，掩兔辚鹿，射麋脚麟。骛于盐浦，割鲜染轮。射中获多，矜而自功。顾谓仆曰：&lsquo;楚亦有平原广泽游猎之地饶乐若此者乎？楚王之猎孰与寡人乎？&rsquo;仆下车对曰：&lsquo;臣，楚国之鄙人也，幸得宿卫十有余年，时从出游，游于后园，览于有无，然犹未能遍睹也，又焉足以言其外泽者</span></p></body></html>

    let html = "<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0,user-scalable=no\"></head>" + data + "</html>";
    return html;
  }
}