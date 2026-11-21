# CCNA 02 – Switching (VLAN, Trunk, VTP, STP, EtherChannel, L2 Security)

## VLANs
```
vlan 10
 name FINANCE
vlan 20,30                      ! several at once
!
interface fa0/1
 switchport mode access
 switchport access vlan 10
interface range fa0/1 - 3
 switchport access vlan 10
```
```
show vlan brief
show interfaces trunk
show interfaces switchport
```
- `switchport host` macro = access mode + portfast + no EtherChannel.
- Disable a VLAN **locally**: `vlan 10` → `shutdown`.
- Disable a VLAN **via VTP everywhere**: `vlan 10` → `state suspend`.

## Trunking & DTP
```
interface g0/1
 switchport trunk encapsulation dot1q     ! only on platforms that also support ISL
 switchport mode trunk
 switchport trunk native vlan 99
 switchport trunk allowed vlan 10,20,30
 switchport nonegotiate                   ! stop sending DTP frames
```
| Mode | Behaviour |
|------|-----------|
| `access` | Always access |
| `trunk` | Always trunk (sends DTP unless `nonegotiate`) |
| `dynamic auto` (default) | Becomes trunk only if neighbor asks |
| `dynamic desirable` | Actively asks to become trunk |

Best practice: hard-code both ends (`mode trunk` / `mode access`) and use `switchport nonegotiate`. `show dtp` shows DTP status.

## VTP
```
vtp mode server | client | transparent | off
vtp domain LAB
vtp version 2
vtp password MyVtpPass
vtp pruning
show vtp status
```
Reset a switch's VLAN database: `delete flash:vtp.dat` and `delete flash:vlan.dat`, then `erase startup-config` and reload.

## Router-on-a-stick (inter-VLAN routing)
```
interface g0/0/0
 no shutdown
interface g0/0/0.10
 encapsulation dot1q 10
 ip address 192.168.10.1 255.255.255.0
interface g0/0/0.20
 encapsulation dot1q 20 native         ! only if this VLAN is the native (untagged) VLAN
 ip address 192.168.20.1 255.255.255.0
```
Layer 3 switch alternative:
```
ip routing
interface vlan 10
 ip address 192.168.10.1 255.255.255.0
interface g1/0/1
 no switchport                          ! routed port
 ip address 10.0.0.1 255.255.255.252
```

## Spanning Tree
```
spanning-tree mode rapid-pvst
spanning-tree vlan 1 root primary         ! become root (priority 24576 or lower)
spanning-tree vlan 1 root secondary       ! backup root
spanning-tree vlan 1 priority 4096        ! manual (multiples of 4096)
no spanning-tree vlan 10                  ! disable STP for a VLAN (avoid!)
!
interface fa0/2
 spanning-tree vlan 1 port-priority 64    ! multiples of 16
interface fa0/1
 spanning-tree portfast                   ! edge port: skip listening/learning
 spanning-tree bpduguard enable           ! err-disable the port if a BPDU arrives
interface g0/1
 spanning-tree guard root                 ! port can never become root port
```
```
show spanning-tree
show spanning-tree summary
debug spanning-tree events
```
- PortFast only belongs on access ports (end hosts).
- `spanning-tree mode pvst` = classic per-VLAN 802.1D behaviour.

## EtherChannel
```
interface range g0/1 - 2
 channel-group 1 mode active
interface port-channel 1
 switchport mode trunk
port-channel load-balance src-dst-ip
```
| Protocol | Modes that form a channel |
|----------|---------------------------|
| PAgP (Cisco) | `desirable` + `desirable`, `desirable` + `auto` |
| LACP (802.3ad) | `active` + `active`, `active` + `passive` |
| Static | `on` + `on` |

`show etherchannel summary` – flags: `SU` = Layer-2 in use, `P` = bundled. Configure the port-channel interface first or let `channel-group` create it; all member ports need identical speed/duplex/VLAN settings.

## Port security
```
interface fa0/1
 switchport mode access
 switchport port-security
 switchport port-security maximum 4
 switchport port-security mac-address 0011.2233.4455      ! static MAC
 switchport port-security mac-address sticky               ! learn & save dynamically
 switchport port-security violation shutdown               ! default
```
| Violation | Drops frames | Syslog + counter | Port err-disabled |
|-----------|:-:|:-:|:-:|
| `protect` | yes | no | no |
| `restrict` | yes | yes | no |
| `shutdown` | yes | yes | yes |

Recover: `shutdown` → `no shutdown`, or `errdisable recovery cause psecure-violation`.

## DHCP snooping
```
ip dhcp snooping
ip dhcp snooping vlan 1
interface g0/1                       ! uplink to the real DHCP server
 ip dhcp snooping trust
interface fa0/1                      ! access port
 ip dhcp snooping limit rate 5       ! packets per second
show ip dhcp snooping binding
```

## Dynamic ARP Inspection (DAI)
Depends on the snooping binding table.
```
ip arp inspection vlan 1
ip arp inspection validate src-mac dst-mac ip
interface g0/1
 ip arp inspection trust
show ip arp inspection
```
