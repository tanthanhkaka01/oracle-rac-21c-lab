# Oracle RAC 21c Lab on Oracle Linux 8

## Overview

This repository documents a 2-node Oracle RAC 21c active-active lab running on Oracle Linux 8 with Oracle VM VirtualBox.

## Architecture Summary

- 2 nodes: `rac01`, `rac02`
- Oracle Grid Infrastructure 21c
- Oracle Database RAC 21c
- ASM shared storage
- VIP and SCAN configuration
- Private interconnect
- DNS-based name resolution

## Lab Environment

- Oracle Linux 8.8
- Oracle VM VirtualBox 7.x
- Host machine with 64 GB RAM
- Shared virtual disks provided by VirtualBox

## Documentation

- [01. Setup Oracle RAC DB](docs/01-setup-oracle-rac-db.md)
- [02. Create a New PDB](docs/02-create-new-pdb.md)
- [03. Run HTTPS API Requests from Oracle SQL](docs/03-run-https-api-requests.md)

## Disclaimer

This project is intended for lab and learning purposes. It simulates a production-style Oracle RAC architecture but is not a production deployment guide.
