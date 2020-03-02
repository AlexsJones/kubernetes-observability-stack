.PHONY: up down deploy

up:
	kind create cluster
deploy:
	kubectl create ns monitoring || true
	kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
	kubectl --namespace monitoring create secret generic grafana-secret \
	--from-literal=admin-user=admin --from-literal=admin-password=admin || true
	kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml || true
	helmfile --log-level=debug --file=releases/cluster.yaml sync
	kubectl wait --for=condition=ready --timeout=300s pods/elasticsearch-master-2 -n monitoring
	kubectl exec $(kubectl get pod -l app=elasticsearch -l"app=elasticsearch-master" -n monitoring  -o jsonpath="{.items[0].metadata.name}") -n monitoring -- curl -XPUT 'localhost:9200/kubernetes_cluster?pretty' -H 'Content-Type: application/json' -d'{"settings" : {"index" : {"number_of_shards" : 3, "number_of_replicas" : 0 }}}'

down:
	kind delete cluster
