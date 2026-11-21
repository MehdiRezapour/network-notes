# ENARSI 03 – OSPFv2 / OSPFv3 (Advanced)

## OSPFv2
```
router ospf 1
 router-id 1.1.1.1
 passive-interface default
 no passive-interface g0/0
 auto-cost reference-bandwidth 10000
 maximum-paths 4
 redistribute eigrp 1 subnets metric 10 metric-type 1
 default-information originate always metric-type 1
 summary-address 172.16.16.0 255.255.252.0     ! ASBR: external summarization
 area 10 range 192.168.0.0 255.255.252.0       ! ABR: inter-area summarization
 area 10 stub no-summary                       ! totally stubby (ABR only)
 area 20 nssa no-summary
 area 10 virtual-link 2.2.2.2
!
interface g0/0
 ip ospf 1 area 0
 ip ospf cost 10
 ip ospf priority 0
 ip ospf network point-to-point
 ip ospf hello-interval 5
 ip ospf dead-interval 20
```
- `stub` / `nssa` flags must match on **all** routers in the area; `no-summary` only on the ABR.
- `area range` goes on the ABR for the area the routes come **from**; it summarizes into the other areas.
- `summary-address` is for external routes on the ASBR.
- Virtual-link: configure on both ends, pointing to the **router-ID** of the other end, across the transit area.
- To redistribute OSPF external routes into another protocol: `redistribute ospf 1 match external 2` (add `internal`/`external 1` as needed).

## OSPFv2 authentication
```
! Plain text
interface g0/0
 ip ospf authentication
 ip ospf authentication-key cisco123
! MD5
interface g0/0
 ip ospf authentication message-digest
 ip ospf message-digest-key 1 md5 cisco123
```
Area-wide: `area 0 authentication [message-digest]`.

## OSPFv3 (IPv4 + IPv6 address families)
```
router ospfv3 1
 router-id 1.1.1.1
 auto-cost reference-bandwidth 10000
 passive-interface default
 area 10 stub no-summary
 area 10 nssa no-summary
 !
 address-family ipv4 unicast
  redistribute eigrp 1 metric 10 metric-type 1
  maximum-paths 4
  default-information originate always metric-type 1
  area 10 range 10.0.0.0 255.255.0.0
  area 10 virtual-link 2.2.2.2
 address-family ipv6 unicast
  summary-prefix 2001:db8::/32                ! ASBR summary
!
interface g0/0
 ospfv3 1 ipv4 area 0
 ospfv3 1 ipv6 area 0
 ospfv3 network point-to-point
 ospfv3 cost 10
 ospfv3 priority 0
 ospfv3 hello-interval 5
 ospfv3 dead-interval 20
 ospfv3 authentication null                   ! disables auth on the interface
 ospfv3 encryption ipsec spi 500 esp aes-cbc 256 <enc-key> sha1 <auth-key>
```
OSPFv3 uses IPsec (AH/ESP) instead of built-in auth fields. Syntax of the key arguments varies by IOS version – check `?` in your lab.

## Show / debug
```
show ip ospf neighbor
show ip ospf interface [brief]
show ip ospf database
show ip ospf database router
show ip ospf virtual-links
show ip route ospf
clear ip ospf process
debug ip ospf events
debug ip ospf adj
!
show ospfv3 neighbor
show ospfv3 interface brief
show ospfv3 database
show ospfv3 virtual-links
show ip route ospfv3
show ipv6 route ospf
clear ospfv3 process
```
