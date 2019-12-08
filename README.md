# kubernetes-cluster-helmfile

A basic cluster with observability using helmfile

Deploys the following into the cluster with auto wiring
- prometheus
- Node exporter
- Grafana
- Weavescope


![](images/grafana.png)


![](images/weavescope.png)

## Requirements

- Kubernetes cluster connected via Kubectl
- Helm ^3.0.0
- Helmfile

## Install

_Generate a grafana password_

```
kubectl create ns monitoring || true;

kubectl --namespace monitoring create secret generic grafana-secret \
--from-literal=admin-user=admin --from-literal=admin-password=admin
```


`helmfile sync`
