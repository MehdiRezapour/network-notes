# ENARSI 05 – VRF-Lite

```
vrf definition RED
 address-family ipv4 unicast
vrf definition GREEN
 address-family ipv4 unicast
vrf definition BLUE
 address-family ipv4 unicast
!
interface g0/1
 vrf forwarding RED
 ip address 10.0.1.1 255.255.255.0      ! the IP is wiped when the VRF is applied – re-enter it
interface g0/0.2
 encapsulation dot1q 2
 vrf forwarding GREEN
 ip address 10.0.2.1 255.255.255.0
```
Routing inside a VRF
```
ip route vrf RED 0.0.0.0 0.0.0.0 10.0.1.254
router eigrp TEST
 address-family ipv4 vrf RED autonomous-system 10
  network 10.0.1.1 0.0.0.0
router ospf 1 vrf RED
router ospfv3 1
 address-family ipv4 unicast vrf RED
 address-family ipv6 unicast vrf RED
router bgp 6500
 no bgp default ipv4-unicast
 address-family ipv4 vrf RED
```
Verification – always name the VRF
```
show vrf
show vrf detail RED
show ip route vrf RED
show ip eigrp vrf RED neighbors
show ip eigrp vrf RED topology all-links
show ospfv3 vrf RED interface brief
ping vrf BLUE 192.168.1.1
```
