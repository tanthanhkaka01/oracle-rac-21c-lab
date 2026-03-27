# Create a Telegram Bot Helper Package for Oracle PL/SQL

## Overview

This guide explains the helper package in [`scripts/PKG_TLG_BOT.pck`](../scripts/PKG_TLG_BOT.pck).

The package wraps common Telegram Bot API operations so PL/SQL code can:

1. Resolve bot configuration from local tables
2. Call Telegram Bot API endpoints through a shared HTTP helper
3. Send messages, photos, and documents
4. Handle chat join requests
5. Write send results into a local log table

This package is useful when your Oracle database needs to notify users or groups through Telegram without adding a separate middleware service.

## Why Use a Telegram Helper Package?

Calling the Telegram Bot API directly from every procedure would create repeated code for:

- Bot token lookup
- Bot URL lookup
- Wallet and proxy configuration
- HTTP request building
- Response parsing
- Logging send results

`PKG_TLG_BOT` centralizes those responsibilities and gives the schema one reusable PL/SQL interface for Telegram integrations.

## Package Dependencies

The package depends on the following database objects and packages:

- `PKG_HELPER_REQUEST_HTTP`
- `PKG_WALLET`
- `PKG_PROXY`
- `PKG_STATUS`
- `PKG_KEY`
- `UTL_URL`
- `UTL_HTTP_MULTIPART`

It also reads or writes these tables:

- `TLG_BOT_TOKEN`
- `LOG_TLG_SEND`
- `TLG_GROUPS_LOGS_LEVEL`
- `BFILES`

Notes:

- `PKG_HELPER_REQUEST_HTTP` is the outbound HTTPS layer documented in [`04-create-http-helper-package.md`](./04-create-http-helper-package.md).
- `PKG_WALLET` and `PKG_PROXY` provide default runtime configuration values.
- `PKG_STATUS` is used to resolve logical statuses such as `ENABLED`, `PENDING`, `DONE`, `FORBIDDEN`, `BAD_REQUEST`, and `NOT_KNOWN`.
- `PKG_KEY` is used to generate new IDs for `LOG_TLG_SEND`.
- The package assumes the schema already stores Telegram bot metadata in `TLG_BOT_TOKEN`.

## What the Package Contains

The package defines these constants:

- `CONSTANT_OWNER`
- `CONSTANT_PACKAGE_NAME`

It then exposes several groups of functions.

### 1. Bot Configuration Lookup

These functions resolve local Telegram bot metadata:

- `FUNC_GET_BOTID_BY_TOKEN`
- `FUNC_GET_USERID_BY_BOTID`
- `FUNC_GET_TOKEN_BY_NAME`
- `FUNC_GET_TOKEN_BY_BOTID`
- `FUNC_GET_TOKEN_BY_USERID`
- `FUNC_GET_URL_BY_BOTID`
- `FUNC_GET_URL_BY_BOTTOKEN`

These functions read from `TLG_BOT_TOKEN` and usually fall back to the currently enabled bot when the input value is `0`.

Typical use cases:

- Find the active bot token
- Map a bot to an owning user
- Build the base Telegram API URL for a bot

## 2. Telegram API Wrappers

These functions call Telegram Bot API endpoints and return raw JSON as `CLOB`:

- `FUNC_TLG_GETME`
- `FUNC_TLG_GETFILE`
- `FUNC_TLG_GETUPDATES`
- `FUNC_TLG_SENDMESSAGE`
- `FUNC_TLG_SENDPHOTO`
- `FUNC_TLG_SENDDOCUMENT`
- `FUNC_TLG_FORWARDMESSAGE`
- `FUNC_TLG_GETCHATMEMB`
- `FUNC_TLG_HANDLE_JOIN`
- `FUNC_TLG_SEND_FILE`

Notes:

- Most functions call the shared HTTP helper with `application/x-www-form-urlencoded`.
- `FUNC_TLG_GETME` uses `application/json`.
- `FUNC_TLG_SEND_FILE` uses `multipart/form-data` through `UTL_HTTP_MULTIPART`.
- Wallet path, wallet password, and proxy can be passed explicitly or resolved from helper packages.

## 3. Logged Send Wrapper

`FUNC_TLG_SEND` is the main application-facing wrapper when you want to both send content and record the result.

It:

1. Resolves the bot token from `vbot_id`
2. Calls one of:
   `sendMessage`, `sendPhoto`, or `sendDocument`
