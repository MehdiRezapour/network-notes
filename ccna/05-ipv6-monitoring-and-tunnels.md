# CCNA 05 – IPv6, Monitoring, PoE, GRE

## IPv6 basics
```
ipv6 unicast-routing                          ! required for a router to forward IPv6
interface g0/0/0
 ipv6 address 2001:db8:1:1::/64 eui-64        ! interface ID from MAC
 ipv6 address 2001:db8:1:1::1/64              ! or fully manual
 ipv6 address fe80::1 link-local              ! manual link-local
show ipv6 interface brief
show ipv6 neighbors
```
Static routes:
```
ipv6 route ::/0 2001:a:b:12::1
ipv6 route 2001:a:b:24::/64 2001:a:b:12::1
show ipv6 route
```

## OSPFv3 (IPv6)
```
ipv6 router ospf 1
 router-id 1.1.1.1
interface g0/0/0
 ipv6 ospf 1 area 0
show ipv6 ospf neighbor
show ipv6 ospf interface brief
show ipv6 route ospf
```
The router-id must be set manually if the router has no IPv4 address.

## DHCPv6 pool (stateless/stateful)
```
ipv6 dhcp pool TEST
 address prefix 2001:a:b:1::/64
 dns-server 2001:4860:4860::8888
 domain-name test.local
```
Cisco option 43 (tells lightweight APs where the WLC is) in an IPv4 pool: `option 43 ip 192.168.1.9`.

## Syslog
```
logging host 10.10.10.5
logging trap informational          ! severity 0-7 (debugging = 7)
terminal monitor                    ! show logs in your SSH/telnet session
show logging
```

## SNMP
```
snmp-server community MYRO ro
snmp-server community MYRW rw                    ! avoid rw in production
snmp-server host 10.10.10.1 version 2c MYRO
snmp-server enable traps config

! SNMPv3 (authentication + encryption)
snmp-server group MYGROUP v3 priv
snmp-server user cisco MYGROUP v3 auth sha AuthPass123 priv aes 256 PrivPass123
```

## PoE
```
show power inline
interface fa0/1
 power inline auto        ! default
 power inline never       ! turn PoE off
```

## GRE tunnel
```
interface tunnel 1
 ip address 172.16.16.1 255.255.255.0
 tunnel source 100.100.100.1          ! or: tunnel source gigabitethernet 0/1
 tunnel destination 200.200.200.1
```
The other router mirrors source/destination. Route traffic into the tunnel with static or dynamic routing.
