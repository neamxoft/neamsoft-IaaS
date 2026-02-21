# ===========================================================================
# Outputs — neamsoft IaaS
# ===========================================================================

output "sendmail_lambda_arn" {
  description = "ARN de la Lambda sendmail"
  value       = aws_lambda_function.neamsoft_sendmail.arn
}

output "api_gateway_url" {
  description = "URL del API Gateway (stage production)"
  value       = aws_api_gateway_stage.production.invoke_url
}

output "api_custom_domain" {
  description = "Dominio custom del API"
  value       = "https://${var.record}/services/v1/sendmail"
}
