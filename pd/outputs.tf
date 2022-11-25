output "demo_service_cloudwatch_high_integration_url" {
  value = "https://events.eu.pagerduty.com/integration/${pagerduty_service_integration.demo_service_cloudwatch.integration_key}/enqueue"
}


output "demo_service_events_integration_endpoint" {
  value = "https://events.pagerduty.com/x-ere/${pagerduty_event_orchestration.demo_service_orchestration.integration[0].parameters[0].routing_key}"
}
