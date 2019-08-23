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

<%!

/*********************************************************************************************************************/
public String imsiProfileQueryForSCT(String imsi, String timezone){
	String	uri			= gcSCTUri + "imsi_query";

	JSONObject obj=new JSONObject();
	obj.put("imsi", imsi);
	String	body	= obj.toString();
	
	JSONObject jsonObjectResponseBody = sendRequestToSct(uri, body);

	String	sResponse	= "";
	
	if (jsonObjectResponseBody==null){
		obj=new JSONObject();
		obj.put("resultCode", gcResultCodeApiExecutionFail);
		obj.put("resultText", gcResultTextApiExecutionFail);
		sResponse = obj.toString();
		writeLog("error", "Return " + gcResultCodeApiExecutionFail + ":" + gcResultTextApiExecutionFail + " to client.");
		return sResponse;
	}
	
	
	try
	{
		int resResult = ((Long)jsonObjectResponseBody.get("result")).intValue();
		obj=new JSONObject();
		if (resResult!=0){	//失敗
			sResponse = "";
			if (resResult==139){
				obj.put("resultCode", gcResultCodeApiNotOurImsi);
				obj.put("resultText", gcResultTextApiNotOurImsi);
				sResponse = obj.toString();
			}else if (resResult==213){
				obj.put("resultCode", gcResultCodeApiInvalidImsi);
				obj.put("resultText", gcResultTextApiInvalidImsi);
				sResponse = obj.toString();
			}
		}else{	//成功，把supplier回覆的內容轉成我們回覆給client端的格式
			obj.put("resultCode", gcResultCodeSuccess);
			obj.put("resultText", gcResultTextSuccess);
			int resStatus = ((Long)jsonObjectResponseBody.get("status")).intValue();
			obj.put("imsi", imsi);
			obj.put("iccid", "");
			obj.put("msisdn", "");
			obj.put("imsiStatus", String.valueOf(resStatus));
			obj.put("imsiType", "Prepaid");
			List	l1	= new LinkedList();
			Map		m1	= null;
			int		i	= 0;
			Long	pkgPackageId;
			Long	pkgProductId;
			Long	pkgStatus;
			Long	pkgTotal;
			Long	pkgUsage;
			Long	pkgToday;
			String	pkgExpiryTime	= "";
			Long	pkgDays;
			String	pkgOpenTime		= "";
			JSONArray jsonPackages = null;
			try{
				jsonPackages = (JSONArray) jsonObjectResponseBody.get("packages");
				JSONObject jsonObjectPackage = null;
				//SCT時區是GMT+8，轉為client端的timezone
				if (beEmpty(timezone)) timezone = "0";
				timezone = String.valueOf(Long.parseLong("-8") + Long.parseLong(timezone));
				for (i=0; i<jsonPackages.size(); i++) {	//把每個人的userId找出來比對
					jsonObjectPackage = (JSONObject) jsonPackages.get(i);
					pkgPackageId = (Long)jsonObjectPackage.get("packageId");
					pkgProductId = (Long)jsonObjectPackage.get("productId");
					pkgStatus = (Long)jsonObjectPackage.get("status");
					pkgTotal = (Long)jsonObjectPackage.get("total")/1000000;
					pkgUsage = (Long)jsonObjectPackage.get("usage")/1000000;
					pkgToday = (Long)jsonObjectPackage.get("today")/1000000;
					pkgExpiryTime = (String) jsonObjectPackage.get("expiryTime");
					//SCT時區是GMT+8，轉為client端的timezone
					pkgExpiryTime = changeTimezoneForADate(pkgExpiryTime, gcDateFormatDashYMDTime, gcDateFormatDashYMDTime, timezone);
					pkgDays = (Long)jsonObjectPackage.get("days");
					pkgOpenTime = (String) jsonObjectPackage.get("openTime");
					//SCT時區是GMT+8，轉為client端的timezone
					pkgOpenTime = changeTimezoneForADate(pkgOpenTime, gcDateFormatDashYMDTime, gcDateFormatDashYMDTime, timezone);
					m1 = new HashMap();
					m1.put("packageId", nullToString(String.valueOf(pkgPackageId), ""));
					m1.put("productId", nullToString(String.valueOf(pkgProductId), ""));
					m1.put("packageStatus", nullToString(String.valueOf(pkgStatus), ""));
					m1.put("totalDataVolume", nullToString(String.valueOf(pkgTotal), ""));
					m1.put("allUsedVolume", nullToString(String.valueOf(pkgUsage), ""));
					m1.put("todayUsedVolume", nullToString(String.valueOf(pkgToday), ""));
					m1.put("expiryTime", nullToString(pkgExpiryTime, ""));
					m1.put("validityDays", nullToString(String.valueOf(pkgDays), ""));
					m1.put("firstUsageTime", nullToString(pkgOpenTime, ""));
					l1.add(m1);
				}	//for (i=0; i<jsonEntries.size(); i++) {	//把每個人的電話號碼找出來比對
			}catch (Exception e){
				writeLog("error", "Exception when parse SCT server response: " + e.toString());
			}
			obj.put("packages", l1);
			sResponse = obj.toString();
			//sResponse = imsiCdrQueryForSCT(imsi, sResponse, timezone);
			writeLog("debug", "Respond to client: " + sResponse);
		}	//if (resResult!=0){	//失敗
	}catch (Exception e){
		obj=new JSONObject();
		obj.put("resultCode", gcResultCodeApiExecutionFail);
		obj.put("resultText", gcResultTextApiExecutionFail);
		sResponse = obj.toString();
		writeLog("error", "Exception when process SCT server response: " + e.toString());
	}
	
	return sResponse;
}

