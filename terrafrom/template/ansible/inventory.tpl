---
all:
  hosts:%{ for name, ips in clusters }
    ${name}.${k8s_domain}:
      ansible_host: ${ips.ipv4}%{ if ips.ipv6 != null }
      ansible_host_ipv6: ${ips.ipv6}%{ endif }%{ endfor }%{ for name, ips in workers }
    ${name}.${k8s_domain}:
      ansible_host: ${ips.ipv4}%{ if ips.ipv6 != null }
      ansible_host_ipv6: ${ips.ipv6}%{ endif }%{ endfor }%{ for name, ips in basic_vms }
    ${name}.${base_domain}:
      ansible_host: ${ips.ipv4}%{ if ips.ipv6 != null }
      ansible_host_ipv6: ${ips.ipv6}%{ endif }%{ endfor }
  children:
    ${tags.env}:
      hosts:%{ for name, ips in clusters }
        ${name}.${k8s_domain}:%{ endfor }%{ for name, ips in workers }
        ${name}.${k8s_domain}:%{ endfor }%{ for name, ips in basic_vms }
        ${name}.${base_domain}:%{ endfor }
    cluster:
      hosts:%{ for name, ips in clusters }
        ${name}.${k8s_domain}:%{ endfor }
    worker:
      hosts:%{ for name, ips in workers }
        ${name}.${k8s_domain}:%{ endfor }
  vars:
    ansible_user: fedora
    ansible_ssh_private_key_file: roles/01-os-init/files/keys/k8s_homelab_ed25519
    ansible_python_interpreter: /usr/bin/python3
