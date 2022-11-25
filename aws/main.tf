resource "aws_sns_topic" "demo_service_high_alerts" {
  name = "demo-service-high-alerts"
}

resource "aws_sns_topic_subscription" "demo_service_high_alerts_subscription" {
  protocol  = "https"
  topic_arn = aws_sns_topic.demo_service_high_alerts.arn
  endpoint  = var.demo_service_high_alerts_subscription_enpoint
}

resource "aws_cloudwatch_metric_alarm" "demo_service_high_alert" {
  alarm_name          = "demo-service-high-alert"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_sns_topic.demo_service_high_alerts.arn]
}

resource "aws_sns_topic" "demo_service_events" {
  name = "demo-service-events"
}

resource "aws_sns_topic_subscription" "demo_service_events_subscription" {
  protocol  = "https"
  topic_arn = aws_sns_topic.demo_service_events.arn
  endpoint  = var.demo_service_events_integration_endpoint
}

resource "aws_cloudwatch_metric_alarm" "demo_service_low_event" {
  alarm_name          = "demo-service-low-event"
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

resource "aws_cloudwatch_metric_alarm" "demo_service_high_event" {
  alarm_name          = "demo-service-high-event"
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

