variable "enable_base" {
  description = "Base común de NetBird (tools.sh up): red, router, grupos k8s-routers y laptops, setup keys y zona DNS."
  type        = bool
}

variable "enable_malla" {
  description = "Demo 2: recursos kube-dns y postgres, sus políticas, nameserver y registro bd. Necesita la base."
  type        = bool
}

variable "enable_certificados" {
  description = "Extra, caso B: recurso gateway, política HTTPS y registro pgadmin. Necesita la base, no la demo 2."
  type        = bool
}

variable "management_url" {
  description = "API de NetBird: https://api.netbird.io, o tu URL si es self-hosted."
  type        = string
}

variable "internal_domain" {
  description = "Zona DNS privada que solo existe dentro de la malla, por ejemplo interno.tu-dominio.com."
  type        = string
}

variable "kube_dns_ip" {
  description = "IP del Service kube-dns: kubectl -n kube-system get svc kube-dns -o jsonpath='{.spec.clusterIP}'"
  type        = string
}

variable "postgres_ip" {
  description = "IP del Service postgres: kubectl -n demo-malla get svc postgres -o jsonpath='{.spec.clusterIP}'"
  type        = string
}

variable "gateway_ip" {
  description = "IP del Service del Gateway: kubectl -n nginx-gateway get svc entrada-nginx -o jsonpath='{.spec.clusterIP}'"
  type        = string
}
