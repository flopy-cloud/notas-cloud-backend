output "api_endpoint" {
  description = "URL del API Gateway"
  value       = aws_apigatewayv2_stage.notas_stage.invoke_url
}

output "frontend_url" {
  description = "URL del sitio web en S3"
  value       = "http://${aws_s3_bucket.notas_frontend.bucket}.s3-website-us-east-1.amazonaws.com"
}

output "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB"
  value       = aws_dynamodb_table.notas_cloud.name
}