# project name: install Oracle Grid 21c, Database Rac 21c with 2 node active - active on 2 server Oracle Linux R8U8 Using Oracle VM Virtualbox;

# server rac01:
# 	Network Adapter 1 - Bridged Adapter ip: 192.168.1.242;
# 	Network Adapter 2 - Host Only Adapter ip: 192.168.10.1;
# 	Hostname: rac01;
# 	Cpu: 16 core;
# 	Ram: 24 GB;
# 	SSD: 200 GB;

# server rac02:
# 	Network Adapter 1 - Bridged Adapter ip: 192.168.1.243;
# 	Network Adapter 2 - Host Only Adapter ip: 192.168.10.2;
# 	Hostname: rac01;
# 	Cpu: 16 core;
# 	Ram: 24 GB;
# 	SSD: 200 GB;

# Virtual IPs (VIPs): Assigned to each node for client failover. These are not permanently tied to the physical interfaces.
192.168.1.244 rac01-vip
192.168.1.245 rac02-vip

# SCAN IP: Used for load balancing and client connection to the cluster.
192.168.1.246 rac-scan
192.168.1.247 rac-scan
192.168.1.248 rac-scan

# pass root, grid, oracle: oracle
# pass sys, ASMSNMP: oracle
# global database name: pridb
# pluggable database name: pridbpdb1
# Administrative password: oracle

# Download and Setup OracleVM VirtualBox
# Download OracleLinux R8U8
# Download Oracle grid 21c LINUX.X64_213000_grid_home.zip
# Download Oracle DB 21c LINUX.X64_213000_db_home.zip

# Create new virtual machine in OracleVM (CPU 16 core, ram 24GB and 120GB Dynamically allocated storage disk) (cpu at least 8 core, ram at least 16GB)

# Set Storage drive: Choose file Oracle Linux R8U8 corresponding

# Setup network:
# 		Adapter 1:
# 				Enable Network Adapter
# 				Attached to: Bridged Adapter

# 		Adapter 2:
# 				Enable Network Adapter
# 				Attached to: Host Only Adapter

# Choose virtual machine corresponding, click Start
# 		Choose Instal Oracle Linux corresponding
# 		Choose Language: English
# 		Choose SOFTWARE SELECTION: Minimal Install
# 		Choose INSTALLATION DESTINATION: Automatic partitioning selected
# 		Click Begin Installation

# Set Root Password: oracle
# after install done, click reboot

------------------------------ Set ip ------------------------------
# check status network adapter
# bash >>
nmcli device status

# enable network adapter (enp0s3 is bridge adapter)
# bash >>
nmcli device connect enp0s3
nmcli device connect enp0s8

# rac01 - set ip static to enp0s3 bridge adapter
# bash >>
nmcli connection modify enp0s3 ipv4.addresses 192.168.1.242/24
nmcli connection modify enp0s3 ipv4.gateway 192.168.1.1
nmcli connection modify enp0s3 ipv4.dns "192.168.1.242 8.8.8.8"
nmcli connection modify enp0s3 ipv4.dns-search ""
nmcli connection modify enp0s3 ipv4.method manual
nmcli connection down enp0s3
nmcli connection up enp0s3

# rac01 - set ip static to enp0s8 host-only adapter
# bash >>
nmcli connection add type ethernet ifname enp0s8 con-name enp0s8 ipv4.addresses 192.168.10.1/24 ipv4.method manual
nmcli connection up enp0s8

# or bash >>
nmcli connection modify enp0s8 ipv4.addresses 192.168.10.2/24
nmcli connection modify enp0s8 ipv4.gateway ""
nmcli connection modify enp0s8 ipv4.dns ""
nmcli connection modify enp0s8 ipv4.method manual
nmcli connection down enp0s8
nmcli connection up enp0s8

# rac01 - set network adapter auto start with OS (enp0s3 is bridge adapter)
nmcli connection modify enp0s3 connection.autoconnect yes
nmcli connection modify enp0s8 connection.autoconnect yes

# rac02 - set ip static to enp0s3 bridge adapter
# bash >>
nmcli connection modify enp0s3 ipv4.addresses 192.168.1.243/24
nmcli connection modify enp0s3 ipv4.gateway 192.168.1.1
nmcli connection modify enp0s3 ipv4.dns "8.8.8.8 8.8.4.4"
nmcli connection modify enp0s3 ipv4.dns-search ""
nmcli connection modify enp0s3 ipv4.method manual
nmcli connection down enp0s3
nmcli connection up enp0s3

