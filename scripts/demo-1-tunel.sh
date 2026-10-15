#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"
T=adios-ips-demo

up() {
  requiere DEMO_HOSTNAME
  requiere_gateway
  k apply -f "$K8S/tunel/01-app.yaml"
  tunel_up "$T" "$DEMO_HOSTNAME" demo-tunel
  dominios "$K8S/tunel/03-conector.yaml" | k apply -f -
  k -n demo-tunel rollout restart deploy/conector
}

rapido() {
  k apply -f "$K8S/tunel/01-app.yaml" -f "$K8S/tunel/02-rapido.yaml"
  k -n demo-tunel rollout status deploy/conector-rapido
  for _ in {1..30}; do
    k -n demo-tunel logs deploy/conector-rapido 2>/dev/null | grep -o 'https://[a-z0-9-]*\.trycloudflare\.com' && return
    sleep 2
  done
  return 1
}

down() {
  k delete namespace demo-tunel --ignore-not-found
  tunel_down "$T" "$DEMO_HOSTNAME"
}

case "${1:-}" in up | rapido | down) "$1" ;; *) echo "uso: $0 up|rapido|down" && exit 1 ;; esac
