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
<%@include file="00_supplier_API_SCT.jsp"%>
<%@include file="00_supplier_API_CUHK.jsp"%>

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

writeLog("debug", "CDR query, receive request header, accountId= " + accountId + ",timestamp= " + timestamp + ",signature= " + signature);

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

String	USERS_JSON_FILE		= application.getRealPath("/00_users.json");
String	SUPPLIERS_JSON_FILE	= application.getRealPath("/00_suppliers.json");
obj = validateHttpRequest(accountId, timestamp, signature, contentStr, USERS_JSON_FILE, SUPPLIERS_JSON_FILE);

String	sResultCode		= "";
String	sResultText		= "";

try{
	sResultCode = (String) obj.get("resultCode");
	sResultText = (String) obj.get("resultText");
}catch (Exception e){
	sResultCode = "";
}
writeLog("debug", "HTTP request validation result: " + sResultCode + ":" + sResultText);
if (beEmpty(sResultCode) || !sResultCode.equals(gcResultCodeSuccess)){
	out.print(obj);
	out.flush();
	return;
}

String	imsi			= (String) obj.get("imsi");
String	iccid			= (String) obj.get("iccid");
String	timezone		= (String) obj.get("timezone");
String	imsiSupplier	= (String) obj.get("imsiSupplier");

String	imsiCdr		= "";
if (imsiSupplier.equals("sct")) imsiCdr = imsiCdrQueryForSCT(imsi, timezone);
if (imsiSupplier.equals("cuhk")) imsiCdr = imsiCdrQueryForCUHK(imsi, timezone);

if (beEmpty(imsiCdr)){
	obj.put("resultCode", gcResultCodeApiExecutionFail);
	obj.put("resultText", gcResultTextApiExecutionFail);
	out.print(obj);
}else{
	out.print(imsiCdr);
}

%>