# rac02 - set ip static to enp0s8 host-only adapter
# bash >>
nmcli connection modify enp0s8 ipv4.addresses 192.168.10.2/24
nmcli connection modify enp0s8 ipv4.gateway ""
nmcli connection modify enp0s8 ipv4.dns ""
nmcli connection modify enp0s8 ipv4.method manual
nmcli connection down enp0s8
nmcli connection up enp0s8

# rac02 - set network adapter auto start with OS (enp0s3 is bridge adapter)
nmcli connection modify enp0s3 connection.autoconnect yes
nmcli connection modify enp0s8 connection.autoconnect yes

# check ip:
ip a
ip route

# check dns
vi /etc/resolv.conf

------------------- Set time and timezone -------------------
# check date and time with zone
date

# set time, no need if install chrony time
# timedatectl set-time '2025-01-13 10:36:30'

# set timezone +7 HCM
timedatectl set-timezone Asia/Ho_Chi_Minh

----------------------------------- set up chrony time -----------------------------------
# check NTP server time and chrony
# bash >>
rpm -q ntp
rpm -q chrony

# install chrony
sudo yum install -y chrony

# start chrony and check status
sudo systemctl start chronyd
sudo systemctl enable chronyd
sudo systemctl status chronyd

------------------------- Update linux -------------------------
# upgrade OS with following command
yum update -y

------------------------- Set hosts file -------------------------
# install nano
dnf install -y nano

# set hosts file
nano /etc/hosts

# plaintext >>
# hosts file
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
# Public IPs
192.168.1.242 rac01
192.168.1.243 rac02

# Private Interconnect IPs: Used for internode communication within the RAC cluster.
192.168.10.1 rac01-priv
192.168.10.2 rac02-priv

# Virtual IPs (VIPs): Assigned to each node for client failover. These are not permanently tied to the physical interfaces.
192.168.1.244 rac01-vip
192.168.1.245 rac02-vip

# SCAN IP: Used for load balancing and client connection to the cluster.
# 192.168.1.246 rac-scan.private.db.com
# 192.168.1.247 rac-scan.private.db.com
# 192.168.1.248 rac-scan.private.db.com

------------------------- set host and set selinux -------------------------
# rac01 – set hostname
hostnamectl set-hostname rac01

# rac02 – set hostname
hostnamectl set-hostname rac02

# Set secure Linux to permissive
vi /etc/selinux/config

# plaintext >>
SELINUX=permissive

# run this command to apply or reboot server
setenforce Permissive

------------------------- Increase disk space (from 50GB to 100GB) -------------------------
# run with root user
# check disk
lsblk

# check disk particularly
fdisk -l /dev/sda
fdisk /dev/sda

Command (m for help): p (print the partition table)
Command (m for help): d (delete a partition)
Enter -> Enter -> Enter

Command (m for help): n (create a new partition)
Enter -> Enter -> Enter

Command (m for help): t (change a partitions system id)
2 -> 8e (change from linux to linux XVM)

Command (m for help): w (write table to disk and exit)

# apply
partprobe

# check partition name
fdisk -l /dev/sda

# bash >>
pvresize /dev/sda2

# Physical volume "/dev/sda2" changed
# 1 physical volume(s) resized or updated / 0 physical volume(s) not resized
  
# extend /
lvextend -r -l +100%FREE /dev/ol/root

# Size of logical volume ol/root changed from <44.00 GiB (11263 extents) to <74.00 GiB (18943 extents).
# Logical volume ol/root successfully resized.
# data blocks changed from 11533312 to 19397632

# growfs disk / - result with be: data blocks changed from 19397632 to 24639488
xfs_growfs /

------------------------- add new disk -------------------------
# run with root user
# check disk
lsblk

# check disk particularly
fdisk -l /dev/sdh
fdisk /dev/sdh

Command (m for help): p (print the partition table)
Command (m for help): d (delete a partition)
Enter -> Enter -> Enter

Command (m for help): n (create a new partition)
Enter -> Enter -> Enter

Command (m for help): t (change a partitions system id)
2 -> 8e (change from linux to linux XVM)

Command (m for help): w (write table to disk and exit)

# apply
partprobe

# check partition name
fdisk -l /dev/sdh

