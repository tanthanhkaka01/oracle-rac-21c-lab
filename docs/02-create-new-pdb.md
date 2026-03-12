# Create a New PDB

## Connect as the `oracle` OS User

```bash
su - oracle
```

## Connect to SQL*Plus in the CDB

```sql
sqlplus / as sysdba
```

## Verify Current Container

```sql
SHOW CON_NAME;
```

Expected result:

```text
CON_NAME
------------------------------
CDB$ROOT
```

## Create a New PDB

```sql
CREATE PLUGGABLE DATABASE PDBORCL2
  ADMIN USER adminpdborcl2
  IDENTIFIED BY oracle123;
```

## Open the PDB on All Instances

```sql
ALTER PLUGGABLE DATABASE PDBORCL2 OPEN INSTANCES=ALL;
```

## Save the PDB State for Auto-Start

```sql
ALTER PLUGGABLE DATABASE PDBORCL2 SAVE STATE INSTANCES=ALL;
```

## Verify the New PDB

```sql
SELECT NAME, OPEN_MODE FROM V$PDBS;
SELECT NAME, NETWORK_NAME FROM CDB_SERVICES WHERE NAME LIKE '%PDBORCL2%';
```

## Update `tnsnames.ora`

Edit the following files on both nodes:

- `$ORACLE_HOME/network/admin/tnsnames.ora`
- `$ORACLE_BASE/homes/OraDB21Home1/network/admin/tnsnames.ora`

Add:

```ora
PDBORCL2 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = rac-scan.private.db.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = PDBORCL2)
    )
  )
```

## Connect to the PDB

```sql
sqlplus adminpdborcl2/oracle123
```
