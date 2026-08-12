# Rol de IAM que la Lambda va a usar
resource "aws_iam_role" "lambda_role" {
  name = "notas-lambda-rol-tf"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Permiso basico para escribir logs en CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permiso para leer y escribir en la tabla DynamoDB
resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "notas-lambda-dynamodb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.notas_cloud.arn
      }
    ]
  })
}

# La funcion Lambda
resource "aws_lambda_function" "notas_backend" {
  function_name    = "notas-cloud-backend-tf"
  runtime          = "python3.12"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_role.arn
  filename         = "${path.module}/../function.zip"
  source_code_hash = filebase64sha256("${path.module}/../function.zip")
  timeout          = 3
  memory_size      = 128
}