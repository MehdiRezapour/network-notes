# ENCOR 05 – Access Control & Infrastructure Security

## ACL recap
```
ip access-list extended 100
 permit ip any any
interface g0/0
 ip access-group 100 in
show access-lists
```

## MAC ACL (Layer 2)
```
mac access-list extended TEST
 permit any any
interface g0/0
 mac access-group TEST in
```

## VLAN ACL (VACL)
Filters traffic **inside** a VLAN (including host-to-host on the same switch).
```
access-list 100 permit ip any any
vlan access-map VMAP 10
 match ip address 100
 action drop                  ! drop ≈ deny, forward ≈ permit
vlan access-map VMAP 20
 action forward
vlan filter VMAP vlan-list 10-20
```

## Line hardening
```
line console 0
 logging synchronous
 exec-timeout 0 0              ! never idle out (lab only!)
 privilege level 15
 absolute-timeout 20           ! force re-authentication after 20 min, active or not
 logout-warning 120            ! warn 120 s before logout
 history size 0
show line
```

## Stronger password hashing
```
username admin algorithm-type sha256 secret MyPass      ! type 8
username admin algorithm-type scrypt secret MyPass      ! type 9
enable algorithm-type sha256 secret MyPass
```
Default `secret` hash is type 5 (MD5). For type 8/9 you cannot type the number plus a plain password – either use `algorithm-type` or paste an existing hash.

## Privilege levels
```
username test privilege 5 secret MyPass
privilege exec level 5 configure terminal
privilege configure level 5 interface
privilege interface level 5 shutdown
privilege interface level 5 no shutdown
privilege interface level 5 ip address
privilege interface level 5 no ip address
```
Plus `enable secret level 5 Pass` to let users elevate to level 5.

## Disable config auto-load from TFTP
```
no service config
```

## Zone-Based Firewall (ZBFW)
```
zone security INSIDE
zone security OUTSIDE
interface g0/0
 zone-member security INSIDE
interface g0/1
 zone-member security OUTSIDE
!
ip access-list extended SSH-OUT
 permit tcp 10.10.10.0 0.0.0.255 any eq 22
class-map type inspect match-all CM-SSH
 match access-group name SSH-OUT
policy-map type inspect PM-IN-OUT
 class type inspect CM-SSH
  inspect                       ! stateful (return traffic allowed automatically)
 class class-default
  drop log
zone-pair security IN-TO-OUT source INSIDE destination OUTSIDE
 service-policy type inspect PM-IN-OUT
show zone security
show policy-map type inspect zone-pair
```
Policy actions: `inspect` (stateful), `drop`, `pass` (no state – you need the reverse rule too). Traffic between interfaces in the same zone is allowed; traffic to the router itself is allowed unless a zone pair involving the "self" zone exists.

## DHCP server extras
```
ip dhcp pool TEST
 host 192.168.10.10 255.255.255.0           ! static lease
 client-identifier 01aa.bbcc.ddee.ff        ! 01 + client MAC
 lease 1                                    ! 1 day (use: lease infinite)
clear ip dhcp binding *
interface g0/0.10
 ip helper-address 192.168.20.2
```

## DHCP snooping
```
ip dhcp snooping
ip dhcp snooping vlan 1,10,20
no ip dhcp snooping information option      ! option 82 – disable if the switch is not the relay
interface g0/0
 ip dhcp snooping trust
interface g0/1
 ip dhcp snooping limit rate 5
```

## Dynamic ARP Inspection
```
ip arp inspection vlan 1,10,20
ip arp inspection validate src-mac dst-mac ip
interface range g0/3 , g1/1
 ip arp inspection trust
!
arp access-list STATIC-HOSTS
 permit ip host 192.168.10.100 mac host 5000.0400.0000 log
ip arp inspection filter STATIC-HOSTS vlan 10 [static]
```
- Trusted ports skip inspection.
- Without `static`: the ARP ACL is checked first, then the DHCP snooping binding table.
- With `static`: only the ACL is used (implicit deny at the end), no fallback to snooping bindings.

## IP Source Guard (IPSG)
```
interface g0/2
 ip verify source                       ! checks source IP against snooping/static bindings
 ip verify source port-security         ! checks IP and MAC
ip source binding 5000.0000.0400 vlan 10 192.168.10.100 interface g0/2     ! static binding
show ip source binding
```
Blocks hosts from spoofing another IP, and from using a manually set IP not in the binding table.
