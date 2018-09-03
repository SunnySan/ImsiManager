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
String	imsi	= nullToString(request.getParameter("imsi"), "");
String	iccid	= nullToString(request.getParameter("iccid"), "");

writeLog("debug", "Receive IMSI/ICCID query request, imsi= " + imsi + ", ICCID= " + iccid);

String	sResultCode		= gcResultCodeSuccess;
String	sResultText		= gcResultTextSuccess;

if (beEmpty(imsi) && beEmpty(iccid)){
	writeLog("debug", "Respond error code= " + gcResultCodeParametersNotEnough + ",error message= " + gcResultTextParametersNotEnough);
	obj.put("resultCode", gcResultCodeParametersNotEnough);
	obj.put("resultText", gcResultTextParametersNotEnough);
	out.print(obj);
	out.flush();
	return;
}

//登入用戶的資訊
String sLoginUserAccountId	= (String)session.getAttribute("Account_Id");
//用戶未登入或 session timeout
if (beEmpty(sLoginUserAccountId)){
	obj.put("resultCode", gcResultCodeNoLoginInfoFound);
	obj.put("resultText", gcResultTextNoLoginInfoFound);
	out.print(obj);
	out.flush();
	return;
}

String imsiQueryApiUri = gcSystemUri + "API_ImsiQuery.jsp";
/* 以下的作法在 cms.gslssd.com 不 work
if (request.getServerPort()==80){
	imsiQueryApiUri = request.getScheme() + "://" + request.getServerName() + "/ImsiManager/API_ImsiQuery.jsp";
}else{
	imsiQueryApiUri = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/ImsiManager/API_ImsiQuery.jsp";
}
*/

writeLog("debug", "My IMSI/ICCID query API URL= " + imsiQueryApiUri);

String	USERS_JSON_FILE		= application.getRealPath("/00_users.json");
JSONObject jsonObjectUser	= getUserProfileJson(USERS_JSON_FILE, sLoginUserAccountId);
String userkey				= "";
if (jsonObjectUser==null){
	writeLog("debug", gcResultCodeNoLoginInfoFound + ":" + gcResultTextNoLoginInfoFound);
	obj.put("resultCode", gcResultCodeNoLoginInfoFound);
	obj.put("resultText", gcResultTextNoLoginInfoFound);
	out.print(obj);
	out.flush();
	return;
}else{
	userkey = (String) jsonObjectUser.get("userKey");
}

String	account		= sLoginUserAccountId;
String	key			= userkey;
String	timestamp	= getDateTimeNowGMT(gcDateFormatDashYMDTime);
JSONObject objTemp=new JSONObject();
objTemp.put("imsi", imsi);
objTemp.put("iccid", iccid);
String	body	= objTemp.toString();
String	signature	= md5(account+timestamp+body+key);

String	sResponse	= "";
try
{

	URL u;
	u = new URL(imsiQueryApiUri);
	HttpURLConnection uc = (HttpURLConnection)u.openConnection();
	uc.setRequestProperty ("Content-Type", "application/json");
	uc.setRequestProperty("contentType", "utf-8");
	uc.setRequestProperty("IM-ACCOUNT", account);
	uc.setRequestProperty("IM-TIMESTAMP", timestamp);
	uc.setRequestProperty("IM-SIGNATURE", signature);
	uc.setRequestMethod("POST");
	uc.setDoOutput(true);
	uc.setDoInput(true);

	byte[] postData = body.getBytes("UTF-8");	//避免中文亂碼問題
	OutputStream os = uc.getOutputStream();
	os.write(postData);
	os.close();

	InputStream in = uc.getInputStream();
	BufferedReader r = new BufferedReader(new InputStreamReader(in));
	StringBuffer buf = new StringBuffer();
	String line;
	while ((line = r.readLine())!=null) {
		buf.append(line);
	}
	in.close();
	sResponse = buf.toString();	//取得回應值
	writeLog("debug", "My IMSI query server response: " + sResponse);
}catch (Exception e){
	objTemp=new JSONObject();
	objTemp.put("resultCode", gcResultCodeApiExecutionFail);
	objTemp.put("resultText", gcResultTextApiExecutionFail);
	sResponse = objTemp.toString();
	writeLog("error", "Exception when send message to my IMSI query server: " + e.toString());
}



if (beEmpty(sResponse)){
	obj.put("resultCode", gcResultCodeUnknownError);
	obj.put("resultText", gcResultTextUnknownError);
	out.print(obj);
	out.flush();
}else{
	out.print(sResponse);
	out.flush();
}

%>