#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"

up() {
  requiere NB_PAT INTERNAL_DOMAIN POSTGRES_PASSWORD
  requiere_netbird
  k create namespace demo-malla --dry-run=client -o yaml | k apply -f -
  printf %s "$POSTGRES_PASSWORD" | secret demo-malla postgres password
  k -n demo-malla get secret postgres-lector >/dev/null 2>&1 ||
    printf %s "$(openssl rand -hex 24)" | secret demo-malla postgres-lector password
  k apply -f "$K8S/malla/01-bd.yaml"
  k -n demo-malla rollout status deploy/postgres
  demo malla true
}

down() {
  k delete namespace demo-malla --ignore-not-found
  demo malla false
}

case "${1:-}" in up | down) "$1" ;; *) echo "uso: $0 up|down" && exit 1 ;; esac