# create disk - result will be: Physical volume "/dev/sdh1" successfully created.
pvcreate /dev/sdh1

# extend / - result will be: Volume group "ol" successfully extended
vgextend /dev/mapper/ol /dev/sdh1

# extend / - result will be: Size of logical volume ol/root changed from 70.00 GiB (17920 extents) to <198.00 GiB (50687 extents).
# Logical volume ol/root successfully resized.
lvextend -l +100%FREE /dev/ol/root

# growfs disk / - result with be: data blocks changed from 19397632 to 24639488
xfs_growfs /

------------------------- Update and install package -------------------------
# íntall oracle-database-preinstall-21c and other relate
# bash >>
dnf install -y oracle-database-preinstall-21c \
               oracleasm-support oracleasmlib kmod-oracleasm \
               net-tools nfs-utils rlwrap unzip xclock \
			   libnsl sysstat ksh make glibc-devel

------------------------- Clone rac01 and rac02 -------------------------
# use Oracle VM to clone rac01 and rac02

--------------------- Set up DNS server ---------------------
# Step 1: Install BIND (using user root – do on both node)
sudo yum install bind bind-utils -y

# Step 2: Configure BIND - Edit the main configuration file (/etc/named.conf)
nano /etc/named.conf

# plaintext >>
# /etc/named.conf
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
        /* Path to ISC DLV key */
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

# Step 3: Create Zone Files
nano /var/named/private.db.com.zone

# plaintext >>
$TTL 86400
@   IN  SOA rac01.private.db.com. root.private.db.com. (
        2024112901  ; Serial (yyyymmddnn)
        3600        ; Refresh
        1800        ; Retry
        604800      ; Expire
        86400       ; Minimum TTL
    )

    IN  NS  rac01.private.db.com.

rac01-priv   IN  A   192.168.10.1
rac02-priv   IN  A   192.168.10.2
rac01   IN  A   192.168.1.244
rac02   IN  A   192.168.1.245
rac-scan IN  A   192.168.1.246
rac-scan IN  A   192.168.1.247
rac-scan IN  A   192.168.1.248

# Create the Reverse Zone File (/var/named/192.168.1.rev):
nano /var/named/192.168.1.rev

# plaintext >>
$TTL 86400
@   IN  SOA rac01.private.db.com. root.private.db.com. (
        2024112901  ; Serial (yyyymmddnn)
        3600        ; Refresh
        1800        ; Retry
        604800      ; Expire
        86400       ; Minimum TTL
    )

    IN  NS  rac01.private.db.com.

244 IN  PTR rac01.private.db.com.
245 IN  PTR rac02.private.db.com.
246 IN  PTR rac-scan.private.db.com.
247 IN  PTR rac-scan.private.db.com.
248 IN  PTR rac-scan.private.db.com.

# Step 4: Set File Permissions
sudo chown named:named /var/named/private.db.com.zone
sudo chown named:named /var/named/192.168.1.rev

# Step 5: Enable and Start BIND Service
sudo systemctl enable named
sudo systemctl start named

# Check the status to ensure everything is running smoothly:
sudo systemctl status named

# check zone is right
sudo named-checkzone private.db.com.zone /var/named/private.db.com.zone
sudo named-checkzone 192.168.1.rev /var/named/192.168.1.rev

# Step 6: Update Firewall Rules
# bash >>
sudo firewall-cmd --add-service=dns --permanent
sudo firewall-cmd --reload

# Step 7: Configure Clients to Use rac01 and rac02 as DNS Server
nano /etc/resolv.conf
 
# rac01 - plaintext >>
nameserver 192.168.1.242
nameserver 8.8.8.8
nameserver 8.8.4.4
 
# rac02 - plaintext >>
nameserver 192.168.1.243
nameserver 8.8.8.8
nameserver 8.8.4.4

# Step 8: Test the DNS Configuration
# bash #
dig rac-scan.private.db.com @192.168.1.242
dig rac-scan.private.db.com

--------------------- Begin install Oracle DB 21c ---------------------
# Open Other Required Ports
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

# Reload Firewall to Apply Changes
sudo firewall-cmd --reload

# check all firewall rule
sudo firewall-cmd --list-all

# turnoff firewalld temporarily and disable firewalld:
systemctl stop firewalld
systemctl disable firewalld

# create group and user grid, oracle
groupadd oinstall
groupadd dba
groupadd asmadmin
groupadd asmdba
groupadd asmoper

