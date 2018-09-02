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
String accountId		= nullToString(request.getParameter("account"), "");
String accountPassword	= nullToString(request.getParameter("password"), "");

writeLog("debug", "Receive login request, accountId= " + accountId);

String	sResultCode		= gcResultCodeSuccess;
String	sResultText		= gcResultTextSuccess;

if (beEmpty(accountId) || beEmpty(accountPassword)){
	writeLog("debug", "Respond error code= " + gcResultCodeParametersNotEnough + ",error message= " + gcResultTextParametersNotEnough);
	obj.put("resultCode", gcResultCodeParametersNotEnough);
	obj.put("resultText", gcResultTextParametersNotEnough);
	out.print(obj);
	out.flush();
	return;
}

session.removeAttribute("Account_Id");	//先清除 session 中的用戶資料

String	USERS_JSON_FILE		= application.getRealPath("/00_users.json");
JSONObject jsonObjectUser	= getUserProfileJson(USERS_JSON_FILE, accountId);

if (jsonObjectUser==null){
	writeLog("debug", gcResultCodeNoLoginInfoFound + ":" + gcResultTextNoLoginInfoFound);
	obj.put("resultCode", gcResultCodeNoLoginInfoFound);
	obj.put("resultText", gcResultTextNoLoginInfoFound);
	out.print(obj);
	out.flush();
	return;
}else{
	//驗證密碼是否正確
	String userPassword = (String) jsonObjectUser.get("userPassword");
	if (!accountPassword.equals(userPassword)){
		writeLog("debug", "Invalid password return " + gcResultCodeInvalidSignature + ":" + gcResultTextInvalidSignature);
		obj.put("resultCode", gcResultCodePasswordIsIncorrect);
		obj.put("resultText", gcResultTextPasswordIsIncorrect);
		out.print(obj);
		out.flush();
		return;
	}
}

session.setAttribute("Account_Id", accountId);	//將登入用戶資料存入 session 中

obj.put("resultCode", sResultCode);
obj.put("resultText", sResultText);
obj.put("accountId", accountId);
out.print(obj);

%>