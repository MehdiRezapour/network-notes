# ======================================================================
# OPTIONAL - Internet access for the whole lab
# The original configs had no NAT and no DNS, so the lab could not reach the Net cloud.
# Run on Mikrotik-1 after Mikrotik-1.rsc.
# ======================================================================
/ip dns
set allow-remote-requests=yes servers=8.8.8.8
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1-wan comment="LAB NAT to Net"
