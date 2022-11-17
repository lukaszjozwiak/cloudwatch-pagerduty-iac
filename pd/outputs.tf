output "demo_service_cloudwatch_integration_url" {
  value = "https://events.eu.pagerduty.com/integration/${pagerduty_service_integration.demo_service_cloudwatch.integration_key}/enqueue"
}
