# CCNA 03 – IP Routing & First-Hop Redundancy

## Static routes
```
ip route 10.10.1.0 255.255.255.0 10.11.12.1            ! next-hop IP (preferred)
ip route 10.10.1.0 255.255.255.0 gigabitethernet 0/0/0 ! exit interface (point-to-point links)
ip route 0.0.0.0 0.0.0.0 185.185.185.2                 ! default route
ip route 0.0.0.0 0.0.0.0 185.185.185.6 2               ! floating static (AD 2) = backup
show ip route
```
Static routes are marked `S` in the routing table (default AD = 1).

## RIPv2
```
router rip
 version 2
 no auto-summary
 network 10.0.0.0
 network 172.16.0.0
```

## OSPFv2 (single area & basics)
```
router ospf 1
 router-id 1.1.1.1
 network 192.168.1.1 0.0.0.0 area 0          ! match one interface
 network 100.100.100.0 0.0.0.255 area 0
 passive-interface default
 no passive-interface serial 0/1/0
 auto-cost reference-bandwidth 1000          ! in Mbps; set the same on all routers
 default-information originate [always]      ! advertise a default route
!
interface gi0/0
 ip ospf cost 10
 ip ospf priority 3                          ! highest priority wins DR; 0 = never DR/BDR
 ip ospf network point-to-point              ! no DR/BDR election
```
- A loopback is advertised as a /32 regardless of its mask. Add `ip ospf network point-to-point` on the loopback to advertise the real mask.
- Router ID order: manual `router-id` → highest loopback IP → highest active interface IP.
- DR election is non-preemptive – clear the process after changing priority: `clear ip ospf process`.
- Summarize between areas on an ABR: `area 10 range 192.168.0.0 255.255.252.0`.
- Simple authentication:
  ```
  interface gi0/0
   ip ospf authentication
   ip ospf authentication-key cisco123
  ```
- Multi-area rule: every non-backbone area must connect to area 0 (directly or via a virtual link).

```
show ip ospf neighbor
show ip ospf interface brief
show ip ospf database
show ip route ospf
debug ip ospf events
debug ip ospf adj
undebug all
```

## HSRP (first-hop redundancy)
```
interface gi0/0
 standby version 2
 standby 10 ip 192.168.10.1
 standby 10 priority 105              ! default 100, higher wins
 standby 10 preempt                   ! reclaim active role after recovery
 standby 10 timers 1 3                ! hello 1s, hold 3s
 standby 10 authentication md5 key-string cisco123
show standby
show standby brief
```
Hosts use the virtual IP as default gateway.
