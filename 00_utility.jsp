<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8" %>

<%@ page import="java.net.*" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.regex.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.io.*" %>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="org.apache.log4j.Logger" %>

<%@ page import="javax.net.ssl.*" %>
<%@ page import="java.security.cert.*" %>


<%@page import="org.json.simple.JSONObject" %>

<%@page import="java.security.MessageDigest" %>

<%!
//注意：因為有些程式使用jxl.jar執行Excel檔案匯出，而jxl.jar有自己的Boolean，所以這裡的Boolean都宣告為java.lang.Boolean，以免compile失敗

/*********************************************************************************************************************/
//檢查字串是否為空值
public java.lang.Boolean beEmpty(String s) {
	return (s==null || s.length()<1);
}	//public java.lang.Boolean beEmpty(String s) {
/*********************************************************************************************************************/

/*********************************************************************************************************************/
//檢查字串是否不為空值
public java.lang.Boolean notEmpty(String s) {
	return (s!=null && s.length()>0);
}	//public java.lang.Boolean notEmpty(String s) {

/*********************************************************************************************************************/

//若字串為null或空值就改為另一字串(例如""或"&nbsp;")
public String nullToString(String sOld, String sReplace){
	return (beEmpty(sOld)?sReplace:sOld);
}
/*********************************************************************************************************************/
//檢查日期格式是否正確
public java.lang.Boolean isDate(String date, String DATE_FORMAT){
	try {
		DateFormat df = new SimpleDateFormat(DATE_FORMAT);
		df.setLenient(false);
		df.parse(date);
		return true;
	} catch (Exception e) {
		return false;
	}
}

/*********************************************************************************************************************/
//取得目前系統時間，並依指定的格式產生字串
public String getDateTimeNow(String sDateFormat){
	/************************************
	sDateFormat:	指定的格式，例如"yyyyMMdd-HHmmss"或"yyyyMMdd"
	*************************************/
	String s;
	SimpleDateFormat nowdate = new java.text.SimpleDateFormat(sDateFormat);
	nowdate.setTimeZone(TimeZone.getTimeZone("GMT+8"));
	s = nowdate.format(new java.util.Date());
	return s;
}	//public String getDateTimeNow(String sDateFormat){

/*********************************************************************************************************************/

//取得目前系統時間，並依指定的格式產生字串
public String getDateTimeNowGMT(String sDateFormat){
	/************************************
	sDateFormat:	指定的格式，例如"yyyyMMdd-HHmmss"或"yyyyMMdd"
	*************************************/
	String s;
	SimpleDateFormat nowdate = new java.text.SimpleDateFormat(sDateFormat);
	nowdate.setTimeZone(TimeZone.getTimeZone("GMT+0"));
	s = nowdate.format(new java.util.Date());
	return s;
}	//public String getDateTimeNow(String sDateFormat){

public String getDateTimeNowGMTMiliSec(String sDateFormat){
	/************************************
	sDateFormat:	指定的格式，例如"yyyyMMdd-HHmmss"或"yyyyMMdd"
	*************************************/
	String s;
	String sResponse = "";
	try{
		SimpleDateFormat nowdate = new java.text.SimpleDateFormat(sDateFormat);
		nowdate.setTimeZone(TimeZone.getTimeZone("GMT+0"));
		s = nowdate.format(new java.util.Date());
		Date d2 = nowdate.parse(s);
		long nowMiliSec = d2.getTime();
		sResponse = String.valueOf(nowMiliSec);
	}catch (Exception e){
		//return "";
	}
	
	return sResponse;
}	//public String getDateTimeNow(String sDateFormat){

/*********************************************************************************************************************/

//將轉換某個時間的時區
public String changeTimezoneForADate(String sOldDate, String sOldDateFormat, String sNewDateFormat, String hourDiff){
	String s;
	String sResponse = "";
	try{
		SimpleDateFormat nowdate = new java.text.SimpleDateFormat(sOldDateFormat);
		Date dOld = nowdate.parse(sOldDate);
		Date dNew = new Date(dOld.getTime() + Long.parseLong(hourDiff) * 3600 * 1000);	//Milisecond
		nowdate = new java.text.SimpleDateFormat(sNewDateFormat);
		sResponse = nowdate.format(dNew);;
	}catch (Exception e){
		//return "";
	}
	
	return sResponse;
}

