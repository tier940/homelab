# Default hosts
127.0.0.1 localhost.localdomain localhost
127.0.0.1 localhost4.localdomain4 localhost4
::1 localhost.localdomain localhost
::1 localhost6.localdomain6 localhost6

# Kubernetes Control Plain
%{ for name, ips in clusters }${ips.ipv4} ${name}.${k8s_domain}%{ if ips.ipv6 != null }${ips.ipv6} ${name}.${k8s_domain}%{ endif }
%{ endfor }
# Kubernetes Workers
%{ for name, ips in workers }${ips.ipv4} ${name}.${k8s_domain}%{ if ips.ipv6 != null }${ips.ipv6} ${name}.${k8s_domain}%{ endif }
%{ endfor }
# Other VMs
%{ for name, ips in basic_vms }${ips.ipv4} ${name}.${base_domain}%{ if ips.ipv6 != null }${ips.ipv6} ${name}.${base_domain}%{ endif }
%{ endfor }