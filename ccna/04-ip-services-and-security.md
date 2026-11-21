# CCNA 04 – DHCP, ACLs, NAT

## DHCP server
```
ip dhcp excluded-address 192.168.1.1 192.168.1.19     ! reserved, never leased
ip dhcp pool LAN
 network 192.168.1.0 255.255.255.0
 default-router 192.168.1.1
 dns-server 8.8.8.8
```
```
show ip dhcp pool
show ip dhcp binding
show ip dhcp conflict
clear ip dhcp conflict *
show run | section dhcp
```

## DHCP relay (server in another subnet)
```
interface g0/0/0.10
 ip helper-address 10.10.10.10
interface g0/0/0.20
 ip helper-address 10.10.10.10
```
Configure it on the interface facing the clients.

## Standard ACLs (match source only)
Place **close to the destination**.
```
access-list 1 deny host 192.168.10.10
access-list 1 permit 192.168.10.0 0.0.0.255
access-list 1 permit any
interface g0/0/2
 ip access-group 1 out
```
Every ACL ends with an implicit `deny any`.

## Extended ACLs (protocol, source, destination, port)
Place **close to the source**.
```
access-list 100 deny icmp any 10.10.10.0 0.0.0.255
access-list 100 deny udp 172.16.16.0 0.0.0.255 10.10.10.0 0.0.0.255 eq 53
access-list 100 permit ip any 10.10.10.0 0.0.0.255
interface g0/0/1
 ip access-group 100 in
```

## Named ACLs (editable by sequence number)
```
ip access-list standard BLOCK-HOSTS
 8 deny host 192.168.1.1
 15 deny host 10.10.10.1
 no 8                                  ! delete one entry
ip access-list extended WEB-ONLY
 remark Only specific web access
 permit tcp host 10.1.2.101 host 10.1.1.101 eq 80
 permit tcp host 10.1.2.102 host 10.1.1.102 eq 443
 deny ip 10.1.2.0 0.0.0.255 10.1.1.0 0.0.0.255
 permit ip 10.1.2.0 0.0.0.255 any
```
`permit tcp any 10.1.2.0 0.0.0.255 established` allows only return traffic (ACK/RST set).

```
show access-lists
```

## NAT
Mark interfaces first:
```
interface g0/0/0
 ip nat inside
interface g0/0/1
 ip nat outside
```
**Static NAT** (1:1)
```
ip nat inside source static 10.10.10.10 100.100.100.1
```
**Dynamic NAT** (pool)
```
access-list 1 permit 10.10.10.0 0.0.0.255
ip nat pool TEST 100.100.100.0 100.100.100.4 netmask 255.255.255.248
ip nat inside source list 1 pool TEST
```
**PAT / overload** (many-to-one)
```
ip nat inside source list 1 pool TEST overload
! or use the outside interface address:
ip nat inside source list 1 interface g0/0/0 overload
```
**Port forwarding**
```
ip nat inside source static tcp 10.10.10.10 443 200.200.200.1 443
```
```
show ip nat translations
show ip nat statistics
clear ip nat translation *
```
Check that the pool netmask matches the pool range.
