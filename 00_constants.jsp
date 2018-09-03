<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8" %>
<%!

//Supplier參數
public static final String	gcSCTUri								= "https://sim.npnchina.com/api/v1/imsi_query";
public static final String	gcSCTAccount							= "TAISYS";
public static final String	gcSCTKey								= "a02779170f1245d7dc03e39b0f1dd818";


//系統參數
public static final String	gcSystemUri									= "https://cms.gslssd.com/ImsiManager/";

/*****************************************************************************/

//ResultCode及ResultText定義
public static final String	gcResultCodeSuccess						= "00000";
public static final String	gcResultTextSuccess						= "Success";
public static final String	gcResultCodeParametersNotEnough			= "00004";
public static final String	gcResultTextParametersNotEnough			= "Parameter not enough";
public static final String	gcResultCodeParametersValidationError	= "00005";
public static final String	gcResultTextParametersValidationError	= "Parameter velidation failed";
public static final String	gcResultCodeNoDataFound					= "00006";
public static final String	gcResultTextNoDataFound					= "No data found";
public static final String	gcResultCodeNoLoginInfoFound			= "00007";
public static final String	gcResultTextNoLoginInfoFound			= "Login account not found or session expired, please login again";
public static final String	gcResultCodeNoPriviledge				= "00008";
public static final String	gcResultTextNoPriviledge				= "No priviledge";
public static final String	gcResultCodeInvalidSignature			= "00009";
public static final String	gcResultTextInvalidSignature			= "Invalid signature";
public static final String	gcResultCodeRequestTimestampIsInvalid	= "00010";
public static final String	gcResultTextRequestTimestampIsInvalid	= "Timestamp is invalid";
public static final String	gcResultCodeImsiApiNotSupport			= "00011";
public static final String	gcResultTextImsiApiNotSupport			= "There is no API for this IMSI";
public static final String	gcResultCodePasswordIsIncorrect			= "00012";
public static final String	gcResultTextPasswordIsIncorrect			= "Password is incorrect.";
public static final String	gcResultCodeApiExecutionFail			= "10001";
public static final String	gcResultTextApiExecutionFail			= "API execution failed";
public static final String	gcResultCodeApiNotOurImsi				= "10002";
public static final String	gcResultTextApiNotOurImsi				= "This IMSI is not ours";
public static final String	gcResultCodeApiInvalidImsi				= "10003";
public static final String	gcResultTextApiInvalidImsi				= "Invalid IMSI";

public static final String	gcResultCodeDBTimeout					= "99001";
public static final String	gcResultTextDBTimeout					= "資料庫連線失敗或逾時!";
public static final String	gcResultCodeDBOKButMailBodyFail			= "99002";
public static final String	gcResultTextDBOKButMailBodyFail			= "成功將資料寫入資料庫，但無法產生通知郵件內容!";
public static final String	gcResultCodeDBOKButUserMailFail			= "99003";
public static final String	gcResultTextDBOKButUserMailFail			= "成功將資料寫入資料庫，無法取得下個簽核人員的Email!";
public static final String	gcResultCodeDBOKButMailSendFail			= "99004";
public static final String	gcResultTextDBOKButMailSendFail			= "成功將資料寫入資料庫，但寄送通知信件失敗!";
public static final String	gcResultCodeMailSendFail				= "99005";
public static final String	gcResultTextMailSendFail				= "發送Email失敗!";
public static final String	gcResultCodeUnknownError				= "99999";
public static final String	gcResultTextUnknownError				= "其他錯誤!";

//日期格式
public static final String	gcDateFormatDateDashTime				= "yyyyMMdd-HHmmss";
public static final String	gcDateFormatSlashYMDTime				= "yyyy/MM/dd HH:mm:ss";
public static final String	gcDateFormatDashYMDTime					= "yyyy-MM-dd HH:mm:ss";
public static final String	gcDateFormatYMD							= "yyyyMMdd";
public static final String	gcDateFormatSlashYMD					= "yyyy/MM/dd";
public static final String	gcDateFormatdashYMD						= "yyyy-MM-dd";
public static final String	gcDateFormatSlashYM						= "yyyy/MM";

%>
