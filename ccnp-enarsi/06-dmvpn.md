# ENARSI 06 – GRE, NHRP, DMVPN & IPsec Protection

## Terminology
- **Overlay**: tunnel IP addresses. **Underlay / NBMA / transport**: real (physical) IPs.
- **NHRP** (Next Hop Resolution Protocol): maps overlay → underlay. **NHS** = Next Hop Server (the hub).
- **Phase 1**: hub-and-spoke only. **Phase 2**: spoke-to-spoke via NHRP resolution. **Phase 3**: hub sends redirects, spokes install shortcuts.

## Point-to-point GRE
```
interface tunnel 1
 bandwidth 4000
 ip mtu 1400
 ip tcp adjust-mss 1360
 keepalive 2 10
 tunnel source g0/1
 tunnel destination 172.16.31.1
```

## Hub (multipoint GRE)
```
interface tunnel 1
 ip address 192.168.100.11 255.255.255.0
 ip mtu 1400
 ip tcp adjust-mss 1360
 tunnel source g0/0
 tunnel mode gre multipoint               ! no tunnel destination on the hub
 tunnel key 100
 ip nhrp network-id 100
 ip nhrp authentication cisco123
 ip nhrp map multicast dynamic            ! send multicast (routing hellos) to all registered spokes
 ip nhrp redirect                         ! Phase 3: tell spokes a shorter path exists
 no ip split-horizon eigrp 1              ! EIGRP: allow re-advertising out the same interface
 ! OSPF alternative: ip ospf network broadcast
```

## Spoke – single hub
```
interface tunnel 1
 ip address 192.168.100.31 255.255.255.0
 ip mtu 1400
 ip tcp adjust-mss 1360
 bandwidth 4000
 tunnel source g0/0
 tunnel destination 172.16.11.1           ! Phase 1 only (point-to-point to hub)
 tunnel key 100
 ip nhrp network-id 100
 ip nhrp authentication cisco123
 ip nhrp nhs 192.168.100.11 nbma 172.16.11.1 multicast
 ip nhrp shortcut                         ! Phase 3: install the shorter path
 ip nhrp registration no-unique           ! when the spoke gets its underlay IP via DHCP
```
First address = overlay, second (after `nbma`) = underlay.
For Phase 2/3 spokes, replace `tunnel destination` with `tunnel mode gre multipoint`.

**Alternative (classic, equivalent) NHRP mapping**
```
ip nhrp map 192.168.100.11 172.16.11.1       ! overlay → underlay
ip nhrp map multicast 172.16.11.1
ip nhrp nhs 192.168.100.11
```

## Timers
```
ip nhrp registration timeout 100
ip nhrp holdtime 300                         ! usually ≈ 3 × registration timeout
```

## Verification
```
show dmvpn
show ip nhrp
show ip nhrp brief
show ip nhrp 192.168.100.31
show ip route nhrp                           ! H = NHRP route, % = next-hop override
show ip route next-hop-override
```

## Protect DMVPN with IPsec (IKEv2)
```
crypto ikev2 keyring KR
 peer ANY
  address 0.0.0.0 0.0.0.0
  pre-shared-key MySharedKey
crypto ikev2 profile IKEV2-PROF
 match identity remote address 0.0.0.0
 authentication remote pre-share
 authentication local pre-share
 keyring local KR
!
crypto ipsec transform-set TS esp-aes 256 esp-sha-hmac
 mode transport
crypto ipsec profile IPSEC-PROF
 set transform-set TS
 set ikev2-profile IKEV2-PROF
!
interface tunnel 1
 tunnel protection ipsec profile IPSEC-PROF
```
Tuning
```
crypto ipsec security-association replay window-size 1024   ! all routers; anti-replay
crypto isakmp nat keepalive 20                              ! spokes behind NAT
crypto ikev2 dpd 40 5 on-demand                             ! dead-peer detection, on spokes
show crypto ipsec transform-set
show crypto ipsec profile
show crypto ikev2 stats
show crypto ikev2 sa
```
Replace the example pre-shared keys with strong secrets and keep them out of the repo.
