# ENCOR 07 – Time, Logging, SNMP, SPAN, EEM

## Clock & NTP
```
clock set 14:30:00 19 Nov 2026
clock timezone IRST 3 30              ! hours, minutes offset from UTC
clock summer-time <zone> recurring
show clock detail                     ! software clock
show calendar                         ! hardware clock
clock update-calendar                 ! software → hardware
clock read-calendar                   ! hardware → software
calendar set 14:30:00 19 November 2026
show ntp status
show ntp associations
```

## Syslog
```
show logging
terminal monitor
logging host 10.10.10.5
logging trap informational            ! or notifications, debugging …
```

## SNMP
```
snmp-server community TEST ro
snmp-server community TEST2 rw
snmp-server host 10.10.10.1 version 2c TEST
snmp-server enable traps config
! SNMPv3: priv = authentication + encryption
snmp-server group TESTGRP v3 priv
snmp-server user cisco TESTGRP v3 auth sha AuthPass123 priv aes 256 PrivPass123
show snmp user
show snmp mib
```

## SPAN / RSPAN
```
monitor session 1 source interface g0/0 rx        ! received traffic
monitor session 1 source interface g0/0 tx        ! transmitted traffic
monitor session 1 source interface g0/0 both
monitor session 1 source vlan 10                  ! interface, vlan, or remote
monitor session 1 destination interface g0/1      ! analyzer port
show monitor session 1
no monitor session all
```
**RSPAN (across switches)**
```
vlan 99
 remote-span
! source switch
monitor session 1 source interface g0/1
monitor session 1 destination remote vlan 99
! destination switch
monitor session 1 source remote vlan 99
monitor session 1 destination interface g0/5
```

## EEM (Embedded Event Manager)
```
event manager applet AUTO-NOSHUT
 event syslog pattern "Interface GigabitEthernet0/0, changed state to administratively down" period 1
 action 1.0 cli command "enable"
 action 1.1 cli command "configure terminal"
 action 1.2 cli command "interface gigabitethernet 0/0"
 action 1.3 cli command "no shutdown"
 action 1.4 syslog msg "Interface brought up by EEM"
event manager applet TRACK-DOWN
 event track 100 state down
 action 2.0 cli command "enable"
 action 2.1 cli command "configure terminal"
 action 2.2 cli command "interface gigabitethernet 0/1"
 action 2.3 cli command "no shutdown"
```

## Config archive
```
archive
 path tftp://192.168.150.1/$h-$t
 write-memory                      ! archive on every "write memory"
```

## Windows helper
`copy /b file1+file2 output` joins binary files (e.g. split IOS images).
