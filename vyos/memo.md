```bash
set service ssh port '22'
set service ssh listen-address '0.0.0.0'

set interfaces ethernet eth0 address '192.168.0.10/24'
set interfaces ethernet eth0 address 'dhcpv6'
set interfaces ethernet eth0 duplex 'auto'
set interfaces ethernet eth0 speed 'auto'
set interfaces ethernet eth0 ipv6 address 'autoconf'
set interfaces ethernet eth0 description 'WAN'
set interfaces ethernet eth1 address '10.0.0.1/8'
set interfaces ethernet eth1 duplex 'auto'
set interfaces ethernet eth1 speed 'auto'
set interfaces ethernet eth0 description 'LAN'

set service dhcp-server shared-network-name lan0 subnet 10.0.0.0/8 option default-router '10.0.0.1'
set service dhcp-server shared-network-name lan0 subnet 10.0.0.0/8 option name-server '10.0.0.1'
set service dhcp-server shared-network-name lan0 subnet 10.0.0.0/8 option ntp-server '10.0.0.1'
set service dhcp-server shared-network-name lan0 subnet 10.0.0.0/8 range 0 start '10.0.1.1'
set service dhcp-server shared-network-name lan0 subnet 10.0.0.0/8 range 0 stop '10.255.255.240'
set service dhcp-server shared-network-name lan0 subnet 10.0.0.0/8 lease '86400'
set service dhcp-server shared-network-name lan0 subnet 10.0.0.0/8 subnet-id '1'

set service dns forwarding cache-size '0'
set service dns forwarding listen-address '10.0.0.1'
set service dns forwarding allow-from '10.0.0.0/8'
set service dns forwarding system

set protocols rip interface eth0
set protocols rip interface eth1
set protocols rip redistribute connected

set system time-zone 'Asia/Tokyo'
set system name-server '1.1.1.1'
set system name-server '1.0.0.1'
set system name-server '2606:4700:4700::1111'
set system name-server '2606:4700:4700::1001'

set nat source rule 1 outbound-interface name 'eth0'
set nat source rule 1 source address '0.0.0.0/0'
set nat source rule 1 translation address masquerade

set service snmp community public network 10.0.0.0/8
```
