# kubernetes-cluster-helmfile

A basic cluster with observability using helmfile

Deploys the following into the cluster with auto wiring

```bash
NAME         	NAMESPACE 	REVISION	UPDATED                             	STATUS  	CHART                 	APP VERSION
elasticsearch	monitoring	2       	2019-12-13 10:32:03.630534 +0000 UTC	deployed	elasticsearch-1.32.1  	6.8.2
envoy        	default   	3       	2019-12-13 10:32:11.392911 +0000 UTC	deployed	envoy-1.9.0           	1.11.2
grafana      	monitoring	3       	2019-12-13 10:31:54.381254 +0000 UTC	deployed	grafana-4.1.3         	6.5.0
grafana-db   	monitoring	3       	2019-12-13 10:31:54.311212 +0000 UTC	deployed	mysql-1.6.1           	5.7.27
jaeger       	monitoring	2       	2019-12-13 10:32:07.08748 +0000 UTC 	deployed	jaeger-operator-2.12.1	1.15.1
prometheus   	monitoring	3       	2019-12-13 10:31:47.864919 +0000 UTC	deployed	prometheus-9.5.2      	2.13.1
weave-scope  	monitoring	3       	2019-12-13 10:31:59.332558 +0000 UTC	deployed	weave-scope-1.1.8     	1.12.0
```

![](images/grafana.png)


![](images/weavescope.png)

## Requirements

- Kubernetes cluster connected via Kubectl
  _I'd recommend GKE 3 x N1-standard-2 at least.._
  ```bash
  gke-standard-cluster-2-default-pool-29c1081e-2tsk   291m         15%    4156Mi          73%
  gke-standard-cluster-2-default-pool-29c1081e-4dhq   301m         15%    3467Mi          61%
  gke-standard-cluster-2-default-pool-29c1081e-vd3n   413m         21%    2940Mi          52%
  ```
- Helm ^3.0.0
- Helmfile

## Install

_Generate a grafana password_

```bash
kubectl create ns monitoring || true;
kubectl create ns monitoring || true;

kubectl --namespace monitoring create secret generic grafana-secret \
--from-literal=admin-user=admin --from-literal=admin-password=admin
```

`helmfile sync`


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

_Create an index_

```bash
kubectl exec $(kubectl get pod -l app=elasticsearch -l"component=client" -n monitoring  -o jsonpath="{.items[0].metadata.name}") -n monitoring -- curl -XPUT 'localhost:9200/twitter?pretty' -H 'Content-Type: application/json' -d'{"settings" : {"index" : {"number_of_shards" : 3, "number_of_replicas" : 0 }}}'
```

_Let's make the virtual services_

```bash
cat <<EOF | kubectl apply -f -
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  name: grafana-vs
  namespace: gloo-system
spec:
  virtualHost:
    domains:
    - '*'
    routes:
    - matchers:
      - prefix: /
      routeAction:
        single:
          upstream:
            name: monitoring-grafana-3000
            namespace: gloo-system
EOF    
```

```bash
glooctl get virtualservices                                                          
+-----------------+--------------+---------+------+----------+-----------------+-------------------------------------+
| VIRTUAL SERVICE | DISPLAY NAME | DOMAINS | SSL  |  STATUS  | LISTENERPLUGINS |               ROUTES                |
+-----------------+--------------+---------+------+----------+-----------------+-------------------------------------+
| grafana-vs      |              | *       | none | Accepted |                 | / ->                                |
|                 |              |         |      |          |                 | gloo-system.monitoring-grafana-3000 |
|                 |              |         |      |          |                 | (upstream)                          |
+-----------------+--------------+---------+------+----------+-----------------+-------------------------------------+

```

Test access via...

```bash
curl $(glooctl proxy url)                                                              
<a href="/login">Found</a>.
```

Tada!
