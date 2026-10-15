variable "network_id" {
  description = "ID de la Network que enruta."
  type        = string
}

variable "peer_groups" {
  description = "IDs de los grupos de peers que hacen de router."
  type        = list(string)
}

variable "masquerade" {
  description = "true: el router traduce la IP de origen, así el destino no necesita ruta de vuelta hacia la malla."
  type        = bool
}

variable "metric" {
  description = "Prioridad de la ruta. Menor gana."
  type        = number
}

variable "enabled" {
  description = "false: deja de enrutar sin borrarlo."
  type        = bool
}
