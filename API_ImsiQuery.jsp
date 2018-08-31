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
https://cms.gslssd.com/CallPro/Event_PCClientNewCDR.jsp?areacode=02&phonenumber1=26585888&accesscode=123456&callerphone=0988123456&recordtime=30&recordtimestart=2018-01-23 10:42&call_direction=0&recordfile=ringtone_04.wav&ring_time=10&talked_time=20&callername=John&calleraddr=台北市內湖區成功路四段&callercompany=Call-Pro&calleremail=hello@gmail.com
************************************呼叫範例*******************************/

String userId		= nullToString(request.getParameter("userId"), "");
String timestamp	= nullToString(request.getParameter("timestamp"), "");
String imsi			= nullToString(request.getParameter("imsi"), "");
String signature	= nullToString(request.getParameter("signature"), "");

String USERS_JSON_FILE	= application.getRealPath("/00_users.json");
JSONObject jsonObjectUser = getUserProfileJson(USERS_JSON_FILE, userId);

if (jsonObjectUser==null){
	out.print("no match");
}else{
	String userkey = (String) jsonObjectUser.get("userKey");
	if (!isSignatureValid(signature, userId+timestamp+imsi)){
	}
	out.print(userkey);
}

String s = md5("test sunny I love you");
//writeLog("debug", "s= " + s);
//out.print(s);
%>