/*********************************************************************************************************************/

//取得昨天日期
public String getYesterday(String sDateFormat){
	/************************************
	sDateFormat:	指定的格式，例如"yyyyMMdd-HHmmss"或"yyyyMMdd"
	*************************************/
	TimeZone.setDefault(TimeZone.getTimeZone("Asia/Taipei"));	//將 Timezone 設為 GMT+8
	java.util.Calendar cal = java.util.Calendar.getInstance();//使用預設時區和語言環境獲得一個日曆。  
	cal.add(java.util.Calendar.DAY_OF_MONTH, -1);//取當前日期的前一天.  
	//cal.add(java.util.Calendar.DAY_OF_MONTH, +1);//取當前日期的後一天.  
	
	//通過格式化輸出日期  
	java.text.SimpleDateFormat format = new java.text.SimpleDateFormat(sDateFormat);
 
	return format.format(cal.getTime());

}	//public String getDateTimeNow(String sDateFormat){

/*********************************************************************************************************************/
//取得七天前日期
public String getWeekAgo(String sDateFormat){
	/************************************
	sDateFormat:	指定的格式，例如"yyyyMMdd-HHmmss"或"yyyyMMdd"
	*************************************/
	TimeZone.setDefault(TimeZone.getTimeZone("Asia/Taipei"));	//將 Timezone 設為 GMT+8
	java.util.Calendar cal = java.util.Calendar.getInstance();//使用預設時區和語言環境獲得一個日曆。  
	cal.add(java.util.Calendar.DAY_OF_MONTH, -7);//取當前日期的前7天.  
	//cal.add(java.util.Calendar.DAY_OF_MONTH, +1);//取當前日期的後一天.  
	
	//通過格式化輸出日期  
	java.text.SimpleDateFormat format = new java.text.SimpleDateFormat(sDateFormat);
 
	return format.format(cal.getTime());

}	//public String getDateTimeNow(String sDateFormat){

/*********************************************************************************************************************/
//取得30天前日期
public String getThirtyDaysAgo(String sDateFormat){
	/************************************
	sDateFormat:	指定的格式，例如"yyyyMMdd-HHmmss"或"yyyyMMdd"
	*************************************/
	TimeZone.setDefault(TimeZone.getTimeZone("Asia/Taipei"));	//將 Timezone 設為 GMT+8
	java.util.Calendar cal = java.util.Calendar.getInstance();//使用預設時區和語言環境獲得一個日曆。  
	cal.add(java.util.Calendar.DAY_OF_MONTH, -30);//取當前日期的前30天.  
	//cal.add(java.util.Calendar.DAY_OF_MONTH, +1);//取當前日期的後一天.  
	
	//通過格式化輸出日期  
	java.text.SimpleDateFormat format = new java.text.SimpleDateFormat(sDateFormat);
 
	return format.format(cal.getTime());

}	//public String getDateTimeNow(String sDateFormat){

/*********************************************************************************************************************/
//取得12個月前日期
public String getTwelveMonthsAgo(String sDateFormat){
	/************************************
	sDateFormat:	指定的格式，例如"yyyyMMdd-HHmmss"或"yyyyMMdd"
	*************************************/
	TimeZone.setDefault(TimeZone.getTimeZone("Asia/Taipei"));	//將 Timezone 設為 GMT+8
	java.util.Calendar cal = java.util.Calendar.getInstance();//使用預設時區和語言環境獲得一個日曆。  
	cal.add(java.util.Calendar.MONTH, -12);//取當前日期的前12個月.  
	
	//通過格式化輸出日期  
	java.text.SimpleDateFormat format = new java.text.SimpleDateFormat(sDateFormat);
 
	return format.format(cal.getTime());

}	//public String getDateTimeNow(String sDateFormat){

