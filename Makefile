.PHONY: up down deploy

up:
	kind create cluster --config=resources/cluster.yaml
helm-repos:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add stable https://kubernetes-charts.storage.googleapis.com/
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo add jetstack https://charts.jetstack.io
	helm repo update

install: support-install helm-repos helm-install install-certs

helm-install: 
	helm install ms stable/metrics-server -n kube-system --set=args={--kubelet-insecure-tls}
	helm install prom prometheus-community/kube-prometheus-stack -n kube-system
	helm install weave stable/weave-scope -n kube-system
	helm install cert-manager --namespace cert-manager --version v1.0.2 jetstack/cert-manager

support-install:
	kubectl create namespace cert-manager
	kubectl create namespace ingress-nginx
	kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.0.2/cert-manager.crds.yaml
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
	kubectl rollout status deployment ingress-nginx-controller -n ingress-nginx -w
	kubectl apply -f resources/ingress.yaml -n kube-system

get-grafana-pass:
	kubectl get secret --namespace kube-system prom-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

install-certs:
	kubectl rollout status deployment cert-manager-webhook -n cert-manager -w
	kubectl apply -f resources/issuer.yaml -n kube-system
	kubectl apply -f resources/local-certificate.yaml -n kube-system

down:
	kind delete cluster