# oinstall: Common group for installation ownership.
# dba: Group that provides database administration privileges.
# asmadmin, asmdba, asmoper: Groups specifically used for managing ASM.

# Create the grid User and Assign to Groups:
useradd -g oinstall -G asmadmin,asmdba,asmoper grid

# -g oinstall: Primary group.
# -G asmadmin,asmdba,asmoper: Secondary groups for ASM privileges.

# Set Password for grid User:
passwd grid

# Create the oracle User and Assign to Groups:
useradd -g oinstall -G dba,asmdba oracle

# add user to group:
sudo usermod -aG dba,asmdba oracle

# -g oinstall: Primary group.
# -G dba,asmdba: Secondary groups for database and ASM privileges.

# Thiết lập mật khẩu cho user oracle
passwd oracle

# list all groups user belong
groups oracle

# Set Up Directories and Permissions
mkdir -p /u01/app/grid
mkdir -p /u01/app/oracle
mkdir -p /u01/app/product/db21c
mkdir -p /u01/app/oraInventory
mkdir -p /u01/app/21c/grid
mkdir -p /u01/app/grid_install
mkdir -p /u01/app/oracle_install

# Assign ownership of the directories to the respective users (grid or oracle):
chown -R grid:oinstall /u01/app/grid
chown -R oracle:oinstall /u01/app/oracle
chown -R oracle:oinstall /u01/app/product/db21c
chown -R grid:oinstall /u01/app/oraInventory
chown -R grid:oinstall /u01/app/21c
chown -R grid:oinstall /u01/app/21c/grid
chown -R grid:oinstall /u01/app/grid_install
chown -R oracle:oinstall /u01/app/oracle_install
chmod -R 775 /u01/app/

----------- Configuring shared storage (using Oracle VM Virtualbox shared disks). -----------
# Open VirtualBox Manager.
# Go to File > Virtual Media Manager.
# Click Create to create a new virtual hard disk.
# create 5 disk - Choose VMDK or VHD format.
# Set disk size and set fixed size (or pre-allocate full size):
# 10 GB for OCR x 3.
# 30 GB for FRA.
# 50 GB for DATA.
# Save the disk and ensure its marked as "Shared."

# Attach Shared Disks to Both VMs
# Select the first VM (rac01) in VirtualBox.
# Go to Settings > Storage > Add Hard Disk.
# Choose Use an existing disk and select the shared disk you created.
# Repeat this process for the second VM (rac02).

# Verify Disk Visibility
lsblk

# clear disk
dd if=/dev/zero of=/dev/sdb bs=1M count=100
dd if=/dev/zero of=/dev/sdc bs=1M count=100
dd if=/dev/zero of=/dev/sdd bs=1M count=100
dd if=/dev/zero of=/dev/sde bs=1M count=100
dd if=/dev/zero of=/dev/sdf bs=1M count=100

# check ID_SERIAL
udevadm info --query=all --name=/dev/sdb | grep ID_SERIAL
udevadm info --query=all --name=/dev/sdc | grep ID_SERIAL
udevadm info --query=all --name=/dev/sdd | grep ID_SERIAL
udevadm info --query=all --name=/dev/sde | grep ID_SERIAL
udevadm info --query=all --name=/dev/sdf | grep ID_SERIAL

# use udev rule to declare asm disk
nano /etc/udev/rules.d/99-oracle-asm.rules

# plaintext >>
ENV{ID_SERIAL}=="VBOX_HARDDISK_VB7fd22947-1ee2be80", OWNER="grid", GROUP="asmadmin", MODE="0660", SYMLINK+="RAC_DATA_01"
ENV{ID_SERIAL}=="VBOX_HARDDISK_VBcea8deba-23e870e8", OWNER="grid", GROUP="asmadmin", MODE="0660", SYMLINK+="RAC_FRA_01"
ENV{ID_SERIAL}=="VBOX_HARDDISK_VBec27af00-c7ce861a", OWNER="grid", GROUP="asmadmin", MODE="0660", SYMLINK+="RAC_OCR_01"
ENV{ID_SERIAL}=="VBOX_HARDDISK_VB0a450419-7e5bd8c9", OWNER="grid", GROUP="asmadmin", MODE="0660", SYMLINK+="RAC_OCR_02"
ENV{ID_SERIAL}=="VBOX_HARDDISK_VB520ecf59-e376a5d1", OWNER="grid", GROUP="asmadmin", MODE="0660", SYMLINK+="RAC_OCR_03"

