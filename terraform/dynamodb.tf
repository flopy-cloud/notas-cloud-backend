resource "aws_dynamodb_table" "notas_cloud" {
  name         = "NotasCloud"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "NotaId"

  attribute {
    name = "NotaId"
    type = "S"
  }

  tags = {
    Proyecto = "notas-cloud"
  }
}