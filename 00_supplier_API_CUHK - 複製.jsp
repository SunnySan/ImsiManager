<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8" %>

<%@ page import="java.net.*" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.regex.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.io.*" %>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext" %>

<%@ page import="javax.net.ssl.*" %>
<%@ page import="java.security.cert.*" %>


<%@page import="org.json.simple.JSONObject" %>

<%@page import="org.apache.commons.httpclient.DefaultHttpMethodRetryHandler" %>
<%@page import="org.apache.commons.httpclient.HttpClient" %>
<%@page import="org.apache.commons.httpclient.HttpException" %>
<%@page import="org.apache.commons.httpclient.methods.PostMethod" %>
<%@page import="org.apache.commons.httpclient.methods.StringRequestEntity" %>
<%@page import="org.apache.commons.httpclient.params.HttpMethodParams" %>

<%@page import="java.io.UnsupportedEncodingException" %>
<%@page import="java.util.Arrays" %>
<%@page import="java.util.Random" %>
<%@page import="com.watchdata.commons.crypto.WD3DesCryptoUtil" %>
<%@page import="com.watchdata.commons.jce.JceBase.Padding" %>
<%@page import="com.watchdata.commons.lang.WDByteUtil" %>
<%@page import="com.watchdata.commons.lang.WDStringUtil" %>

<%!

