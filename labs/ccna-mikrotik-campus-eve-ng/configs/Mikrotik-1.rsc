# ======================================================================
# Device : Mikrotik-1   (RouterOS 7)
# Role   : Edge router. WAN on ether1 (Net cloud), LAN block A, link to Mikrotik-2
# Load   : paste in the terminal, or upload and run:  /import file-name=Mikrotik-1.rsc
# ======================================================================
/system identity
set name=Mikrotik-1

# ---- Interfaces: friendly names ---------------------------------------
/interface ethernet
set [ find default-name=ether1 ] name=ether1-wan
set [ find default-name=ether2 ] name=ether2-lan-router2
set [ find default-name=ether3 ] name=ether3-lan
set [ find default-name=ether4 ] name=ether4-lan
set [ find default-name=ether5 ] name=ether5-lan

# ---- Bridge for the block A hosts (ether3-ether5, ether6 spare) -------
/interface bridge
add name=bridge1
/interface bridge port
add bridge=bridge1 interface=ether3-lan
add bridge=bridge1 interface=ether4-lan
add bridge=bridge1 interface=ether5-lan
add bridge=bridge1 interface=ether6

# ---- Addresses --------------------------------------------------------
/ip address
add address=172.20.16.1/26 interface=bridge1 network=172.20.16.0
add address=10.16.12.1/24 interface=ether2-lan-router2 network=10.16.12.0

# ---- DHCP server for block A (172.20.16.0/26) -------------------------
/ip pool
add name=dhcp_pool0 ranges=172.20.16.2-172.20.16.62
/ip dhcp-server
add address-pool=dhcp_pool0 interface=bridge1 name=dhcp1
/ip dhcp-server network
add address=172.20.16.0/26 dns-server=8.8.8.8 gateway=172.20.16.1

# ---- WAN: address and default route come from the Net cloud -----------
/ip dhcp-client
add interface=ether1-wan

# ---- Static routes to the other blocks (all via Mikrotik-2) -----------
/ip route
add dst-address=172.20.16.64/26 gateway=10.16.12.2 comment="Block B"
add dst-address=172.20.16.128/26 gateway=10.16.12.2 comment="Block C"
add dst-address=172.20.16.192/26 gateway=10.16.12.2 comment="Block D"
add dst-address=10.16.23.0/24 gateway=10.16.12.2 comment="Link M2-vIOS3"
add dst-address=10.16.34.0/24 gateway=10.16.12.2 comment="Link vIOS3-vIOS4"

# ---- RoMON (remote management between MikroTik devices) ---------------
/tool romon
set enabled=yes
