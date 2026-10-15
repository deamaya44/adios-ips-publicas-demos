variable "name" {
  description = "Nombre del grupo de nameservers."
  type        = string
}

variable "description" {
  description = "Descripción visible en el panel."
  type        = string
}

variable "enabled" {
  description = "false: los peers dejan de usar estos nameservers."
  type        = bool
}

variable "primary" {
  description = "true: resuelve todo. false: solo los dominios de domains."
  type        = bool
}

variable "domains" {
  description = "Dominios que se resuelven con estos nameservers."
  type        = list(string)
}

variable "search_domains_enabled" {
  description = "true: agrega los dominios como search domains en los peers."
  type        = bool
}

variable "groups" {
  description = "IDs de los grupos que reciben esta configuración DNS."
  type        = list(string)
}

variable "nameservers" {
  description = "Servidores DNS."
  type = list(object({
    ip      = string
    ns_type = string
    port    = number
  }))
}