/*********************************************************************************************************************/
public String imsiProfileQueryForCUHK(String imsi, String timezone){
	String httpUrl = gcCUHKUri + "qrysub";
	//String httpReq = "{\"authKey\":\"FaTyLS63\",\"imsi\": \"" + imsi + "\"}";
	JSONObject obj=new JSONObject();
	obj.put("authKey", gcCUHKAuthKey);
	obj.put("imsi", imsi);
	String	httpReq	= obj.toString();
	
	writeLog("debug", "Send to CUHK, URL= " + httpUrl);
	writeLog("debug", "Data to be sent to CUHK, request= " + httpReq);
	
	HttpClient client = new HttpClient();
	PostMethod method = null;
	String	httpReqEncoded = "";
	String	httpRet = "";
	String	sResponse	= "";
	try {
		HttpApiCodec httpApiCodec = new HttpApiCodec();
		method = new PostMethod(httpUrl);
		httpReqEncoded = httpApiCodec.encode(httpReq);
		//System.out.println("[HttpApi-Send] " + httpReqEncoded);
		method.setRequestEntity(new StringRequestEntity(httpReqEncoded, "application/json", "UTF-8"));
		method.getParams().setParameter(HttpMethodParams.RETRY_HANDLER, new DefaultHttpMethodRetryHandler());
		client.executeMethod(method);
		int statusCode = method.getStatusCode();
		writeLog("debug", "CUHK response HTTP status code= " + String.valueOf(statusCode));
		
		// If status code is not 200, the response does not need to be decoded. 
		if (200 != statusCode) {
			httpRet = method.getResponseBodyAsString();
			writeLog("debug", "CUHK response data= " + httpRet);
			//System.out.println("[HttpApi-Recv] " + httpRet);
		} else {
			httpRet = method.getResponseBodyAsString();
			writeLog("debug", "CUHK response encoded data= " + httpRet);
			httpRet = httpApiCodec.decode(httpRet);
			writeLog("debug", "CUHK response plain data= " + httpRet);	//成功取得回覆，例如： {"effTime":"20180521204023","expTime":"20501231235959","iccid":"8985207180017768550","imsi":"454070019242000","lifeCycle":"0","lifeCycleTime":"20180521204023","msisdn":"85213200000","planCode":"760008","retCode":"000000","retMesg":"Operation Successfully."}
			sResponse = translateCUHKResponse(httpRet, timezone);
			writeLog("debug", "Our translated data= " + sResponse);
		}
	} catch (UnsupportedEncodingException e) {
		writeLog("error", "Exception when send data to CUHK, error= " + e.toString());
		sResponse	= "";
	} catch (HttpException e) {
		writeLog("error", "Exception when send data to CUHK, error= " + e.toString());
		sResponse	= "";
	} catch (IOException e) {
		writeLog("error", "Exception when send data to CUHK, error= " + e.toString());
		sResponse	= "";
	} catch (Exception e) {
		writeLog("error", "Exception when send data to CUHK, error= " + e.toString());
	} finally {
		if (null != method) {
			method.releaseConnection();
		}
	}

	//如果有IMSI資料，就繼續尋找 Package 資料
	if (notEmpty(sResponse) && sResponse.indexOf(gcResultCodeSuccess)>0){
		httpUrl = gcCUHKUri + "qrypacklist";
		writeLog("debug", "Send to CUHK to get package info, URL= " + httpUrl);
		writeLog("debug", "Data to be sent to CUHK to get package info, request= " + httpReq);
		client = new HttpClient();
		method = null;

		try {
			HttpApiCodec httpApiCodec = new HttpApiCodec();
			method = new PostMethod(httpUrl);
			httpReqEncoded = httpApiCodec.encode(httpReq);
			//System.out.println("[HttpApi-Send] " + httpReqEncoded);
			method.setRequestEntity(new StringRequestEntity(httpReqEncoded, "application/json", "UTF-8"));
			method.getParams().setParameter(HttpMethodParams.RETRY_HANDLER, new DefaultHttpMethodRetryHandler());
			client.executeMethod(method);
			int statusCode = method.getStatusCode();
			writeLog("debug", "Get package info, CUHK response HTTP status code= " + String.valueOf(statusCode));
			
			// If status code is not 200, the response does not need to be decoded. 
			if (200 != statusCode) {
				httpRet = method.getResponseBodyAsString();
				writeLog("debug", "Get package info, CUHK response data= " + httpRet);
				//System.out.println("[HttpApi-Recv] " + httpRet);
			} else {
				httpRet = method.getResponseBodyAsString();
				writeLog("debug", "Get package info, CUHK response encoded data= " + httpRet);
				httpRet = httpApiCodec.decode(httpRet);
				writeLog("debug", "Get package info, CUHK response plain data= " + httpRet);	//成功取得回覆，例如： {"packList":[{"effTime":"20180521204023","expTime":"20501231235959","packCode":"761005","packOrderSn":"11000079296247"},{"effTime":"20180521204023","expTime":"20501231235959","packCode":"761006","packOrderSn":"11000079296247"},{"effTime":"20180521204023","expTime":"20501231235959","packCode":"762000","packOrderSn":"11000079296247"}],"retCode":"000000","retMesg":"Operation Successfully."}
				sResponse = translateCUHKPackageResponse(httpRet, sResponse, timezone);
				writeLog("debug", "Get package info, Our translated data= " + sResponse);
			}
		} catch (UnsupportedEncodingException e) {
			writeLog("error", "Get package info, exception when send data to CUHK, error= " + e.toString());
			sResponse	= "";
		} catch (HttpException e) {
			writeLog("error", "Get package info, exception when send data to CUHK, error= " + e.toString());
			sResponse	= "";
		} catch (IOException e) {
			writeLog("error", "Get package info, exception when send data to CUHK, error= " + e.toString());
			sResponse	= "";
		} catch (Exception e) {
			writeLog("error", "Get package info, exception when send data to CUHK, error= " + e.toString());
		} finally {
			if (null != method) {
				method.releaseConnection();
			}
		}
	}	//if (notEmpty(sResponse) && sResponse.indexOf(gcResultCodeSuccess)>0){

	//如果有IMSI資料，就繼續尋找 CDR 資料
	if (notEmpty(sResponse) && sResponse.indexOf(gcResultCodeSuccess)>0){
		httpUrl = gcCUHKUri + "qryusage";

		JSONObject obj=new JSONObject();
		obj.put("authKey", gcCUHKAuthKey);
		obj.put("imsi", imsi);
		obj.put("beginDate", getThirtyDaysAgo(gcDateFormatYMD));
		obj.put("endDate", getYesterday(gcDateFormatYMD));
		String	httpReq	= obj.toString();

		writeLog("debug", "Send to CUHK to get CDR info, URL= " + httpUrl);
		writeLog("debug", "Data to be sent to CUHK to get CDR info, request= " + httpReq);
		client = new HttpClient();
		method = null;

		try {
			HttpApiCodec httpApiCodec = new HttpApiCodec();
			method = new PostMethod(httpUrl);
			httpReqEncoded = httpApiCodec.encode(httpReq);
			//System.out.println("[HttpApi-Send] " + httpReqEncoded);
			method.setRequestEntity(new StringRequestEntity(httpReqEncoded, "application/json", "UTF-8"));
			method.getParams().setParameter(HttpMethodParams.RETRY_HANDLER, new DefaultHttpMethodRetryHandler());
			client.executeMethod(method);
			int statusCode = method.getStatusCode();
			writeLog("debug", "Get CDR info, CUHK response HTTP status code= " + String.valueOf(statusCode));
			
			// If status code is not 200, the response does not need to be decoded. 
			if (200 != statusCode) {
				httpRet = method.getResponseBodyAsString();
				writeLog("debug", "Get CDR info, CUHK response data= " + httpRet);
				//System.out.println("[HttpApi-Recv] " + httpRet);
			} else {
				httpRet = method.getResponseBodyAsString();
				writeLog("debug", "Get CDR info, CUHK response encoded data= " + httpRet);
				httpRet = httpApiCodec.decode(httpRet);
				writeLog("debug", "Get CDR info, CUHK response plain data= " + httpRet);	//成功取得回覆，例如： {"packList":[{"effTime":"20180521204023","expTime":"20501231235959","packCode":"761005","packOrderSn":"11000079296247"},{"effTime":"20180521204023","expTime":"20501231235959","packCode":"761006","packOrderSn":"11000079296247"},{"effTime":"20180521204023","expTime":"20501231235959","packCode":"762000","packOrderSn":"11000079296247"}],"retCode":"000000","retMesg":"Operation Successfully."}
				sResponse = translateCUHKCDRResponse(httpRet, sResponse, timezone);
				writeLog("debug", "Get CDR info, Our translated data= " + sResponse);
			}
		} catch (UnsupportedEncodingException e) {
			writeLog("error", "Get CDR info, exception when send data to CUHK, error= " + e.toString());
		} catch (HttpException e) {
			writeLog("error", "Get CDR info, exception when send data to CUHK, error= " + e.toString());
		} catch (IOException e) {
			writeLog("error", "Get CDR info, exception when send data to CUHK, error= " + e.toString());
		} catch (Exception e) {
			writeLog("error", "Get CDR info, exception when send data to CUHK, error= " + e.toString());
		} finally {
			if (null != method) {
				method.releaseConnection();
			}
		}
	}	//if (notEmpty(sResponse) && sResponse.indexOf(gcResultCodeSuccess)>0){
	
	return sResponse;
}	//public String imsiProfileQueryForCUHK(String imsi, String timezone){