3. Parses the JSON response
4. Maps the result to a local status
5. Inserts a row into `LOG_TLG_SEND`
6. Commits through an autonomous transaction

Return value:

- Telegram `message_id` when successful
- `-1` when the response maps to an error case

Supported `vsendtype` values in the current implementation:

- `sendMessage`
- `sendPhoto`
- `sendDocument`

## 4. System Log Helper

Two functions support Telegram-based operational logging:

- `FUNC_GET_SYSTEM_GROUP`
- `FUNC_SYSTEM_LOG`

`FUNC_GET_SYSTEM_GROUP` resolves a Telegram group by log level from `TLG_GROUPS_LOGS_LEVEL`.

`FUNC_SYSTEM_LOG` sends a message to the mapped group by calling `FUNC_TLG_SEND`.

This is useful for:

- Job status notifications
- Error alerts
- Simple operational monitoring messages

## Recommended Table Design

The exact table definitions are not included in this repository, but the package implies the following minimum structures.

### `TLG_BOT_TOKEN`

Expected columns:

- `BOT_ID`
- `BOT_NAME`
- `BOT_TOKEN`
- `BOT_URL`
- `USER_ID`
- `STATUS_ID`

Typical `BOT_URL` format:

```text
https://api.telegram.org/bot<token>
```

### `LOG_TLG_SEND`

Expected columns:

- `ROW_INS_DATE`
- `BOT_ID`
- `TLGSEND_ID`
- `UPDATE_ID`
- `SENDTYPE`
- `CHAT_ID`
- `MESSAGE_ID`
- `FILE_ID`
- `TEXT`
- `PARSE_MODE`
- `ENTITIES`
- `REPLY_TO_MESSAGE_ID`
- `STATUS_ID`
- `RESULT_CLOB`

### `TLG_GROUPS_LOGS_LEVEL`

Expected columns:

- `TLGGROUP_ID`
- `LOG_LEVEL`
- `STATUS_ID`

### `BFILES`

Expected columns:

- `BFILE_ID`
- `FILE_NAME`
- `MIME_TYPE`
- `FILE_BFILE`

This table is used by `FUNC_TLG_SEND_FILE` to upload a document from an Oracle `BFILE`.

## Create the Package

Connect as the target schema and run:

```sql
@scripts/PKG_TLG_BOT.pck
```

If you run it from another working directory, use the full or correct relative path:

```sql
@d:\Projects\oracle-rac-21c-lab\scripts\PKG_TLG_BOT.pck
```

After compilation, verify the object status:

```sql
SELECT object_name, object_type, status
FROM   user_objects
WHERE  object_name = 'PKG_TLG_BOT';
```

## Example 1: Check Bot Identity

Use `getMe` to confirm the configured token is valid.

```sql
SELECT PKG_TLG_BOT.FUNC_TLG_GETME() AS response_json
FROM dual;
```

## Example 2: Read Telegram Updates

```sql
SELECT PKG_TLG_BOT.FUNC_TLG_GETUPDATES(
         voffset  => 0,
         vlimit   => 5,
         vtimeout => 10
       ) AS response_json
FROM dual;
```

This is useful when you want to inspect incoming messages or join requests before building higher-level bot logic.

## Example 3: Send a Text Message

```sql
SELECT PKG_TLG_BOT.FUNC_TLG_SENDMESSAGE(
         vchat_id => -1001234567890,
         vtext    => 'Hello from Oracle PL/SQL'
       ) AS response_json
FROM dual;
```

If you want automatic logging, call `FUNC_TLG_SEND` instead:

```sql
SELECT PKG_TLG_BOT.FUNC_TLG_SEND(
         vbot_id   => 1,
         vchat_id  => -1001234567890,
         vsendtype => 'sendMessage',
         vtext     => 'Hello from Oracle PL/SQL'
       ) AS message_id
FROM dual;
```

## Example 4: Send a Photo by Telegram File ID or URL

```sql
SELECT PKG_TLG_BOT.FUNC_TLG_SENDPHOTO(
         vchat_id => -1001234567890,
         vphoto   => 'https://example.com/image.jpg',
         vcaption => 'Sample photo'
       ) AS response_json
FROM dual;
```

Depending on your Telegram flow, `vphoto` can be:

