variable "network_id" {
  description = "ID de la Network."
  type        = string
}

variable "name" {
  description = "Nombre del recurso."
  type        = string
}

variable "description" {
  description = "Descripción visible en el panel."
  type        = string
}

variable "address" {
  description = "IP con máscara (10.96.0.10/32), rango o dominio."
  type        = string
}

variable "groups" {
  description = "IDs de los grupos del recurso. Las políticas usan estos grupos como destino."
  type        = list(string)
}

variable "enabled" {
  description = "false: el recurso deja de publicarse sin borrarlo."
  type        = bool
}
