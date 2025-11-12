import http from '@ohos.net.http';
import Url from '@ohos.url'
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CallBack } from './HttpNetResponse'
import HttpNetResponse from './HttpNetResponse'


/**
 * 网络请求
 * @param url url地址
 * @param method 请求类型
 * @param params 请求参数
 * @param callBack 请求返回结果
 */
export async function HttpNetRequest(url: string, method: http.RequestMethod,
  params: Map<string, string | number | Object>, headerParams: Map<string, string>, callBack?: CallBack) {
  // 请求数据数据
  let tag = "vh_network"
  // 创建一个网络请求
  let httpRequest = http.createHttp();

  hilog.debug(1, tag, '网络请求地址 === ' + url);

  // 将数据请求参数转换为 Record
  let paramsJson: Record<string, string> = {};
  params.forEach((value, key) => {
    if (key != undefined && key != null) {
      paramsJson[key] = value.toString();
    }
  })
  hilog.debug(1, tag, '网络请求参数 === ' + JSON.stringify(paramsJson));


  // 创建基础请求头，包含默认的Content-Type
  let headerValue: Record<string, string> = {
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  // 将headerParams中的键值对合并到请求头
  if (headerParams) {
    headerParams.forEach((value, key) => {
      if (key) { // 确保key有效
        // 将值统一转为字符串格式
        headerValue[key] = value?.toString() ?? '';
      }
    });
  }

  // 用于订阅HTTP响应头，此接口会比request请求先返回。可以根据业务需要订阅此消息
  httpRequest.on('headersReceive', (header) => {
    hilog.debug(1, tag, 'header: === ' + JSON.stringify(header));
  });

  // 发起请求
  let responseResult = httpRequest.request(url, {
    // 请求方式 GET POST
    method: method,
    //携带额外参数,将数据请求参数转换为支持application/x-www-form-urlencoded的请求格式
    extraData: new Url.URLParams(paramsJson).toString(),
    // 开发者根据自身业务需要添加header字段
    header: headerValue,
    // 连接超时时间，默认为60秒（60000ms）
    connectTimeout: 15000,
    // 读取超时时间，默认为60秒（60000ms）
    readTimeout: 15000,
    // 是否使用缓存，默认为使用缓存（true）
    usingCache: false,
    // 协议类型
    usingProtocol: http.HttpProtocol.HTTP2
  }, (error, response) => {
    if (!error) {
      hilog.debug(1, tag, 'VHSDK Network Response === ' + response.result);
      try {
        let responseObject: HttpNetResponse = JSON.parse(`${response.result}`);
        if (callBack) {
          if (responseObject.code == 200) {
            callBack.onSuccess(responseObject.data);
          } else if(response.responseCode == 200 && responseObject.code == undefined){
            callBack.onSuccess(response.result);
          }
          else {
            callBack.onFailure(responseObject.code, responseObject.msg);
          }
        }
      } catch (error) {
        hilog.error(1, tag, 'VHNetworkingBaseRequest 解析 JSON 失败:', error);
      }
    } else {
      hilog.info(1, tag, 'VHNetworkingBaseRequest VHSDK Network Response Error === ' + error);
      if (callBack) {
        callBack.onFailure(error.code, JSON.stringify(error.message))
      }
    }
    // 取消订阅HTTP响应头事件
    httpRequest.off('headersReceive');
    // 当该请求使用完毕时，调用destroy方法主动销毁
    httpRequest.destroy();
  }
  );
}


/**
 * 网络请求
 * @param url url地址
 * @param method 请求类型
 * @param params 请求参数
 * @param callBack 请求返回结果
 */
export async function HttpNetRequestWithJsonHeader(url: string, method: http.RequestMethod,
  params: Map<string, string | number | Object>, headerParams: Map<string, string>, callBack?: CallBack) {
  // 请求数据数据
  let tag = "vh_network"
  // 创建一个网络请求
  let httpRequest = http.createHttp();

  hilog.debug(1, tag, '网络请求地址 === ' + url);

  // 将数据请求参数转换为 Record
  let paramsJson: Record<string, string | object> = {};
  params.forEach((value, key) => {
    if (key != undefined && key != null) {
      if (typeof value === 'object') {
        paramsJson[key] = value;
      } else {
        paramsJson[key] = value.toString();
      }
    }
  })
  const jsonParams = JSON.stringify(paramsJson);

  hilog.debug(1, tag, '网络请求参数 === ' + JSON.stringify(paramsJson));


  // 创建基础请求头，包含默认的Content-Type
  let headerValue: Record<string, string> = {
    'Content-Type': 'application/json'
  };

  // 将headerParams中的键值对合并到请求头
  if (headerParams) {
    headerParams.forEach((value, key) => {
      if (key) { // 确保key有效
        // 将值统一转为字符串格式
        headerValue[key] = value?.toString() ?? '';
      }
    });
  }

  // 用于订阅HTTP响应头，此接口会比request请求先返回。可以根据业务需要订阅此消息
  httpRequest.on('headersReceive', (header) => {
    hilog.debug(1, tag, 'header: === ' + JSON.stringify(header));
  });

  // 发起请求
  let responseResult = httpRequest.request(url, {
    // 请求方式 GET POST
    method: method,
    //携带额外参数,将数据请求参数转换为支持application/x-www-form-urlencoded的请求格式
    extraData: jsonParams,
    // 开发者根据自身业务需要添加header字段
    header: headerValue,
    // 连接超时时间，默认为60秒（60000ms）
    connectTimeout: 15000,
    // 读取超时时间，默认为60秒（60000ms）
    readTimeout: 15000,
    // 是否使用缓存，默认为使用缓存（true）
    usingCache: false,
    // 协议类型
    usingProtocol: http.HttpProtocol.HTTP2
  }, (error, response) => {
    if (!error) {
      hilog.debug(1, tag, 'VHSDK Network Response === ' + response.result);
      try {
        let responseObject: HttpNetResponse = JSON.parse(`${response.result}`);
        if (callBack) {
          if (responseObject.code == 200) {
            callBack.onSuccess(responseObject.data);
          } else {
            callBack.onFailure(responseObject.code, responseObject.msg);
          }
        }
      } catch (error) {
        hilog.error(1, tag, 'VHNetworkingBaseRequest 解析 JSON 失败:', error);
      }
    } else {
      hilog.info(1, tag, 'VHNetworkingBaseRequest VHSDK Network Response Error === ' + error);
      if (callBack) {
        callBack.onFailure(error.code, JSON.stringify(error.message))
      }
    }
    // 取消订阅HTTP响应头事件
    httpRequest.off('headersReceive');
    // 当该请求使用完毕时，调用destroy方法主动销毁
    httpRequest.destroy();
  }
  );
}


/**
 * 网络请求
 * @param url url地址
 * @param method 请求类型
 * @param params 请求参数
 * @param callBack 请求返回结果
 */
export async function HttpNetRequestWithJson(url: string, method: http.RequestMethod,
  params: Map<string, string | number | Object>, headerParams: Map<string, string>, callBack?: CallBack) {
  // 请求数据数据
  let tag = "vh_network"
  // 创建一个网络请求
  let httpRequest = http.createHttp();

  hilog.debug(1, tag, '网络请求地址 === ' + url);

  // 将数据请求参数转换为 Record
  let paramsJson: Record<string, string|object> = {};
  params.forEach((value, key) => {
    if (key != undefined && key != null) {
      if(typeof value === 'object'){
        paramsJson[key] = value;
      }else{
        paramsJson[key] = value.toString();
      }
    }
  })
  const jsonParams = JSON.stringify(paramsJson);

  hilog.debug(1, tag, '网络请求参数 === ' + JSON.stringify(paramsJson));


  // 创建基础请求头，包含默认的Content-Type
  let headerValue: Record<string, string> = {
    'Content-Type': 'application/json'
  };

  // 将headerParams中的键值对合并到请求头
  if (headerParams) {
    headerParams.forEach((value, key) => {
      if (key) { // 确保key有效
        // 将值统一转为字符串格式
        headerValue[key] = value?.toString() ?? '';
      }
    });
  }

  // 用于订阅HTTP响应头，此接口会比request请求先返回。可以根据业务需要订阅此消息
  httpRequest.on('headersReceive', (header) => {
    hilog.debug(1, tag, 'header: === ' + JSON.stringify(header));
  });

  // 发起请求
  let responseResult = httpRequest.request(url, {
    // 请求方式 GET POST
    method: method,
    //携带额外参数,将数据请求参数转换为支持application/x-www-form-urlencoded的请求格式
    extraData:jsonParams,
    // 开发者根据自身业务需要添加header字段
    header: headerValue,
    // 连接超时时间，默认为60秒（60000ms）
    connectTimeout: 15000,
    // 读取超时时间，默认为60秒（60000ms）
    readTimeout: 15000,
    // 是否使用缓存，默认为使用缓存（true）
    usingCache: false,
    // 协议类型
    usingProtocol: http.HttpProtocol.HTTP2
  }, (error, response) => {
    if (!error) {
      hilog.debug(1, tag, 'VHSDK Network Response === ' + response.result);
      try {
        let responseObject: HttpNetResponse = JSON.parse(`${response.result}`);
        if (callBack) {
          if (responseObject.code == 200) {
            callBack.onSuccess(responseObject.data);
          } else {
            callBack.onFailure(responseObject.code, responseObject.msg);
          }
        }
      } catch (error) {
        hilog.error(1, tag, 'VHNetworkingBaseRequest 解析 JSON 失败:', error);
      }
    } else {
      hilog.info(1, tag, 'VHNetworkingBaseRequest VHSDK Network Response Error === ' + error);
      if (callBack) {
        callBack.onFailure(error.code, JSON.stringify(error.message))
      }
    }
    // 取消订阅HTTP响应头事件
    httpRequest.off('headersReceive');
    // 当该请求使用完毕时，调用destroy方法主动销毁
    httpRequest.destroy();
  }
  );
}