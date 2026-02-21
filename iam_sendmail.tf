# ===========================================================================
# IAM — neamsoft-sendmail
# ===========================================================================

# ---------------------------------------------------------------------------
# Rol de ejecución para la Lambda
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "lambda_assume_role_sendmail" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_basic_execution_sendmail" {
  name               = "neamsoft-sendmail-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_sendmail.json

  tags = {
    Service = "neamsoft-sendmail"
    Managed = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Política con permisos SES + CloudWatch Logs + X-Ray
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "lambda_sendmail_permissions" {
  # Amazon SES
  statement {
    sid    = "AllowSES"
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail",
    ]
    resources = ["*"]
  }

  # CloudWatch Logs
  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  # X-Ray Tracing
  statement {
    sid    = "AllowXRay"
    effect = "Allow"
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_sendmail_policy" {
  name        = "neamsoft-sendmail-lambda-policy"
  description = "Permisos para Lambda sendmail: SES, CloudWatch Logs, X-Ray"
  policy      = data.aws_iam_policy_document.lambda_sendmail_permissions.json

  tags = {
    Service = "neamsoft-sendmail"
    Managed = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_sendmail_attach" {
  role       = aws_iam_role.lambda_basic_execution_sendmail.name
  policy_arn = aws_iam_policy.lambda_sendmail_policy.arn
}
