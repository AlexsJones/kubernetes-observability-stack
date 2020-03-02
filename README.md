# kubernetes-observability-stack

Here is a [helmfile](https://github.com/roboll/helmfile) recipe for creating a cluster with a basic level of observability.

Deploys the following into the cluster with auto wiring

```bash
NAME                  	NAMESPACE 	REVISION	UPDATED                                	STATUS  	CHART                 	APP VERSION
elasticsearch-operator	monitoring	1       	2020-03-01 21:16:20.53616681 +0000 UTC 	deployed	elasticsearch-7.6.0   	7.6.0      
fluent                	monitoring	1       	2020-03-01 21:30:27.688215501 +0000 UTC	deployed	fluentd-2.3.3         	v2.4.0     	1.3.7      
grafana               	monitoring	3       	2020-03-01 21:40:53.021552724 +0000 UTC	deployed	grafana-5.0.3         	6.6.2      
jaeger                	monitoring	3       	2020-03-01 21:40:49.493019061 +0000 UTC	deployed	jaeger-operator-2.12.1	1.15.1     
kibana                	monitoring	4       	2020-03-01 21:40:29.372724259 +0000 UTC	deployed	kibana-7.6.0          	7.6.0      
prometheus            	monitoring	3       	2020-03-01 21:40:46.123752464 +0000 UTC	deployed	prometheus-10.6.0     	2.16.0  
```

![](images/grafana.png)


![](images/weavescope.png)

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


### Bonus

_Deploy a Jaeger operator for the local ES cluster_

```bash
kubectl apply -n monitoring -f - << EOF
apiVersion: jaegertracing.io/v1
kind: Jaeger
metadata:
  name: elasticsearch-operator
spec:
  strategy: production
  storage:
    type: elasticsearch
    options:
      es:
        server-urls: http://elasticsearch-client:9200
EOF
```