/*********************************************************************************************************************/
//判斷某個日期是否已過期
public java.lang.Boolean isExpired(String sExpiryDate){
	if (beEmpty(sExpiryDate)) return false;
	java.lang.Boolean bExpired = true;
	try {
		TimeZone.setDefault(TimeZone.getTimeZone("Asia/Taipei"));	//將 Timezone 設為 GMT+8
		java.util.Calendar cal = java.util.Calendar.getInstance();//使用預設時區和語言環境獲得一個日曆。  
		java.util.Date dateNow = cal.getTime();	//目前時間
		SimpleDateFormat sdf = new SimpleDateFormat(gcDateFormatDashYMDTime);
		java.util.Date dateExpiry = sdf.parse(sExpiryDate);	//過期的時間
		bExpired = dateNow.after(dateExpiry);	//若目前時間超過過期的時間，則回覆true
	} catch (Exception e) {
		e.printStackTrace();
		writeLog("error", "Parsing date exception= " + e.toString());
		return true;
	}
	return bExpired;
}

/*********************************************************************************************************************/

/**
	* 數字不足部份補零回傳
	* @param str 字串
	* @param lenSize 字串數字最大長度,不足的部份補零
	* @return 回傳補零後字串數字
*/
public String MakesUpZero(String str, int lenSize) {
	String zero = "0000000000";
	String returnValue = zero;
	
	returnValue = zero + str;
	
	return returnValue.substring(returnValue.length() - lenSize);

}

/*********************************************************************************************************************/

//產生6碼的隨機數字
public String generateRandomNumber(){
	String txtRandom = String.valueOf(Math.round(Math.random()*1000000));
	txtRandom = MakesUpZero(txtRandom, 6);	//不足4碼的話，將前面補0

	return txtRandom;
}

/*********************************************************************************************************************/
//寫入檔案
public java.lang.Boolean writeToFile(String sFilePath, String content){
	//content是寫入的內容
	java.lang.Boolean bOK = true;
	String s = "";

	if (beEmpty(content)) return false;

	Writer out = null;
	try {
		out = new BufferedWriter(new OutputStreamWriter(
		new FileOutputStream(sFilePath, false), "UTF-8"));	//指定UTF-8
		out.write(content);
		out.close();
	}catch(Exception e){
		s = "Error write to file, filePath=" + sFilePath + "<p>" + e.toString();
		writeLog("error", s);
		bOK = false;
	}

	return bOK;
}	//public java.lang.Boolean writeToFile(String sFilePath, String content){

/*********************************************************************************************************************/
//讀取某個文字檔的內容
public String readFileContent(String sPath){
	//sPath:檔案的路徑及檔名，呼叫此函數前請先以【String fileName=getServletContext().getRealPath("directory/jsp.txt");】取得檔案的徑名，然後以此徑名做為sPath參數送給此函數
	java.io.File file = new java.io.File(sPath);
	FileInputStream fis = null;
	BufferedInputStream bis = null;
	DataInputStream dis = null;
	String content = "";
	try {
		fis = new FileInputStream(file);
		bis = new BufferedInputStream(fis);
		dis = new DataInputStream(bis);
		while (dis.available() != 0) {
			content += dis.readLine();
		}
		content = new String(content.getBytes("8859_1"),"utf-8");
	} catch (FileNotFoundException e) {
		content = "";
		writeLog("error", "readFileContent error, sPath: " + sPath + ", desc: " + e.toString(), "utility");
	} catch (IOException e) {
		content = "";
		writeLog("error", "readFileContent error, sPath: " + sPath + ", desc: " + e.toString(), "utility");
	}finally{
		if (dis!=null){ try{dis.close();}catch (Exception ignored) {}}
		if (bis!=null){ try{bis.close();}catch (Exception ignored) {}}
		if (fis!=null){ try{fis.close();}catch (Exception ignored) {}}
	}
	return content;
}

