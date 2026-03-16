# Create an HTTP Helper Package for Oracle PL/SQL

## Overview

This guide explains the helper package in [`scripts/PKG_HELPER_REQUEST_HTTP.pck`](../scripts/PKG_HELPER_REQUEST_HTTP.pck).

The package wraps `UTL_HTTP` so application code can call HTTPS endpoints with a simpler and more reusable API.

It provides helpers for:

1. Sending text requests and returning a `CLOB`
2. Sending `CLOB` payloads and returning a `CLOB`
3. Downloading binary content and returning a `BLOB`
4. Sending `multipart/form-data` requests

The flow is:

1. Prepare the wallet and ACL setup.
2. Compile the helper package.
3. Call HTTPS endpoints through reusable PL/SQL functions.

This package is useful when you already completed the wallet and ACL setup described in [`03-run-https-api-requests.md`](./03-run-https-api-requests.md) and want a reusable PL/SQL layer instead of repeating low-level `UTL_HTTP` code.

## Why Use a Helper Package?

Calling `UTL_HTTP` directly works, but application code quickly becomes repetitive.

This package centralizes:

- Wallet configuration
- Proxy configuration
- Transfer timeout handling
- Retry logic
- Header setup
- Response reading
- Error reporting

That makes calling code shorter and easier to maintain.

## Package Dependencies

The package depends on the following objects:

- `UTL_HTTP`
- `DBMS_LOCK`
- `DBMS_LOB`
- `UTL_HTTP_MULTIPART`
- `PKG_WALLET`
- `PKG_PROXY`

Notes:

- `PKG_WALLET` only needs to return string values for wallet path and wallet password.
- `PKG_PROXY` only needs to return a string value for proxy configuration.
- In practice, those helper packages can be very small because they only return configuration strings.
- In this repository, only [`PKG_HELPER_REQUEST_HTTP.pck`](../scripts/PKG_HELPER_REQUEST_HTTP.pck) is present. Create or adapt `PKG_WALLET` and `PKG_PROXY` in your environment before compiling this package.

## What the Package Contains

The package defines these constants:

- `CONSTANT_OWNER`
- `CONSTANT_PACKAGE_NAME`

It exposes four public functions:

### `FUNC_REQUEST_HTML`

Use this when the request body is a normal `VARCHAR` and the response is text.

Main parameters:

- `vurl`: target URL
- `vdata`: request body
- `vmethod`: HTTP method, default `POST`
- `vtimeout`: timeout in seconds, default `10`
- `vcontent_type`: request content type
- `vwallet_path`: wallet path
- `vwallet_pass`: wallet password
- `vproxy`: proxy address
- `v_max_attempt`: number of retry attempts when the request fails

Return type:

- `CLOB`

### `FUNC_REQUEST_HTML_CLOB`

Use this when the request body is larger and should be passed as `CLOB`.

Typical use case:

- Large JSON payloads
- Long XML payloads
- Text bodies larger than `VARCHAR2` limits in your calling context

Return type:

- `CLOB`

### `FUNC_REQUEST_BLOB_RAW`

Use this when the response is binary data.

Typical use case:

- Downloading a PDF
- Downloading an image
- Downloading any file stream

Return type:

- `BLOB`

### `FUNC_REQUEST_MULTIPART`

Use this when the endpoint expects `multipart/form-data`.

Typical use case:

- File upload APIs
- Mixed text and file form submissions

Input type:

- `UTL_HTTP_MULTIPART.PARTS`

Return type:

- `CLOB`

## Implementation Notes

The package follows the same request flow in each function:

1. Set the wallet with `UTL_HTTP.SET_WALLET`
2. Set the timeout with `UTL_HTTP.SET_TRANSFER_TIMEOUT`
3. Configure the proxy
4. Start the request
5. Write the request body when present
6. Read the response
7. Retry on failure until `v_max_attempt` is reached

Notes:

- The package sets `User-Agent` to `Mozilla/4.0`.
- UTF-8 is used through `UTL_HTTP.SET_BODY_CHARSET`.
- A simple retry loop waits `1` second between attempts.
- `v_max_attempt` controls how many times the package will try again when the API call fails.
- This is useful because external API calls often fail temporarily due to timeout, unstable network, proxy issues, or short-lived remote server errors.
- When all retries fail, the package raises `-20001` with `SQLERRM` and `UTL_HTTP.GET_DETAILED_SQLERRM`.

## Create the Package

Connect as the target schema and run the package script:

```sql
@scripts/PKG_HELPER_REQUEST_HTTP.pck
```

If you run it from another working directory, use the full or correct relative path:

