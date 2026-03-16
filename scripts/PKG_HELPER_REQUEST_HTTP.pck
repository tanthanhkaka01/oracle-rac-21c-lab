create or replace package PKG_HELPER_REQUEST_HTTP is

  -- Author  : ADMINISTRATOR
  -- Created : 09/09/2025 10:01:50
  -- Purpose : PACKAGE TO HELPER REQUEST HTTP
  
  -- Public type declarations
  -- type <TypeName> is <Datatype>;
  
  -- Public constant declarations
  -- <ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  -- <VariableName> <Datatype>;

  -- Public function and procedure declarations
  -- function <FunctionName>(<Parameter> <Datatype>) return <Datatype>;
  
  CONSTANT_OWNER CONSTANT VARCHAR(500) := SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA');
  CONSTANT_PACKAGE_NAME CONSTANT VARCHAR(500) := 'PKG_HELPER_REQUEST_HTTP';
  
  FUNCTION FUNC_REQUEST_HTML (
    vurl IN VARCHAR
    , vdata IN VARCHAR DEFAULT NULL
    , vmethod IN VARCHAR DEFAULT 'POST'
    , vtimeout IN NUMBER DEFAULT 10
    , vcontent_type IN VARCHAR DEFAULT 'application/x-www-form-urlencoded; charset="UTF-8"'
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    , v_max_attempt IN NUMBER DEFAULT 3
    ) RETURN CLOB;
  
  FUNCTION FUNC_REQUEST_HTML_CLOB (
    vurl IN VARCHAR
    , vdata IN CLOB DEFAULT NULL
    , vmethod IN VARCHAR DEFAULT 'POST'
    , vtimeout IN NUMBER DEFAULT 600
    , vcontent_type IN VARCHAR DEFAULT 'application/x-www-form-urlencoded; charset="UTF-8"'
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    , v_max_attempt IN NUMBER DEFAULT 3
    ) RETURN CLOB;
  
  FUNCTION FUNC_REQUEST_BLOB_RAW (
    vurl IN VARCHAR
    , vdata IN VARCHAR DEFAULT NULL
    , vmethod IN VARCHAR DEFAULT 'GET'
    , vtimeout IN NUMBER DEFAULT 600
    , vcontent_type IN VARCHAR DEFAULT 'application/x-www-form-urlencoded; charset="UTF-8"'
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    , v_max_attempt IN NUMBER DEFAULT 3
    ) RETURN BLOB;
    
  FUNCTION FUNC_REQUEST_MULTIPART (
    vurl IN VARCHAR
    , v_parts IN UTL_HTTP_MULTIPART.PARTS
    , vmethod IN VARCHAR DEFAULT 'POST'
    , vtimeout IN NUMBER DEFAULT 600
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    , v_max_attempt IN NUMBER DEFAULT 3
    ) RETURN CLOB;
    

