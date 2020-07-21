# Running a MicroK8s cluster in lxd containers

LXD setup (required):
https://linuxcontainers.org/lxd/getting-started-cli/

```bash
# setup LXD profile for MicroK8s, containers and install MicroK8s inside them
local$ ansible-playbook site.yml

# verify
local$ lxc profile list
+----------+---------+
|   NAME   | USED BY |
+----------+---------+
| default  | 3       |
+----------+---------+
| microk8s | 3       |
+----------+---------+

local$ lxc list
+------+---------+-----------------------+------+-----------+-----------+
| NAME |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
+------+---------+-----------------------+------+-----------+-----------+
| n1   | RUNNING | 10.37.17.100 (eth0)   |      | CONTAINER | 0         |
|      |         | 10.1.51.1 (cni0)      |      |           |           |
|      |         | 10.1.51.0 (flannel.1) |      |           |           |
+------+---------+-----------------------+------+-----------+-----------+
| n2   | RUNNING | 10.37.17.101 (eth0)   |      | CONTAINER | 0         |
|      |         | 10.1.90.1 (cni0)      |      |           |           |
|      |         | 10.1.90.0 (flannel.1) |      |           |           |
+------+---------+-----------------------+------+-----------+-----------+
| n3   | RUNNING | 10.37.17.102 (eth0)   |      | CONTAINER | 0         |
|      |         | 10.1.98.1 (cni0)      |      |           |           |
|      |         | 10.1.98.0 (flannel.1) |      |           |           |
+------+---------+-----------------------+------+-----------+-----------+

# setup MicroK8s cluster
local$ lxc exec n1 -- microk8s add-node
Join node with: microk8s join 10.37.17.100:25000/XXX [...]
local$ lxc exec n2 -- microk8s join 10.37.17.100:25000/XXX
local$ lxc exec n1 -- microk8s add-node
local$ lxc exec n3 -- microk8s join 10.37.17.100:25000/XXX

# running `kubectl get nodes` / list K8s nodes
local$ lxc exec n1 -- k get nodes -owide
NAME   STATUS   ROLES    AGE     VERSION                    INTERNAL-IP    EXTERNAL-IP   OS-IMAGE           KERNEL-VERSION       CONTAINER-RUNTIME
n1     Ready    <none>   12m     v1.18.4-1+6f17be3f1fd54a   10.37.17.100   <none>        Ubuntu 20.04 LTS   4.15.0-112-generic   containerd://1.3.4
n2     Ready    <none>   7m28s   v1.18.4-1+6f17be3f1fd54a   10.37.17.101   <none>        Ubuntu 20.04 LTS   4.15.0-112-generic   containerd://1.3.4
n3     Ready    <none>   6m12s   v1.18.4-1+6f17be3f1fd54a   10.37.17.102   <none>        Ubuntu 20.04 LTS   4.15.0-112-generic   containerd://1.3.4

# clean up
local$ ansible-playbook 99-clean-lxd.yml
```
