.PHONY: up down deploy

up:
	kind create cluster
helm-repos:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add stable https://kubernetes-charts.storage.googleapis.com/
	helm repo update
helm-install: support-install helm-repos
	helm install ms stable/metrics-server -n kube-system --set=args={--kubelet-insecure-tls}
	helm install prom prometheus-community/kube-prometheus-stack -n kube-system
support-install:
	kubectl --namespace monitoring create secret generic grafana-secret \
	--from-literal=admin-user=admin --from-literal=admin-password=admin || true
	kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
down:
	kind delete cluster
