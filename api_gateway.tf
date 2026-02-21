# ===========================================================================
# API Gateway — neamsoft API (api.neamsoft.com.mx)
# ===========================================================================

# ---------------------------------------------------------------------------
# REST API
# ---------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "neamsoft_api" {
  name        = "neamsoft-api"
  description = "API REST de neamsoft — servicios backend"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Service = "neamsoft-api"
    Managed = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Recursos: /services/v1/sendmail
# ---------------------------------------------------------------------------
resource "aws_api_gateway_resource" "services" {
  rest_api_id = aws_api_gateway_rest_api.neamsoft_api.id
  parent_id   = aws_api_gateway_rest_api.neamsoft_api.root_resource_id
  path_part   = "services"
}

resource "aws_api_gateway_resource" "v1" {
  rest_api_id = aws_api_gateway_rest_api.neamsoft_api.id
  parent_id   = aws_api_gateway_resource.services.id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "sendmail" {
  rest_api_id = aws_api_gateway_rest_api.neamsoft_api.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "sendmail"
}

# ---------------------------------------------------------------------------
# Método POST + Integración Lambda
# ---------------------------------------------------------------------------
resource "aws_api_gateway_method" "sendmail_post" {
  rest_api_id   = aws_api_gateway_rest_api.neamsoft_api.id
  resource_id   = aws_api_gateway_resource.sendmail.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "sendmail_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.neamsoft_api.id
  resource_id             = aws_api_gateway_resource.sendmail.id
  http_method             = aws_api_gateway_method.sendmail_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.neamsoft_sendmail.invoke_arn
}

# ---------------------------------------------------------------------------
# CORS — Método OPTIONS
# ---------------------------------------------------------------------------
resource "aws_api_gateway_method" "sendmail_options" {
  rest_api_id   = aws_api_gateway_rest_api.neamsoft_api.id
  resource_id   = aws_api_gateway_resource.sendmail.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "sendmail_options" {
  rest_api_id = aws_api_gateway_rest_api.neamsoft_api.id
  resource_id = aws_api_gateway_resource.sendmail.id
  http_method = aws_api_gateway_method.sendmail_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "sendmail_options_200" {
  rest_api_id = aws_api_gateway_rest_api.neamsoft_api.id
  resource_id = aws_api_gateway_resource.sendmail.id
  http_method = aws_api_gateway_method.sendmail_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "sendmail_options" {
  rest_api_id = aws_api_gateway_rest_api.neamsoft_api.id
  resource_id = aws_api_gateway_resource.sendmail.id
  http_method = aws_api_gateway_method.sendmail_options.http_method
  status_code = aws_api_gateway_method_response.sendmail_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# ---------------------------------------------------------------------------
# Deployment + Stage
# ---------------------------------------------------------------------------
resource "aws_api_gateway_deployment" "neamsoft_api" {
  rest_api_id = aws_api_gateway_rest_api.neamsoft_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.sendmail.id,
      aws_api_gateway_method.sendmail_post.id,
      aws_api_gateway_integration.sendmail_lambda.id,
      aws_api_gateway_method.sendmail_options.id,
      aws_api_gateway_integration.sendmail_options.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "production" {
  rest_api_id   = aws_api_gateway_rest_api.neamsoft_api.id
  deployment_id = aws_api_gateway_deployment.neamsoft_api.id
  stage_name    = "production"

  tags = {
    Service = "neamsoft-api"
    Managed = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Custom Domain — api.neamsoft.com.mx
# ---------------------------------------------------------------------------
resource "aws_api_gateway_domain_name" "neamsoft_api" {
  domain_name              = var.record
  regional_certificate_arn = var.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Service = "neamsoft-api"
    Managed = "terraform"
  }
}

resource "aws_api_gateway_base_path_mapping" "neamsoft_api" {
  api_id      = aws_api_gateway_rest_api.neamsoft_api.id
  stage_name  = aws_api_gateway_stage.production.stage_name
  domain_name = aws_api_gateway_domain_name.neamsoft_api.domain_name
}

# ---------------------------------------------------------------------------
# Route53 — Alias a API Gateway
# ---------------------------------------------------------------------------
resource "aws_route53_record" "neamsoft_api" {
  zone_id = var.zone_id
  name    = var.record
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.neamsoft_api.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.neamsoft_api.regional_zone_id
    evaluate_target_health = false
  }
}
