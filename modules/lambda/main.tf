#lambda 

resource "aws_iam_role" "lambda_role" {
  name = "terraform_iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}


resource "aws_iam_policy" "iam_policy_for_lambda" {
 
 name         = "aws_iam_policy_for_terraform_aws_lambda_role"

 policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid: "VisualEditor0",
      Effect = "Allow"
      Action = "ec2:*"
      Resource = "*"
    }]
  })
}


resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AlarmAction"
  action        = "lambda:InvokeFunction" 
  function_name = aws_lambda_function.terraform_lambda.function_name
  principal     = "lambda.alarms.cloudwatch.amazonaws.com"
  source_arn    = var.cloudwatch_metric_alarm_arn
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn =  aws_iam_policy.iam_policy_for_lambda.arn
}


resource "aws_lambda_function" "terraform_lambda" {
  function_name = "lambda"
  filename      = "lambda_function_payload.zip"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda.lambda_handler"
  publish       = true

  source_code_hash =  filebase64sha256("lambda_function_payload.zip")

  runtime       = "python3.12"

  tags = {
    Name = "terrform-lambda1"
  }

}