/*****************************************************************************/

public String imsiCdrQueryForSCT(String imsi, String timezone){
	String	uri			= gcSCTUri + "imsi_query_cdr_stat";

	JSONObject obj=new JSONObject();
	obj.put("imsi", imsi);
	String	body	= obj.toString();
	
	JSONObject jsonObjectResponseBody = sendRequestToSct(uri, body);

	String	sResponse	= "";
	
	if (jsonObjectResponseBody==null){
		obj=new JSONObject();
		obj.put("resultCode", gcResultCodeApiExecutionFail);
		obj.put("resultText", gcResultTextApiExecutionFail);
		sResponse = obj.toString();
		writeLog("error", "Return " + gcResultCodeApiExecutionFail + ":" + gcResultTextApiExecutionFail + " to client.");
		return sResponse;
	}
	
	try{
		int resResult = ((Long)jsonObjectResponseBody.get("result")).intValue();
		obj=new JSONObject();
		if (resResult!=0){	//失敗
			sResponse = "";
			if (resResult==139){
				obj.put("resultCode", gcResultCodeApiNotOurImsi);
				obj.put("resultText", gcResultTextApiNotOurImsi);
			}else if (resResult==213){
				obj.put("resultCode", gcResultCodeApiInvalidImsi);
				obj.put("resultText", gcResultTextApiInvalidImsi);
			}else{
				obj.put("resultCode", gcResultCodeApiExecutionFail);
				obj.put("resultText", gcResultTextApiExecutionFail);
			}
			sResponse = obj.toString();
		}else{	//成功，把supplier回覆的內容轉成我們回覆給client端的格式
			obj.put("resultCode", gcResultCodeSuccess);
			obj.put("resultText", gcResultTextSuccess);
			List	l1	= new LinkedList();
			Map		m1	= null;
			int		i	= 0;
			String	cdrDate	= "";
			Long	cdrUsage;
			String	cdrLocation		= "";
			JSONArray jsonCdrs = null;
			try{
				jsonCdrs = (JSONArray) jsonObjectResponseBody.get("cdr");
				JSONObject jsonObjectCdr = null;
				for (i=0; i<jsonCdrs.size(); i++) {	//把每個人的userId找出來比對
					jsonObjectCdr = (JSONObject) jsonCdrs.get(i);
					cdrDate = (String)jsonObjectCdr.get("date");
					cdrUsage = (Long)jsonObjectCdr.get("usage")/1000000;
					cdrLocation = (String)jsonObjectCdr.get("location");

					m1 = new HashMap();
					m1.put("cdrDate", nullToString(String.valueOf(cdrDate), ""));
					m1.put("cdrUsage", nullToString(String.valueOf(cdrUsage), ""));
					m1.put("cdrLocation", nullToString(String.valueOf(cdrLocation), ""));
					l1.add(m1);
				}	//for (i=0; i<jsonEntries.size(); i++) {	//把每個人的電話號碼找出來比對
			}catch (Exception e){
				writeLog("error", "Exception when parse SCT server CDR response: " + e.toString());
			}
			obj.put("cdrs", l1);
			sResponse = obj.toString();
			writeLog("debug", "Respond to client(include CDR): " + sResponse);
		}	//if (resResult!=0){	//失敗
	}catch (Exception e){
		writeLog("error", "Exception when parse CDR response from SCT server: " + e.toString());
		obj=new JSONObject();
		obj.put("resultCode", gcResultCodeApiExecutionFail);
		obj.put("resultText", gcResultTextApiExecutionFail);
		sResponse = obj.toString();
	}
	
	return sResponse;
}

