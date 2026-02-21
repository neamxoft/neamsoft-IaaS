# 🏗️ neamsoft IaaS — Infraestructura como Código

Infraestructura Terraform para los servicios backend de **neamsoft**, desplegados en AWS.

## Arquitectura

```
                    ┌─────────────────────────────────────────────┐
                    │              api.neamsoft.com.mx             │
                    │               (Route53 + ACM)               │
                    └─────────────┬───────────────────────────────┘
                                  │
                    ┌─────────────▼───────────────────────────────┐
                    │          API Gateway (Regional)              │
                    │     /services/v1/sendmail [POST]             │
                    └─────────────┬───────────────────────────────┘
                                  │ AWS_PROXY
                    ┌─────────────▼───────────────────────────────┐
                    │     Lambda: neamsoft-sendmail-website        │
                    │     Python 3.14 | arm64 | X-Ray Active      │
                    └─────────────┬───────────────────────────────┘
                                  │
                    ┌─────────────▼───────────────────────────────┐
                    │            Amazon SES                        │
                    │         Envío de correos                     │
                    └─────────────────────────────────────────────┘
```

## Componentes

| Archivo | Descripción |
|---|---|
| `main.tf` | Provider AWS |
| `variables.tf` | Variables, objetos `properties-sendmail` y `sendmail-envs` |
| `lambda_sendmail.tf` | Lambda function + CloudWatch Log Group + Permission |
| `iam_sendmail.tf` | IAM Role + Policy (SES, CloudWatch, X-Ray) |
| `api_gateway.tf` | REST API, recursos, CORS, dominio custom, Route53 |
| `outputs.tf` | ARN Lambda, URLs del API |
| `envs.tfvars` | Valores de variables por entorno |

## Variables de Entorno (Lambda)

| Variable | Descripción |
|---|---|
| `SENDER_EMAIL` | Correo verificado en SES (remitente) |
| `TO_EMAIL` | Correo destino de los mensajes |
| `SUBJECT` | Asunto fijo de los correos |
| `REGION` | Región AWS para SES |

## Variables de Terraform (`envs.tfvars`)

```hcl
region          = "us-east-1"
profile         = "neamsoft"
zone_id         = "Z0123456789ABCDEF"
certificate_arn = "arn:aws:acm:us-east-1:123456789:certificate/abc-123"
```

## Payload de Entrada

```bash
curl -X POST https://api.neamsoft.com.mx/services/v1/sendmail \
  -H "Content-Type: application/json" \
  -d '{"message": "<h2>Hola</h2><p>Mensaje de prueba</p>"}'
```

## Comandos

```bash
make build_sendmail   # Empaqueta la Lambda
make plan             # Terraform plan
make deploy           # Build + Deploy completo
make destroy          # Destruir infraestructura
```

## Prerrequisitos

1. **AWS CLI** configurado con perfil `neamsoft`
2. **Terraform** >= 1.0
3. **Certificado ACM** validado para `api.neamsoft.com.mx`
4. **Zona Route53** para `neamsoft.com.mx`
5. **SES** — Correo remitente verificado
