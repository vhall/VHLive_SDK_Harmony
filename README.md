微吼直播鸿蒙SDK
===

### 1 简介
此项目是微吼直播鸿蒙SDK直播观看SDK。用于直播&点播观看、聊天、参会直播互动

### 2 版本更新

|   版本号   |    日期     |     更新说明      |
|:-------:|:---------:|:-------------:| 
| v1.0.12 | 2015-12-2 | 1:微吼直播鸿蒙版本SDK |  


### 3 集成方式

参考文档<br>
1：开发文档 https://developer.vhall.com/7504802m0<br>
2：下载安装 ohpm install @vhall/vhall_live

```
|-- entry
|   |-- ability
|   |-- pages
|   |   `-- index.ets (登录页)]
|   |   `-- KeySettingPage.ets (appkey配置页)]
|   |   `-- LiveEnterPage.ets (活动进入初始化页)]
|   |   `-- InvitationCard.ets (开屏海报)]
|-- watchKit (观看页)
    |-- src 
    |-- |-- main 
    |-- |-- |-- etc 
    |   |   |   |-- builder 
    |   |   |        `-- AnnouncementBuilder.ets (公告示例)]
    |   |   |        `-- CardBuilder.ets (推屏卡片弹窗)]
    |   |   |        `-- WatchGiftBuilder.ets (观看有礼示例)]    
    |   |   |   |-- components 
    |   |   |   |-- `-- adv (广告组件)]
    |   |   |   |-- `-- chat (聊天组件)]
    |   |   |   |        `-- ChatComponent.ets (聊天组件示例)]
    |   |   |   |        `-- GiftComponent.ets (礼物示例)]
    |   |   |   |        `-- PrivateChatComponent.ets (问答私聊)]
    |   |   |   |        `-- QaComponent.ets (问答示例)]    
    |   |   |   |-- `-- doc (文档组件)]
    |   |   |   |        `-- VHDocPageComponent.ets (文档&白板组件)]       
    |   |   |   |        `-- VHQuestionnaireDialog.ets (问卷弹窗)]       
    |   |   |   |-- `-- goods (商品组件)]
    |   |   |   |-- `-- menu (自定义菜单)]
    |   |   |   |-- `-- player (播放器组件)]
    |   |   |   |        `-- VHWatchVodPlayerComponent.ets (点播播放器组件示例)]
    |   |   |   |        `-- VHWatchLivePlayerComponent.ets (直播播放器组件示例)]
    |   |   |   |        `-- VHWarmPlayerView.ets (暖场视频组件示例)]
    |   |   |   |        `-- VHAISummaryView.ets (ai剪辑示例)]
    |   |   |   |        `-- VHBarrageView.ets (弹幕示例)]
    |   |   |   |        `-- VHMarqueeView.ets (跑马灯示例)]
    |   |   |   |        `-- VHPlayerWaterMark.ets (播放器水印示例)]
    |   |   |   |-- `-- timer (计时器)]                        
    |   |   |   |-- pages 
    |   |   |   |-- `-- WatchLivePage.ets (直播观看页)]
    |   |   |   |-- `-- WatchVodPage.ets (回放观看页)]
    |   |   |   |-- `-- StartPage.ets (观看验证-密码验证)]
    |   |   |   |-- `-- ReservationPage.ets (预约页面)]
    |   |   |   |-- `-- ExamPage.ets (快问快答嵌入页面)]





