# kubernetes-observability-stack

This repository deploys some simple but useful observability systems into a cluster.
It uses helm3 for Kubernetes manifest package management.

Deploys the following into the cluster with auto wiring:
- Metrics-server
- Elasticsearch-operator
- Jaeger-operator
- Prometheus-operator
- Weavescope
- Fluent-bit
- Kibana
- Grafana

## Requirements

- Kind
- Kubectl
- Helm ^3.0.0

## Install


```bash
make up
make helm-install
```


## Delete cluster

```bash
make down
```

## Pretty pictures
