#create s3 buket
resource "aws_s3_bucket" "tbc-image" {
  bucket = var.bucket_name

  tags = {
    Name = "image bucket"
  }
}

resource "aws_s3_object" "file_upload" {
  bucket = aws_s3_bucket.tbc-image.id
  key    = var.key
  source = var.image_source
  content_type = var.content_type
}


data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*",
      
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.tbc-image.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.tbc-image.id

  block_public_acls   = false
  block_public_policy = false
}