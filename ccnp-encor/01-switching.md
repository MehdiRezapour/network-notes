# ENCOR 01 – Advanced Switching

## Host-facing port template
```
interface g0/1
 switchport mode access
 spanning-tree portfast
 ! or the macro: switchport host
```
Useful checks: `show vlan brief`, `show vlan summary`, `show vlan id 10`, `show vlan name TEST`, `show interfaces status`, `show mac address-table vlan 10`.
Lab tool for L2 attacks (DTP/STP/DHCP): Kali `yersinia -G`.

## VLAN by name & trunk tuning
```
interface g0/1
 switchport access vlan 10            ! or: switchport access vlan name TEST
 switchport trunk native vlan 99
 switchport trunk allowed vlan 10,20,30
```

## VTP
```
vtp mode server
vtp domain LAB
vtp password MyVtpPass [hidden | secret]
vtp version 3
vtp pruning
vtp primary [vlan | mst] [force]      ! VTPv3 only; one primary server can write
show vtp status
show vtp password
```
- VTPv3 also carries MST config: `vtp mode server mst`, `vtp primary mst`.
- Pruning: VLANs not in use downstream are not flooded over the trunk.
- `shutdown` under a VLAN is local only; `state suspend` is propagated by VTP.

## STP tuning
```
show spanning-tree root
show spanning-tree vlan 10
show spanning-tree interface g0/0 detail
debug spanning-tree events
!
spanning-tree vlan 10 max-age 20
spanning-tree vlan 10 hello-time 2
spanning-tree vlan 10 forward-time 15
!
interface g0/0
 spanning-tree guard root              ! nobody else can claim root
 spanning-tree portfast edge           ! edge | network | disable
 spanning-tree bpduguard enable
!
errdisable recovery cause bpduguard
errdisable recovery interval 30
show errdisable recovery
```
Global defaults: `spanning-tree portfast default`, `spanning-tree portfast bpduguard default`.

## MST (Multiple Spanning Tree)
```
spanning-tree mode mst
spanning-tree mst configuration
 name REGION1
 revision 1
 instance 1 vlan 1, 10-15
 instance 2 vlan 16-20
 show pending                            ! review before commit
 exit                                    ! exiting applies the change
spanning-tree mst 1 root primary
spanning-tree mst 1 priority 4096
interface g0/0
 spanning-tree mst 1 cost 2000
 spanning-tree mst 1 port-priority 64
show spanning-tree mst
show spanning-tree mst configuration
show spanning-tree mst interface g0/0
```
Name, revision and VLAN-to-instance mapping must match on all switches in the region.

## EtherChannel (LACP/PAgP tuning)
```
interface range g0/0 - 1
 channel-group 1 mode active                   ! LACP
 lacp rate fast                                ! 1-second LACPDUs
 lacp port-priority 100
channel-group 1 mode desirable non-silent      ! PAgP
!
lacp system-priority 100
interface port-channel 1
 port-channel min-links 2                      ! bundle goes down if fewer links are up
 lacp max-bundle 4                             ! max active links (rest are hot-standby)
show lacp internal
show lacp neighbor
show lacp sys-id
show pagp internal
show etherchannel summary
```
To wipe a port back to defaults: `default interface range g0/0 - 3`. Configure/remove with `interface port-channel 1` / `no interface port-channel 1`.