```sql
@d:\Projects\oracle-rac-21c-lab\scripts\PKG_HELPER_REQUEST_HTTP.pck
```

After compilation, verify the object status:

```sql
SELECT object_name, object_type, status
FROM   user_objects
WHERE  object_name = 'PKG_HELPER_REQUEST_HTTP';
```

## Example 1: Simple Text POST Request

```sql
SELECT PKG_HELPER_REQUEST_HTTP.FUNC_REQUEST_HTML(
         vurl          => 'https://postman-echo.com/post',
         vdata         => 'name=oracle&env=lab',
         vmethod       => 'POST',
         vcontent_type => 'application/x-www-form-urlencoded; charset="UTF-8"'
       ) AS response_text
FROM dual;
```

## Example 2: JSON Request with `CLOB`

```sql
DECLARE
  l_payload  CLOB;
  l_response CLOB;
BEGIN
  l_payload := '{"message":"hello from oracle","source":"plsql"}';

  l_response := PKG_HELPER_REQUEST_HTTP.FUNC_REQUEST_HTML_CLOB(
                  vurl          => 'https://postman-echo.com/post',
                  vdata         => l_payload,
                  vmethod       => 'POST',
                  vcontent_type => 'application/json; charset="UTF-8"'
                );

  DBMS_OUTPUT.PUT_LINE(DBMS_LOB.SUBSTR(l_response, 4000, 1));
END;
/
```

## Example 3: Download a Binary File

```sql
DECLARE
  l_blob BLOB;
BEGIN
  l_blob := PKG_HELPER_REQUEST_HTTP.FUNC_REQUEST_BLOB_RAW(
              vurl    => 'https://example.com/sample.pdf',
              vmethod => 'GET'
            );

  DBMS_OUTPUT.PUT_LINE('Downloaded bytes: ' || DBMS_LOB.GETLENGTH(l_blob));
END;
/
```

## Example 4: Multipart Request

```sql
DECLARE
  l_parts    UTL_HTTP_MULTIPART.PARTS;
  l_response CLOB;
BEGIN
  l_parts := UTL_HTTP_MULTIPART.PARTS();

  l_response := PKG_HELPER_REQUEST_HTTP.FUNC_REQUEST_MULTIPART(
                  vurl   => 'https://example.com/upload',
                  v_parts => l_parts,
                  vmethod => 'POST'
                );

  DBMS_OUTPUT.PUT_LINE(DBMS_LOB.SUBSTR(l_response, 4000, 1));
END;
/
```

Notes:

- The exact way to populate `UTL_HTTP_MULTIPART.PARTS` depends on your Oracle helper utilities and target API contract.
- If your environment does not already use `UTL_HTTP_MULTIPART`, verify that the package is available before using this function.

## Recommended Supporting Packages

This helper package is easier to operate if wallet and proxy values are centralized in separate packages.

Example design:

- `PKG_WALLET.FUNC_GET_WALLET_PATH`
- `PKG_WALLET.FUNC_GET_WALLET_PASS`
- `PKG_PROXY.FUNC_GET_PROXY`

Those packages do not need complex logic. Returning string values is enough.

This allows callers to omit those parameters in most requests and keep configuration in one place.

## Common Errors

### `ORA-24247: network access denied by access control list (ACL)`

Cause:

- The schema does not have the required host ACL.

Fix:

- Recheck the ACL grants from [`03-run-https-api-requests.md`](./03-run-https-api-requests.md).

### `ORA-29024: Certificate validation failure`

Cause:

- The wallet does not trust the remote certificate chain.

Fix:

- Rebuild or update the wallet with the required root or intermediate certificates.

### `ORA-28759: failure to open file`

Cause:

- The wallet path is wrong or inaccessible from the database server.

Fix:

- Verify the wallet directory path and permissions.

### `PLS-00201` for `PKG_WALLET` or `PKG_PROXY`

Cause:

- The helper package references local packages that do not exist yet in the schema.

Fix:

- Create those packages first, or modify the defaults in `PKG_HELPER_REQUEST_HTTP` to match your environment.

## Practical Recommendation

Use this package when:

- Your PL/SQL code calls HTTPS endpoints repeatedly
- You want one shared retry and wallet strategy
- You want calling code to stay short and consistent

Use direct `UTL_HTTP` only when:

- You are testing a one-off call
- You need a custom flow that does not fit the helper package yet

## References

- Package script: [`PKG_HELPER_REQUEST_HTTP.pck`](../scripts/PKG_HELPER_REQUEST_HTTP.pck)
- Setup guide: [`03-run-https-api-requests.md`](./03-run-https-api-requests.md)
