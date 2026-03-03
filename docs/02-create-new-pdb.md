# connect OS user oracle
su - oracle

# connect to sqlplus CDB
sqlplus / as sysdba

# check connect to CDB or PDB -- CDB$ROOT = CDB
SQL> SHOW CON_NAME;

CON_NAME
------------------------------
CDB$ROOT

# create new pdb
CREATE PLUGGABLE DATABASE PDBORCL2 ADMIN USER adminpdborcl2 IDENTIFIED BY oracle123;

# Open PDB (all instance)
ALTER PLUGGABLE DATABASE PDBORCL2 OPEN INSTANCES=ALL;

# Optional: Save state to autostart PDB (all instance)
ALTER PLUGGABLE DATABASE PDBORCL2 SAVE STATE INSTANCES=ALL;

# check all pdb
SELECT NAME, OPEN_MODE FROM V$PDBS;
SELECT NAME, NETWORK_NAME FROM CDB_SERVICES WHERE NAME LIKE '%PDBORCL2%';

------------------------------------ add tnsnames.ora ------------------------------------
# run as user oracle (both node)
nano $ORACLE_HOME/network/admin/tnsnames.ora
nano /home/app/oracle/homes/OraDB21Home1/network/admin/tnsnames.ora

# plaintext >>
PDBORCL2 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = rac-scan.private.db.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = PDBORCL2)
    )
  )

# connect to pdb
sqlplus adminpdborcl2/oracle123