# ENCOR 06 – GRE & IPsec

## GRE tunnel
```
interface tunnel 1
 ip address 10.10.10.1 255.255.255.0
 tunnel source gigabitethernet 0/0
 tunnel destination 100.100.34.2
 keepalive 30 3                 ! probe every 30 s, down after 3 misses
 ip mtu 1400                    ! leave room for GRE (+IPsec) overhead
 ip tcp adjust-mss 1360         ! MTU - 40 bytes; avoids fragmentation of TCP
```
MSS = the Maximum Segment Size of the TCP payload; the router rewrites it in TCP SYNs.

## IPsec concepts
- **IKE phase 1 (ISAKMP):** peers authenticate and build a secure channel.
- **IKE phase 2 (IPsec):** negotiates the data-plane SA.
- **ESP** = encryption + authentication; **AH** = authentication only (no encryption).
- **HMAC** = hash combined with a secret key (integrity + authenticity).
- **Anti-replay** protects against captured packets being resent.

## GRE over IPsec with an IPsec profile (IKEv1)
```
crypto isakmp policy 1
 encryption aes 256
 authentication pre-share
 group 5
crypto isakmp key MySharedKey address 100.100.34.2    ! peer's underlay (tunnel destination) IP
!
crypto ipsec transform-set TS esp-aes 256 esp-sha-hmac
 mode transport                                       ! GRE already provides the outer header
crypto ipsec profile IPSEC-PROF
 set transform-set TS
!
interface tunnel 1
 tunnel protection ipsec profile IPSEC-PROF
```
IPsec VTI alternative: `tunnel mode ipsec ipv4` on the tunnel and `mode tunnel` in the transform-set.

## Classic crypto map (site-to-site)
```
access-list 100 permit ip 192.168.1.0 0.0.0.255 192.168.2.0 0.0.0.255   ! interesting traffic
crypto map CMAP 10 ipsec-isakmp
 set peer 10.10.10.2
 set transform-set TS
 match address 100
interface g0/1
 crypto map CMAP
```
```
show crypto isakmp policy
show crypto isakmp sa
show crypto ipsec transform-set
show crypto ipsec sa
```
