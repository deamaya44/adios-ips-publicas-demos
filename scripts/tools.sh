#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"
CRDS=https://raw.githubusercontent.com/cloudflare/origin-ca-issuer/v0.15.0/deploy/crds
GATEWAY_API="https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.8.0"
NGF_CRDS=https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.8.0/deploy/crds.yaml

netbird_up() {
  requiere INTERNAL_DOMAIN
  demo base true
  k apply -f "$K8S/netbird/01-routing-peer.yaml"
  tf output -raw routers_setup_key | secret netbird netbird-setup-key key
  k -n netbird rollout restart statefulset/routing-peer
  k -n netbird rollout status statefulset/routing-peer
}

up() {
  k apply --server-side -k "$GATEWAY_API"
  helm --kube-context "$KUBE_CONTEXT" upgrade --install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric \
    --version 2.8.0 -n nginx-gateway --create-namespace -f "$K8S/gateway/00-nginx-gateway-values.yaml" --wait
  dominios "$K8S/gateway/01-gateway.yaml" | k apply -f -
  k -n nginx-gateway wait gateway/entrada --for=condition=Programmed --timeout=180s
  helm --kube-context "$KUBE_CONTEXT" upgrade --install cert-manager oci://quay.io/jetstack/charts/cert-manager \
    --version v1.21.2 -n cert-manager --create-namespace -f "$K8S/certificados/00-cert-manager-values.yaml" --wait
  k apply -f "$CRDS/cert-manager.k8s.cloudflare.com_clusteroriginissuers.yaml" \
    -f "$CRDS/cert-manager.k8s.cloudflare.com_originissuers.yaml"
  helm --kube-context "$KUBE_CONTEXT" upgrade --install origin-ca-issuer \
    oci://ghcr.io/cloudflare/origin-ca-issuer-charts/origin-ca-issuer --version 0.6.9 \
    -n origin-ca-issuer --create-namespace --wait
  if [[ -n ${NB_PAT:-} ]]; then netbird_up; else echo "sin NB_PAT: se omite NetBird, que usan la demo 2 y el caso B del extra"; fi
}

down() {
  "$ROOT/scripts/extra-certificados.sh" down
  "$ROOT/scripts/demo-2-malla.sh" down
  "$ROOT/scripts/demo-1-tunel.sh" down
  salir
  k delete namespace netbird --ignore-not-found
  demo base false
  helm --kube-context "$KUBE_CONTEXT" uninstall origin-ca-issuer -n origin-ca-issuer --ignore-not-found --wait
  k delete --ignore-not-found -f "$CRDS/cert-manager.k8s.cloudflare.com_clusteroriginissuers.yaml" \
    -f "$CRDS/cert-manager.k8s.cloudflare.com_originissuers.yaml"
  helm --kube-context "$KUBE_CONTEXT" uninstall cert-manager -n cert-manager --ignore-not-found --wait
  k delete crd -l app.kubernetes.io/instance=cert-manager --ignore-not-found
  k delete --ignore-not-found -f "$K8S/gateway/01-gateway.yaml" --wait
  helm --kube-context "$KUBE_CONTEXT" uninstall ngf -n nginx-gateway --ignore-not-found --wait
  k delete --ignore-not-found -f "$NGF_CRDS"
  k delete --ignore-not-found -k "$GATEWAY_API"
  k delete namespace cert-manager origin-ca-issuer nginx-gateway --ignore-not-found
}

case "${1:-}" in up | laptop | down) "$1" ;; *) echo "uso: $0 up|laptop|down" && exit 1 ;; esac
