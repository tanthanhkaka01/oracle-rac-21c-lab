# Oracle RAC 21c (2-Node Active-Active) Lab on Oracle Linux 8

## Overview

This repository documents the design and implementation of a 2-node Oracle RAC 21c cluster running on Oracle Linux 8 Update 8 using VirtualBox.

## Architecture Summary

- 2 Nodes (rac1, rac2)
- Grid Infrastructure 21c
- ASM for shared storage
- SCAN + VIP configuration
- Private Interconnect
- DNS-based name resolution

Full documentation is available in the /docs directory.

## Lab Environment

- Oracle Linux 8.8
- VirtualBox 7.x
- 64GB RAM host machine
- Shared disks via VirtualBox

## Disclaimer

This is a lab environment designed to simulate production-grade RAC architecture.