//將 CUHK 的回應資料轉成我們回覆給client端的資料
public String translateCUHKResponse(String httpRet, String timezone){
	String	sResponse	= "";
	JSONObject obj=new JSONObject();
	
	JSONObject jsonObjectResponseBody = null;
	String	retCode	= "";

	try{
		JSONParser	parser	= new JSONParser();
		Object objResponseBody = parser.parse(httpRet);
		jsonObjectResponseBody = (JSONObject) objResponseBody;
		retCode	= (String) jsonObjectResponseBody.get("retCode");
		if (beEmpty(retCode)) return "";
	}catch(Exception e){
		writeLog("error", "Exception when parse 'retCode' of CUHK response data, error= " + e.toString());
		return "";
	}
	
	if (!retCode.equals("000000")){
		if (retCode.equals("300004") || retCode.equals("300005")){
			obj.put("resultCode", gcResultCodeApiInvalidImsi);
			obj.put("resultText", gcResultTextApiInvalidImsi);
		}else if (retCode.equals("300006")){
			obj.put("resultCode", gcResultCodeApiNotOurImsi);
			obj.put("resultText", gcResultTextApiNotOurImsi);
		}else{
			obj.put("resultCode", gcResultCodeApiExecutionFail);
			obj.put("resultText", gcResultTextApiExecutionFail);
		}
	}

	if (retCode.equals("000000")){
		try{
			String	imsi	= (String) jsonObjectResponseBody.get("imsi");
			String	iccid	= (String) jsonObjectResponseBody.get("iccid");
			String	msisdn	= (String) jsonObjectResponseBody.get("msisdn");
			String	imsiStatus	= (String) jsonObjectResponseBody.get("lifeCycle");
			//writeLog("debug", "imsiStatus= " + imsiStatus);
			if (beEmpty(imsiStatus)) imsiStatus = "";
			if (imsiStatus.equals("0")){
				imsiStatus = "1";				//Inactive -> Not activated
			}else if (imsiStatus.equals("1")){
				imsiStatus = "2";				//Active -> Activated
			}else if (imsiStatus.equals("2")){
				imsiStatus = "5";				//Pending for top-up -> Pending for top-up
			}else if (imsiStatus.equals("3")){
				imsiStatus = "3";				//Locked -> Freeze
			}else if (imsiStatus.equals("4")){
				imsiStatus = "4";				//Expired -> Terminated
			}
			obj.put("imsi", imsi);
			obj.put("iccid", iccid);
			obj.put("msisdn", msisdn);
			obj.put("imsiStatus", imsiStatus);
			obj.put("imsiType", "Prepaid");
			obj.put("resultCode", gcResultCodeSuccess);
			obj.put("resultText", gcResultTextSuccess);
		}catch (Exception e){
			writeLog("error", "Exception when get imsi, iccid, msisdn, lifecycle of CUHK response data, error= " + e.toString());
			obj.put("resultCode", gcResultCodeApiExecutionFail);
			obj.put("resultText", gcResultTextApiExecutionFail);
		}
	}	//if (retCode.equals("000000")){

	sResponse = obj.toString();
	return sResponse;
}	//public String translateCUHKResponse(String httpRet){


