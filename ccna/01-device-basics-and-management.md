# CCNA 01 – Device Basics & Management

## CLI modes
```
Switch>            ! user EXEC
Switch> enable
Switch#            ! privileged EXEC
Switch# configure terminal
Switch(config)#    ! global config
Switch(config-if)# ! interface config
```

## Essential show commands
```
show version
show clock
show ip protocols
show ip interface brief
show arp
show mac address-table
show startup-config
show running-config
show flash:
show access-lists
show cdp neighbors detail
show lldp neighbors detail
show interfaces fastethernet 0/1
show interfaces gigabitethernet 0/0/0
```
Output filters: `show run | begin line`, `show run | section ip route`, `show run | include dhcp`.

## Save / erase / reload
```
copy running-config startup-config     ! or: write memory
write erase                            ! or: erase startup-config
reload
```

## Basic interface setup
```
hostname R1
interface gigabitethernet 0/0/0
 description Link to S1
 ip address 192.168.1.1 255.255.255.0
 no shutdown
!
interface range gigabitethernet 0/0/0 - 3        ! range of ports
interface range fastethernet 0/1 - 5 , fastethernet 0/10
!
! Switch management SVI
interface vlan 1
 ip address 192.168.1.2 255.255.255.0
 no shutdown
ip default-gateway 192.168.1.1
!
interface gigabitethernet 0/0/0
 media-type sfp
 speed 100
 duplex half        ! only if you must override auto-negotiation
```

## CDP / LLDP
```
no cdp run                  ! disable globally
interface range gi0/0/0 - 3
 no cdp enable              ! disable per interface
lldp run
interface gi0/0/0
 lldp transmit
 lldp receive
```
Tip: use `do show ip interface brief` to run an EXEC command from config mode.

## Console / VTY access & passwords
```
! Local users (preferred over line passwords)
username admin secret StrongPass1
enable secret StrongPass2
service password-encryption          ! weak (type 7) obfuscation of plain passwords

line console 0
 login local
 exec-timeout 10 0                   ! idle timeout: 10 minutes
 logging synchronous                 ! stops log messages from breaking what you type

line vty 0 15
 login local
 transport input ssh                 ! none | telnet | ssh | all
 transport output none
 access-class 1 in                   ! restrict who can connect (standard ACL)
!
access-list 1 permit host 192.168.1.11
```
- `secret` is hashed; `password` is stored in clear text (or weakly encrypted type 7).
- Never use `username X password ...` in production.
- Privilege levels: `username admin privilege 1 secret ...` and `privilege exec level 5 show running-config`.
- Name resolution: `ip name-server 192.168.1.3`, `ip domain-lookup`.

## SSH
```
hostname R1
ip domain-name test.local
crypto key generate rsa modulus 2048     ! use >= 2048 (768/1024 are weak)
ip ssh version 2
username admin secret StrongPass1
line vty 0 15
 login local
 transport input ssh
```
Client side: `ssh -l admin 192.168.1.1`.

## AAA with RADIUS (local fallback)
```
aaa new-model
radius server MYRADIUS
 address ipv4 192.168.1.2
 key MyRadiusKey
aaa authentication login REMOTE group radius local
aaa authentication enable default group radius enable
line vty 0 15
 login authentication REMOTE
```

## Banners
```
banner motd #Authorized access only!#
banner login #Warning: all activity is monitored.#
banner exec #Welcome#
```
Choose a delimiter character that does not appear in the message.

## NTP
```
ntp server 10.0.0.1       ! client
ntp master 3              ! make this device an authoritative source (lab use)
show ntp status
show ntp associations
```

## Password recovery
**Router**
1. Reboot and send a break (`Ctrl+Break` / `Ctrl+C`) to enter ROMMON.
2. `confreg 0x2142` (ignore startup-config) then `reset`/`boot`.
3. Skip the setup wizard, `enable`, then `copy startup-config running-config`.
4. Fix the password: `username admin secret NEW`, `enable secret NEW`.
5. `config-register 0x2102` then `copy running-config startup-config`.

**Switch**
1. Hold MODE button while powering on until the `switch:` prompt appears.
2. `flash_init`, `dir flash:`
3. `rename flash:config.text flash:config.text.old`, then `boot`.
4. After boot: `rename flash:config.text.old flash:config.text`, `copy flash:config.text running-config`, set new passwords, `write memory`.

Hardening:
```
no service password-recovery     ! recovery no longer possible (config is wiped if you break in)
secure boot-image                ! IOS image cannot be deleted
secure boot-config               ! archive of startup-config is protected
show secure bootset
```

## Backup & restore
```
copy running-config tftp:
copy startup-config tftp:
copy flash: tftp:                ! backup IOS
copy tftp: flash:                ! restore IOS
boot system flash:<image-name>
copy tftp: running-config
copy tftp: startup-config
```
