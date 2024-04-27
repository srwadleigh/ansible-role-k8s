# ansible-roles-k8s

 - https://docs.k3s.io/
 - https://docs.rke2.io/
 - https://kube-vip.io/
 - https://github.com/sbstp/kubie
 - https://kubernetes.io/docs/tasks/tools/

## Requirements

Install `yq` on the local system, this is required for the kubectl formatting handler which places an updated kubeconfig in the local ~/.kube

Recommended `kubie` for context management after deployment

## Cluster Example

cluster hosts

```
[k8s_somecluster]
somecluster_control k8s_node_type=bootstrap
somecluster_agent_smith k8s_node_type=agent k8s_external_ip=x.x.x.x
somecluster_agent_jones k8s_node_type=agent k8s_external_ip=x.x.x.x
```

cluster tasks

```
- name: Setup k8s server node
  hosts: somehost
  become: true
  roles:
    - role: k8s
      k8s_type: rke2
      k8s_cluster_name: somecluster
      k8s_cluster_url: somecluster.somewhere
      k8s_cni_interface: enp1s0
      k8s_selinux: true

    - role: firewalld
      firewalld_add:
        - name: internal
          interfaces:
            - enp1s0
          masquerade: true
          forward: true
          interfaces:
            - enp1s0
          services:
            - dhcpv6-client
            - ssh
            - http
            - https
          ports:
            - 6443/tcp        # kubernetes API
            - 9345/tcp        # supervisor API
            - 10250/tcp       # kubelet metrics
            - 2379/tcp        # etcd client
            - 2380/tcp        # etcd peer
            - 30000-32767/tcp # NodePort range
            - 8472/udp        # canal/flannel vxlan
            - 9099/tcp        # canal health checks
                    
        - name: trusted
          sources:
            - 10.42.0.0/16
            - 10.43.0.0/16

        - name: public
          masquerade: true
          forward: true
          interfaces:
            - enp7s0
          services:
            - http
            - https

      firewalld_remove:
        - name: public
          interfaces:
            - enp1s0
          services:
            - dhcpv6-client
            - ssh
```

## Retrieve kube config from an existing cluster

This task will retrieve and format the kubectl config for an existing cluster, this runs automatically during cluster creation.

`k8s_cluster_name` sets the cluster context
`k8s_cluster_url` sets the server address

```
ansible-playbook -i prod/ site.yml --tags=k8s-get-config --limit=k8s_somecluster
```

## Basic Cluster Interaction

```
kubie ctx <cluster-name>
kubectl get node -o wide
kubectl get pods,svc,ds --all-namespaces
```

## Deployment and Removal

Deploy

```
ansible-playbook -i hosts site.yml --tags=firewalld,k8s --limit=somehost
```

Remove firewall role

```
ansible-playbook -i hosts site.yml --tags=firewalld,k8s --extra-vars "firewall_action=remove" --limit=somehost
```

There is a task to completely destroy an existing cluster, this will ask for interactive user confirmation and should be used with caution.

```
ansible-playbook -i prod/ site.yml --tags=k8s --extra-vars 'k8s_action=destroy' --limit=some_innocent_cluster
```

Manual removal commands

```
/usr/local/bin/k3s-uninstall.sh
/usr/local/bin/k3s-agent-uninstall.sh

/usr/local/bin/rke2-uninstall.sh
/usr/local/bin/rke2-agent-uninstall.sh
```

## Managing K3S Services

servers

```
systemctl status k3s.service
journalctl -u k3s.service -f
```

agents

```
systemctl status k3s-agent.service
journalctl -u k3s-agent -f
```

uninstall servers

```
/usr/local/bin/k3s-uninstall.sh
```

uninstall agents

```
/usr/local/bin/k3s-agent-uninstall.sh
```

## Managing RKE2 Services

servers

```
systemctl status rke2-server.service
journalctl -u rke2-server -f
```

agents

```
systemctl status rke2-agent.service
journalctl -u rke2-agent -f
```

uninstall servers

```
/usr/bin/rke2-uninstall.sh
```

uninstall agents

```
/usr/local/bin/rke2-uninstall.sh
```


override default cannal options

```
# /var/lib/rancher/rke2/server/manifests/rke2-canal-config.yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-canal
  namespace: kube-system
spec:
  valuesContent: |-
    flannel:
      iface: "eth1"
```

Enable flannels wireguard support under canal

`kubectl rollout restart ds rke2-canal -n kube-system`

```
# /var/lib/rancher/rke2/server/manifests/rke2-canal-config.yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-canal
  namespace: kube-system
spec:
  valuesContent: |-
    flannel:
      backend: "wireguard"
```
