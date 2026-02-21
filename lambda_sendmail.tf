# ===========================================================================
# Lambda — neamsoft-sendmail-website
# ===========================================================================

# ---------------------------------------------------------------------------
# CloudWatch Log Group
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "sendmail_logs" {
  name              = "/aws/lambda/${var.properties-sendmail.function_name}"
  retention_in_days = 14

  tags = {
    Service = "neamsoft-sendmail"
    Managed = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Lambda Function
# ---------------------------------------------------------------------------
resource "aws_lambda_function" "neamsoft_sendmail" {
  function_name = var.properties-sendmail.function_name
  description   = var.properties-sendmail.description
  handler       = var.properties-sendmail.handler
  runtime       = var.properties-sendmail.runtime
  timeout       = var.properties-sendmail.timeout
  memory_size   = var.properties-sendmail.memory_size
  filename      = var.properties-sendmail.filename
  role          = aws_iam_role.lambda_basic_execution_sendmail.arn
  architectures = ["arm64"]

  source_code_hash = filebase64sha256(var.properties-sendmail.filename)

  environment {
    variables = {
      SENDER_EMAIL = var.sendmail-envs.SENDER_EMAIL
      TO_EMAIL     = var.sendmail-envs.TO_EMAIL
      SUBJECT      = var.sendmail-envs.SUBJECT
      REGION       = var.sendmail-envs.REGION
    }
  }

  tracing_config {
    mode = "Active"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_sendmail_attach,
    aws_cloudwatch_log_group.sendmail_logs,
  ]

  tags = {
    Service = "neamsoft-sendmail"
    Managed = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Permission — API Gateway invoca la Lambda
# ---------------------------------------------------------------------------
resource "aws_lambda_permission" "sendmail_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.neamsoft_sendmail.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.neamsoft_api.execution_arn}/*/*"
}
