# Run HTTPS API Requests from Oracle SQL

## Overview

This guide shows how to call an HTTPS endpoint from Oracle SQL with `UTL_HTTP`.

The flow is:

1. Create a database user and grant the required privileges.
2. Create an Oracle wallet on the database server.
3. Add the trusted root certificate to the wallet.
4. Grant network ACLs to the user.
5. Execute an HTTPS request from SQL.

The example request in this document uses `https://tuoitre.vn/`.

## Why Run an API Call from Oracle SQL?

Calling an external API directly from Oracle SQL or PL/SQL is useful when the database itself is part of the integration flow.

Typical use cases:

- Push data from database tables to an external API without adding a separate middleware layer.
- Pull reference data from an external service during a PL/SQL job or batch process.
- Trigger an HTTP callback from database logic, for example after a business event is committed.
- Keep the integration close to scheduled jobs already running in `DBMS_SCHEDULER`.
- Support legacy systems where the Oracle database is the main execution platform.

## Why Not Use Python Instead?

In many modern systems, Python, Java, or another application layer is still the better place to call external APIs.

Python is usually better when:

- The integration needs complex authentication flows such as OAuth, JWT rotation, or SDK-based signing.
- The API payloads are large, nested, or require extensive JSON transformation.
- You need modern observability, retries, circuit breakers, and structured error handling.
- You want clearer separation between database responsibilities and application responsibilities.
- The integration is maintained by application engineers rather than DBAs or PL/SQL developers.

Oracle SQL or PL/SQL is better when:

- The logic must run entirely inside the database.
- The calling code is already part of a stored procedure, trigger alternative, batch job, or scheduler job.
- You want to avoid another runtime, deployment unit, or integration service for a small and controlled use case.
- The request is simple and the security model can be managed with ACLs and wallets.

Practical recommendation:

- Use Oracle SQL for small, controlled, database-centric integrations.
- Use Python or another middleware layer for larger, more complex, or higher-change API integrations.

## Prerequisites

- Oracle Database 21c
- OS access as the `oracle` user on the database server
- A root certificate file copied to the database server
- `orapki` available under `$ORACLE_HOME/bin/orapki`

## Step 1: Create a Database User

Connect as `SYS` or another administrative account and create a dedicated user for outbound HTTP calls.

```sql
CREATE USER api_user IDENTIFIED BY "<DB_USER_PASSWORD>";

GRANT CREATE SESSION TO api_user;
GRANT CREATE PROCEDURE TO api_user;
GRANT EXECUTE ON UTL_HTTP TO api_user;
```

Notes:

- `CREATE SESSION` allows the user to connect.
- `CREATE PROCEDURE` is optional, but useful if the user will wrap the HTTP call in PL/SQL.
- `EXECUTE ON UTL_HTTP` allows the user to use the package directly.

## Step 2: Create the Wallet Directories

Log in to Oracle Linux as the OS user `oracle`.

Notes:

- `testrac` in the example paths is only a lab-specific database name placeholder.
- Replace `testrac` with the database name, `DB_UNIQUE_NAME`, or admin directory name used on your server.
- The base path can differ by OS and Oracle installation layout. On Oracle Linux it is often under `$ORACLE_BASE`, while on another host it may be a different absolute path.

Optional cleanup:

```bash
rm -rf $ORACLE_BASE/admin/testrac/wallet/wallet_isrg_root_x1/
```

Create the working directories:

```bash
mkdir -p $ORACLE_BASE/admin/testrac/wallet/wallettemp/
mkdir -p $ORACLE_BASE/admin/testrac/wallet/wallet_isrg_root_x1/
```

## Step 3: Export the Trusted Root Certificate

Open the target site in a browser and export the root CA certificate used by the site.

Reference workflow:

- Open the HTTPS site in a browser.
- View the certificate chain.
- Export the root certificate, not only the leaf certificate.
- Copy the exported certificate file to:
  `$ORACLE_BASE/admin/testrac/wallet/wallettemp/`

For example, the certificate file may be named:

```text
$ORACLE_BASE/admin/testrac/wallet/wallettemp/ISRG Root X1.crt
```

Comment:

- This example assumes the certificate was copied into the wallet temp directory created earlier.
- If your server uses a different admin path or directory naming convention, adjust the full path accordingly.

Reference:

- Oracle-Base article on `UTL_HTTP` and SSL wallet setup: https://oracle-base.com/articles/misc/utl_http-and-ssl

## Step 4: Create the Oracle Wallet

Run the following commands as the OS user `oracle`.

Optional wallet cleanup:

```bash
$ORACLE_HOME/bin/orapki wallet remove -wallet $ORACLE_BASE/admin/testrac/wallet/ -trusted_cert_all -pwd '<WALLET_PASSWORD>'
```

Create the wallet:

```bash
$ORACLE_HOME/bin/orapki wallet create \
  -wallet $ORACLE_BASE/admin/testrac/wallet/wallet_isrg_root_x1/ \
  -pwd '<WALLET_PASSWORD>' \
  -auto_login
```

Add the trusted root certificate:

```bash
$ORACLE_HOME/bin/orapki wallet add \
  -wallet $ORACLE_BASE/admin/testrac/wallet/wallet_isrg_root_x1/ \
  -trusted_cert \
  -cert "$ORACLE_BASE/admin/testrac/wallet/wallettemp/ISRG Root X1.crt" \
  -pwd '<WALLET_PASSWORD>'
```

