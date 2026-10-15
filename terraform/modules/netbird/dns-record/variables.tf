variable "zone_id" {
  description = "ID de la zona privada."
  type        = string
}

variable "name" {
  description = "Nombre completo (FQDN) dentro de la zona, por ejemplo bd.interno.tu-dominio.com."
  type        = string
}

variable "type" {
  description = "Tipo de registro (A, CNAME...)."
  type        = string
}

variable "content" {
  description = "IP o destino del registro."
  type        = string
}

variable "ttl" {
  description = "TTL en segundos."
  type        = number
}