/*****************************************************************************/
//呼叫 SCT API 並取得回覆資料
public JSONObject sendRequestToSct(String uri, String body){
	String	account		= gcSCTAccount;
	String	key			= gcSCTKey;
	String	nonce		= generateRandomNumber();
	String	timestamp	= getDateTimeNow(gcDateFormatDashYMDTime);
	String	signature	= md5(account+nonce+timestamp+body+key);
	signature = signature.toLowerCase();

	JSONObject obj=new JSONObject();

	String	sResponse	= "";
	try
	{
		//因為SCT憑證有問題，所以需加入以下設定，允許SCT的不安全憑證
		TrustManager[] trustAllCerts = new TrustManager[]{ 
			new X509TrustManager() { 
				public java.security.cert.X509Certificate[] getAcceptedIssuers() { 
					 return null; 
				} 
				public void checkClientTrusted(X509Certificate[] certs, String authType) { 
				} 
				public void checkServerTrusted (X509Certificate[] certs, String authType) { 
				} 
			} 
		};
		SSLContext sc = SSLContext.getInstance("SSL"); 
		sc.init(null, trustAllCerts, new java.security.SecureRandom()); 
		HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory()); 

		HostnameVerifier allHostsValid = new HostnameVerifier() { 
			public boolean verify(String hostname, SSLSession session) { 
				return true; 
			} 
		}; 

		// set the allTrusting verifier 
		HttpsURLConnection.setDefaultHostnameVerifier(allHostsValid);
		//因為SCT憑證有問題，所以需加入以上設定，允許SCT的不安全憑證

		URL u;
		writeLog("debug", "Data to be sent to SCT, SCT-ACCOUNT= " + account);
		writeLog("debug", "Data to be sent to SCT, SCT-NONCE= " + nonce);
		writeLog("debug", "Data to be sent to SCT, SCT-TIMESTAMP= " + timestamp);
		writeLog("debug", "Data to be sent to SCT, SCT-SIGN= " + signature);
		writeLog("debug", "Data to be sent to SCT, POSTDATA= " + body);
		u = new URL(uri);
		HttpsURLConnection uc = (HttpsURLConnection)u.openConnection();
		uc.setRequestProperty ("Content-Type", "application/json");
		uc.setRequestProperty("contentType", "utf-8");
		uc.setRequestProperty("SCT-ACCOUNT", account);
		uc.setRequestProperty("SCT-NONCE", nonce);
		uc.setRequestProperty("SCT-TIMESTAMP", timestamp);
		uc.setRequestProperty("SCT-SIGN", signature);
		uc.setRequestMethod("POST");
		uc.setDoOutput(true);
		uc.setDoInput(true);
	
		//byte[] postData = body.getBytes("UTF-8");	//避免中文亂碼問題
		byte[] postData = body.getBytes();	//避免中文亂碼問題
		//String strPostData = new String(postData);
		//writeLog("debug", "Data to be sent to SCT, POSTDATA bytes= " + strPostData);
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
		writeLog("debug", "SCT server response: " + sResponse);
		
		
		JSONParser	parser	= new JSONParser();
		Object objResponseBody = parser.parse(sResponse);
		JSONObject jsonObjectResponseBody = (JSONObject) objResponseBody;
		return jsonObjectResponseBody;
	}catch (Exception e){
		writeLog("error", "Exception when send message to SCT server: " + e.toString());
		return null;
	}
	
}
%>