# reload udev and check
udevadm control --reload-rules
udevadm trigger
ls -l /dev/RAC_*

----------------------------------- install GUI and Xfce desktop -----------------------------------
# install GUI
yum -y groups install "Server with GUI"

echo "exec /usr/bin/xfce4-session" >> ~/.xinitrc
startx

#install tightvnc
yum -y install tigervnc-server

# add firewall
firewall-cmd --add-service=vnc-server --permanent
firewall-cmd --reload

# login into grid user to set up vncserver
su - grid

# set password
vncpasswd

# set port and resolution
vncserver :1 -geometry 1024x768 -depth 24

# kill VNC
vncserver -kill :1

----------------------------------- Set up SSH equivalency -----------------------------------
# You need to generate SSH key pairs for both the grid and oracle users on each server.
# Log in as grid User on both server:
# bash >>
su - grid

# Generate SSH Key Pair:
ssh-keygen -t rsa

# Press Enter three time to default
# bash >>
ssh-copy-id -i ~/.ssh/id_rsa.pub grid@rac02

# Copy key from grid-rac02 to grid-rac01:
# bash >>
ssh-copy-id -i ~/.ssh/id_rsa.pub grid@rac01

# Repeat for the oracle user on both server:
su - oracle

# bash >>
ssh-keygen -t rsa

# Press Enter three time to default
# Copy the Public Key from oracle@rac01 to oracle@rac02:
ssh-copy-id -i ~/.ssh/id_rsa.pub oracle@rac02

# Copy the Public Key from oracle@rac02 to oracle@rac01:
ssh-copy-id -i ~/.ssh/id_rsa.pub oracle@rac01

# Test as grid User:
ssh rac02

# exit ssh
exit;

---------------------------------- Set /dev/shm size == RAM ----------------------------------
# set /dev/shm size do on both node - run with root user
su - root

# bash >>
umount /dev/shm
mount -t tmpfs tmpfs -o size=16G /dev/shm

# (/dev/shm is RAM) set permanent, login root user and add row to file /etc/fstab and then restart server
# bash >>
nano /etc/fstab

# plaintext >>
tmpfs   /dev/shm        tmpfs   defaults,size=16G        0       0

# reload immediate
systemctl daemon-reload

---------------------------------- Set swap size ----------------------------------
# set swap size do on both node
sudo dd if=/dev/zero of=/swapfile bs=1G count=16
sudo mkswap /swapfile
sudo swapon /swapfile
free -h

# bash >>
nano /etc/fstab

# plaintext >>
/swapfile swap swap defaults 0 0

----------------------------------- Copy grid, oracle DB zip file -----------------------------------
# use grid and oracle user to copy source zip file grid, oracle to folder /u01/app/grid_install and /u01/app/oracle_install

----------------------------------- install grid -----------------------------------
# extract grid folder (do on rac01)
su - grid

# bash >>
unzip /u01/app/grid_install/LINUX.X64_213000_grid_home.zip -d /u01/app/21c/grid

# declare environment (do on both node)
# my rac01:
nano /home/grid/setEnv.sh

# rac01 - plaintext >>
export ORACLE_BASE=/u01/app/grid
export ORACLE_HOME=/u01/app/21c/grid
export GRID_HOME=/u01/app/21c/grid
export ORACLE_SID=+ASM1 # For ASM instance (the number may vary based on your node)
export PATH=$ORACLE_HOME/bin:$PATH

# rac02 - plaintext >>
export ORACLE_BASE=/u01/app/grid
export ORACLE_HOME=/u01/app/21c/grid
export GRID_HOME=/u01/app/21c/grid
export ORACLE_SID=+ASM2 # For ASM instance (the number may vary based on your node)
export PATH=$ORACLE_HOME/bin:$PATH

# Proceed with configuration and updates .bash_profile 
# bash >>
echo ". /home/grid/setEnv.sh" >> /home/grid/.bash_profile
source /home/grid/.bash_profile