Optional verification:

```bash
$ORACLE_HOME/bin/orapki wallet display \
  -wallet $ORACLE_BASE/admin/testrac/wallet/wallet_isrg_root_x1/
```

## Step 5: Grant ACLs to the Database User

For a production-oriented setup, grant access only to the specific target host instead of using `host => '*'`.

### Grant Host Access

Connect as `SYS` and grant access only to `tuoitre.vn` on HTTPS port `443`.

```sql
BEGIN
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
    host       => 'tuoitre.vn',
    lower_port => 443,
    upper_port => 443,
    ace        => XS$ACE_TYPE(
                    privilege_list => XS$NAME_LIST('http'),
                    principal_name => 'API_USER',
                    principal_type => XS_ACL.PTYPE_DB
                  )
  );
END;
/
```

If your requests go to `www.tuoitre.vn`, add that host explicitly as well:

```sql
BEGIN
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
    host       => 'www.tuoitre.vn',
    lower_port => 443,
    upper_port => 443,
    ace        => XS$ACE_TYPE(
                    privilege_list => XS$NAME_LIST('http'),
                    principal_name => 'API_USER',
                    principal_type => XS_ACL.PTYPE_DB
                  )
  );
END;
/
```

### Grant Wallet Access

When the session opens a password-protected wallet, grant wallet access to the same database user.

Notes:

- `file:<WALLET_DIRECTORY_URI>` is only an example placeholder.
- Your environment may use a different mount point, drive, or directory root depending on OS and Oracle installation.
- Replace `<WALLET_DIRECTORY_URI>` with the real wallet directory URI on your database server.

```sql
BEGIN
  DBMS_NETWORK_ACL_ADMIN.APPEND_WALLET_ACE(
    wallet_path => 'file:<WALLET_DIRECTORY_URI>',
    ace         => XS$ACE_TYPE(
                     privilege_list => XS$NAME_LIST('use_client_certificates', 'use_passwords'),
                     principal_name => 'API_USER',
                     principal_type => XS_ACL.PTYPE_DB
                   )
  );
END;
/
```

Notes:

- This setup follows the principle of least privilege.
- Grant only the exact host names that the application needs.
- `use_passwords` is required when you pass the wallet password at runtime.
- `use_client_certificates` is commonly granted together with wallet access to avoid wallet-related permission issues.

## Step 6: Run the HTTPS Request

Connect as the new user:

```sql
CONNECT api_user/"<DB_USER_PASSWORD>";
```

Run a simple request:

Comment:

- The wallet path below must match your actual wallet location.
- Replace `file:<WALLET_DIRECTORY_URI>` with the correct `file:` URI for your environment.

```sql
SELECT UTL_HTTP.REQUEST(
         'https://tuoitre.vn/',
         NULL,
         'file:<WALLET_DIRECTORY_URI>',
         '<WALLET_PASSWORD>'
       ) AS response_text
FROM dual;
```

Important:

- `UTL_HTTP.REQUEST` returns up to the first 2000 bytes only.
- For larger responses or JSON APIs, a `BEGIN_REQUEST` / `GET_RESPONSE` / `READ_TEXT` pattern is usually better.
- For repeated or application-level integrations, a helper package is usually better than repeating the low-level `UTL_HTTP` flow in every procedure.

## Optional Test Using `SET_WALLET`

Instead of passing the wallet in every call, the user can set the wallet once in the session:

Comment:

- As above, replace `file:<WALLET_DIRECTORY_URI>` with the path that exists on your server.

```sql
BEGIN
  UTL_HTTP.SET_WALLET(
    path     => 'file:<WALLET_DIRECTORY_URI>',
    password => '<WALLET_PASSWORD>'
  );
END;
/
```

Then run:

```sql
SELECT UTL_HTTP.REQUEST('https://tuoitre.vn/') AS response_text
FROM dual;
```

## Common Errors

### `ORA-24247: network access denied by access control list (ACL)`

Cause:

- The host ACL was not granted, or the host name in the ACL does not match the URL being called.

Fix:

- Verify that the target host was granted explicitly, such as `tuoitre.vn` or `www.tuoitre.vn`.
- Verify that the URL host exactly matches the ACL host entry.

### `ORA-29024: Certificate validation failure`

Cause:

- The wallet does not contain the correct trusted root or intermediate certificate.

Fix:

- Re-export the correct certificate chain from the target site.
- Add the required trusted certificate to the wallet.

### `ORA-28759: failure to open file`

Cause:

- The wallet path is wrong, inaccessible, or the database process cannot read it.

Fix:

- Verify the absolute wallet path.
- Verify OS permissions on the wallet directory and files.

## Verification Queries

Check host ACLs:

```sql
SELECT host, lower_port, upper_port, principal, privilege
FROM   dba_host_aces
WHERE  principal = 'API_USER';
```

Check wallet ACLs:

```sql
SELECT wallet_path, principal, privilege
FROM   dba_wallet_aces
WHERE  principal = 'API_USER';
```

## References

- Oracle Database `DBMS_NETWORK_ACL_ADMIN`: https://docs.oracle.com/en/database/oracle/oracle-database/21/arpls/DBMS_NETWORK_ACL_ADMIN.html
- Oracle Database `UTL_HTTP`: https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/UTL_HTTP.html
- Oracle-Base, `UTL_HTTP and SSL (HTTPS) using Oracle Wallets`: https://oracle-base.com/articles/misc/utl_http-and-ssl
