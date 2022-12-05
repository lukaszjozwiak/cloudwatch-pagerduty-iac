locals {
  pagerduty_url = "https://events.pagerduty.com/x-ere"
}

data "aws_iam_policy_document" "cloudwatch_key_access" {
  statement {
    sid = "Allow cloudwatch to send events to encrypted topics"

    actions = [
      "kms:*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "*"
    ]
  }
}

resource "aws_kms_key" "sns_key" {
  description         = "Sns key"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.cloudwatch_key_access.json
}

resource "aws_kms_alias" "sns_alias" {
  name          = "alias/sns-key-alias"
  target_key_id = aws_kms_key.sns_key.key_id
}

resource "aws_sns_topic" "demo_service_events" {
  name              = "demo-service-events"
  kms_master_key_id = aws_kms_key.sns_key.key_id
}

resource "aws_sns_topic_subscription" "demo_service_events_subscription" {
  protocol  = "https"
  topic_arn = aws_sns_topic.demo_service_events.arn
  endpoint  = "${local.pagerduty_url}/${var.demo_service_events_integration_key}"
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
  name              = "demo-service-qa-events"
  kms_master_key_id = aws_kms_key.sns_key.key_id
}

resource "aws_sns_topic_subscription" "demo_service_qa_events_subscription" {
  protocol  = "https"
  topic_arn = aws_sns_topic.demo_service_qa_events.arn
  endpoint  = "${local.pagerduty_url}/${var.demo_service_qa_events_integration_key}"
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

