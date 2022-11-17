output "demo_service_cloudwatch_high_integration_url" {
  value = "https://events.eu.pagerduty.com/integration/${pagerduty_service_integration.demo_service_cloudwatch.integration_key}/enqueue"
}


output "demo_service_cloudwatch_low_integration_url" {
  value = "https://events.pagerduty.com/x-ere/${pagerduty_ruleset.demo_service_ruleset.routing_keys[0]}"
}
