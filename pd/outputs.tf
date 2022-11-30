output "demo_service_events_integration_endpoint" {
  value = "https://events.pagerduty.com/x-ere/${pagerduty_event_orchestration.demo_service_orchestration.integration[0].parameters[0].routing_key}"
}

output "demo_service_qa_events_integration_endpoint" {
  value = "https://events.pagerduty.com/x-ere/${pagerduty_event_orchestration.demo_service_qa_orchestration.integration[0].parameters[0].routing_key}"
}
