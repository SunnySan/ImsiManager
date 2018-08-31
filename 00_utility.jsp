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
	if (s.equals(signature)){
		return true;
	}else{
		return false;
	}
}	//public java.lang.Boolean beEmpty(String s) {

/*********************************************************************************************************************/

%>