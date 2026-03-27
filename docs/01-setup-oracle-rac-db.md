# Install Oracle Grid 21c and Oracle RAC 21c on Oracle Linux 8

## Project Summary

This guide describes how to install Oracle Grid Infrastructure 21c and Oracle Database RAC 21c in an active-active 2-node lab on Oracle Linux 8 Update 8 using Oracle VM VirtualBox.

## Lab Topology

### Server `rac01`

- Adapter 1: Bridged Adapter, `192.168.1.242`
- Adapter 2: Host-Only Adapter, `192.168.10.1`
- Hostname: `rac01`
- CPU: 16 cores
- RAM: 24 GB
- SSD: 200 GB

### Server `rac02`

- Adapter 1: Bridged Adapter, `192.168.1.243`
- Adapter 2: Host-Only Adapter, `192.168.10.2`
- Hostname: `rac02`
- CPU: 16 cores
- RAM: 24 GB
- SSD: 200 GB

### Virtual IPs

```text
192.168.1.244 rac01-vip
192.168.1.245 rac02-vip
```

### SCAN IPs

```text
192.168.1.246 rac-scan
192.168.1.247 rac-scan
192.168.1.248 rac-scan
```

## Default Credentials

- `root`, `grid`, `oracle`: `<CHANGE_ME_PASSWORD>`
- `sys`, `ASMSNMP`: `<CHANGE_ME_PASSWORD>`
- Global database name: `pridb`
- Pluggable database name: `pridbpdb1`
- Administrative password: `<CHANGE_ME_PASSWORD>`

## Required Downloads

- Oracle VM VirtualBox
- Oracle Linux 8 Update 8
- `LINUX.X64_213000_grid_home.zip`
- `LINUX.X64_213000_db_home.zip`

## Create the Virtual Machines

Create two virtual machines in Oracle VM VirtualBox with:

- CPU: 16 cores
- RAM: 24 GB
- Disk: 120 GB dynamically allocated

Minimum recommended lab sizing:

- CPU: 8 cores
- RAM: 16 GB

Attach the Oracle Linux 8 Update 8 ISO to each VM.

## Initial OS Installation

For each node:

1. Start the VM.
2. Select the Oracle Linux installer.
3. Choose `English`.
4. Select `Minimal Install`.
5. Select automatic partitioning.
6. Click `Begin Installation`.
7. Set the root password to a strong value, for example `<CHANGE_ME_PASSWORD>`.
8. Reboot after installation completes.

## Configure Networking

### Check Network Device Status

```bash
nmcli device status
```

### Enable Network Adapters

`enp0s3` is the bridged adapter.

```bash
nmcli device connect enp0s3
nmcli device connect enp0s8
```

### Configure `rac01`

Set static IP for `enp0s3`:

```bash
nmcli connection modify enp0s3 ipv4.addresses 192.168.1.242/24
nmcli connection modify enp0s3 ipv4.gateway 192.168.1.1
nmcli connection modify enp0s3 ipv4.dns "192.168.1.242 8.8.8.8"
nmcli connection modify enp0s3 ipv4.dns-search ""
nmcli connection modify enp0s3 ipv4.method manual
nmcli connection down enp0s3
nmcli connection up enp0s3
```

Set static IP for `enp0s8`:

```bash
nmcli connection add type ethernet ifname enp0s8 con-name enp0s8 ipv4.addresses 192.168.10.1/24 ipv4.method manual
nmcli connection up enp0s8
```

Alternative:

```bash
nmcli connection modify enp0s8 ipv4.addresses 192.168.10.1/24
nmcli connection modify enp0s8 ipv4.gateway ""
nmcli connection modify enp0s8 ipv4.dns ""
nmcli connection modify enp0s8 ipv4.method manual
nmcli connection down enp0s8
nmcli connection up enp0s8
```

Enable auto-start:

```bash
nmcli connection modify enp0s3 connection.autoconnect yes
nmcli connection modify enp0s8 connection.autoconnect yes
```

### Configure `rac02`

Set static IP for `enp0s3`:

```bash
nmcli connection modify enp0s3 ipv4.addresses 192.168.1.243/24
nmcli connection modify enp0s3 ipv4.gateway 192.168.1.1
nmcli connection modify enp0s3 ipv4.dns "8.8.8.8 8.8.4.4"
nmcli connection modify enp0s3 ipv4.dns-search ""
nmcli connection modify enp0s3 ipv4.method manual
nmcli connection down enp0s3
nmcli connection up enp0s3
```

