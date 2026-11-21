# ENARSI 07 – Infrastructure Security

## Unicast Reverse Path Forwarding (uRPF)
Drops packets whose source address fails a reverse routing check – mitigates IP spoofing.
```
interface g0/0
 ip verify unicast source reachable-via rx                 ! strict: must arrive on the interface the route points to
 ip verify unicast source reachable-via any                ! loose: any route to the source is enough
 ip verify unicast source reachable-via rx allow-default   ! also accept sources matching the default route
```
Use strict mode at the edge of single-homed networks, loose mode when routing is asymmetric.

## IPv6 ACL
```
ipv6 access-list BLOCK-V6
 deny ipv6 2001:db8:bad::/48 any
 permit ipv6 any any
interface g0/0
 ipv6 traffic-filter BLOCK-V6 in      ! or out
```
IPv6 ACLs implicitly permit neighbor discovery (NS/NA) – before the implicit deny.

## Port security: protect vs restrict
Both drop frames from unauthorized MACs. `restrict` also logs/counts violations; `protect` is silent.

## Console history
```
line console 0
 history size 0
```
