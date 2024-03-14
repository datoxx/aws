#cloudwatch
resource "aws_cloudwatch_metric_alarm" "terminate_alarm" {
  alarm_name          = "terraform-terminate"
  actions_enabled     = true
  alarm_actions       =  [var.lambda_arn]
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