Set static IP for `enp0s8`:

```bash
nmcli connection modify enp0s8 ipv4.addresses 192.168.10.2/24
nmcli connection modify enp0s8 ipv4.gateway ""
nmcli connection modify enp0s8 ipv4.dns ""
nmcli connection modify enp0s8 ipv4.method manual
nmcli connection down enp0s8
nmcli connection up enp0s8
```

Enable auto-start:

```bash
nmcli connection modify enp0s3 connection.autoconnect yes
nmcli connection modify enp0s8 connection.autoconnect yes
```

### Verify IP and Routing

```bash
ip a
ip route
```

### Check DNS Resolver

```bash
vi /etc/resolv.conf
```

## Set Time and Time Zone

Check current date and time:

```bash
date
```

Optional manual time configuration:

```bash
# timedatectl set-time '2025-01-13 10:36:30'
```

Set timezone:

```bash
timedatectl set-timezone Asia/Ho_Chi_Minh
```

## Configure Chrony

Check installed packages:

```bash
rpm -q ntp
rpm -q chrony
```

Install and enable Chrony:

```bash
sudo yum install -y chrony
sudo systemctl start chronyd
sudo systemctl enable chronyd
sudo systemctl status chronyd
```

## Update Linux

```bash
yum update -y
```

## Configure `/etc/hosts`

Install `nano`:

```bash
dnf install -y nano
```

Edit:

```bash
nano /etc/hosts
```

Content:

```text
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.1.242 rac01
192.168.1.243 rac02

192.168.10.1 rac01-priv
192.168.10.2 rac02-priv

192.168.1.244 rac01-vip
192.168.1.245 rac02-vip

# 192.168.1.246 rac-scan.private.db.com
# 192.168.1.247 rac-scan.private.db.com
# 192.168.1.248 rac-scan.private.db.com
```

## Set Hostname and SELinux

Set hostname on `rac01`:

```bash
hostnamectl set-hostname rac01
```

Set hostname on `rac02`:

```bash
hostnamectl set-hostname rac02
```

Edit SELinux configuration:

```bash
vi /etc/selinux/config
```

Set:

```text
SELINUX=permissive
```

Apply immediately or reboot:

```bash
setenforce Permissive
```

## Increase Root Disk Space

Run as `root`.

Check disk layout:

```bash
lsblk
fdisk -l /dev/sda
fdisk /dev/sda
```

In `fdisk`:

```text
Command (m for help): p
Command (m for help): d
Enter
Enter
Enter

Command (m for help): n
Enter
Enter
Enter

Command (m for help): t
2
8e

Command (m for help): w
```

Apply and resize:

```bash
partprobe
fdisk -l /dev/sda
pvresize /dev/sda2
lvextend -r -l +100%FREE /dev/ol/root
xfs_growfs /
```

## Add a New Disk

Run as `root`.

```bash
lsblk
fdisk -l /dev/sdh
fdisk /dev/sdh
```

In `fdisk`:

```text
Command (m for help): p
Command (m for help): d
Enter
Enter
Enter

Command (m for help): n
Enter
Enter
Enter

Command (m for help): t
2
8e

Command (m for help): w
```

Apply and extend LVM:

```bash
partprobe
fdisk -l /dev/sdh
pvcreate /dev/sdh1
vgextend /dev/mapper/ol /dev/sdh1
lvextend -l +100%FREE /dev/ol/root
xfs_growfs /
```

## Install Required Packages

```bash
dnf install -y oracle-database-preinstall-21c \
               oracleasm-support oracleasmlib kmod-oracleasm \
               net-tools nfs-utils rlwrap unzip xclock \
               libnsl sysstat ksh make glibc-devel
```

## Clone the Nodes

Use Oracle VM VirtualBox to clone the lab nodes as needed.

## Set Up DNS Server

### Install BIND

Run on both nodes as `root`:

```bash
sudo yum install bind bind-utils -y
```

### Configure `/etc/named.conf`

```bash
nano /etc/named.conf
```

