# ENARSI 04 – BGP (Advanced)

## Neighbor setup (address-family style)
```
router bgp 6200
 bgp router-id 1.1.1.1
 no bgp default ipv4-unicast
 neighbor 100.100.100.2 remote-as 6300
 neighbor 100.100.100.2 password MyBgpKey
 neighbor 100.100.100.2 timers 10 40               ! keepalive / hold
 neighbor 100.100.100.2 update-source loopback0
 neighbor 100.100.100.2 ebgp-multihop 2
 address-family ipv4 unicast
  network 100.100.100.0 mask 255.255.255.0
  neighbor 100.100.100.2 activate
  neighbor 100.100.100.2 next-hop-self
  neighbor 100.100.100.2 soft-reconfiguration inbound
  neighbor 100.100.100.2 distribute-list 100 in
  neighbor 100.100.100.2 prefix-list PL in
  neighbor 100.100.100.2 route-map RM in
  neighbor 100.100.100.2 default-originate
  maximum-paths 4
```

## Route attributes via route-map
```
route-map SET-ATTR permit 10
 set weight 40
 set local-preference 200
 set as-path prepend 6500 6500 6500
 set metric 10
route-map SET-ATTR permit 20
```
Examples
```
! Weight directly on a neighbor
neighbor 20.20.20.2 weight 20

! Local-pref on selected prefixes
access-list 1 permit 40.40.40.0 0.0.0.3
route-map LP permit 10
 match ip address 1
 set local-preference 200
route-map LP permit 20
router bgp 6500
 neighbor 60.60.60.1 route-map LP in

! AS-path prepend, MED outbound
access-list 100 permit ip 70.70.70.0 0.0.0.255 any
route-map MED permit 10
 match ip address 100
 set metric 10
route-map MED permit 20
router bgp 6500
 neighbor 20.20.20.2 route-map MED out
```

## Aggregation
```
ip route 192.168.0.0 255.255.252.0 null0
router bgp 6300
 address-family ipv4 unicast
  aggregate-address 192.168.0.0 255.255.252.0 summary-only as-set
```
`as-set` keeps the AS numbers of the contributing routes in the aggregate (prevents loops). Redistribute selected statics:
```
access-list 1 permit 192.168.0.0 0.0.3.255
route-map STATIC permit 10
 match ip address 1
router bgp 6300
 redistribute static route-map STATIC
```

## AS-path filtering
```
ip as-path access-list 1 permit ^$             ! only routes originated locally
ip as-path access-list 2 permit _6200$         ! originated in AS 6200
router bgp 65100
 neighbor 10.1.1.1 filter-list 1 out
route-map RM permit 10
 match as-path 2
```
Verification:
```
show ip bgp filter-list 1
show ip bgp regexp _6200$
show ip bgp route-map RM
show ip bgp prefix-list PL
show ip bgp neighbors 10.1.1.1 routes
show ip bgp 172.16.0.1 bestpath
show ip bgp 172.16.0.0/16 longer-prefixes
```
Example extended ACL used to filter default-like prefixes: `permit ip 192.168.0.0 0.0.255.255 host 255.255.255.255`.

## Peer groups
```
router bgp 6200
 neighbor IBGP peer-group
 neighbor IBGP remote-as 6200
 neighbor IBGP update-source loopback0
 neighbor IBGP next-hop-self
 neighbor IBGP password MyBgpKey
 neighbor IBGP timers 10 40
 neighbor 192.168.1.1 peer-group IBGP
 neighbor 192.168.1.2 peer-group IBGP
 address-family ipv4 unicast
  neighbor IBGP activate
  neighbor IBGP soft-reconfiguration inbound
  neighbor IBGP prefix-list PL in
  neighbor IBGP route-map RM in
```
Peer groups save configuration and let the router build updates once for all members.

## Scaling iBGP
**Route reflector** – the RR re-advertises iBGP routes to its clients, so a full mesh is not needed:
```
neighbor 10.1.1.1 route-reflector-client
```
**Confederation** – split one AS into sub-ASes; outside world sees one AS:
```
router bgp 65100
 bgp confederation identifier 200
 bgp confederation peers 65200
```

## Protecting against route floods
```
neighbor 10.1.1.1 maximum-prefix 6 50 warning-only
neighbor 10.1.1.1 maximum-prefix 6 50 restart 10
```
`6` = maximum prefixes, `50` = warning threshold (% of max). `warning-only` just logs when the limit is exceeded; without it the session goes down, and `restart 10` re-establishes it after 10 minutes.

## BGP into IGP
```
router bgp 65100
 bgp redistribute-internal          ! allow iBGP routes to be redistributed into an IGP
router ospf 1
 redistribute bgp 65100 subnets
```

## MP-BGP for IPv6
```
router bgp 65100
 bgp router-id 1.1.1.1              ! required when there is no IPv4 address
 neighbor 10.12.1.2 remote-as 65200
 address-family ipv6 unicast
  neighbor 10.12.1.2 activate
  neighbor 10.12.1.2 route-map V6-NH out
route-map V6-NH permit 10
 set ipv6 next-hop 2001:db8:0:12::1
show bgp ipv6 unicast
show bgp ipv6 unicast summary
clear bgp ipv6 unicast *
```

## Clearing
```
clear ip bgp *                         ! hard
clear bgp ipv4 unicast *
clear bgp ipv6 unicast *
clear ip bgp 100.100.100.1 soft in
clear ip bgp 100.100.100.1 soft out
clear ip bgp * soft
```
