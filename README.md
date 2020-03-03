# kubernetes-observability-stack

Here is a [helmfile](https://github.com/roboll/helmfile) recipe for creating a cluster with a basic level of observability.

Deploys the following into the cluster with auto wiring:
- Elasticsearch-operator
- Jaeger-operator
- Prometheus-operator
- Weavescope
- Fluent-bit
- Kibana
- Grafana

![](images/grafana.png)


![](images/weavescope.png)


![](images/kibana.png)

## Requirements

- Kind
- Kubectl
- Helm ^3.0.0
- Helmfile

## Install


```bash
make up
make deploy
```


## Delete cluster

```bash
make down
```