# do this on rac02 to clear file
# bash >>
rm -rf /u01/app/21c/grid/*
rm -rf /u01/app/oraInventory/*

# Start the installation in background so can close terminal putty (need to set up display for user grid):
vncserver :1 -geometry 1024x768 -depth 24
export DISPLAY=:1
nohup /u01/app/21c/grid/gridSetup.sh > /u01/app/21c/grid/grid_setup.log 2>&1 &

# Step 1. Configure Oracle Grid Infrastructure for a New Cluster

# Step 2. Configure an Oracle Standalone Cluster

# Step 3. Create Local SCAN
		Cluster Name: rac
		SCAN Name: rac-scan.private.db.com
		SCAN Port: 1521
		
# Step 4. Add node
		Public hostname: rac01		Virtual Hostname: rac01-vip
		Public hostname: rac02		Virtual Hostname: rac02-vip
		
	Checked: Reuse private and public keys existing in ther user home
	
# Step 5. Set Private interface are use
		Interface Name: enp0s3		Use for: Public
		Interface Name: enp0s8		Use for: ASM & Private
		
# Step 6. Use Oracle Flex ASM for storage

# Step 7. GIMR Option
		Do not use a GIMR database
		
# Step 8. Create ASM Disk Group
		Disk group name: OCR
		Disk Discovery Path: 'dev/RAC*'
		Select Disks: /dev/RAC_OCR_01, /dev/RAC_OCR_02, /dev/RAC_OCR_03
		
# Step 9. ASM Password
		Use same passwords for these accounts
		Password: oracle

# Step 10. Failure Isolation
		Do not use Intelligent Platform Management Interface (IPMI)
		
# Step 11. Management Options
		Uncheck

# Step 12. Operating System Groups
		Default
		
# Step 13. Installation Location
		Oracle base: /u01/app/grid
		
# Step 14. Create Inventory
		Inventory Directory: /u01/app/oraInventory
		
# Step 15. Root script execution
		Automatically run confiration scripts
		Use "root" user credential
		Password: oracle
		
# Step 16. Perform Prerequisite Checks
		If everything ok this installer will auto next this step
		If not, Click Fix & Check Again
		If have OS Kernal Version Warning, check Ignore warning and click Next
		
# Step 17. Summary
		Click Install
		
# Step 18. Install Product
		When running, This install show a message -> Click Yes
		
# Step 19. Finish
		Click Close

----------------------------------- Check CRS Services -----------------------------------
# Add the crsctl to the environment
# login root user do on both node
su – root

mkdir /home/root
nano /home/root/setEnv.sh

# plaintext >>
export ORACLE_HOME=/u01/app/21c/grid
export GRID_HOME=/u01/app/21c/grid
export PATH=$ORACLE_HOME/bin:$PATH

# bash >>
echo ". /home/root/setEnv.sh" >> /root/.bash_profile
source /root/.bash_profile

# Check CRS (Cluster Ready Services) Status:
crsctl check crs

# restart crs
crsctl stop crs
crsctl start crs
crsctl check crs

----------------------------------- install asmca -----------------------------------
# Run the asmca using grid user (just only run on rac01)
# bash >>
su - grid
vncserver :1 -geometry 1024x768 -depth 24
export DISPLAY=:1
nohup /u01/app/21c/grid/bin/asmca > /tmp/asmca_setup.log 2>&1 &

# Step 1. Choose Disk Groups

# Step 2. Create Disk Group DATA
		Click Create
		Disk group Name: DATA
		Redundancy: External (None)
		Checked on /dev/RAC_DATA_01
		Click Ok
		
# Step 3. Create Disk Group FRA
		Click Create
		Disk group Name: FRA
		Redundancy: External (None)
		Checked on /dev/RAC_FRA_01
		Click Ok

# Step 4. Exit

# Step to add disk to disk group (right click to disk group -> add disk -> choose disk and ok)

----------------------------------- install oracle DB -----------------------------------
# login oracle and extract oracle folder (do on rac01)
su - oracle

# extract zip file to oracle home folder
unzip /u01/app/oracle_install/LINUX.X64_213000_db_home.zip -d /u01/app/product/db21c

# declare environment (do on both node)
nano /home/oracle/setEnv.sh

# plaintext - ORACLE_SID value depend on whith node, when node 1, then ORACLE_SID = pridb1>>
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/product/db21c
export ORAINVENTORY=/u01/app/oraInventory
export ORACLE_SID=pridb1
export GRID_HOME=/u01/app/21c/grid
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
export PATH=$GRID_HOME/bin:$ORACLE_HOME/bin:$PATH

# bash >>
echo ". /home/oracle/setEnv.sh" >> /home/oracle/.bash_profile
source /home/oracle/.bash_profile

# Run the runInstaller (just only run on rac01)
vncserver :2 -geometry 1024x768 -depth 24

export DISPLAY=:2
nohup /u01/app/product/db21c/runInstaller > /tmp/oracle_setup.log 2>&1 &

# Step 1. Configuration Option
		Set up Software Only
		
# Step 2. Database Installation Option
		Oracle Real Application Clusters database installation
		
# Step 3. Nodes Selection
		Checked on rac01, rac02
		
# Step 4. Database Edition
		Enterprise Edition
		
# Step 5. Installation Location
		Oracle base: /u01/app/oracle
		
# Step 6. Operating System Groups
		Database Administrator (OSDBA) group: dba
		Database Operator (OSOPER) group: oinstall
		Database Backup and Recovery (OSBACKUPDBA) group: dba
		Data Guard administrative (OSDGDBA) group: dba
		Encryption Key Management administrative (OSKMDBA) group: dba
		Real Application Cluster administrative (OSRACDBA) group: dba
		
# Step 7. Root script execution
		Checked on Automatically run configuration scripts
		Use "root" user credential
		Password: oracle
		
# Step 8. Prerequisite Checks
		If everything ok, this install will auto move to next step
		
# Step 9. Summary
		Click Install
		
# Step 10. Install product
		If everything ok, this install will auto move to next step

# Step 11. Finish
		Click Close

# run Post-Installation Scripts as root on both node
su - root

/u01/app/oraInventory/orainstRoot.sh
/u01/app/product/db21c/root.sh

--------------------------- run NETCA (no need) ---------------------------
# no need to run netca to add LISTENER because grid has does

--------------------------- run DBCA ---------------------------
# Run the runInstaller (just only run on rac01)
vncserver :2 -geometry 1024x768 -depth 24
export DISPLAY=:2
nohup $ORACLE_HOME/bin/dbca > /tmp/dbca_setup.log 2>&1 &

# Step 1. Database Operation
		Create a Database

# Step 2. Creation Mode
		Advanced configuration
		
# Step 3. Deployment Type
		Database type: Oracle Real Application Cluster (RAC) database
		Database Management Policy: Automatic
		Checked on General Purpose or Transaction Processing
		
# Step 4. Nodes Selection
		Checked on rac01, rac02

# Step 5. Database Identification
		Global database name: pridb
		SID prefix: pridb
		Checked on Create as Container database
		Checked on Use Local Undo Tablespace for PDBs
		Checked on Create a Container database with one or more PDBs
		Number of PDBs: 1
		PDB name: pridbpdb1
		
# Step 6. Storage Option
		Use following for the database storage attributes
		Database files storage type: Automatic Storage Management (ASM)
		Database files location: +DATA/{DB_UNIQUE_NAME}
		Checked on Use Oracle-Managed Files (OMF)

# Step 7. Fast Recovery Option
		Checked on Specify Fast Recovery Area
		Recovery files storage type: Automatic Storage Management (ASM)
		Fast Recovery Area: +FRA/{DB_UNIQUE_NAME}
		Fast Recovery Area size: 102304 MB

# Step 8. Data Vault Option
		No Check everything and click next

# Step 9. Configuration Options
		Memory:
			Use Automatic Shared Memory Management
			SGA size: 12288 MB
			PGA size: 4096 MB
			
		Sizing:
			Processes: 1280
			
		Character Sets:
			Use Unicode (AL32UTF8)
			National character set: AL16UTF16
			Default language: American
			Default territory: United States

		Connection Mode:
			Dedicated server mode
		
# Step 10. Management Options
		Checked on Run Cluster Verification Utility (CVU) checks periodically
		Checked on Configure Enterprice Manager (EM) database express
		EM database express port: 5500

# Step 11. User Credentials
		Use the same administrative password for all accounts
		Password: oracle		Confirm password: oracle

# Step 12. Creation Option
		Checked on Create database

# Step 13. Prerequisite Checks
		Auto next

# Step 14. Summary
		Click Finish

# Step 15. Progress Page
		Auto next

# Step 16. Finish
		Click close

------------------------------------ add tnsnames.ora ------------------------------------
# run as user oracle (both node)
nano $ORACLE_HOME/network/admin/tnsnames.ora
nano $ORACLE_BASE/homes/OraDB21Home1/network/admin/tnsnames.ora

# plaintext >>
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