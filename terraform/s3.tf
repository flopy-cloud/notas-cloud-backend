resource "aws_s3_bucket" "notas_frontend" {
  bucket = "notas-cloud-flopy-2026-tf"
}

resource "aws_s3_bucket_website_configuration" "notas_frontend_website" {
  bucket = aws_s3_bucket.notas_frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "notas_frontend_public" {
  bucket = aws_s3_bucket.notas_frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "notas_frontend_policy" {
  bucket = aws_s3_bucket.notas_frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.notas_frontend.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.notas_frontend_public]
}