.PHONY: up down deploy

up:
	kind create cluster
deploy:
	kubectl create ns monitoring || true
	kubectl --namespace monitoring create secret generic grafana-secret \
	--from-literal=admin-user=admin --from-literal=admin-password=admin || true
	kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
	helmfile --log-level=debug --file=releases/cluster.yaml sync
	kubectl wait --for=condition=ready --timeout=300s pods/elasticsearch-master-2 -n monitoring
down:
	kind delete cluster
