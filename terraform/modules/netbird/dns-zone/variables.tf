variable "name" {
  description = "Nombre de la zona en el panel."
  type        = string
}

variable "domain" {
  description = "Dominio de la zona, por ejemplo interno.tu-dominio.com."
  type        = string
}

variable "distribution_groups" {
  description = "IDs de los grupos que reciben la zona."
  type        = list(string)
}

variable "enable_search_domain" {
  description = "true: los peers pueden usar nombres cortos (bd en vez de bd.interno.tu-dominio.com)."
  type        = bool
}

variable "enabled" {
  description = "false: la zona deja de distribuirse sin borrarla."
  type        = bool
}