/***************************************************************************************/

//將 CUHK 的 package 回應資料轉成我們回覆給client端的資料
public String translateCUHKPackageResponse(String httpRet, String imsiResponse, String timezone){
	String	sResponse	= imsiResponse;
	JSONObject obj=null;
	
	JSONObject jsonObjectResponseBody = null;
	String	retCode	= "";

	try{
		JSONParser	parser	= new JSONParser();
		Object objResponseBody = parser.parse(httpRet);
		jsonObjectResponseBody = (JSONObject) objResponseBody;
		retCode	= (String) jsonObjectResponseBody.get("retCode");
		if (beEmpty(retCode)) return sResponse;
		if (!retCode.equals("000000")) return sResponse;

		//將之前取得的IMSI資料String轉成JSON object
		parser	= new JSONParser();
		objResponseBody = parser.parse(imsiResponse);
		obj = (JSONObject) objResponseBody;
	}catch(Exception e){
		writeLog("error", "Exception when parse 'retCode' of CUHK response data, error= " + e.toString());
		return sResponse;
	}
	

	if (retCode.equals("000000")){
		List	l1	= new LinkedList();
		Map		m1	= null;
		int		i	= 0;
		String	packCode;
		String	effTime;
		String	expTime;
		JSONArray jsonPackages = null;
		try{
			jsonPackages = (JSONArray) jsonObjectResponseBody.get("packList");
			JSONObject jsonObjectPackage = null;
			for (i=0; i<jsonPackages.size(); i++) {	//把每個人的userId找出來比對
				jsonObjectPackage = (JSONObject) jsonPackages.get(i);
				packCode = (String) jsonObjectPackage.get("packCode");
				effTime = (String) jsonObjectPackage.get("effTime");
				expTime = (String) jsonObjectPackage.get("expTime");
				//SCT時區是GMT+8，轉為client端的timezone
				if (beEmpty(timezone)) timezone = "0";
				timezone = String.valueOf(Long.parseLong("-8") + Long.parseLong(timezone));
				effTime = changeTimezoneForADate(effTime, gcDateFormatDateAndTime, gcDateFormatDashYMDTime, timezone);
				expTime = changeTimezoneForADate(expTime, gcDateFormatDateAndTime, gcDateFormatDashYMDTime, timezone);
				m1 = new HashMap();
				m1.put("packageId", nullToString(packCode, ""));
				m1.put("productId","");
				m1.put("packageStatus", "");
				m1.put("totalDataVolume", "");
				m1.put("allUsedVolume", "");
				m1.put("todayUsedVolume", "");
				m1.put("expiryTime", nullToString(expTime, ""));
				m1.put("validityDays", "");
				m1.put("firstUsageTime", nullToString(effTime, ""));
				l1.add(m1);
			}	//for (i=0; i<jsonEntries.size(); i++) {	//把每個人的電話號碼找出來比對
		}catch (Exception e){
			writeLog("error", "Exception when parse CUHK server package response: " + e.toString());
		}
		obj.put("packages", l1);
		sResponse = obj.toString();
	}
	return sResponse;
}	//public String translateCUHKPackageResponse(String httpRet, String imsiResponse, String timezone){


