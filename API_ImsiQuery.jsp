<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8" %>
<%@ page trimDirectiveWhitespaces="true" %>

<%@page import="java.net.InetAddress" %>
<%@page import="org.json.simple.JSONObject" %>
<%@page import="org.json.simple.parser.JSONParser" %>
<%@page import="org.json.simple.parser.ParseException" %>
<%@page import="org.json.simple.JSONArray" %>
<%@page import="org.apache.commons.io.IOUtils" %>
<%@page import="java.util.*" %>

<%@include file="00_constants.jsp"%>
<%@include file="00_utility.jsp"%>

<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html;charset=utf-8");
response.setHeader("Pragma","no-cache"); 
response.setHeader("Cache-Control","no-cache"); 
response.setDateHeader("Expires", 0); 

out.clear();	//注意，一定要有out.clear();，要不然client端無法解析XML，會認為XML格式有問題

/*********************開始做事吧*********************/
JSONObject obj=new JSONObject();

/************************************呼叫範例*******************************
************************************呼叫範例*******************************/

String 		accountId = nullToString(request.getHeader("IM-ACCOUNT"), "");
String 		timestamp = nullToString(request.getHeader("IM-TIMESTAMP"), "");
String 		signature = nullToString(request.getHeader("IM-SIGNATURE"), "");

writeLog("debug", "Receive request header, accountId= " + accountId + ",timestamp= " + timestamp + ",signature= " + signature);

InputStream	is	= null;
String		contentStr	= "";

//取得POST內容
try {
	is = request.getInputStream();
	contentStr= IOUtils.toString(is, "utf-8");
} catch (IOException e) {
	e.printStackTrace();
	writeLog("error", "\nUnable to get request body: " + e.toString());
	return;
}

if (beEmpty(contentStr)){
	out.println("no content");
	writeLog("info", "Request body is empty, quit...");
	return;
}else{
	writeLog("debug", "Request body= " + contentStr);
}

String		imsi			= "";
String		iccid			= "";

try{
	JSONParser	parser			= new JSONParser();
	Object		objBody			= parser.parse(contentStr);
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
	out.print(obj);
	out.flush();
	return;
}

String	sResultCode		= gcResultCodeSuccess;
String	sResultText		= gcResultTextSuccess;

if (beEmpty(accountId) || beEmpty(timestamp) || (beEmpty(imsi) && beEmpty(iccid)) || beEmpty(signature)){
	writeLog("debug", "Respond error code= " + gcResultCodeParametersNotEnough + ",error message= " + gcResultTextParametersNotEnough);
	obj.put("resultCode", gcResultCodeParametersNotEnough);
	obj.put("resultText", gcResultTextParametersNotEnough);
	out.print(obj);
	out.flush();
	return;
}

String	USERS_JSON_FILE		= application.getRealPath("/00_users.json");
String	SUPPLIERS_JSON_FILE	= application.getRealPath("/00_suppliers.json");
JSONObject jsonObjectUser	= getUserProfileJson(USERS_JSON_FILE, accountId);
String	timezone			= "";

if (jsonObjectUser==null){
	writeLog("debug", gcResultCodeNoLoginInfoFound + ":" + gcResultTextNoLoginInfoFound);
	obj.put("resultCode", gcResultCodeNoLoginInfoFound);
	obj.put("resultText", gcResultTextNoLoginInfoFound);
	out.print(obj);
	out.flush();
	return;
}else{
	//驗證簽名是否正確
	String userkey = (String) jsonObjectUser.get("userKey");
	timezone = (String) jsonObjectUser.get("timezone");
	if (!isSignatureValid(signature, accountId+timestamp+contentStr+userkey)){
		writeLog("debug", "Invalid signature return " + gcResultCodeInvalidSignature + ":" + gcResultTextInvalidSignature);
		obj.put("resultCode", gcResultCodeInvalidSignature);
		obj.put("resultText", gcResultTextInvalidSignature);
		out.print(obj);
		out.flush();
		return;
	}
	//out.print(userkey);
}

if (!isTimestampValid(timestamp, gcDateFormatDashYMDTime)){
	writeLog("debug", "Invalid timestamp return " + gcResultCodeRequestTimestampIsInvalid + ":" + gcResultTextRequestTimestampIsInvalid);
	obj.put("resultCode", gcResultCodeRequestTimestampIsInvalid);
	obj.put("resultText", gcResultTextRequestTimestampIsInvalid);
	out.print(obj);
	out.flush();
	return;
}


String imsiSupplier = getImsiSupplier(SUPPLIERS_JSON_FILE, imsi, iccid);
if (beEmpty(imsiSupplier)){
	writeLog("debug", "No supplier API can be found for IMSI= " + imsi + ", ICCID= " + iccid + ", return " + gcResultCodeImsiApiNotSupport + ":" + gcResultTextImsiApiNotSupport);
	obj.put("resultCode", gcResultCodeImsiApiNotSupport);
	obj.put("resultText", gcResultTextImsiApiNotSupport);
	out.print(obj);
	out.flush();
	return;
}

String	imsiProfile	= "";
if (imsiSupplier.equals("sct")) imsiProfile = imsiProfileQueryForSCT(imsi, timezone);

if (beEmpty(imsiProfile)){
	obj.put("resultCode", gcResultCodeApiExecutionFail);
	obj.put("resultText", gcResultTextApiExecutionFail);
	out.print(obj);
}else{
	out.print(imsiProfile);
}

%>