/*********************************************************************************************************************/
//刪除某個檔案
public java.lang.Boolean DeleteFile(String sFileName){
	java.lang.Boolean bOK = true;
	if (sFileName==null || sFileName.length()<1)	return false;
	
	java.io.File f = new java.io.File(sFileName);
	if(f.exists()){//檢查是否存在
		writeLog("info", "delete file: " + sFileName, "utility");
		f.delete();//刪除文件
	} 
	return bOK;
}	//public java.lang.Boolean DeleteFile(String sPath, String sFileName){

/*********************************************************************************************************************/
//某個檔案是否存在
public java.lang.Boolean isFileExist(String sFileName){
	java.lang.Boolean bOK = false;
	if (sFileName==null || sFileName.length()<1)	return false;
	
	java.io.File f = new java.io.File(sFileName);
	if(f.exists()){//檔案存在
		bOK = true;
	} 
	return bOK;
}	//public java.lang.Boolean DeleteFile(String sPath, String sFileName){

/*********************************************************************************************************************/
//判斷字串內容是否為數字
public java.lang.Boolean isNumeric(String number) { 
	try {
		Integer.parseInt(number);
		return true;
	}catch (NumberFormatException sqo) {
		return false;
	}
}

/*********************************************************************************************************************/
public void writeLog(String sLevel, String sLog, String sClass){
	if (beEmpty(sClass)) sClass = "NoClass";
	Logger logger = Logger.getLogger(sClass);
	writeToLog(sLevel, sLog, logger);
}
public void writeLog(String sLevel, String sLog){
	Logger logger = Logger.getLogger(this.getClass());
	writeToLog(sLevel, sLog, logger);
}
public void writeToLog(String sLevel, String sLog, Logger logger){
	if (sLevel.equalsIgnoreCase("debug"))	logger.debug(sLog);
	if (sLevel.equalsIgnoreCase("info"))	logger.info(sLog);
	if (sLevel.equalsIgnoreCase("warn"))	logger.warn(sLog);
	if (sLevel.equalsIgnoreCase("error"))	logger.error(sLog);
	if (sLevel.equalsIgnoreCase("fatal"))	logger.fatal(sLog);
	//org.apache.log4j.Layout.DateLayout l = DateLayout();
	//logger.info(l.getTimeZone());
}

/*********************************************************************************************************************/
public String md5(String str) {
	String md5=null;
	try {
		MessageDigest md=MessageDigest.getInstance("MD5");
		byte[] barr=md.digest(str.getBytes());
		StringBuffer sb=new StringBuffer();
		for (int i=0; i < barr.length; i++) {sb.append(byte2Hex(barr[i]));}
		String hex=sb.toString();
		md5=hex.toUpperCase();
		if (md5==null) md5 = "";
	}catch(Exception e){
		e.printStackTrace();
		return "";
	}
	return md5;
}

/*********************************************************************************************************************/
public String byte2Hex(byte b) {
	String[] h={"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"};
	int i=b;
	if (i < 0) {i += 256;}
	return h[i/16] + h[i%16];
}

