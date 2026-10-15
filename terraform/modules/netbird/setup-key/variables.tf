variable "name" {
  description = "Nombre de la setup key."
  type        = string
}

variable "type" {
  description = "reusable: la usan varios peers. one-off: un solo uso."
  type        = string
}

variable "ephemeral" {
  description = "true: NetBird borra el peer cuando lleva un rato desconectado (útil para pods)."
  type        = bool
}

variable "usage_limit" {
  description = "Cuántas veces se puede usar. 0 = sin límite."
  type        = number
}

variable "expiry_seconds" {
  description = "Vigencia de la key en segundos."
  type        = number
}

variable "auto_groups" {
  description = "IDs de los grupos a los que entra el peer al registrarse."
  type        = list(string)
}
