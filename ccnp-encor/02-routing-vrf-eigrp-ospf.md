# ENCOR 02 – VRF, EIGRP, OSPF, IP SLA

## VRF-Lite
```
vrf definition TEST
 address-family ipv4
 address-family ipv6
interface g0/0
 vrf forwarding TEST
 ip address 10.0.0.1 255.255.255.0     ! re-enter the IP – it is removed when the VRF is applied
show vrf
show vrf TEST
show ip route vrf TEST
ping vrf TEST 10.0.0.2
traceroute vrf TEST 10.0.0.2
```
Routing per VRF: `router ospf 1 vrf TEST`, `address-family ipv4 vrf TEST` under EIGRP/BGP.

## EIGRP (classic)
```
router eigrp 1
 eigrp router-id 1.1.1.1
 network 10.10.0.0 0.0.255.255
 passive-interface default
 no passive-interface g0/0
 variance 3                                ! unequal-cost load balancing
 redistribute static metric 10000 100 255 1 1500
 redistribute ospf 1 metric 10000 100 255 1 1500
!
interface g0/0
 ip hello-interval eigrp 1 5
 ip hold-time eigrp 1 15
 bandwidth 100000                          ! kbps – influences the metric
 ip address 172.16.16.1 255.255.255.0 secondary
```
```
show ip eigrp neighbors
show ip eigrp topology
show ip eigrp topology all-links            ! includes non-successor routes
show ip eigrp topology all-links | section 192.168.2.0
show ip protocols
clear ip eigrp neighbors
```

## EIGRP named mode
Convert: `eigrp upgrade-cli TEST` (from classic AS 1).
```
router eigrp TEST
 address-family ipv4 unicast autonomous-system 1
  af-interface default
   passive-interface
  exit-af-interface
  af-interface g0/0
   no passive-interface
   authentication mode md5
   authentication key-chain EIGRP-KEYS
  exit-af-interface
  topology base
   variance 3
   redistribute static metric 10000 100 255 1 1500
   redistribute ospf 1 metric 10000 100 255 1 1500
  exit-af-topology
  network 10.0.0.0 0.255.255.255
!
key chain EIGRP-KEYS
 key 1
  key-string qwert123
show key chain EIGRP-KEYS
```
VRF: `address-family ipv4 vrf TEST autonomous-system 1`.

## OSPF
```
router ospf 1
router ospf 1 vrf TEST
 router-id 1.1.1.1
 maximum-paths 4
 auto-cost reference-bandwidth 10000
 passive-interface default
 network 192.168.1.0 0.0.0.255 area 0       ! or enable per-interface (below)
 redistribute eigrp 1 subnets
!
interface g0/0
 ip ospf 1 area 0
 ip ospf cost 10
 ip ospf priority 5
 ip ospf network point-to-point
```
```
show ip ospf interface brief
show ip ospf neighbor
show ip ospf database
show ip route ospf
clear ip ospf process
```
DNS lookup: `ip name-server 192.168.1.2`, `ip domain-lookup`.

**Default route**
- `default-information originate` – only if the router already has a default route.
- `default-information originate always` – advertise regardless.
- Metric type: E2 (default) keeps the same external cost everywhere; `metric-type 1` (E1) adds internal path cost.

**Special areas**
```
area 10 stub                    ! all routers in area
area 10 stub no-summary         ! totally stubby (ABR)
area 20 nssa
summary-address 172.16.16.0 255.255.252.0   ! ASBR: summarize external routes
area 10 virtual-link 2.2.2.2    ! both ends; target = remote router-id
```

## OSPFv3 (IPv4 + IPv6)
```
router ospfv3 1
 router-id 1.1.1.1
 address-family ipv4 unicast
 address-family ipv6 unicast
interface g0/0
 ospfv3 1 ipv6 area 0
 ospfv3 1 ipv4 area 0
show ospfv3 neighbor
```

## IP SLA + tracking (conditional static route)
```
ip sla 1
 icmp-echo 10.36.7.2 source-interface g0/1
 threshold 1000
 timeout 1000
 frequency 3
ip sla schedule 1 life forever start-time now
track 1 ip sla 1 reachability
 delay down 1 up 1
ip route 10.36.7.0 255.255.255.252 10.10.68.2 track 1
show ip sla statistics
show track brief
```

## Misc
```
interface g0/0
 ip directed-broadcast        ! normally disabled – security risk
ip multicast-routing
```
