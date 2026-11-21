# ENCOR 03 – BGP

## Basic eBGP
```
router bgp 6200
 bgp router-id 1.1.1.1
 no bgp default ipv4-unicast
 neighbor 100.100.100.2 remote-as 6300
 address-family ipv4
  neighbor 100.100.100.2 activate
  network 100.100.100.0 mask 255.255.255.252
```
```
show ip bgp summary
show ip bgp neighbors
show bgp
show ip route bgp
show tcp brief             ! BGP runs over TCP/179
```
The `network` command only advertises a prefix that exists in the routing table with an exact match.

## iBGP essentials
```
neighbor 2.2.2.2 remote-as 6200
neighbor 2.2.2.2 update-source loopback0     ! peer between loopbacks
neighbor 2.2.2.2 next-hop-self               ! iBGP does not change next hop by default
neighbor 2.2.2.2 ebgp-multihop 2             ! eBGP peers that are not directly connected
```
iBGP does not re-advertise iBGP-learned routes (split horizon) → full mesh, route reflectors or confederations.

## Aggregation
```
ip route 192.168.0.0 255.255.252.0 null0
router bgp 6200
 network 192.168.0.0 mask 255.255.252.0
! or:
 aggregate-address 192.168.0.0 255.255.252.0 summary-only
```

## Redistribute static
```
access-list 1 permit 192.168.0.0 0.0.3.255
route-map STATIC-TO-BGP permit 10
 match ip address 1
router bgp 6200
 redistribute static route-map STATIC-TO-BGP
```

## Filtering inbound routes
Three equivalent methods (prefix-list is the most flexible):
```
! 1) distribute-list with ACL
access-list 1 deny 172.16.0.0 0.0.255.255
access-list 1 permit any
router bgp 6200
 neighbor 100.100.45.1 distribute-list 1 in

! 2) prefix-list
ip prefix-list NO-172 seq 10 deny 172.16.0.0/16 ge 25 le 26
ip prefix-list NO-172 seq 20 permit 0.0.0.0/0 le 32
router bgp 6200
 neighbor 100.100.45.1 prefix-list NO-172 in

! 3) route-map
route-map FILTER deny 10
 match ip address 10
route-map FILTER permit 20
router bgp 6200
 neighbor 100.100.45.1 route-map FILTER in
```
`ge/le` match prefix lengths; `0.0.0.0/0 le 32` = any prefix. A route-map without a final empty `permit` entry blocks everything else (implicit deny).

## Path attributes (route-map examples)
```
ip prefix-list TARGET seq 10 permit 40.40.40.0/30

route-map SET-WEIGHT permit 10
 match ip address prefix-list TARGET
 set weight 100
route-map SET-WEIGHT permit 20

route-map SET-LP permit 10
 match ip address prefix-list TARGET
 set local-preference 200
route-map SET-LP permit 20

route-map PREPEND permit 10
 set as-path prepend 6500 6500 6500 6500

route-map SET-MED permit 10
 match ip address prefix-list TARGET
 set metric 20
route-map SET-MED permit 20
```
Apply with `neighbor X route-map NAME in|out`, then refresh: `clear bgp ipv4 unicast * soft`.

| Attribute | Scope | Preferred | Default |
|-----------|-------|-----------|---------|
| Weight | local router only (Cisco) | higher | 0 (32768 for local routes) |
| Local preference | whole AS | higher | 100 |
| AS-path length | between ASes | shorter | – |
| MED (metric) | to neighbor AS | lower | 0 |

Best-path order: Weight → Local-Pref → locally originated → AS-path → Origin → MED → eBGP over iBGP → lowest IGP metric to next hop → oldest/router-ID.
Shortcut for weight: `neighbor 20.20.20.2 weight 20`.

## Clearing & verifying
```
clear ip bgp *                                  ! hard reset (drops sessions)
clear bgp ipv4 unicast * soft                   ! refresh policy without dropping sessions
clear ip bgp 100.100.45.1 soft in
clear ip bgp 100.100.45.1 soft out
show ip bgp neighbors 100.100.45.1 received-routes      ! needs soft-reconfiguration inbound
show ip bgp neighbors 100.100.45.1 advertised-routes
```
