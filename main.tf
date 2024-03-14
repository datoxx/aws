provider "aws" {
  region  = "eu-central-1"
}



// create ec2 server, use ec2 module
module "myapp-server" {
    source = "./modules/ec2"
    my_ip  = var.my_ip
    instance_type = var.instance_type
    ami = var.ami
    key_name = var.key_name
    public_key_location  = var.public_key_location 
}

# // create s3 
# module "my-s3" {
#     source = "./modules/s3"
#     bucket_name = var.bucket_name
#     key = var.key
#     image_source = var.image_source
#     content_type = var.content_type
# }


# // create cloudFront
# module "cloudFront" {
#     source = "./modules/cloudFront"
#     s3 = module.my-s3.s3
#     key = var.key

# }



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
  source_arn    = aws_cloudwatch_metric_alarm.terminate_alarm.arn
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

  source_code_hash =  filebase64sha256("./lambda_function_payload.zip")

  runtime       = "python3.12"

  tags = {
    Name = "terrform-lambda1"
  }

}


#cloudwatch
resource "aws_cloudwatch_metric_alarm" "terminate_alarm" {
  alarm_name          = "terraform-terminate"
  actions_enabled     = true
  alarm_actions       = [aws_lambda_function.terraform_lambda.arn]
  namespace           = "AWS/Usage"
  metric_name         = "CallCount"
  statistic           = "Average"
  period              = 30
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "missing"

  dimensions = {
    Type     = "API"
    Resource = "TerminateInstances"
    Service  = "EC2"
    Class    = "None"
  }
}