/***************************************************************************************/

//將 CUHK 的 CDR 回應資料轉成我們回覆給client端的資料
public String translateCUHKCDRResponse(String httpRet, String imsiResponse, String timezone){
	String	sResponse	= imsiResponse;
	JSONObject obj=null;
	
	JSONObject jsonObjectResponseBody = null;
	String	retCode	= "";

	try{
		JSONParser	parser	= new JSONParser();
		Object objResponseBody = parser.parse(httpRet);
		jsonObjectResponseBody = (JSONObject) objResponseBody;
		retCode	= (String) jsonObjectResponseBody.get("retCode");
		if (beEmpty(retCode)) return sResponse;

		//將之前取得的IMSI資料String轉成JSON object
		parser	= new JSONParser();
		objResponseBody = parser.parse(imsiResponse);
		obj = (JSONObject) objResponseBody;

		if (!retCode.equals("000000"))
			obj.put("resultCodeCDR", gcResultCodeApiExecutionFail);
			obj.put("resultTextCDR", gcResultTextApiExecutionFail);
			sResponse = obj.toString();
			return sResponse;
		}
	}catch(Exception e){
		writeLog("error", "Exception when parse 'retCode' of CUHK response data, error= " + e.toString());
		return sResponse;
	}
	

	if (retCode.equals("000000")){
		obj.put("resultCodeCDR", gcResultCodeSuccess);
		obj.put("resultTextCDR", gcResultTextSuccess);
		List	l1	= new LinkedList();
		Map		m1	= null;
		int		i	= 0;
		String	cdrDate	= "";
		Long	cdrUsage;
		String	cdrLocation		= "";
		JSONArray jsonCdrs = null;
		try{
			jsonCdrs = (JSONArray) jsonObjectResponseBody.get("usageList");
			JSONObject jsonObjectCdr = null;
			for (i=0; i<jsonCdrs.size(); i++) {	//把每個人的userId找出來比對
				jsonObjectCdr = (JSONObject) jsonCdrs.get(i);
				cdrUsage = (Long)jsonObjectCdr.get("usage")/1000000;
				cdrLocation = (String)jsonObjectCdr.get("mccmnc");

				m1 = new HashMap();
				m1.put("cdrDate", nullToString(String.valueOf(cdrDate), ""));
				m1.put("cdrUsage", nullToString(String.valueOf(cdrUsage), ""));
				m1.put("cdrLocation", nullToString(String.valueOf(cdrLocation), ""));
				l1.add(m1);
			}	//for (i=0; i<jsonEntries.size(); i++) {	//把每個人的電話號碼找出來比對
		}catch (Exception e){
			writeLog("error", "Exception when parse CUHK server CDR response: " + e.toString());
		}
		obj.put("cdrs", l1);
		sResponse = obj.toString();
		writeLog("debug", "Respond to client(include CDR): " + sResponse);
	}
	return sResponse;
}	//public String translateCUHKResponse(String httpRet){




