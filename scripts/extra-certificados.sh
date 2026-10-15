#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"
NS=demo-extra
T=adios-ips-extra
C="$K8S/certificados"

origin_ca() {
  requiere DEMO_HOSTNAME CERT_MANAGER_CLOUDFLARE_TOKEN
  requiere_gateway
  k apply -f "$C/01-namespace.yaml"
  printf %s "$CERT_MANAGER_CLOUDFLARE_TOKEN" | secret "$NS" cloudflare-origin-ca api-token
  k apply -f "$C/origin-ca/01-issuer.yaml"
  dominios "$C/origin-ca/02-certificado.yaml" | k apply -f -
  k -n "$NS" wait certificate/publico-tls --for=condition=Ready --timeout=180s
  en "$NS" "$K8S/tunel/01-app.yaml" | k apply -f -
  tunel_up "$T" "$EXTRA_HOSTNAME" "$NS"
  dominios "$C/origin-ca/03-conector.yaml" | k apply -f -
  k -n "$NS" rollout restart deploy/conector
}

letsencrypt() {
  requiere NB_PAT INTERNAL_DOMAIN POSTGRES_PASSWORD PGADMIN_PASSWORD CERT_MANAGER_CLOUDFLARE_TOKEN
  requiere_gateway
  requiere_netbird
  k apply -f "$C/01-namespace.yaml"
  printf %s "$CERT_MANAGER_CLOUDFLARE_TOKEN" | secret cert-manager cloudflare-api-token api-token
  k apply -f "$C/letsencrypt/01-issuer.yaml"
  dominios "$C/letsencrypt/02-certificado.yaml" |
    sed "s/name: letsencrypt-staging$/name: ${LE_ISSUER:-letsencrypt-staging}/" | k apply -f -
  printf %s "$POSTGRES_PASSWORD" | secret "$NS" postgres password
  k -n "$NS" get secret postgres-lector >/dev/null 2>&1 ||
    printf %s "$(openssl rand -hex 24)" | secret "$NS" postgres-lector password
  printf %s "$PGADMIN_PASSWORD" | secret "$NS" pgadmin password
  en "$NS" "$K8S/malla/01-bd.yaml" | k apply -f -
  k -n "$NS" rollout status deploy/postgres
  k -n "$NS" wait certificate/interno-tls --for=condition=Ready --timeout=300s
  dominios "$C/letsencrypt/03-pgadmin.yaml" | k apply -f -
  k -n "$NS" rollout restart deploy/pgadmin
  k -n "$NS" rollout status deploy/pgadmin
  demo certificados true
}

down() {
  k delete namespace "$NS" --ignore-not-found
  tunel_down "$T" "$EXTRA_HOSTNAME"
  demo certificados false
}

case "${1:-}" in
  letsencrypt | down) "$1" ;;
  origin-ca) origin_ca ;;
  *) echo "uso: $0 origin-ca|letsencrypt|down" && exit 1 ;;
esac