```conf
options {
        listen-on port 53 { any; };
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        recursing-file  "/var/named/data/named.recursing";
        secroots-file   "/var/named/data/named.secroots";
        allow-query     { any; };
        recursion yes;
        dnssec-enable yes;
        dnssec-validation yes;
        bindkeys-file "/etc/named.root.key";
        managed-keys-directory "/var/named/dynamic";
        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
        type hint;
        file "named.ca";
};

zone "private.db.com" IN {
    type master;
    file "/var/named/private.db.com.zone";
    allow-update { none; };
};

zone "192.168.1.in-addr.arpa" IN {
    type master;
    file "/var/named/192.168.1.rev";
    allow-update { none; };
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
```

### Create Zone Files

```bash
nano /var/named/private.db.com.zone
```

```dns
$TTL 86400
@   IN  SOA rac01.private.db.com. root.private.db.com. (
        2024112901
        3600
        1800
        604800
        86400
    )

    IN  NS  rac01.private.db.com.

rac01-priv   IN  A   192.168.10.1
rac02-priv   IN  A   192.168.10.2
rac01        IN  A   192.168.1.244
rac02        IN  A   192.168.1.245
rac-scan     IN  A   192.168.1.246
rac-scan     IN  A   192.168.1.247
rac-scan     IN  A   192.168.1.248
```

```bash
nano /var/named/192.168.1.rev
```

```dns
$TTL 86400
@   IN  SOA rac01.private.db.com. root.private.db.com. (
        2024112901
        3600
        1800
        604800
        86400
    )

    IN  NS  rac01.private.db.com.

244 IN PTR rac01.private.db.com.
245 IN PTR rac02.private.db.com.
246 IN PTR rac-scan.private.db.com.
247 IN PTR rac-scan.private.db.com.
248 IN PTR rac-scan.private.db.com.
```

### Set Permissions and Start BIND

```bash
sudo chown named:named /var/named/private.db.com.zone
sudo chown named:named /var/named/192.168.1.rev
sudo systemctl enable named
sudo systemctl start named
sudo systemctl status named
sudo named-checkzone private.db.com.zone /var/named/private.db.com.zone
sudo named-checkzone 192.168.1.rev /var/named/192.168.1.rev
```

### Open Firewall for DNS

```bash
sudo firewall-cmd --add-service=dns --permanent
sudo firewall-cmd --reload
```

### Configure Resolver on Both Nodes

```bash
nano /etc/resolv.conf
```

`rac01`:

```text
nameserver 192.168.1.242
nameserver 8.8.8.8
nameserver 8.8.4.4
```

`rac02`:

```text
nameserver 192.168.1.243
nameserver 8.8.8.8
nameserver 8.8.4.4
```

### Test DNS

```bash
dig rac-scan.private.db.com @192.168.1.242
dig rac-scan.private.db.com
```

## Open Oracle Database Ports

```bash
sudo firewall-cmd --permanent --add-port=1521/tcp
sudo firewall-cmd --permanent --add-port=5432/tcp
sudo firewall-cmd --permanent --add-port=2100/tcp
sudo firewall-cmd --permanent --add-port=3260/tcp
sudo firewall-cmd --permanent --add-port=6200/tcp
sudo firewall-cmd --permanent --add-port=2016/tcp
sudo firewall-cmd --permanent --add-port=1158/tcp
sudo firewall-cmd --permanent --add-port=9000-9100/tcp
sudo firewall-cmd --permanent --add-port=5556/tcp
sudo firewall-cmd --permanent --add-port=7070/tcp
sudo firewall-cmd --permanent --add-port=42424/tcp
sudo firewall-cmd --permanent --add-port=4888/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --list-all
```

Optional in the lab:

```bash
systemctl stop firewalld
systemctl disable firewalld
```

## Create Users and Groups

```bash
groupadd oinstall
groupadd dba
groupadd asmadmin
groupadd asmdba
groupadd asmoper
useradd -g oinstall -G asmadmin,asmdba,asmoper grid
passwd grid
useradd -g oinstall -G dba,asmdba oracle
sudo usermod -aG dba,asmdba oracle
passwd oracle
groups oracle
```

## Create Oracle Directories