/*********************************************************************************************************************/
//驗證 HTTP request 資料是否合法，欄位是否有少
public JSONObject validateHttpRequest(String accountId, String timestamp, String signature, String httpBody, String userProfile, String supplierProfile){
	JSONObject	obj			= new JSONObject();
	
	String		imsi		= "";
	String		iccid		= "";

	if (beEmpty(httpBody)){
		writeLog("info", "Request body is empty, quit...");
		obj.put("resultCode", gcResultCodeParametersNotEnough);
		obj.put("resultText", gcResultTextParametersNotEnough);
		return obj;
	}else{
		writeLog("debug", "Request body= " + httpBody);
	}

	try{
		JSONParser	parser			= new JSONParser();
		Object		objBody			= parser.parse(httpBody);
		JSONObject	jsonObjectBody	= (JSONObject) objBody;
		try{
			imsi = (String) jsonObjectBody.get("imsi");
		}catch (Exception e){
			imsi = "";
		}
		try{
			iccid = (String) jsonObjectBody.get("iccid");
		}catch (Exception e){
			iccid = "";
		}
	}catch (Exception e) {
		writeLog("error", "Parse request body json error: " + e.toString());
		writeLog("debug", "Respond error code= " + gcResultCodeParametersNotEnough + ",error message= " + gcResultTextParametersNotEnough);
		obj.put("resultCode", gcResultCodeParametersNotEnough);
		obj.put("resultText", gcResultTextParametersNotEnough);
		return obj;
	}

	if (beEmpty(accountId) || beEmpty(timestamp) || (beEmpty(imsi) && beEmpty(iccid)) || beEmpty(signature)){
		writeLog("debug", "Respond error code= " + gcResultCodeParametersNotEnough + ",error message= " + gcResultTextParametersNotEnough);
		obj.put("resultCode", gcResultCodeParametersNotEnough);
		obj.put("resultText", gcResultTextParametersNotEnough);
		return obj;
	}
	
	JSONObject jsonObjectUser	= getUserProfileJson(userProfile, accountId);
	String	timezone			= "";
	
	if (jsonObjectUser==null){
		writeLog("debug", gcResultCodeNoLoginInfoFound + ":" + gcResultTextNoLoginInfoFound);
		obj.put("resultCode", gcResultCodeNoLoginInfoFound);
		obj.put("resultText", gcResultTextNoLoginInfoFound);
		return obj;
	}else{
		//驗證簽名是否正確
		String userkey = (String) jsonObjectUser.get("userKey");
		timezone = (String) jsonObjectUser.get("timezone");
		if (!isSignatureValid(signature, accountId+timestamp+httpBody+userkey)){
			writeLog("debug", "Invalid signature return " + gcResultCodeInvalidSignature + ":" + gcResultTextInvalidSignature);
			obj.put("resultCode", gcResultCodeInvalidSignature);
			obj.put("resultText", gcResultTextInvalidSignature);
			return obj;
		}
	}

	if (!isTimestampValid(timestamp, gcDateFormatDashYMDTime)){
		writeLog("debug", "Invalid timestamp return " + gcResultCodeRequestTimestampIsInvalid + ":" + gcResultTextRequestTimestampIsInvalid);
		obj.put("resultCode", gcResultCodeRequestTimestampIsInvalid);
		obj.put("resultText", gcResultTextRequestTimestampIsInvalid);
		return obj;
	}

	String imsiSupplier = getImsiSupplier(supplierProfile, imsi, iccid);
	if (beEmpty(imsiSupplier)){
		writeLog("debug", "No supplier API can be found for IMSI= " + imsi + ", ICCID= " + iccid + ", return " + gcResultCodeImsiApiNotSupport + ":" + gcResultTextImsiApiNotSupport);
		obj.put("resultCode", gcResultCodeImsiApiNotSupport);
		obj.put("resultText", gcResultTextImsiApiNotSupport);
		return obj;
	}

	obj.put("resultCode", gcResultCodeSuccess);
	obj.put("resultText", gcResultTextSuccess);
	obj.put("imsi", nullToString(imsi, ""));
	obj.put("iccid", nullToString(iccid, ""));
	obj.put("timezone", timezone);
	obj.put("imsiSupplier", imsiSupplier);
	
	return obj;
}	//public JSONObject validateHttpRequest(String accountId, String timestamp, String signature, String httpBody, String userProfile, String supplierProfile){

