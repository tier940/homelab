# Kubernetes Controllers
%{ for name, ips in controllers }${name}.${base_domain} ${ips.ipv4} %{ if ips.ipv6 != null }${ips.ipv6}%{ endif }
%{ endfor }
# Kubernetes Workers
%{ for name, ips in workers }${name}.${base_domain} ${ips.ipv4} %{ if ips.ipv6 != null }${ips.ipv6}%{ endif }
%{ endfor }