end PKG_HELPER_REQUEST_HTTP;
/
create or replace package body PKG_HELPER_REQUEST_HTTP is
  
  FUNCTION FUNC_REQUEST_HTML (
    vurl IN VARCHAR
    , vdata IN VARCHAR DEFAULT NULL
    , vmethod IN VARCHAR DEFAULT 'POST'
    , vtimeout IN NUMBER DEFAULT 10
    , vcontent_type IN VARCHAR DEFAULT 'application/x-www-form-urlencoded; charset="UTF-8"'
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    , v_max_attempt IN NUMBER DEFAULT 3
    ) RETURN CLOB
    IS
    v_retry_count INTEGER := 0;
    req utl_http.req;
    resp utl_http.resp;
    msg varchar2(80);
    -- raw_buffer RAW(32767);
    entire_msg clob;
    BEGIN

    -- Set Oracle Wallet for HTTPS
    UTL_HTTP.SET_WALLET(path => vwallet_path, password => vwallet_pass);

    -- Set transfer timeout
    UTL_HTTP.SET_TRANSFER_TIMEOUT(vtimeout);

    -- Configure proxy
    IF NVL(vproxy, '0') <> '0'
      THEN
        UTL_HTTP.SET_PROXY(proxy => vproxy, no_proxy_domains => NULL);
      ELSE
        UTL_HTTP.SET_PROXY(proxy => NULL, no_proxy_domains => NULL);
    END IF;

    -- Begin HTTP request with retry logic
    LOOP
        BEGIN
            req := UTL_HTTP.BEGIN_REQUEST(url => vurl, method => vmethod);

            -- Set headers
            UTL_HTTP.SET_HEADER(r => req, name => 'User-Agent', value => 'Mozilla/4.0');
            UTL_HTTP.SET_HEADER(r => req, name => 'Content-Type', value => vcontent_type);
            UTL_HTTP.SET_BODY_CHARSET(req, 'UTF-8');

            -- Send request body
            IF vdata IS NOT NULL THEN
                UTL_HTTP.SET_HEADER(r => req, name => 'Content-Length', value => LENGTHB(vdata));
                UTL_HTTP.WRITE_TEXT(r => req, data => vdata);
                -- DBMS_OUTPUT.PUT_LINE(vdata);
            END IF;

            -- Get response
            resp := UTL_HTTP.GET_RESPONSE(r => req);
            
            -- DBMS_LOB.CREATETEMPORARY(entire_msg, TRUE);

            -- Read response
            BEGIN
                LOOP
                    UTL_HTTP.READ_TEXT(r => resp, data => msg);
                    entire_msg := entire_msg || msg;
                    -- UTL_HTTP.READ_RAW(r => resp, data => raw_buffer);
                    -- DBMS_LOB.WRITEAPPEND(entire_msg, UTL_RAW.LENGTH(raw_buffer), raw_buffer);
                END LOOP;
            EXCEPTION
                WHEN UTL_HTTP.END_OF_BODY THEN
                    NULL;
                WHEN UTL_HTTP.TOO_MANY_REQUESTS THEN
                    UTL_HTTP.END_RESPONSE(resp);
                    RAISE;
            END;

            UTL_HTTP.END_RESPONSE(resp);
            EXIT; -- Exit retry loop on success

        EXCEPTION
            WHEN OTHERS THEN
                UTL_HTTP.END_RESPONSE(resp);
                v_retry_count := v_retry_count + 1;
                IF v_retry_count >= v_max_attempt THEN
                  RAISE_APPLICATION_ERROR(-20001, 'Request failed after ' || v_retry_count || 
                                                    ' retries: ' || SQLERRM || 
                                                    '. Detailed error: ' || UTL_HTTP.GET_DETAILED_SQLERRM);
                ELSE
                    DBMS_LOCK.SLEEP(1);
                END IF;
        END;
    END LOOP;

    -- RETURN UTL_ENCODE.BASE64_ENCODE(entire_msg);
    RETURN entire_msg;
                                            
    END FUNC_REQUEST_HTML;
  
  FUNCTION FUNC_REQUEST_HTML_CLOB (
    vurl IN VARCHAR
    , vdata IN CLOB DEFAULT NULL
    , vmethod IN VARCHAR DEFAULT 'POST'
    , vtimeout IN NUMBER DEFAULT 600
    , vcontent_type IN VARCHAR DEFAULT 'application/x-www-form-urlencoded; charset="UTF-8"'
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    , v_max_attempt IN NUMBER DEFAULT 3
    ) RETURN CLOB
    IS
    v_retry_count INTEGER := 0;
    req utl_http.req;
    resp utl_http.resp;
    msg varchar2(80);
    entire_msg clob;
    BEGIN
      
    UTL_HTTP.SET_WALLET(path => vwallet_path, password => vwallet_pass);
    
    utl_http.SET_TRANSFER_TIMEOUT(vtimeout);

    -- Configure proxy
    IF NVL(vproxy, '0') <> '0'
      THEN
        UTL_HTTP.SET_PROXY(proxy => vproxy, no_proxy_domains => NULL);
      ELSE
        UTL_HTTP.SET_PROXY(proxy => NULL, no_proxy_domains => NULL);
    END IF;

    -- Begin HTTP request with retry logic
    LOOP
        BEGIN
    
            req := utl_http.begin_request(url => vurl, method => vmethod);
            
            UTL_HTTP.SET_HEADER(r => req, name => 'User-Agent', value => 'Mozilla/4.0');
            UTL_HTTP.SET_HEADER(r => req, name => 'content-type', value => vcontent_type);
            -- utl_http.set_header(r => req, name => 'encoding', value => 'UTF-8');
            UTL_HTTP.SET_BODY_CHARSET(req, 'UTF-8');
            
            IF vdata IS NOT NULL
              THEN
                  UTL_HTTP.SET_HEADER(r => req, name => 'content-length', value => LENGTH(vdata));
                  utl_http.write_text(r => req, data => vdata);
              END IF;
              
            resp := utl_http.get_response(r => req);
            
            begin
                loop
                    utl_http.read_text(r => resp, data => msg);
                    entire_msg := entire_msg || msg;
                end loop;
                
            exception
                when utl_http.end_of_body then null;
                WHEN UTL_HTTP.TOO_MANY_REQUESTS THEN UTL_HTTP.END_RESPONSE(resp); 
            end;
            
            utl_http.end_response(resp);
            EXIT; -- Exit retry loop on success

        EXCEPTION
            WHEN OTHERS THEN
                UTL_HTTP.END_RESPONSE(resp);
                v_retry_count := v_retry_count + 1;
                IF v_retry_count >= v_max_attempt THEN
                  RAISE_APPLICATION_ERROR(-20001, 'Request failed after ' || v_retry_count || 
                                                    ' retries: ' || SQLERRM || 
                                                    '. Detailed error: ' || UTL_HTTP.GET_DETAILED_SQLERRM);
                ELSE
                    DBMS_LOCK.SLEEP(1);
                END IF;
        END;
    END LOOP;
    
    RETURN entire_msg;
      
    END;
  
  FUNCTION FUNC_REQUEST_BLOB_RAW (
    vurl IN VARCHAR
    , vdata IN VARCHAR DEFAULT NULL
    , vmethod IN VARCHAR DEFAULT 'GET'
    , vtimeout IN NUMBER DEFAULT 600
    , vcontent_type IN VARCHAR DEFAULT 'application/x-www-form-urlencoded; charset="UTF-8"'
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    , v_max_attempt IN NUMBER DEFAULT 3
    ) RETURN BLOB
    IS
    v_retry_count INTEGER := 0;
    req utl_http.req;
    resp utl_http.resp;
    msg varchar2(32767);
    entire_msg BLOB;
    BEGIN
      
    UTL_HTTP.SET_WALLET(path => vwallet_path, password => vwallet_pass);
    
    utl_http.SET_TRANSFER_TIMEOUT(vtimeout);

    -- Configure proxy
    IF NVL(vproxy, '0') <> '0'
      THEN
        UTL_HTTP.SET_PROXY(proxy => vproxy, no_proxy_domains => NULL);
      ELSE
        UTL_HTTP.SET_PROXY(proxy => NULL, no_proxy_domains => NULL);
    END IF;
      
    DBMS_LOB.createtemporary(entire_msg, FALSE);

    -- Begin HTTP request with retry logic
    LOOP
        BEGIN
    
            req := utl_http.begin_request(url => vurl, method => vmethod);
            
            UTL_HTTP.SET_HEADER(r => req, name => 'User-Agent', value => 'Mozilla/4.0');
            utl_http.set_header(r => req, name => 'content-type', value => vcontent_type);
            -- utl_http.set_header(r => req, name => 'encoding', value => 'UTF-8');
            UTL_HTTP.SET_BODY_CHARSET(req, 'UTF-8');
            
            IF vdata IS NOT NULL
              THEN
                  utl_http.set_header(r => req, name => 'content-length', value => LENGTHB(vdata));
                  utl_http.write_text(r => req, data => vdata);
              END IF;
              
            resp := utl_http.get_response(r => req);
            
            begin
                loop
                    utl_http.read_raw(r => resp, data => msg, len => 100);
                    DBMS_LOB.writeappend (entire_msg, UTL_RAW.length(msg), msg);
                end loop;
                
            exception
                when utl_http.end_of_body then null;
                WHEN UTL_HTTP.TOO_MANY_REQUESTS THEN UTL_HTTP.END_RESPONSE(resp); 
            end;
            
            utl_http.end_response(resp);
            EXIT; -- Exit retry loop on success

        EXCEPTION
            WHEN OTHERS THEN
                UTL_HTTP.END_RESPONSE(resp);
                v_retry_count := v_retry_count + 1;
                IF v_retry_count >= v_max_attempt THEN
                  RAISE_APPLICATION_ERROR(-20001, 'Request failed after ' || v_retry_count || 
                                                    ' retries: ' || SQLERRM || 
                                                    '. Detailed error: ' || UTL_HTTP.GET_DETAILED_SQLERRM);
                ELSE
                    DBMS_LOCK.SLEEP(1);
                END IF;
        END;
    END LOOP;
    
    RETURN entire_msg;
      
    END;
    
  FUNCTION FUNC_REQUEST_MULTIPART (
    vurl IN VARCHAR
    , v_parts IN UTL_HTTP_MULTIPART.PARTS
    , vmethod IN VARCHAR DEFAULT 'POST'
    , vtimeout IN NUMBER DEFAULT 600
    , vwallet_path IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PATH
    , vwallet_pass IN VARCHAR DEFAULT PKG_WALLET.FUNC_GET_WALLET_PASS
    , vproxy IN VARCHAR DEFAULT PKG_PROXY.FUNC_GET_PROXY
    , v_max_attempt IN NUMBER DEFAULT 3
    ) RETURN CLOB
    IS
    v_retry_count INTEGER := 0;
    v_parts_02 UTL_HTTP_MULTIPART.PARTS := v_parts;
    l_http_request utl_http.req;
    resp utl_http.resp;
    l_response_header_name varchar2(32767);
    l_response_header_value varchar2(32767);
    msg varchar2(80);
    entire_msg clob;
    BEGIN
      
    UTL_HTTP.SET_WALLET(path => vwallet_path, password => vwallet_pass);
    
    utl_http.SET_TRANSFER_TIMEOUT(vtimeout);

    -- Configure proxy
    IF NVL(vproxy, '0') <> '0'
      THEN
        UTL_HTTP.SET_PROXY(proxy => vproxy, no_proxy_domains => NULL);
      ELSE
        UTL_HTTP.SET_PROXY(proxy => NULL, no_proxy_domains => NULL);
    END IF;

    -- Begin HTTP request with retry logic
    LOOP
        BEGIN
   
            l_http_request := utl_http.begin_request(
                                url => vurl,
                                method => vmethod,
                                http_version => 'HTTP/1.1'
                              );
            
          --   utl_http_multipart.send_with_data(l_http_request, v_parts, vdata);
            utl_http_multipart.send(l_http_request, v_parts_02);
           
            resp := utl_http.get_response(l_http_request);
            -- dbms_output.put_line('Response> Status Code: ' || l_http_response.status_code);
            -- dbms_output.put_line('Response> Reason Phrase: ' || l_http_response.reason_phrase);
            -- dbms_output.put_line('Response> HTTP Version: ' || l_http_response.http_version);
           
            for i in 1 .. utl_http.get_header_count(resp) loop
              utl_http.get_header(resp, i, l_response_header_name, l_response_header_value);
              -- dbms_output.put_line('Response> ' || l_response_header_name || ': ' || l_response_header_value);
            end loop;
            
            begin
                loop
                    utl_http.read_text(r => resp, data => msg);
                    entire_msg := entire_msg || msg;
                end loop;
                
            exception
                when utl_http.end_of_body then null;
                WHEN UTL_HTTP.TOO_MANY_REQUESTS THEN UTL_HTTP.END_RESPONSE(resp); 
            end;
            
            utl_http.end_response(resp);
            EXIT; -- Exit retry loop on success

        EXCEPTION
            WHEN OTHERS THEN
                UTL_HTTP.END_RESPONSE(resp);
                v_retry_count := v_retry_count + 1;
                IF v_retry_count >= v_max_attempt THEN
                  RAISE_APPLICATION_ERROR(-20001, 'Request failed after ' || v_retry_count || 
                                                    ' retries: ' || SQLERRM || 
                                                    '. Detailed error: ' || UTL_HTTP.GET_DETAILED_SQLERRM);
                ELSE
                    DBMS_LOCK.SLEEP(1);
                END IF;
        END;
    END LOOP;
    
    RETURN entire_msg;
    
    END;



end PKG_HELPER_REQUEST_HTTP;
/
