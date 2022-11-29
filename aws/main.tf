resource "aws_sns_topic" "demo_service_events" {
  name = "demo-service-events"
}

resource "aws_sns_topic_subscription" "demo_service_events_subscription" {
  protocol  = "https"
  topic_arn = aws_sns_topic.demo_service_events.arn
  endpoint  = var.demo_service_events_integration_endpoint
}

resource "aws_cloudwatch_metric_alarm" "demo_service_warning" {
  alarm_name          = "demo-service-warning"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "[Low] This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_sns_topic.demo_service_events.arn]
}

resource "aws_cloudwatch_metric_alarm" "demo_service_error" {
  alarm_name          = "demo-service-error"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "[High] This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_sns_topic.demo_service_events.arn]
}

