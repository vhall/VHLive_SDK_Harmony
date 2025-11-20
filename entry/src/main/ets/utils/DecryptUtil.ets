import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer, util } from '@kit.ArkTS';



export class DecryptUtil {

  static decryptMessage(symKey: cryptoFramework.SymKey, cipherText: cryptoFramework.DataBlob) {
    let decoder = cryptoFramework.createCipher('AES128|ECB|PKCS7');
    decoder.initSync(cryptoFramework.CryptoMode.DECRYPT_MODE, symKey, null); // ECB模式params为null。
    let decryptData = decoder.doFinalSync(cipherText);
    return decryptData;
  }

  static genSymKeyByData(symKeyData: Uint8Array) {
    let symKeyBlob: cryptoFramework.DataBlob = { data: symKeyData };
    let aesGenerator = cryptoFramework.createSymKeyGenerator('AES128');
    let symKey = aesGenerator.convertKeySync(symKeyBlob);
    console.info('convertKeySync success');
    return symKey;
  }

  static decrypt(keyBase64: string, ciphertextBase64: string): string {
    let decryptStr: string = '';
    try {
      // 预处理Base64字符串：移除空格和换行符
      const cleanCipherText = ciphertextBase64
        .replace(/ /g, "+")           // 每个空格替换为"+"号（三个空格=三个+号）
        .replace(/\n/g, "+")          // 换行符替换为"+"号
        .replace(/\t/g, "+")          // 制表符替换为"+"号
        .replace(/\r/g, "+")          // 回车符替换为"+"号
      const cleanKeyBase64 = keyBase64.replace(/\s/g, '');
      const textEncoder = new util.TextEncoder();
      const keyUint8: Uint8Array = textEncoder.encodeInto(cleanKeyBase64);
      let keyData = new Uint8Array(keyUint8);
      let symKey = DecryptUtil.genSymKeyByData(keyData);
      let base64 = new util.Base64Helper();
      const ciphertextBytes: Uint8Array = base64.decodeSync(cleanCipherText);
      let plainText: cryptoFramework.DataBlob = { data: ciphertextBytes };
      let decryptText = DecryptUtil.decryptMessage(symKey, plainText);
      if (decryptText.data !== null) {
        decryptStr = buffer.from(decryptText.data).toString('utf-8');
      }
    } catch (error) {
      console.error(`decrypt ECB "${error}", error code: ${error.code}`);
    }
    return decryptStr;
  }

}