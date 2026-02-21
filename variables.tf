# ===========================================================================
# Variables — neamsoft IaaS
# ===========================================================================

variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "profile" {
  description = "Perfil de AWS CLI"
  type        = string
  default     = "default"
}

variable "record" {
  description = "Dominio del API Gateway"
  type        = string
  default     = "api.neamsoft.com.mx"
}

variable "zone_id" {
  description = "ID de la zona hospedada en Route53"
  type        = string
}

variable "certificate_arn" {
  description = "ARN del certificado ACM para el dominio API"
  type        = string
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
    function_name = "neamsoft-sendmail-website"
    description   = "neamsoft Mailer — Envío de correos via SES"
    handler       = "sendmail.lambda_handler"
    runtime       = "python3.14"
    timeout       = 30
    memory_size   = 128
    filename      = "neamsoft-sendmail.zip"
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
    SENDER_EMAIL = "no-reply@neamsoft.com.mx"
    TO_EMAIL     = "contacto@neamsoft.com.mx"
    SUBJECT      = "Nuevo mensaje de contacto — neamsoft"
    REGION       = "us-east-1"
  }
}
