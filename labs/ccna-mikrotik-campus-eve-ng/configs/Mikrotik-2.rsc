# ======================================================================
# Device : Mikrotik-2   (RouterOS 7)
# Role   : Middle router. LAN block B, link to Mikrotik-1 (north) and vIOS3 (south)
# Load   : paste in the terminal, or upload and run:  /import file-name=Mikrotik-2.rsc
# ======================================================================
/system identity
set name=Mikrotik-2

# ---- Interfaces: friendly names ---------------------------------------
/interface ethernet
set [ find default-name=ether1 ] name=ether1-lan-router1
set [ find default-name=ether2 ] name=ether2-lan-router3
set [ find default-name=ether4 ] name=ether4-lan
set [ find default-name=ether5 ] name=ether5-lan
set [ find default-name=ether6 ] name=ether6-lan

# ---- Bridge for the block B hosts -------------------------------------
/interface bridge
add name=bridge1
/interface bridge port
add bridge=bridge1 interface=ether4-lan
add bridge=bridge1 interface=ether5-lan
add bridge=bridge1 interface=ether6-lan

# ---- Addresses --------------------------------------------------------
/ip address
add address=10.16.12.2/24 interface=ether1-lan-router1 network=10.16.12.0
add address=10.16.23.1/24 interface=ether2-lan-router3 network=10.16.23.0
add address=172.20.16.65/26 interface=bridge1 network=172.20.16.64

# ---- DHCP server for block B (172.20.16.64/26) ------------------------
/ip pool
add name=dhcp_pool0 ranges=172.20.16.66-172.20.16.126
/ip dhcp-server
add address-pool=dhcp_pool0 interface=bridge1 name=dhcp1
/ip dhcp-server network
add address=172.20.16.64/26 dns-server=8.8.8.8 gateway=172.20.16.65

# ---- Static routes ----------------------------------------------------
/ip route
add dst-address=0.0.0.0/0 gateway=10.16.12.1 comment="Default via Mikrotik-1"
add dst-address=172.20.16.128/26 gateway=10.16.23.2 comment="Block C"
add dst-address=172.20.16.192/26 gateway=10.16.23.2 comment="Block D"
add dst-address=10.16.34.0/24 gateway=10.16.23.2 comment="Link vIOS3-vIOS4"

# ---- RoMON ------------------------------------------------------------
/tool romon
set enabled=yes