/*********************************************************************************************************************/
public JSONObject getUserProfileJson(String usersFile, String userId){
	int			i					= 0;
	String users = readFileContent(usersFile);
	String tempUserId;
	JSONParser	parser				= new JSONParser();
	try {
		Object objBody = parser.parse(users);
		JSONObject jsonObjectBody = (JSONObject) objBody;
		JSONArray jsonUsers = (JSONArray) jsonObjectBody.get("users");
		JSONObject jsonObjectUser = null;
		
		for (i=0; i<jsonUsers.size(); i++) {	//把每個人的userId找出來比對
			jsonObjectUser = (JSONObject) jsonUsers.get(i);
			tempUserId = (String) jsonObjectUser.get("userId");
			if (tempUserId.equals(userId)) return jsonObjectUser;
		}	//for (i=0; i<jsonEntries.size(); i++) {	//把每個人的電話號碼找出來比對
		writeLog("debug", "找不到符合的user...");
	} catch (Exception e) {
		writeLog("error", "getUserProfileJson error: " + e.toString());
		return null;
	}
	return null;
}

/*********************************************************************************************************************/
public java.lang.Boolean isSignatureValid(String signature, String sourceText) {
	String s = md5(sourceText);
	if (s.equalsIgnoreCase(signature)){
		return true;
	}else{
		writeLog("debug", "Invalid signature, correct signature= " + s);
		return false;
	}
}	//public java.lang.Boolean beEmpty(String s) {

/*********************************************************************************************************************/
public java.lang.Boolean isTimestampValid(String timestamp, String sDateFormat) {
	SimpleDateFormat nowdate = new java.text.SimpleDateFormat(sDateFormat);
	nowdate.setTimeZone(TimeZone.getTimeZone("GMT+0"));
	String sNow = nowdate.format(new java.util.Date());
	writeLog("debug", "Current GMT+0 time= " + sNow);
	Date d1 = null;
	Date d2 = null;
	try {
	    d1 = nowdate.parse(timestamp);
	    d2 = nowdate.parse(sNow);
		long diff = d2.getTime() - d1.getTime();
		long diffSeconds = diff / 1000;
		
		if (diffSeconds>600 || diffSeconds<-600){
			writeLog("debug", "Invalid timestamp, the time difference in second= " + String.valueOf(diffSeconds));
			return false;
		}
	} catch (Exception e) {
		writeLog("error", "Failed to compare timestamp, error= " + e.toString());
	    return false;
	}
	return true;
}

/*********************************************************************************************************************/
public String getImsiSupplier(String suppliersFile, String imsi, String iccid){
	int		i			= 0;
	String	suppliers	= readFileContent(suppliersFile);
	String	tempImsiStart;
	String	tempIccidStart;
	String	tempSupplier;
	JSONParser	parser				= new JSONParser();
	try {
		Object objBody = parser.parse(suppliers);
		JSONObject jsonObjectBody = (JSONObject) objBody;
		JSONArray jsonSuppliers = (JSONArray) jsonObjectBody.get("suppliers");
		JSONObject jsonObjectSupplier = null;

		for (i=0; i<jsonSuppliers.size(); i++) {	//把每個人的userId找出來比對
			jsonObjectSupplier = (JSONObject) jsonSuppliers.get(i);
			try{
				tempImsiStart = (String) jsonObjectSupplier.get("imsiStart");
			}catch (Exception e){
				tempImsiStart = "";
			}
			try{
				tempIccidStart = (String) jsonObjectSupplier.get("iccidStart");
			}catch (Exception e){
				tempIccidStart = "";
			}

			if (notEmpty(imsi) && notEmpty(tempImsiStart) && imsi.startsWith(tempImsiStart)){
				tempSupplier = (String) jsonObjectSupplier.get("supplier");
				writeLog("debug", "Found IMSI supplier= " + tempSupplier);
				return tempSupplier;
			}
			if (notEmpty(iccid) && notEmpty(tempIccidStart) && iccid.startsWith(tempIccidStart)){
				tempSupplier = (String) jsonObjectSupplier.get("supplier");
				writeLog("debug", "Found ICCID supplier= " + tempSupplier);
				return tempSupplier;
			}
		}	//for (i=0; i<jsonEntries.size(); i++) {	//把每個人的電話號碼找出來比對
		writeLog("debug", "找不到符合的Supplier...");
	} catch (Exception e) {
		writeLog("error", "getImsiSupplier error: " + e.toString());
		return "";
	}

	return "";
}

/*********************************************************************************************************************/

%>