- A file ID already known to Telegram
- An HTTP URL that Telegram can fetch

## Example 5: Send a Document by Telegram File ID

```sql
SELECT PKG_TLG_BOT.FUNC_TLG_SENDDOCUMENT(
         vchat_id => -1001234567890,
         vfile_id => 'AgACAgUAAxkBAAIB...',
         vcaption => 'Sample document'
       ) AS response_json
FROM dual;
```

## Example 6: Send a Document from `BFILES`

```sql
SELECT PKG_TLG_BOT.FUNC_TLG_SEND_FILE(
         vchat_id  => -1001234567890,
         vbfile_id => 1001,
         vcaption  => 'Database file upload'
       ) AS response_json
FROM dual;
```

This path is useful when the file already exists on the database server and is registered in a local `BFILES` table.

## Example 7: Approve a Join Request

```sql
SELECT PKG_TLG_BOT.FUNC_TLG_HANDLE_JOIN(
         vchat_id        => -1001234567890,
         vuser_id        => 123456789,
         vresponse_type  => 1
       ) AS response_json
FROM dual;
```

Use `vresponse_type => 2` to decline the join request.

## Example 8: Write a System Log Message

```sql
SELECT PKG_TLG_BOT.FUNC_SYSTEM_LOG(
         vlog_level => 1,
         vbot_id    => 1,
         vtext      => 'Nightly job completed successfully'
       ) AS message_id
FROM dual;
```

This requires a matching log group entry in `TLG_GROUPS_LOGS_LEVEL`.

## Implementation Notes

Some implementation details are worth knowing before you use this package in production.

- `FUNC_TLG_SEND` uses `PRAGMA AUTONOMOUS_TRANSACTION`, so the log row is committed independently from the caller transaction.
- Success and error handling are inferred from the Telegram JSON response:
  `ok = true`, `Forbidden`, `Bad Request`, or a fallback `NOT_KNOWN`.
- `FUNC_TLG_SENDMESSAGE`, `FUNC_TLG_SENDPHOTO`, and `FUNC_TLG_SENDDOCUMENT` manually replace `&` and `+` in text values instead of using a full URL-encoding helper.
- `FUNC_TLG_SEND_FILE` is the only function in this package that uploads a real file stream with multipart handling.
- The package currently logs only three send types through `FUNC_TLG_SEND`; other wrapper functions return raw JSON but are not inserted into `LOG_TLG_SEND`.

## Common Errors

### `ORA-24247: network access denied by access control list (ACL)`

Cause:

- The schema does not have outbound HTTPS access to `api.telegram.org` or the proxy host.

Fix:

- Recheck the ACL and wallet setup from [`03-run-https-api-requests.md`](./03-run-https-api-requests.md).

### `ORA-29024: Certificate validation failure`

Cause:

- The wallet does not trust the certificate chain used by Telegram or by the configured proxy.

Fix:

- Add the correct trusted certificates to the Oracle wallet.

### `PLS-00201` for missing helper packages

Cause:

- One of the dependent packages such as `PKG_WALLET`, `PKG_PROXY`, `PKG_STATUS`, or `PKG_KEY` does not exist in the schema.

Fix:

- Create the missing package first, or modify `PKG_TLG_BOT` to match your environment.

### Telegram response: `Forbidden`

Cause:

- The bot cannot write to the target chat, or the user blocked the bot.

Fix:

- Verify that the bot is present in the group or still allowed by the user.

### Telegram response: `Bad Request`

Cause:

- The request payload is invalid, for example wrong `chat_id`, invalid file ID, or unsupported markup content.

Fix:

- Inspect `RESULT_CLOB` in `LOG_TLG_SEND` and validate the input parameters.

## Practical Recommendation

Use this package when:

- Your Oracle schema needs to send Telegram notifications directly
- You want one shared place for token lookup and HTTP calling
- You want send results logged in a database table

Use a middleware layer instead when:

- You need advanced bot workflows, webhook processing, or queue-based retry orchestration
- You expect high message volume
- You need stronger observability, secret rotation, and application-level monitoring

## References

- Package script: [`PKG_TLG_BOT.pck`](../scripts/PKG_TLG_BOT.pck)
- HTTP helper guide: [`04-create-http-helper-package.md`](./04-create-http-helper-package.md)
- HTTPS setup guide: [`03-run-https-api-requests.md`](./03-run-https-api-requests.md)
