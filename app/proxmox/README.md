# Proxmox
```bash
crontab -e

0 */1 * * * bash /opt/clear_memory_cache.sh
*/1 * * * * bash /opt/add_qemu_etcd.sh
*/1 * * * * bash /opt/add_lxc_etcd.sh
```
