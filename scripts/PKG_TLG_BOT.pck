create or replace package PKG_TLG_BOT is

  -- Author  : tanthanhkaka01
  -- Created : 10/09/2025 10:34:58
  -- Purpose : PACKAGE TO HELPER BOT METHOD
  
  -- Public type declarations
  -- type <TypeName> is <Datatype>;
  
  -- Public constant declarations
  -- <ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  -- <VariableName> <Datatype>;

  -- Public function and procedure declarations
  -- function <FunctionName>(<Parameter> <Datatype>) return <Datatype>;
  
  CONSTANT_OWNER CONSTANT VARCHAR(500) := SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA');
  CONSTANT_PACKAGE_NAME CONSTANT VARCHAR(500) := 'PKG_TLG_BOT';
  
  FUNCTION FUNC_GET_BOTID_BY_TOKEN (
    vbot_token IN VARCHAR DEFAULT '0'
    ) RETURN NUMBER;
  
  FUNCTION FUNC_GET_USERID_BY_BOTID (
    vbot_id IN NUMBER DEFAULT 0
    ) RETURN NUMBER;
  
  FUNCTION FUNC_GET_TOKEN_BY_NAME (
    vbot_name IN VARCHAR DEFAULT '0'
    ) RETURN VARCHAR;
    
  FUNCTION FUNC_GET_TOKEN_BY_BOTID (
    vbot_id IN NUMBER DEFAULT 0
    ) RETURN VARCHAR;
    
  FUNCTION FUNC_GET_TOKEN_BY_USERID (
    vuser_id IN NUMBER DEFAULT 0
    ) RETURN VARCHAR;
    
  FUNCTION FUNC_GET_URL_BY_BOTID (
    vbot_id IN NUMBER DEFAULT FUNC_GET_BOTID_BY_TOKEN
    ) RETURN VARCHAR;
    
  FUNCTION FUNC_GET_URL_BY_BOTTOKEN (
    vbot_token IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    ) RETURN VARCHAR;
  
  FUNCTION FUNC_TLG_GETME (
    vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB;
    
  FUNCTION FUNC_TLG_GETFILE (
    vfile_id IN VARCHAR
    , vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB;
  
  FUNCTION FUNC_TLG_GETUPDATES (
    voffset IN NUMBER DEFAULT 0
    , vlimit IN NUMBER DEFAULT 5
    , vtimeout IN NUMBER DEFAULT 10
    , vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB;
    
  FUNCTION FUNC_TLG_SENDMESSAGE (
    vchat_id IN NUMBER
    , vtext IN VARCHAR
    , vparse_mode IN VARCHAR DEFAULT NULL
    , ventities IN VARCHAR DEFAULT NULL
    , vreply_to_message_id IN NUMBER DEFAULT NULL
    , vreply_markup IN VARCHAR DEFAULT NULL
    , vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB;
    
  FUNCTION FUNC_TLG_SENDPHOTO (
    vchat_id IN NUMBER
    , vphoto IN VARCHAR
    , vcaption IN VARCHAR DEFAULT NULL
    , vparse_mode IN VARCHAR DEFAULT NULL
    , vcaption_entities IN VARCHAR DEFAULT NULL
    , vreply_to_message_id IN NUMBER DEFAULT NULL
    , vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB;
    
  FUNCTION FUNC_TLG_SENDDOCUMENT (
    vchat_id IN NUMBER
    , vfile_id IN VARCHAR
    , vcaption IN VARCHAR DEFAULT NULL
    , vparse_mode IN VARCHAR DEFAULT NULL
    , vcaption_entities IN VARCHAR DEFAULT NULL
    , vreply_to_message_id IN NUMBER DEFAULT NULL
    , vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB;
    
  FUNCTION FUNC_TLG_FORWARDMESSAGE (
    vchat_id IN NUMBER
    , vfrom_chat_id IN NUMBER
    , vmessage_id IN NUMBER
    , vmessage_thread_id IN NUMBER DEFAULT NULL
    , vdisable_notification IN NUMBER DEFAULT NULL
    , vprotect_content IN NUMBER DEFAULT NULL
    , vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB;
    
  FUNCTION FUNC_TLG_GETCHATMEMB (
    vchat_id IN NUMBER
    , vuser_id IN NUMBER
    , vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB;
    
  FUNCTION FUNC_TLG_HANDLE_JOIN (
    vchat_id IN NUMBER
    , vuser_id IN NUMBER
    , vresponse_type IN NUMBER DEFAULT 1
    , vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB;
    
  FUNCTION FUNC_TLG_SEND_FILE (
    vchat_id IN NUMBER
    , vbfile_id IN NUMBER
    , vcaption IN VARCHAR DEFAULT NULL
    , vparse_mode IN VARCHAR DEFAULT NULL
    , vcaption_entities IN VARCHAR DEFAULT NULL
    , vreply_to_message_id IN NUMBER DEFAULT NULL
    , vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB;
    
  FUNCTION FUNC_TLG_SEND (
    vbot_id IN NUMBER DEFAULT FUNC_GET_BOTID_BY_TOKEN
    , vchat_id IN NUMBER
    , vsendtype IN VARCHAR
    , vfile_id IN VARCHAR DEFAULT NULL
    , vtext IN VARCHAR DEFAULT NULL
    , vparse_mode IN VARCHAR DEFAULT NULL
    , ventities IN VARCHAR DEFAULT NULL
    , vreply_to_message_id IN NUMBER DEFAULT NULL
    , vreply_markup IN VARCHAR DEFAULT NULL
    , vupdate_id IN NUMBER DEFAULT NULL
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN NUMBER;
    
  FUNCTION FUNC_GET_SYSTEM_GROUP (
    vlog_level IN NUMBER DEFAULT 1
    ) RETURN NUMBER;
    
  FUNCTION FUNC_SYSTEM_LOG (
    vlog_level IN NUMBER DEFAULT 1
    , vbot_id IN NUMBER DEFAULT FUNC_GET_BOTID_BY_TOKEN
    , vtext IN VARCHAR
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN NUMBER;
  
  

end PKG_TLG_BOT;
/
create or replace package body PKG_TLG_BOT is
  
  FUNCTION FUNC_GET_BOTID_BY_TOKEN (
    vbot_token IN VARCHAR DEFAULT '0'
    ) RETURN NUMBER
    IS
    str01 VARCHAR(32767);
    vbot_id NUMBER(20);
    BEGIN
      
    str01 := '
    WITH TABLE_TEMP01 AS (
      SELECT :v01 AS BOT_TOKEN
      FROM DUAL
    )
    SELECT
      NVL(MAX(A.BOT_ID) KEEP (DENSE_RANK FIRST ORDER BY A.BOT_ID DESC), 0) AS BOT_ID
    FROM TLG_BOT_TOKEN A, TABLE_TEMP01 B
    WHERE
      1 = 1
      AND (
        A.BOT_TOKEN = B.BOT_TOKEN
        OR (A.STATUS_ID = PKG_STATUS.FUNC_GET_ID_BY_STATUS(vstatus => ''ENABLED'')
           AND ''0'' = B.BOT_TOKEN)
      )
    ';
    
    EXECUTE IMMEDIATE str01 INTO vbot_id USING vbot_token;
    RETURN vbot_id;
    
    END;
  
  FUNCTION FUNC_GET_USERID_BY_BOTID (
    vbot_id IN NUMBER DEFAULT 0
    ) RETURN NUMBER
    IS
    str01 VARCHAR(32767);
    vuser_id VARCHAR(200);
    BEGIN
      
    str01 := '
    WITH TABLE_TEMP01 AS (
      SELECT :v01 AS BOT_ID
      FROM DUAL
    )
    SELECT
      NVL(MAX(A.USER_ID) KEEP (DENSE_RANK FIRST ORDER BY A.BOT_ID DESC), ''0'') AS BOT_TOKEN
    FROM TLG_BOT_TOKEN A, TABLE_TEMP01 B
    WHERE
      1 = 1
      AND (
        A.BOT_ID = B.BOT_ID
        OR (A.STATUS_ID = PKG_STATUS.FUNC_GET_ID_BY_STATUS(vstatus => ''ENABLED'')
           AND 0 = B.BOT_ID)
      )
    ';
    
    EXECUTE IMMEDIATE str01 INTO vuser_id USING vbot_id;
    
    RETURN vuser_id;
    
    END;
  
  FUNCTION FUNC_GET_TOKEN_BY_NAME (
    vbot_name IN VARCHAR DEFAULT '0'
    ) RETURN VARCHAR
    IS
    str01 VARCHAR(32767);
    vbot_token VARCHAR(200);
    BEGIN
      
    str01 := '
    WITH TABLE_TEMP01 AS (
      SELECT :vbot_name AS BOT_NAME FROM DUAL
    )
    SELECT
      NVL(MAX(BOT_TOKEN) KEEP (DENSE_RANK FIRST ORDER BY BOT_ID DESC), ''0'') AS BOT_TOKEN
    FROM TLG_BOT_TOKEN A, TABLE_TEMP01 B
    WHERE
      1 = 1
      AND (
        A.BOT_NAME = B.BOT_NAME
        OR (A.STATUS_ID = PKG_STATUS.FUNC_GET_ID_BY_STATUS(vstatus => ''ENABLED'')
           AND ''0'' = B.BOT_NAME)
      )
    ';
    
    EXECUTE IMMEDIATE str01 INTO vbot_token USING vbot_name;
    
    RETURN vbot_token;
    
    END;
    
  FUNCTION FUNC_GET_TOKEN_BY_BOTID (
    vbot_id IN NUMBER DEFAULT 0
    ) RETURN VARCHAR
    IS
    str01 VARCHAR(32767);
    vbot_token VARCHAR(200);
    BEGIN
      
    str01 := '
    WITH TABLE_TEMP01 AS (
      SELECT :v01 AS BOT_ID
      FROM DUAL
    )
    SELECT
      NVL(MAX(A.BOT_TOKEN) KEEP (DENSE_RANK FIRST ORDER BY A.BOT_ID DESC), ''0'') AS BOT_TOKEN
    FROM TLG_BOT_TOKEN A, TABLE_TEMP01 B
    WHERE
      1 = 1
      AND (
        A.BOT_ID = B.BOT_ID
        OR (A.STATUS_ID = PKG_STATUS.FUNC_GET_ID_BY_STATUS(vstatus => ''ENABLED'')
           AND 0 = B.BOT_ID)
      )
    ';
    
    EXECUTE IMMEDIATE str01 INTO vbot_token USING vbot_id;
    
    RETURN vbot_token;
    
    END;
    
  FUNCTION FUNC_GET_TOKEN_BY_USERID (
    vuser_id IN NUMBER DEFAULT 0
    ) RETURN VARCHAR
    IS
    str01 VARCHAR(32767);
    vbot_token VARCHAR(200);
    BEGIN
      
    str01 := '
    WITH TABLE_TEMP01 AS (
      SELECT :v01 AS USER_ID
      FROM DUAL
    )
    SELECT
      NVL(MAX(A.BOT_TOKEN) KEEP (DENSE_RANK FIRST ORDER BY A.BOT_ID DESC), ''0'') AS BOT_TOKEN
    FROM TLG_BOT_TOKEN A, TABLE_TEMP01 B
    WHERE
      1 = 1
      AND (
        A.USER_ID = B.USER_ID
        OR (A.STATUS_ID = PKG_STATUS.FUNC_GET_ID_BY_STATUS(vstatus => ''ENABLED'')
           AND 0 = B.USER_ID)
      )
    ';
    
    EXECUTE IMMEDIATE str01 INTO vbot_token USING vuser_id;
    
    RETURN vbot_token;
    
    END;
    
  FUNCTION FUNC_GET_URL_BY_BOTID (
    vbot_id IN NUMBER DEFAULT FUNC_GET_BOTID_BY_TOKEN
    ) RETURN VARCHAR
    IS
    str01 VARCHAR(32767);
    vbot_url VARCHAR(500);
    BEGIN
      
    str01 := '
    SELECT
      NVL(MAX(BOT_URL), ''0'') AS BOT_URL
    FROM TLG_BOT_TOKEN
    WHERE
      1 = 1
      AND BOT_ID = :vbot_id
    ';
    
    EXECUTE IMMEDIATE str01 INTO vbot_url USING vbot_id;
    RETURN vbot_url;
    
    END;
    
  FUNCTION FUNC_GET_URL_BY_BOTTOKEN (
    vbot_token IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    ) RETURN VARCHAR
    IS
    str01 VARCHAR(32767);
    vbot_url VARCHAR(500);
    BEGIN
      
    str01 := '
    SELECT
      NVL(MAX(BOT_URL), ''0'') AS BOT_URL
    FROM TLG_BOT_TOKEN
    WHERE
      1 = 1
      AND BOT_TOKEN = :v01
    ';
    
    EXECUTE IMMEDIATE str01 INTO vbot_url USING vbot_token;
    RETURN vbot_url;
    
    END;
  
  FUNCTION FUNC_TLG_GETME (
    vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB
    IS
    vurl VARCHAR(200) := FUNC_GET_URL_BY_BOTTOKEN(vbot_token => vtoken) || '/getMe';
    BEGIN
    
    RETURN PKG_HELPER_REQUEST_HTTP.FUNC_REQUEST_HTML(
      vurl => vurl
      , vdata => NULL
      , vmethod => 'POST'
      -- , vtimeout => DEFAULT
      , vcontent_type => 'application/json'
      , vwallet_path => vwallet_path
      , vwallet_pass => vwallet_pass
      , vproxy => vproxy
      );
      
    END;
    
  FUNCTION FUNC_TLG_GETFILE (
    vfile_id IN VARCHAR
    , vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB
    IS
    vurl VARCHAR(200) := FUNC_GET_URL_BY_BOTTOKEN(vbot_token => vtoken) ||  '/getFile';
    vdata VARCHAR(4000);
    BEGIN
      
    vdata := 'file_id=' || vfile_id;
    
    RETURN PKG_HELPER_REQUEST_HTTP.FUNC_REQUEST_HTML(
      vurl => vurl
      , vdata => vdata
      , vmethod => 'POST'
      -- , vtimeout => DEFAULT
      , vcontent_type => 'application/x-www-form-urlencoded; charset="UTF-8"'
      , vwallet_path => vwallet_path
      , vwallet_pass => vwallet_pass
      , vproxy => vproxy
      );
      
    END;
  
  FUNCTION FUNC_TLG_GETUPDATES (
    voffset IN NUMBER DEFAULT 0
    , vlimit IN NUMBER DEFAULT 5
    , vtimeout IN NUMBER DEFAULT 10
    , vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB
    IS
    vurl VARCHAR(200) := FUNC_GET_URL_BY_BOTTOKEN(vbot_token => vtoken) ||  '/getUpdates';
    vdata VARCHAR(4000);
    BEGIN
    
    vdata := 'offset=' || utl_url.escape(voffset,TRUE);
    vdata := vdata || '&limit=' || utl_url.escape(vlimit,TRUE);
    vdata := vdata || '&timeout=' || utl_url.escape(vtimeout,TRUE);
    
    RETURN PKG_HELPER_REQUEST_HTTP.FUNC_REQUEST_HTML(
      vurl => vurl
      , vdata => vdata
      , vmethod => 'POST'
      -- , vtimeout => DEFAULT
      , vcontent_type => 'application/x-www-form-urlencoded; charset="UTF-8"'
      , vwallet_path => vwallet_path
      , vwallet_pass => vwallet_pass
      , vproxy => vproxy
      );
      
    END;
    
  FUNCTION FUNC_TLG_SENDMESSAGE (
    vchat_id IN NUMBER
    , vtext IN VARCHAR
    , vparse_mode IN VARCHAR DEFAULT NULL
    , ventities IN VARCHAR DEFAULT NULL
    , vreply_to_message_id IN NUMBER DEFAULT NULL
    , vreply_markup IN VARCHAR DEFAULT NULL
    , vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB
    IS
    vurl VARCHAR(200) := FUNC_GET_URL_BY_BOTTOKEN(vbot_token => vtoken) ||  '/sendMessage';
    vdata VARCHAR(4000);
    BEGIN
    
    -- vdata := 'chat_id=' || utl_url.escape(vchat_id, TRUE);
    -- vdata := vdata || '&text=' || utl_url.escape(vtext, TRUE);
    vdata := 'chat_id=' || vchat_id;
    vdata := vdata || '&text=' || REPLACE(REPLACE(vtext, '&', '%26'), '+', '%2B'); -- %2B = + -- URL - ENCODED
    
    IF vparse_mode IS NOT NULL
      THEN 
       vdata := vdata || '&parse_mode=' || vparse_mode;
    END IF;
    
    IF ventities IS NOT NULL
      THEN 
       vdata := vdata || '&entities=' || ventities;
    END IF;
    
    IF NVL(vreply_to_message_id, 0) > 0
      THEN 
       vdata := vdata || '&reply_to_message_id=' || vreply_to_message_id;
    END IF;
    
    IF vreply_markup IS NOT NULL
      THEN 
       vdata := vdata || '&reply_markup=' || vreply_markup;
    END IF;
    
    RETURN PKG_HELPER_REQUEST_HTTP.FUNC_REQUEST_HTML(
      vurl => vurl
      , vdata => vdata
      , vmethod => 'POST'
      -- , vtimeout => DEFAULT
      , vcontent_type => 'application/x-www-form-urlencoded; charset="UTF-8"'
      , vwallet_path => vwallet_path
      , vwallet_pass => vwallet_pass
      , vproxy => vproxy
      );
      
    END;
    
  FUNCTION FUNC_TLG_SENDPHOTO (
    vchat_id IN NUMBER
    , vphoto IN VARCHAR
    , vcaption IN VARCHAR DEFAULT NULL
    , vparse_mode IN VARCHAR DEFAULT NULL
    , vcaption_entities IN VARCHAR DEFAULT NULL
    , vreply_to_message_id IN NUMBER DEFAULT NULL
    , vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB
    IS
    vurl VARCHAR(200) := FUNC_GET_URL_BY_BOTTOKEN(vbot_token => vtoken) ||  '/sendPhoto';
    vdata VARCHAR(4000);
    BEGIN
    
    -- vdata := 'chat_id=' || utl_url.escape(vchat_id, TRUE);
    -- vdata := vdata || '&text=' || utl_url.escape(vtext, TRUE);
    vdata := 'chat_id=' || vchat_id;
    vdata := vdata || '&photo=' || vphoto;
    
    IF vcaption IS NOT NULL
      THEN
       vdata := vdata || '&caption=' || REPLACE(REPLACE(vcaption, '&', '%26'), '+', '%2B'); -- %2B = + -- URL - ENCODED
    END IF;
    
    IF vparse_mode IS NOT NULL
      THEN 
       vdata := vdata || '&parse_mode=' || vparse_mode;
    END IF;
    
    IF vcaption_entities IS NOT NULL
      THEN 
       vdata := vdata || '&caption_entities=' || vcaption_entities;
    END IF;
    
    IF NVL(vreply_to_message_id, 0) > 0
      THEN 
       vdata := vdata || '&reply_to_message_id=' || vreply_to_message_id;
    END IF;
    
    RETURN PKG_HELPER_REQUEST_HTTP.FUNC_REQUEST_HTML(
      vurl => vurl
      , vdata => vdata
      , vmethod => 'POST'
      -- , vtimeout => DEFAULT
      , vcontent_type => 'application/x-www-form-urlencoded; charset="UTF-8"'
      , vwallet_path => vwallet_path
      , vwallet_pass => vwallet_pass
      , vproxy => vproxy
      );
      
    END;
    
  FUNCTION FUNC_TLG_SENDDOCUMENT (
    vchat_id IN NUMBER
    , vfile_id IN VARCHAR
    , vcaption IN VARCHAR DEFAULT NULL
    , vparse_mode IN VARCHAR DEFAULT NULL
    , vcaption_entities IN VARCHAR DEFAULT NULL
    , vreply_to_message_id IN NUMBER DEFAULT NULL
    , vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB
    IS
    vurl VARCHAR(200) := FUNC_GET_URL_BY_BOTTOKEN(vbot_token => vtoken) ||  '/sendDocument';
    vdata VARCHAR(4000);
    BEGIN
    
    -- vdata := 'chat_id=' || utl_url.escape(vchat_id, TRUE);
    -- vdata := vdata || '&text=' || utl_url.escape(vtext, TRUE);
    vdata := 'chat_id=' || vchat_id;
    vdata := vdata || '&document=' || vfile_id;
    
    IF vcaption IS NOT NULL
      THEN
       vdata := vdata || '&caption=' || REPLACE(REPLACE(vcaption, '&', '%26'), '+', '%2B'); -- %2B = + -- URL - ENCODED
    END IF;
    
    IF vparse_mode IS NOT NULL
      THEN 
       vdata := vdata || '&parse_mode=' || vparse_mode;
    END IF;
    
    IF vcaption_entities IS NOT NULL
      THEN 
       vdata := vdata || '&caption_entities=' || vcaption_entities;
    END IF;
    
    IF NVL(vreply_to_message_id, 0) > 0
      THEN 
       vdata := vdata || '&reply_to_message_id=' || vreply_to_message_id;
    END IF;
    
    RETURN PKG_HELPER_REQUEST_HTTP.FUNC_REQUEST_HTML(
      vurl => vurl
      , vdata => vdata
      , vmethod => 'POST'
      -- , vtimeout => DEFAULT
      , vcontent_type => 'application/x-www-form-urlencoded; charset="UTF-8"'
      , vwallet_path => vwallet_path
      , vwallet_pass => vwallet_pass
      , vproxy => vproxy
      );
      
    END;
    
  FUNCTION FUNC_TLG_FORWARDMESSAGE (
    vchat_id IN NUMBER
    , vfrom_chat_id IN NUMBER
    , vmessage_id IN NUMBER
    , vmessage_thread_id IN NUMBER DEFAULT NULL
    , vdisable_notification IN NUMBER DEFAULT NULL
    , vprotect_content IN NUMBER DEFAULT NULL
    , vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB
    IS
    vurl VARCHAR(200) := FUNC_GET_URL_BY_BOTTOKEN(vbot_token => vtoken) ||  '/forwardMessage';
    vdata VARCHAR(4000);
    BEGIN
    
    -- vdata := 'chat_id=' || utl_url.escape(vchat_id, TRUE);
    -- vdata := vdata || '&text=' || utl_url.escape(vtext, TRUE);
    vdata := 'chat_id=' || vchat_id;
    
    IF vmessage_thread_id IS NOT NULL
      THEN
        vdata := vdata || '&message_thread_id=' || vchat_id;
    END IF;
    
    vdata := vdata || '&from_chat_id=' || vfrom_chat_id;
    
    IF vdisable_notification IS NOT NULL
      THEN
        vdata := vdata || '&disable_notification=' || vdisable_notification;
    END IF;
    
    IF vprotect_content IS NOT NULL
      THEN
        vdata := vdata || '&protect_content=' || vprotect_content;
    END IF;
    
    vdata := vdata || '&message_id=' || vmessage_id;
    
    RETURN PKG_HELPER_REQUEST_HTTP.FUNC_REQUEST_HTML(
      vurl => vurl
      , vdata => vdata
      , vmethod => 'POST'
      -- , vtimeout => DEFAULT
      , vcontent_type => 'application/x-www-form-urlencoded; charset="UTF-8"'
      , vwallet_path => vwallet_path
      , vwallet_pass => vwallet_pass
      , vproxy => vproxy
      );
      
    END;
    
  FUNCTION FUNC_TLG_GETCHATMEMB (
    vchat_id IN NUMBER
    , vuser_id IN NUMBER
    , vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB
    IS
    vurl VARCHAR(200) := FUNC_GET_URL_BY_BOTTOKEN(vbot_token => vtoken) ||  '/getChatMember';
    vdata VARCHAR(4000);
    BEGIN
    
    vdata := 'chat_id=' || vchat_id;
    vdata := vdata || '&user_id=' || vuser_id;
    
    RETURN PKG_HELPER_REQUEST_HTTP.FUNC_REQUEST_HTML(
      vurl => vurl
      , vdata => vdata
      , vmethod => 'POST'
      -- , vtimeout => DEFAULT
      , vcontent_type => 'application/x-www-form-urlencoded; charset="UTF-8"'
      , vwallet_path => vwallet_path
      , vwallet_pass => vwallet_pass
      , vproxy => vproxy
      );
      
    END;
    
  FUNCTION FUNC_TLG_HANDLE_JOIN (
    vchat_id IN NUMBER
    , vuser_id IN NUMBER
    , vresponse_type IN NUMBER DEFAULT 1
    , vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB
    IS
    vurl VARCHAR(200) := FUNC_GET_URL_BY_BOTTOKEN(vbot_token => vtoken) ||  '/';
    vresponse_type_text01 VARCHAR(100) := 'approveChatJoinRequest';
    vresponse_type_text02 VARCHAR(100) := 'declineChatJoinRequest';
    vdata VARCHAR(4000);
    BEGIN
      
    IF vresponse_type = 1
      THEN vurl := vurl || vresponse_type_text01;
      ELSE vurl := vurl || vresponse_type_text02;
    END IF;
    
    vdata := 'chat_id=' || vchat_id;
    vdata := vdata || '&user_id=' || vuser_id;
    
    RETURN PKG_HELPER_REQUEST_HTTP.FUNC_REQUEST_HTML(
      vurl => vurl
      , vdata => vdata
      , vmethod => 'POST'
      -- , vtimeout => DEFAULT
      , vcontent_type => 'application/x-www-form-urlencoded; charset="UTF-8"'
      , vwallet_path => vwallet_path
      , vwallet_pass => vwallet_pass
      , vproxy => vproxy
      );
      
    END;
    
  FUNCTION FUNC_TLG_SEND_FILE (
    vchat_id IN NUMBER
    , vbfile_id IN NUMBER
    , vcaption IN VARCHAR DEFAULT NULL
    , vparse_mode IN VARCHAR DEFAULT NULL
    , vcaption_entities IN VARCHAR DEFAULT NULL
    , vreply_to_message_id IN NUMBER DEFAULT NULL
    , vtoken IN VARCHAR DEFAULT FUNC_GET_TOKEN_BY_BOTID
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN CLOB
    IS
    vurl VARCHAR(500) := FUNC_GET_URL_BY_BOTTOKEN(vbot_token => vtoken) ||  '/sendDocument';
    str01 VARCHAR(32767);
    vfile_name VARCHAR(500);
    vmime_type VARCHAR(500);
    vfile_bfile BFILE;
    v_parts utl_http_multipart.parts := utl_http_multipart.parts();
    BEGIN
    
    str01 := '
    SELECT
        FILE_NAME, MIME_TYPE, FILE_BFILE
    FROM BFILES
    WHERE
        BFILE_ID = :vbfile_id
    ';
    
    EXECUTE IMMEDIATE str01 INTO vfile_name, vmime_type, vfile_bfile USING vbfile_id;
    
    utl_http_multipart.add_file(
            p_parts => v_parts
            , p_name => 'document'
            , p_filename => vfile_name
            , p_content_type => vmime_type
            , p_blob => vfile_bfile);
    utl_http_multipart.add_param(v_parts, 'chat_id', TO_CHAR(vchat_id));
    IF vcaption IS NOT NULL THEN utl_http_multipart.add_param(v_parts, 'caption', vcaption); END IF;
    IF vparse_mode IS NOT NULL THEN utl_http_multipart.add_param(v_parts, 'parse_mode', vparse_mode); END IF;
    IF vcaption_entities IS NOT NULL THEN utl_http_multipart.add_param(v_parts, 'caption_entities', vcaption_entities); END IF;
    IF vreply_to_message_id IS NOT NULL THEN utl_http_multipart.add_param(v_parts, 'reply_to_message_id', vreply_to_message_id); END IF;
    
    RETURN PKG_HELPER_REQUEST_HTTP.FUNC_REQUEST_MULTIPART (
        vurl => vurl
        , v_parts => v_parts
        -- , vmethod => 'POST'
        -- , vtimeout => 600
        , vwallet_path => vwallet_path
        , vwallet_pass => vwallet_pass
        , vproxy => vproxy
    );
    
    END;
    
  FUNCTION FUNC_TLG_SEND (
    vbot_id IN NUMBER DEFAULT FUNC_GET_BOTID_BY_TOKEN
    , vchat_id IN NUMBER
    , vsendtype IN VARCHAR
    , vfile_id IN VARCHAR DEFAULT NULL
    , vtext IN VARCHAR DEFAULT NULL
    , vparse_mode IN VARCHAR DEFAULT NULL
    , ventities IN VARCHAR DEFAULT NULL
    , vreply_to_message_id IN NUMBER DEFAULT NULL
    , vreply_markup IN VARCHAR DEFAULT NULL
    , vupdate_id IN NUMBER DEFAULT NULL
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN NUMBER
    IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    str01 VARCHAR(32767);
    vbot_token VARCHAR(500) := FUNC_GET_TOKEN_BY_BOTID(vbot_id => vbot_id);
    vtlgsend_id NUMBER(20) := PKG_KEY.GET_KEYS(vkeyname => 'LOG_TLG_SEND');
    vmessage_id NUMBER(20);
    vstatus_id NUMBER(20) := PKG_STATUS.FUNC_GET_ID_BY_STATUS(vstatus => 'PENDING');
    vresult_clob CLOB;
    BEGIN
    
    str01 := '
    INSERT INTO LOG_TLG_SEND (
    ROW_INS_DATE, BOT_ID, TLGSEND_ID, UPDATE_ID, SENDTYPE
    , CHAT_ID, MESSAGE_ID, FILE_ID, TEXT, PARSE_MODE
    , ENTITIES, REPLY_TO_MESSAGE_ID, STATUS_ID, RESULT_CLOB
    )
    SELECT
      SYSDATE AS ROW_INS_DATE
      , :vbot_id AS BOT_ID
      , :vtlgsend_id AS TLGSEND_ID
      , :vupdate_id AS UPDATE_ID
      , :vsendtype AS SENDTYPE
      , :vchat_id AS CHAT_ID
      , :vmessage_id AS MESSAGE_ID
      , :vfile_id AS FILE_ID
      , :vtext AS TEXT
      , :vparse_mode AS PARSE_MODE
      , :ventities AS ENTITIES
      , :vreply_to_message_id AS REPLY_TO_MESSAGE_ID
      , :vstatus_id AS STATUS_ID
      , :vresult_clob AS RESULT_CLOB
    FROM DUAL
    ';
    
    CASE
      WHEN vsendtype = 'sendMessage'
        THEN vresult_clob := FUNC_TLG_SENDMESSAGE (
          vchat_id => vchat_id
          , vtext => vtext
          , vparse_mode => vparse_mode
          , ventities => ventities
          , vreply_to_message_id => vreply_to_message_id
          , vreply_markup => vreply_markup
          , vtoken => vbot_token
          , vwallet_path => vwallet_path
          , vwallet_pass => vwallet_pass
          , vproxy => vproxy
          );
      WHEN vsendtype = 'sendPhoto'
        THEN vresult_clob := FUNC_TLG_SENDPHOTO (
          vchat_id => vchat_id
          , vphoto => vfile_id
          , vcaption => vtext
          , vparse_mode => vparse_mode
          , vcaption_entities => ventities
          , vreply_to_message_id => vreply_to_message_id
          , vtoken => vbot_token
          , vwallet_path => vwallet_path
          , vwallet_pass => vwallet_pass
          , vproxy => vproxy
          );
      WHEN vsendtype = 'sendDocument'
        THEN vresult_clob := FUNC_TLG_SENDDOCUMENT (
          vchat_id => vchat_id
          , vfile_id => vfile_id
          , vcaption => vtext
          , vparse_mode => vparse_mode
          , vcaption_entities => ventities
          , vreply_to_message_id => vreply_to_message_id
          , vtoken => vbot_token
          , vwallet_path => vwallet_path
          , vwallet_pass => vwallet_pass
          , vproxy => vproxy
          );
      ELSE NULL;
    END CASE;
    
    CASE
      WHEN JSON_VALUE(vresult_clob, '$.ok') = 'true'
        THEN
          vstatus_id := PKG_STATUS.FUNC_GET_ID_BY_STATUS(vstatus => 'DONE');
          vmessage_id := JSON_VALUE(vresult_clob, '$.*.message_id');
      WHEN SUBSTR(JSON_VALUE(vresult_clob, '$.description'), 1, LENGTH('Forbidden')) = 'Forbidden'
        THEN
          vstatus_id := PKG_STATUS.FUNC_GET_ID_BY_STATUS(vstatus => 'FORBIDDEN');
          vmessage_id := -1;
      WHEN SUBSTR(JSON_VALUE(vresult_clob, '$.description'), 1, LENGTH('Bad Request')) = 'Bad Request'
        THEN
          vstatus_id := PKG_STATUS.FUNC_GET_ID_BY_STATUS(vstatus => 'BAD_REQUEST');
          vmessage_id := -1;
      ELSE
          vstatus_id := PKG_STATUS.FUNC_GET_ID_BY_STATUS(vstatus => 'NOT_KNOWN');
          vmessage_id := -1;
    END CASE;
    
    EXECUTE IMMEDIATE str01 USING vbot_id, vtlgsend_id, vupdate_id, vsendtype, vchat_id
                                  , vmessage_id, vfile_id, vtext, vparse_mode, ventities
                                  , vreply_to_message_id, vstatus_id, vresult_clob;
                                  
    COMMIT;
    
    RETURN vmessage_id;
      
    END;
    
  FUNCTION FUNC_GET_SYSTEM_GROUP (
    vlog_level IN NUMBER DEFAULT 1
    ) RETURN NUMBER
    IS
    str01 VARCHAR(32767);
    vtlggroup_id NUMBER(20);
    BEGIN
      
    str01 := '
    SELECT
      NVL(MAX(TLGGROUP_ID), 0) AS TLGGROUP_ID
    FROM TLG_GROUPS_LOGS_LEVEL
    WHERE
      LOG_LEVEL = :vlog_level
      AND STATUS_ID = PKG_STATUS.FUNC_GET_ID_BY_STATUS(''ENABLED'')
    ';
    
    EXECUTE IMMEDIATE str01 INTO vtlggroup_id USING vlog_level;
    RETURN vtlggroup_id;
      
    END;
    
  FUNCTION FUNC_SYSTEM_LOG (
    vlog_level IN NUMBER DEFAULT 1
    , vbot_id IN NUMBER DEFAULT FUNC_GET_BOTID_BY_TOKEN
    , vtext IN VARCHAR
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    ) RETURN NUMBER
    IS
    BEGIN
      
    RETURN FUNC_TLG_SEND(
				vbot_id => vbot_id
				, vchat_id => FUNC_GET_SYSTEM_GROUP(vlog_level => vlog_level)
				, vsendtype => 'sendMessage'
				-- , vfile_id => ''
				, vtext => vtext
				, vparse_mode => ''
-- 				, vparse_mode => 'HTML'
-- 				, vparse_mode => 'Markdown' -- special character ASCII Encoding URL
				-- , ventities => '[{"offset":0,"length":' || LENGTH(A.FIRST_NAME || ' ' || A.LAST_NAME) || ''
				-- 				|| ' ,"type":"text_mention","user":{"id":' || A.TLGUSER_ID || '}}]'
        , vwallet_path => vwallet_path
        , vwallet_pass => vwallet_pass
        , vproxy => vproxy
		);
    
    END;
  


end PKG_TLG_BOT;
/