/**
 * HttpApiCodec
 *  
 * @author Chef
 *
 */
public class HttpApiCodec {
    
    private String[] secretKeyPool = gcCUHK3DESKey;
    
    /**
     * decode HexString
     * @param hexEncoded
     * @return
     * @throws Exception
     */
    public String decode(String hexEncoded) throws Exception {
        return decode(WDByteUtil.HEX2Bytes(hexEncoded));
    }
    
    /**
     * decode byte array.
     * @param encodedBytes
     * @return
     * @throws Exception
     */
    @SuppressWarnings("unused")
    public String decode(byte[] encodedBytes) throws Exception {   
        String hexLength = decodeLength(encodedBytes);
        String hexSecIdx = decodeSecIdx(encodedBytes);
        String secretKey = getSecretKey(hexSecIdx);
        String encrypted = decodeHexText(encodedBytes);
        String hexMAC    = decodeMAC(encodedBytes, hexSecIdx, secretKey, encrypted);
        return decrypt2Text(encrypted, secretKey);
    }

    /**
     * @param encodeBytes
     * @param hexSecIdx
     * @param secretKey
     * @param encrypted
     * @return
     * @throws Exception
     */
    protected String decodeMAC(byte[] encodeBytes, String hexSecIdx, String secretKey, String encrypted)
            throws Exception {
        byte[] bytesMAC = Arrays.copyOfRange(encodeBytes, encodeBytes.length - 8, encodeBytes.length);
        String hexMAC = WDByteUtil.bytes2HEX(bytesMAC);
        String myHexMAC = genMac(hexSecIdx, secretKey, encrypted);
        if (!myHexMAC.equals(hexMAC)) {
            throw new Exception("MESSAGE_MAC_ERROR");
        }
        return hexMAC;
    }

    /**
     * 
     * @param encodeBytes
     * @return
     */
    protected String decodeHexText(byte[] encodeBytes) {
        byte[] byteBuf = Arrays.copyOfRange(encodeBytes, 3, encodeBytes.length - 8);
        String hexEncrypted = WDByteUtil.bytes2HEX(byteBuf);
        return hexEncrypted;
    }
    
    /**
     * 
     * @param encodeBytes
     * @return
     * @throws Exception
     */
    protected String decodeSecIdx(byte[] encodeBytes) throws Exception {
        byte[] byteBuf = Arrays.copyOfRange(encodeBytes, 2, 3);
        String hexSecIdx = WDByteUtil.bytes2HEX(byteBuf);
        int intSecIdx = Integer.valueOf(hexSecIdx, 16);
        if (intSecIdx < 1 || intSecIdx > 5) {
            throw new Exception("INVALID_SECRET_INDEX");
        }
        return hexSecIdx;
    }
    
    /**
     * 
     * @param encodeBytes
     * @return
     * @throws Exception
     */
    protected String decodeLength(byte[] encodeBytes) throws Exception {
        byte[] byteBuf = Arrays.copyOfRange(encodeBytes, 0, 2);
        int length = Integer.valueOf(WDByteUtil.bytes2HEX(byteBuf), 16);
        if (length != encodeBytes.length - 2) {
            throw new Exception("INVALID_MESSAGE_LENGTH");
        }
        return WDByteUtil.bytes2HEX(byteBuf);
    }


    /**
     * 
     * @param plainText
     * @return
     * @throws Exception
     */
    public String encode(String plainText) throws Exception {
        String hexSecIdx = String.format("%02X", new Random().nextInt(5) + 1);
        return encode(plainText, hexSecIdx);
    }
    
