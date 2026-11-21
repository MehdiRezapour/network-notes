# ENCOR 04 – FHRP, NAT, Policy-Based Routing

## HSRP
```
interface g0/0
 standby version 2
 standby 10 ip 192.168.1.1
 standby 10 priority 105
 standby 10 preempt
 standby 10 timers 1 3
 standby 10 track 1 decrement 10         ! lower priority when the tracked object fails
show standby
show standby brief
```
**Tracked object with IP SLA**
```
ip sla 1
 icmp-echo 8.8.8.8 source-interface g0/0
 threshold 1000
 timeout 1000
 frequency 3
ip sla schedule 1 life forever start-time now
track 1 ip sla 1 reachability
 delay up 1 down 1
show ip sla statistics
```

## VRRP
**VRRPv3 (address-family syntax)**
```
fhrp version vrrp v3
interface g0/0
 vrrp 10 address-family ipv4
  address 192.168.1.1 primary
  priority 110
  preempt
  timers advertise 1000                 ! milliseconds
show vrrp brief
```
**VRRPv2 (classic)**
```
fhrp version vrrp v2
interface g0/0
 vrrp 10 ip 192.168.1.1
 vrrp 10 timers advertise 1
 vrrp 10 priority 110
 vrrp 10 preempt
 vrrp 10 track 1 decrement 20
```
If the virtual IP equals the router's real interface IP, that router becomes owner with priority 255.

## GLBP (load balancing gateway)
```
track 1 interface g0/0 line-protocol
interface g0/0
 glbp 10 ip 192.168.1.1
 glbp 10 priority 110
 glbp 10 preempt
 glbp 10 timers 1 3
 glbp 10 load-balancing round-robin       ! or weighted | host-dependent
 glbp 10 weighting 150 lower 130 upper 145
 glbp 10 weighting track 1 decrement 15
show glbp
show track brief
```
When weight drops below `lower` the router stops forwarding; it resumes above `upper`.

## NAT
```
interface g0/0
 ip nat inside                    ! or: ip nat outside
ip nat inside source static 192.168.1.1 100.100.100.1
ip nat pool TEST 100.100.100.0 100.100.100.10 netmask 255.255.255.240
access-list 1 permit any
ip nat inside source list 1 pool TEST overload
ip nat inside source list 1 interface g0/0 overload
ip nat inside source static tcp 192.168.1.2 22 100.100.100.1 22      ! port forwarding
show ip nat translations
```

## Policy-Based Routing (PBR) with time-range and tracking
```
time-range WORKHOURS
 periodic weekdays 7:00 to 17:00          ! Monday–Friday
time-range WEEKEND
 periodic weekend 0:00 to 23:59           ! Saturday–Sunday
!
access-list 100 permit ip 192.168.10.0 0.0.0.255 any time-range WORKHOURS
!
route-map PBR permit 10
 match ip address 100
 set ip next-hop verify-availability 50.50.50.2 5 track 100
!
interface range g0/3.10 - g0/3.20
 ip policy route-map PBR
```
`verify-availability` uses the track object to confirm the next hop is alive before using it. Match on ingress interface: `match interface g0/0` in the route-map.