```bash
mkdir -p /u01/app/grid
mkdir -p /u01/app/oracle
mkdir -p /u01/app/product/db21c
mkdir -p /u01/app/oraInventory
mkdir -p /u01/app/21c/grid
mkdir -p /u01/app/grid_install
mkdir -p /u01/app/oracle_install

chown -R grid:oinstall /u01/app/grid
chown -R oracle:oinstall /u01/app/oracle
chown -R oracle:oinstall /u01/app/product/db21c
chown -R grid:oinstall /u01/app/oraInventory
chown -R grid:oinstall /u01/app/21c
chown -R grid:oinstall /u01/app/21c/grid
chown -R grid:oinstall /u01/app/grid_install
chown -R oracle:oinstall /u01/app/oracle_install
chmod -R 775 /u01/app/
```

## Configure Shared Storage

### Create Shared Disks in VirtualBox

Create 5 shared disks:

- 3 disks x 10 GB for OCR
- 1 disk x 30 GB for FRA
- 1 disk x 50 GB for DATA

Attach the shared disks to both VMs.

### Verify Disk Visibility

```bash
lsblk
```

### Clear Shared Disks

```bash
dd if=/dev/zero of=/dev/sdb bs=1M count=100
dd if=/dev/zero of=/dev/sdc bs=1M count=100
dd if=/dev/zero of=/dev/sdd bs=1M count=100
dd if=/dev/zero of=/dev/sde bs=1M count=100
dd if=/dev/zero of=/dev/sdf bs=1M count=100
```

### Get Disk Serial IDs

```bash
udevadm info --query=all --name=/dev/sdb | grep ID_SERIAL
udevadm info --query=all --name=/dev/sdc | grep ID_SERIAL
udevadm info --query=all --name=/dev/sdd | grep ID_SERIAL
udevadm info --query=all --name=/dev/sde | grep ID_SERIAL
udevadm info --query=all --name=/dev/sdf | grep ID_SERIAL
```

### Configure Udev Rules

```bash
nano /etc/udev/rules.d/99-oracle-asm.rules
```

```udev
ENV{ID_SERIAL}=="VBOX_HARDDISK_VB7fd22947-1ee2be80", OWNER="grid", GROUP="asmadmin", MODE="0660", SYMLINK+="RAC_DATA_01"
ENV{ID_SERIAL}=="VBOX_HARDDISK_VBcea8deba-23e870e8", OWNER="grid", GROUP="asmadmin", MODE="0660", SYMLINK+="RAC_FRA_01"
ENV{ID_SERIAL}=="VBOX_HARDDISK_VBec27af00-c7ce861a", OWNER="grid", GROUP="asmadmin", MODE="0660", SYMLINK+="RAC_OCR_01"
ENV{ID_SERIAL}=="VBOX_HARDDISK_VB0a450419-7e5bd8c9", OWNER="grid", GROUP="asmadmin", MODE="0660", SYMLINK+="RAC_OCR_02"
ENV{ID_SERIAL}=="VBOX_HARDDISK_VB520ecf59-e376a5d1", OWNER="grid", GROUP="asmadmin", MODE="0660", SYMLINK+="RAC_OCR_03"
```

Reload and verify:

```bash
udevadm control --reload-rules
udevadm trigger
ls -l /dev/RAC_*
```

## Install GUI and XFCE

```bash
yum -y groups install "Server with GUI"
echo "exec /usr/bin/xfce4-session" >> ~/.xinitrc
startx
yum -y install tigervnc-server
firewall-cmd --add-service=vnc-server --permanent
firewall-cmd --reload
```

Configure VNC for `grid`:

```bash
su - grid
vncpasswd
vncserver :1 -geometry 1024x768 -depth 24
vncserver -kill :1
```

## Set Up SSH Equivalency

### For `grid`

```bash
su - grid
ssh-keygen -t rsa
ssh-copy-id -i ~/.ssh/id_rsa.pub grid@rac02
```

On `rac02`:

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub grid@rac01
```

### For `oracle`

```bash
su - oracle
ssh-keygen -t rsa
ssh-copy-id -i ~/.ssh/id_rsa.pub oracle@rac02
```

On `rac02`:

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub oracle@rac01
```

Test:

```bash
ssh rac02
exit
```

## Resize `/dev/shm`

Run on both nodes as `root`.

```bash
umount /dev/shm
mount -t tmpfs tmpfs -o size=16G /dev/shm
nano /etc/fstab
```

Add:

```fstab
tmpfs   /dev/shm        tmpfs   defaults,size=16G        0       0
```

