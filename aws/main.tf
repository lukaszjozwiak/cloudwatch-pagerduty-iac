resource "aws_sns_topic" "demo_service_events" {
  name = "demo-service-events"
}

resource "aws_sns_topic_subscription" "demo_service_events_subscription" {
  protocol  = "https"
  topic_arn = aws_sns_topic.demo_service_events.arn
  endpoint  = var.demo_service_events_integration_endpoint
}

resource "aws_cloudwatch_metric_alarm" "demo_service_warning" {
  alarm_name          = "demo-service-FCP_LOW_LEVEL_ALERT"
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

resource "aws_sns_topic" "demo_service_qa_events" {
  name = "demo-service-qa-events"
}

resource "aws_sns_topic_subscription" "demo_service_qa_events_subscription" {
  protocol  = "https"
  topic_arn = aws_sns_topic.demo_service_qa_events.arn
  endpoint  = var.demo_service_qa_events_integration_endpoint
}

resource "aws_cloudwatch_metric_alarm" "maximum_service_capacity_utilized" {
  alarm_name          = "demo-service-qa-maximum-capacity-FCP_LOW_LEVEL_ALERT"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "8"
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = "900"
  statistic           = "Average"
  threshold           = "4"
  alarm_description   = "Service scaled to maximum cpacity for over 2 hours"
  alarm_actions       = [aws_sns_topic.demo_service_qa_events.arn]
  dimensions = {
    ClusterName = "demo-cluster"
    ServiceName = "demo-service-qa"
  }
}

resource "aws_cloudwatch_metric_alarm" "demo_service_qa_error" {
  alarm_name          = "demo-service-qa-error"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "[High] This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_sns_topic.demo_service_qa_events.arn]
}

