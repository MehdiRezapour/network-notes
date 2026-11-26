# Extension: distribute VLANs with VTP

Goal: create VLANs only on the core switches and let the edge switches learn them.
Block C and block D are separate Layer-2 domains, so use two VTP domains.
> Not tested on a live EVE-NG.

## Prepare the edge switches (important)
A fresh VLAN database avoids revision-number surprises:
```
delete flash:vlan.dat
reload
```
After the reload re-apply the edge config **without** the `vlan 10/20/30` lines (clients cannot create VLANs).

## Block C: Switch5 = server, Switch9 and Switch10 = clients
```
! Switch5
vtp domain LAB-C
vtp version 2
vtp password LabPass123
vtp mode server
!
! Switch9 and Switch10
vtp domain LAB-C
vtp version 2
vtp password LabPass123
vtp mode client
```

## Block D: Switch6 = server, Switch7 and Switch8 = clients
```
! Switch6
vtp domain LAB-D
vtp version 2
vtp password LabPass123
vtp mode server
!
! Switch7 and Switch8
vtp domain LAB-D
vtp version 2
vtp password LabPass123
vtp mode client
```

## Verify
```
show vtp status          ! domain, mode, revision number
show vlan brief          ! on a client: VLAN 10/20/30 appear without being configured
```
Notes: VTP only works over trunks (the Port-channels are trunks). A switch with a higher configuration revision can overwrite the database of the whole domain – that is why `vlan.dat` is deleted first.