    /**
     * 
     * @param plainText
     * @param hexSecIdx
     * @return
     */
    public String encode(String plainText, String hexSecIdx) throws Exception {
        String secretKey = getSecretKey(hexSecIdx);
        String hexEncrypted = encryptText(plainText, secretKey);
        String hexMAC = genMac(hexSecIdx, secretKey, hexEncrypted);
        String hexLength = String.format("%04X", WDByteUtil.HEX2Bytes(hexSecIdx + hexEncrypted + hexMAC).length);
        return hexLength + hexSecIdx + hexEncrypted + hexMAC;
    }
    
    /**
     * 根据密钥 + 密钥索引 获取 DES3-ECB的MAC
     * @param secretIdx
     * @param secretKey
     * @param hexEncrypted
     * @return
     */
    public String genMac(String secretIdx, String secretKey, String hexEncrypted) {
        hexEncrypted = encryptHex(secretIdx + hexEncrypted, secretKey);
        byte[] byteEncrypted = WDByteUtil.HEX2Bytes(hexEncrypted);
        byte[] byteMAC = Arrays.copyOfRange(byteEncrypted, byteEncrypted.length - 8, byteEncrypted.length);
        return WDByteUtil.bytes2HEX(byteMAC);
    }
    
    
    /**
     * 
     * @param hexEncrypted
     * @param secretKey
     * @return
     * @throws UnsupportedEncodingException
     */
    public String decrypt2Text(String hexEncrypted, String secretKey) throws UnsupportedEncodingException {
        
        String hexDecrypted = decrypt2Hex(hexEncrypted, secretKey);
        return new String(WDByteUtil.HEX2Bytes(hexDecrypted), "UTF-8");
    }
    
    /**
     * 
     * @param hexEncrypted
     * @param secretKey
     * @return
     */
    public String decrypt2Hex(String hexEncrypted, String secretKey) {
        String hexDecrypted = WD3DesCryptoUtil.ecb_decrypt(secretKey, hexEncrypted, Padding.NoPadding);
        return WDStringUtil.trimTail(hexDecrypted, "FF");
    }

    /**
     * Encrypt plain text by 3DES-ECB.
     * @param plainText
     * @param secretKey
     * @return
     * @throws UnsupportedEncodingException
     */
    public String encryptText(String plainText, String secretKey) throws UnsupportedEncodingException  {
        return encryptHex(WDByteUtil.bytes2HEX(plainText.getBytes("UTF-8")), secretKey);
    }
    
    /**
     * 
     * Encrypt HEX-String TEXT by 3DES-ECB.
     * @param hexText HEX-String Text.
     * @param secretKey SecretKey
     * @return
     */
    public String encryptHex(String hexText, String secretKey) {

        if (hexText.length() % 16 != 0) {
            int padLen = 16 - hexText.length() % 16;
            hexText = WDStringUtil.paddingTail(hexText, hexText.length() + padLen, "F");
        }
        return WD3DesCryptoUtil.ecb_encrypt(secretKey, hexText, Padding.NoPadding);
    }
    
    /**
     * Get SecretKey by Secret Index(HEXString)
     * HEXSecretIndex["01", "02", "03", "04", "05"]
     * @param hexSecIdex  HEX Secret Index
     * @return
     * @throws Exception 
     * @throws NumberFormatException 
     */
    public String getSecretKey(String hexSecIdex) throws NumberFormatException, Exception {
        return getSecretKey(Integer.valueOf(hexSecIdex, 16) - 1);
    }

    
    /**
     * Get SecretKey by secretKeypool.index.
     * @param index secretKeyPool.index
     * @return SecretKey
     */
    private String getSecretKey(int index) throws Exception {
        if (index > 4) {
            throw new Exception("INVALID_SECRET_INDEX");
        }
        return secretKeyPool[index];
    }

}

%>