Reload:

```bash
systemctl daemon-reload
```

## Configure Swap

```bash
sudo dd if=/dev/zero of=/swapfile bs=1G count=16
sudo mkswap /swapfile
sudo swapon /swapfile
free -h
nano /etc/fstab
```

Add:

```fstab
/swapfile swap swap defaults 0 0
```

## Copy Oracle Installation Files

Copy the Grid Infrastructure and Oracle Database zip files into:

- `/u01/app/grid_install`
- `/u01/app/oracle_install`

## Install Oracle Grid Infrastructure

### Extract Grid Home

Run on `rac01` as `grid`:

```bash
su - grid
unzip /u01/app/grid_install/LINUX.X64_213000_grid_home.zip -d /u01/app/21c/grid
```

### Set Grid Environment

Create `/home/grid/setEnv.sh`.

`rac01`:

```bash
export ORACLE_BASE=/u01/app/grid
export ORACLE_HOME=/u01/app/21c/grid
export GRID_HOME=/u01/app/21c/grid
export ORACLE_SID=+ASM1
export PATH=$ORACLE_HOME/bin:$PATH
```

`rac02`:

```bash
export ORACLE_BASE=/u01/app/grid
export ORACLE_HOME=/u01/app/21c/grid
export GRID_HOME=/u01/app/21c/grid
export ORACLE_SID=+ASM2
export PATH=$ORACLE_HOME/bin:$PATH
```

Load the environment:

```bash
echo ". /home/grid/setEnv.sh" >> /home/grid/.bash_profile
source /home/grid/.bash_profile
```

Optional cleanup on `rac02`:

```bash
rm -rf /u01/app/21c/grid/*
rm -rf /u01/app/oraInventory/*
```

### Start the Grid Installer

```bash
vncserver :1 -geometry 1024x768 -depth 24
export DISPLAY=:1
nohup /u01/app/21c/grid/gridSetup.sh > /u01/app/21c/grid/grid_setup.log 2>&1 &
```

### Grid Installer Choices

1. Configure Oracle Grid Infrastructure for a New Cluster.
2. Configure an Oracle Standalone Cluster.
3. Create Local SCAN:
   - Cluster Name: `rac`
   - SCAN Name: `rac-scan.private.db.com`
   - SCAN Port: `1521`
4. Add nodes:
   - `rac01` with VIP `rac01-vip`
   - `rac02` with VIP `rac02-vip`
5. Interface usage:
   - `enp0s3`: Public
   - `enp0s8`: ASM and Private
6. Use Oracle Flex ASM for storage.
7. Do not use a GIMR database.
8. Create ASM disk group:
   - Disk group name: `OCR`
   - Discovery path: `/dev/RAC*`
   - Select `RAC_OCR_01`, `RAC_OCR_02`, `RAC_OCR_03`
9. Use the same ASM password, for example `<CHANGE_ME_PASSWORD>`.
10. Do not use IPMI.
11. Leave management options unchecked.
12. Keep default operating system groups.
13. Set Oracle base to `/u01/app/grid`.
14. Set inventory directory to `/u01/app/oraInventory`.
15. Run configuration scripts automatically with `root` / `oracle`.
16. Complete prerequisite checks.
17. Click `Install`.
18. If prompted during installation, click `Yes`.
19. Click `Close`.

## Check CRS Services

Run as `root` on both nodes:

```bash
mkdir /home/root
nano /home/root/setEnv.sh
```

```bash
export ORACLE_HOME=/u01/app/21c/grid
export GRID_HOME=/u01/app/21c/grid
export PATH=$ORACLE_HOME/bin:$PATH
```

```bash
echo ". /home/root/setEnv.sh" >> /root/.bash_profile
source /root/.bash_profile
crsctl check crs
crsctl stop crs
crsctl start crs
crsctl check crs
```

## Create ASM Disk Groups with `asmca`

Run on `rac01` as `grid`:

```bash
su - grid
vncserver :1 -geometry 1024x768 -depth 24
export DISPLAY=:1
nohup /u01/app/21c/grid/bin/asmca > /tmp/asmca_setup.log 2>&1 &
```

In `asmca`:

1. Create disk group `DATA` with external redundancy using `/dev/RAC_DATA_01`.
2. Create disk group `FRA` with external redundancy using `/dev/RAC_FRA_01`.
3. Exit.

