resource "pagerduty_service" "demo_service" {
  name              = "Demo Service"
  escalation_policy = pagerduty_escalation_policy.demo_team_all_members_escalation_policy.id
  alert_creation    = "create_alerts_and_incidents"

  incident_urgency_rule {
    type    = "constant"
    urgency = "severity_based"
  }
}

data "pagerduty_vendor" "cloudwatch" {
  name = "Cloudwatch"
}

data "pagerduty_vendor" "prometheus" {
  name = "Prometheus"
}

resource "pagerduty_service_integration" "demo_service_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.demo_service.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_service_integration" "demo_service_prometheus" {
  name    = data.pagerduty_vendor.prometheus.name
  service = pagerduty_service.demo_service.id
  vendor  = data.pagerduty_vendor.prometheus.id
}

resource "pagerduty_event_orchestration" "demo_service_orchestration" {
  name = "Demo Service Event Orchestration"
  team = pagerduty_team.demo_team.id
}

resource "pagerduty_event_orchestration_router" "demo_service_router" {
  event_orchestration = pagerduty_event_orchestration.demo_service_orchestration.id
  set {
    id = "start"
  }
  catch_all {
    actions {
      route_to = pagerduty_service.demo_service.id
    }
  }
}

resource "pagerduty_event_orchestration_service" "demo_service_orchestration_service" {
  service = pagerduty_service.demo_service.id
  set {
    id = "start"
    rule {
      label = "Warnings should create low urgency incidents"
      condition {
        expression = "event.custom_details.firing matches part 'FCP_LOW_LEVEL_ALERT'"
      }
      condition {
        expression = "event.custom_details.AlarmName matches part 'FCP_LOW_LEVEL_ALERT'"
      }
      actions {
        severity = "warning"
      }
    }
  }
  catch_all {
    actions {
      severity = "error"
    }
  }
}

resource "pagerduty_service" "demo_service_qa" {
  name              = "Demo Service QA"
  escalation_policy = pagerduty_escalation_policy.demo_team_all_members_escalation_policy.id
  alert_creation    = "create_alerts_and_incidents"

  incident_urgency_rule {
    type    = "constant"
    urgency = "severity_based"
  }
}

resource "pagerduty_event_orchestration" "demo_service_qa_orchestration" {
  name = "Demo Service QA Event Orchestration"
  team = pagerduty_team.demo_team.id
}

resource "pagerduty_event_orchestration_router" "demo_service_qa_router" {
  event_orchestration = pagerduty_event_orchestration.demo_service_qa_orchestration.id
  set {
    id = "start"
  }
  catch_all {
    actions {
      route_to = pagerduty_service.demo_service_qa.id
    }
  }
}

resource "pagerduty_event_orchestration_service" "demo_service_qa_orchestration_service" {
  service = pagerduty_service.demo_service_qa.id
  set {
    id = "start"
  }
  catch_all {
    actions {
      suppress = true
    }
  }
}

