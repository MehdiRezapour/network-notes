# ENARSI 01 – DHCP, IPv6 Addressing, Forwarding

## DHCPv4 server
```
ip dhcp excluded-address 192.168.10.1 192.168.10.20
ip dhcp pool TEST
 network 192.168.10.0 255.255.255.0
 default-router 192.168.10.1
 dns-server 8.8.8.8
 lease 1                                   ! days (or: lease infinite)
 option 43 ip 192.168.1.9                  ! WLC address for lightweight APs
ip dhcp pool PRINTER
 host 192.168.10.50 255.255.255.0          ! static reservation
 client-identifier 01aa.bbcc.ddee.ff       ! 01 + MAC address
interface g0/0
 ip helper-address 192.168.20.2            ! relay
```
```
show ip dhcp pool
show ip dhcp binding
show ip dhcp conflict
clear ip dhcp binding *
debug ip dhcp server events
debug ip dhcp server packet
```
Client side (Windows): `ipconfig /all | more`.

## IPv6 interface addressing
```
ipv6 unicast-routing
interface g0/0
 ipv6 address 2001:ab:1::/64 eui-64
 ipv6 enable                         ! only creates the link-local address
 ipv6 address fe80::1 link-local
 ipv6 address autoconfig             ! SLAAC client
show ipv6 interface brief
```
Windows randomizes interface IDs; to use EUI-64 in labs (PowerShell):
```
Get-NetIPv6Protocol
Set-NetIPv6Protocol -RandomizeIdentifiers Disabled
```

## Router Advertisements (RA / NDP)
```
interface g0/0
 ipv6 nd ra suppress all                   ! router stops sending RAs
 ipv6 nd router-preference high            ! default-gateway preference (only routers advertise the gateway)
 ipv6 nd prefix 2001:db8:a:a::/64 no-autoconfig   ! clear the A flag (no SLAAC)
 ipv6 nd managed-config-flag               ! M flag → stateful DHCPv6
 ipv6 nd other-config-flag                 ! O flag → stateless DHCPv6 (DNS etc. only)
```
| Method | M | O | A |
|--------|---|---|---|
| SLAAC | 0 | 0 | 1 |
| Stateless DHCPv6 | 0 | 1 | 1 |
| Stateful DHCPv6 | 1 | – | 0 |

## DHCPv6
```
ipv6 dhcp pool TEST
 address prefix 2001:db8:a:a::/64
 dns-server 2001:4860:4860::8888
 domain-name test.local
interface g0/0
 ipv6 dhcp server TEST [rapid-commit]      ! rapid-commit: only Solicit/Reply (2 messages)
!
interface g1/0                              ! client side
 ipv6 address dhcp rapid-commit
!
interface g2/0                              ! relay agent
 ipv6 dhcp relay destination 2001:db8:100::1
show ipv6 dhcp interface g0/0
show ipv6 dhcp pool
show ipv6 dhcp binding
```

## Forwarding & misc
```
show ip cef
show adjacency detail
show ip cef exact-route 192.168.1.10 192.168.2.10    ! which path a flow takes
interface g0/0
 ip proxy-arp                                         ! on by default
 no ip redirects
show ip route 192.168.0.0 255.255.0.0 longer-prefixes
```
IPv6 static route using a **link-local** next hop must also name the exit interface:
```
ipv6 route 2001:ab:a:a::/64 g0/0 fe80::2
show ipv6 neighbors
```