## Install Oracle Database 21c

### Extract the Database Home

Run on `rac01` as `oracle`:

```bash
su - oracle
unzip /u01/app/oracle_install/LINUX.X64_213000_db_home.zip -d /u01/app/product/db21c
```

### Set Oracle Environment

Create `/home/oracle/setEnv.sh`.

Example for node 1:

```bash
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/product/db21c
export ORAINVENTORY=/u01/app/oraInventory
export ORACLE_SID=pridb1
export GRID_HOME=/u01/app/21c/grid
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
export PATH=$GRID_HOME/bin:$ORACLE_HOME/bin:$PATH
```

Load the environment:

```bash
echo ". /home/oracle/setEnv.sh" >> /home/oracle/.bash_profile
source /home/oracle/.bash_profile
```

### Run the Oracle Installer

```bash
vncserver :2 -geometry 1024x768 -depth 24
export DISPLAY=:2
nohup /u01/app/product/db21c/runInstaller > /tmp/oracle_setup.log 2>&1 &
```

### Oracle Installer Choices

1. Set up software only.
2. Choose Oracle Real Application Clusters database installation.
3. Select nodes `rac01` and `rac02`.
4. Choose Enterprise Edition.
5. Set Oracle base to `/u01/app/oracle`.
6. Set OS groups:
   - OSDBA: `dba`
   - OSOPER: `oinstall`
   - OSBACKUPDBA: `dba`
   - OSDGDBA: `dba`
   - OSKMDBA: `dba`
   - OSRACDBA: `dba`
7. Run configuration scripts automatically with `root` / `oracle`.
8. Complete prerequisite checks.
9. Click `Install`.
10. Wait for installation to complete.
11. Click `Close`.

### Run Post-Installation Scripts

Run as `root` on both nodes:

```bash
/u01/app/oraInventory/orainstRoot.sh
/u01/app/product/db21c/root.sh
```

## `NETCA`

No manual `NETCA` step is required because the Grid installation already provides the listener.

## Create the RAC Database with `DBCA`

```bash
vncserver :2 -geometry 1024x768 -depth 24
export DISPLAY=:2
nohup $ORACLE_HOME/bin/dbca > /tmp/dbca_setup.log 2>&1 &
```

### `DBCA` Choices

1. Database operation: Create a database.
2. Creation mode: Advanced configuration.
3. Deployment type:
   - Oracle Real Application Clusters (RAC) database
   - Database management policy: Automatic
   - Workload type: General Purpose or Transaction Processing
4. Select nodes `rac01` and `rac02`.
5. Database identification:
   - Global database name: `pridb`
   - SID prefix: `pridb`
   - Create as container database
   - Use local undo tablespace for PDBs
   - Create 1 PDB named `pridbpdb1`
6. Storage:
   - Storage type: ASM
   - Data files location: `+DATA/{DB_UNIQUE_NAME}`
   - Use OMF
7. Fast recovery:
   - Enable FRA
   - Location: `+FRA/{DB_UNIQUE_NAME}`
   - Size: `102304 MB`
8. Data Vault: leave unchecked.
9. Configuration options:
   - Memory:
     - Use Automatic Shared Memory Management
     - SGA: `12288 MB`
     - PGA: `4096 MB`
   - Sizing:
     - Processes: `1280`
   - Character sets:
     - Database: `AL32UTF8`
     - National: `AL16UTF16`
     - Language: `American`
     - Territory: `United States`
   - Connection mode: Dedicated server mode
10. Management options:
   - Enable CVU checks periodically
   - Enable EM Database Express on port `5500`
11. User credentials:
   - Use the same password for all accounts
   - Password: `<CHANGE_ME_PASSWORD>`
12. Choose `Create database`.
13. Complete prerequisite checks.
14. Click `Finish`.
15. Wait for progress to complete.
16. Click `Close`.

## Configure `tnsnames.ora`

Run as `oracle` on both nodes and update:

- `$ORACLE_HOME/network/admin/tnsnames.ora`
- `$ORACLE_BASE/homes/OraDB21Home1/network/admin/tnsnames.ora`

Add:

```ora
pridb =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = rac-scan.private.db.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = pridb)
    )
  )

pridbpdb1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = rac-scan.private.db.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = pridbpdb1)
    )
  )
```
