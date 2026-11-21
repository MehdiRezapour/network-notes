# ENARSI 02 – EIGRP (Advanced)

## Classic mode
```
router eigrp 1
 eigrp router-id 1.1.1.1
 network 10.0.0.0 0.255.255.255
 passive-interface default
 no passive-interface g0/0
 no auto-summary
 variance 2
 maximum-paths 4
 metric weights 0 1 0 1 0 0
 timers active-time 2                   ! SIA timer in minutes
 default-metric 100000 10 255 1 1500
 redistribute ospf 1 metric 10000 100 255 1 1500
!
interface g0/0
 ip hello-interval eigrp 1 5
 ip hold-time eigrp 1 15
 ip summary-address eigrp 1 10.1.0.0 255.255.0.0
 bandwidth 1000000                      ! kbps
 delay 10                               ! tens of microseconds
```
Metric = f(bandwidth, delay) by default (K1 = K3 = 1).

## Named mode
```
router eigrp TEST
 address-family ipv4 unicast autonomous-system 1
  af-interface default
   passive-interface
  exit-af-interface
  af-interface g0/0
   no passive-interface
   hello-interval 5
   hold-time 15
   summary-address 10.1.0.0 255.255.0.0
   authentication mode md5
   authentication key-chain EIGRP-KEYS
   ! or: authentication mode hmac-sha-256 0 MyPassword
  exit-af-interface
  eigrp router-id 1.1.1.1
  eigrp stub connected summary             ! stub: only advertise what is listed
  maximum-paths 4
  timers active-time 2
  topology base
   variance 3
   redistribute ospf 1 metric 10000 100 255 1 1500
  exit-af-topology
  network 10.0.0.0 0.255.255.255
```
Stub options: `connected`, `static`, `summary`, `redistributed`, `leak-map`, `receive-only` (advertises nothing).

## Key chains with lifetimes
```
key chain EIGRP-KEYS
 key 1
  key-string cisco
  accept-lifetime 00:00:00 1 Feb 2026 23:59:59 28 Feb 2026
  send-lifetime   00:00:00 1 Feb 2026 23:59:59 28 Feb 2026
show key chain
```
Classic-mode interface commands:
```
interface g0/0
 ip authentication mode eigrp 1 md5
 ip authentication key-chain eigrp 1 EIGRP-KEYS
```
HMAC-SHA-256 and MD5 need matching keys on both neighbors; synchronize time (NTP) when using lifetimes.

## Filtering and metric manipulation
```
ip prefix-list BLOCK seq 10 deny 10.1.100.0/24
ip prefix-list BLOCK seq 20 permit 0.0.0.0/0 le 32
router eigrp TEST
 address-family ipv4 unicast autonomous-system 1
  topology base
   distribute-list prefix BLOCK in               ! filter by prefix
   distribute-list gateway BLOCK in              ! filter by advertising next hop (uses a prefix-list)
   offset-list 10 in 100000 g0/0                 ! add to the metric to steer traffic away
access-list 10 permit 10.1.100.0 0.0.0.255
```
Remember: to filter EIGRP routes you must apply the filter **inside EIGRP** with `distribute-list`.

## Split horizon (hub-and-spoke / DMVPN)
```
interface tunnel 1
 no ip split-horizon eigrp 1                 ! classic mode
router eigrp TEST
 address-family ipv4 unicast autonomous-system 1
  af-interface tunnel 1
   no split-horizon                          ! named mode
```
By default EIGRP does not advertise a route out of the interface it was learned on.

## EIGRP for IPv6
```
! Classic
ipv6 router eigrp 1
 eigrp router-id 1.1.1.1                     ! mandatory
interface range g0/0 - 1
 ipv6 eigrp 1                                ! must be enabled per interface
! Named
router eigrp TEST
 address-family ipv6 unicast autonomous-system 1
  eigrp router-id 1.1.1.1                    ! enables EIGRP on all interfaces automatically
  af-interface loopback0
   shutdown                                  ! exclude one interface
ipv6 prefix-list V6 deny 2001:db8:1::1/128
ipv6 prefix-list V6 permit ::/0 le 128
```

## Show / debug
```
show ip protocols
show ip route eigrp
show ip eigrp neighbors
show ip eigrp interface
show ip eigrp topology
show ip eigrp topology 192.168.1.0
show ip eigrp topology all-links
show ip eigrp topology active
show eigrp protocols
show eigrp address-family ipv6
debug eigrp packet hello
```
