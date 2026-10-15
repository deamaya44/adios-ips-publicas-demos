#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export K8S="$ROOT/k8s"
TF="$ROOT/terraform"

set -a
source "$ROOT/.env"
set +a
export TUNNEL_LOGLEVEL=error
EXTRA_HOSTNAME="${EXTRA_HOSTNAME:-extra.${DEMO_HOSTNAME#*.}}"
PERFIL=adios-ips

k() { kubectl --context "$KUBE_CONTEXT" "$@"; }
tf() { "$(command -v tofu || command -v terraform)" -chdir="$TF" "$@"; }

requiere() {
  local v
  for v in "$@"; do
    [[ -n ${!v:-} ]] || { echo "falta $v en .env" >&2 && exit 1; }
  done
}

requiere_netbird() {
  k -n netbird get statefulset routing-peer >/dev/null 2>&1 || { echo "falta la base de NetBird: pon NB_PAT en .env y corre ./scripts/tools.sh up" >&2 && exit 1; }
}

requiere_gateway() {
  k -n nginx-gateway get gateway entrada >/dev/null 2>&1 || { echo "falta el Gateway: corre ./scripts/tools.sh up" >&2 && exit 1; }
}

secret() {
  k -n "$1" create secret generic "$2" --from-file="$3=/dev/stdin" --dry-run=client -o yaml |
    k apply --server-side --force-conflicts -f - >/dev/null
}

dominios() {
  sed -e "s/pgadmin\.interno\.tu-dominio\.com/pgadmin.$INTERNAL_DOMAIN/" \
    -e "s/extra\.tu-dominio\.com/$EXTRA_HOSTNAME/" -e "s/demo\.tu-dominio\.com/$DEMO_HOSTNAME/" "$@"
}

en() {
  local ns=$1
  shift
  sed -E "s/^(  name|  namespace): demo-(tunel|malla)$/\1: $ns/" "$@"
}

svc_ip() { k -n "$1" get svc "$2" -o jsonpath='{.spec.clusterIP}' 2>/dev/null || true; }

tunel_up() {
  cloudflared tunnel info "$1" >/dev/null 2>&1 || cloudflared tunnel create "$1"
  cloudflared tunnel route dns --overwrite-dns "$1" "$2"
  cloudflared tunnel token "$1" | secret "$3" tunel-token token
}

dns_api() {
  local c
  c=$(sed -n '/BEGIN/,/END/{/-----/d;p;}' ~/.cloudflared/cert.pem | base64 -d)
  curl -fsS -X "$1" -H @- "https://api.cloudflare.com/client/v4/zones/$(jq -r .zoneID <<<"$c")/dns_records$2" \
    <<<"Authorization: Bearer $(jq -r .apiToken <<<"$c")"
}

tunel_down() {
  local id r
  id=$(cloudflared tunnel list --name "$1" --output json 2>/dev/null | jq -r '.[0].id // empty') || return 0
  [[ -n "$id" ]] || return 0
  for r in $(dns_api GET "?name=$2&content=$id.cfargotunnel.com" | jq -r '.result[].id'); do
    dns_api DELETE "/$r" >/dev/null
  done
  cloudflared tunnel delete -f "$1"
}

salir() {
  netbird down >/dev/null 2>&1 || true
  netbird profile select default >/dev/null 2>&1 || true
  netbird profile remove "$PERFIL" >/dev/null 2>&1 || true
}

laptop() {
  salir
  netbird profile add "$PERFIL"
  tf output -raw laptops_setup_key | netbird up --profile "$PERFIL" \
    --management-url "${NB_MANAGEMENT_URL:-https://api.netbird.io}" --setup-key-file /dev/stdin
}

demo() {
  local state base=false malla=false certificados=false auto=""
  [[ ${AUTO_APPROVE:-0} == 1 ]] && auto=-auto-approve
  tf init -input=false >/dev/null
  state=$(tf state list 2>/dev/null || true)
  [[ $state == *'module.netbird_groups["routers"]'* ]] && base=true
  [[ $state == *'module.netbird_groups["bd"]'* ]] && malla=true
  [[ $state == *'module.netbird_groups["gateway"]'* ]] && certificados=true
  [[ ${!1} == "$2" ]] && return 0
  printf -v "$1" %s "$2"
  tf apply -input=false ${auto:+"$auto"} \
    -var "enable_base=$base" -var "enable_malla=$malla" -var "enable_certificados=$certificados" \
    -var "management_url=${NB_MANAGEMENT_URL:-https://api.netbird.io}" -var "internal_domain=$INTERNAL_DOMAIN" \
    -var "kube_dns_ip=$(svc_ip kube-system kube-dns)" -var "postgres_ip=$(svc_ip demo-malla postgres)" \
    -var "gateway_ip=$(svc_ip nginx-gateway entrada-nginx)"
}
