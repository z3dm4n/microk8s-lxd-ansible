# Running a MicroK8s cluster in lxd containers

LXD setup (required):
https://linuxcontainers.org/lxd/getting-started-cli/

```bash
# setup LXD profile for MicroK8s, containers and install MicroK8s inside them
localhost$ ansible-playbook site.yml

# verify
localhost$ lxc profile list
+----------+---------+
|   NAME   | USED BY |
+----------+---------+
| default  | 3       |
+----------+---------+
| microk8s | 3       |
+----------+---------+

localhost$ lxc list
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
localhost$ lxc exec n1 -- microk8s add-node
Join node with: microk8s join 10.37.17.100:25000/XXX [...]
localhost$ lxc exec n2 -- microk8s join 10.37.17.100:25000/XXX
localhost$ lxc exec n1 -- microk8s add-node
localhost$ lxc exec n3 -- microk8s join 10.37.17.100:25000/XXX

# list all MicroK8s nodes
localhost$ lxc exec n1 -- k get nodes -owide
NAME   STATUS   ROLES    AGE     VERSION                    INTERNAL-IP    EXTERNAL-IP   OS-IMAGE           KERNEL-VERSION       CONTAINER-RUNTIME
n1     Ready    <none>   12m     v1.18.4-1+6f17be3f1fd54a   10.37.17.100   <none>        Ubuntu 20.04 LTS   4.15.0-112-generic   containerd://1.3.4
n2     Ready    <none>   7m28s   v1.18.4-1+6f17be3f1fd54a   10.37.17.101   <none>        Ubuntu 20.04 LTS   4.15.0-112-generic   containerd://1.3.4
n3     Ready    <none>   6m12s   v1.18.4-1+6f17be3f1fd54a   10.37.17.102   <none>        Ubuntu 20.04 LTS   4.15.0-112-generic   containerd://1.3.4

# enable MetalLB loadbalancer
localhost$ lxc shell n1
n1$ echo "10.37.17.200-10.37.17.250" | microk8s.enable metallb

# create a simple demo deployment
localhost$ lxc exec n1 -- kubectl create deployment microbot --image=dontrebootme/microbot:v1
deployment.apps/microbot created
localhost$ lxc exec n1 -- kubectl scale deployment microbot --replicas=3
deployment.apps/microbot scaled
localhost$ lxc exec n1 -- kubectl expose deployment microbot --type=LoadBalancer --port=80 --name=microbot-service
service/microbot-service exposed
localhost$ lxc exec n1 -- kubectl get svc
NAME               TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)        AGE
kubernetes         ClusterIP      10.152.183.1     <none>         443/TCP        23m
microbot-service   LoadBalancer   10.152.183.213   10.37.17.200   80:31613/TCP   2m13s
localhost$ lxc exec n1 -- kubectl get pods -owide
NAME                        READY   STATUS    RESTARTS   AGE     IP          NODE   NOMINATED NODE   READINESS GATES
microbot-6d97548556-ck4pt   1/1     Running   0          2m34s   10.1.11.5   n3     <none>           <none>
microbot-6d97548556-g27v4   1/1     Running   0          2m50s   10.1.6.4    n2     <none>           <none>
microbot-6d97548556-mxnbl   1/1     Running   0          2m34s   10.1.11.4   n3     <none>           <none>

# verify
localhost$ curl -s http://10.37.17.200/

# clean up
localhost$ ansible-playbook 99-clean-lxd.yml
```
