# El API en si (HTTP API)
resource "aws_apigatewayv2_api" "notas_api" {
  name          = "notas-api-tf"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["content-type"]
  }
}

# Conexion entre el API y la Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.notas_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.notas_backend.invoke_arn
  payload_format_version = "2.0"
}

# Rutas: una por cada metodo que soporta /notas
resource "aws_apigatewayv2_route" "get_notas" {
  api_id    = aws_apigatewayv2_api.notas_api.id
  route_key = "GET /notas"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "post_notas" {
  api_id    = aws_apigatewayv2_api.notas_api.id
  route_key = "POST /notas"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "put_notas" {
  api_id    = aws_apigatewayv2_api.notas_api.id
  route_key = "PUT /notas"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "delete_notas" {
  api_id    = aws_apigatewayv2_api.notas_api.id
  route_key = "DELETE /notas"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Stage: la "version publicada" del API
resource "aws_apigatewayv2_stage" "notas_stage" {
  api_id      = aws_apigatewayv2_api.notas_api.id
  name        = "notas"
  auto_deploy = true
}

# Permiso para que API Gateway pueda invocar la Lambda
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notas_backend.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.notas_api.execution_arn}/*/*"
}