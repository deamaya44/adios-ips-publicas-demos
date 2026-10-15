variable "name" {
  description = "Nombre de la política."
  type        = string
}

variable "description" {
  description = "Descripción visible en el panel."
  type        = string
}

variable "enabled" {
  description = "false: la política deja de aplicar y los peers pierden la ruta."
  type        = bool
}

variable "rules" {
  description = "Reglas de la política. sources y destinations son IDs de grupos."
  type = list(object({
    name          = string
    enabled       = bool
    action        = string
    bidirectional = bool
    protocol      = string
    ports         = list(string)
    sources       = list(string)
    destinations  = list(string)
  }))
}
