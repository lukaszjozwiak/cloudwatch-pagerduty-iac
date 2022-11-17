output "demo_service_cloudwatch_integration_url" {
  value = "${pagerduty_service_integration.demo_service_cloudwatch.html_url}/${pagerduty_service_integration.demo_service_cloudwatch.integration_key}"
}
