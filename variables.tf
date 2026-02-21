# ===========================================================================
# Variables — neamsoft IaaS
# ===========================================================================

variable "region" {
  description = "Región de AWS"
  type        = string
  default     = ""
}

variable "profile" {
  description = "Perfil de AWS CLI"
  type        = string
  default     = ""
}

variable "record" {
  description = "Dominio del API Gateway"
  type        = string
  default     = ""
}

variable "zone_id" {
  description = "ID de la zona hospedada en Route53"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ARN del certificado ACM para el dominio API"
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Propiedades de la Lambda Sendmail
# ---------------------------------------------------------------------------
variable "properties-sendmail" {
  description = "Configuración de la Lambda sendmail"
  type = object({
    function_name = string
    description   = string
    handler       = string
    runtime       = string
    timeout       = number
    memory_size   = number
    filename      = string
  })
  default = {
    function_name = ""
    description   = ""
    handler       = ""
    runtime       = ""
    timeout       = 30
    memory_size   = 128
    filename      = ""
  }
}

# ---------------------------------------------------------------------------
# Variables de entorno de la Lambda Sendmail
# ---------------------------------------------------------------------------
variable "sendmail-envs" {
  description = "Variables de entorno para la Lambda sendmail"
  type = object({
    SENDER_EMAIL = string
    TO_EMAIL     = string
    SUBJECT      = string
    REGION       = string
  })
  default = {
    SENDER_EMAIL = ""
    TO_EMAIL     = ""
    SUBJECT      = ""
    REGION       = ""
  }
}
