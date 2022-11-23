resource "pagerduty_team" "demo_team" {
  name = "Demo team"
}

resource "pagerduty_user" "rairmana" {
  name  = "rairmana"
  email = "rairmana@rhyta.com"
}

resource "pagerduty_user" "idicresi" {
  name  = "idicresi"
  email = "idicresi@rhyta.com"
}

resource "pagerduty_user" "elmsynea" {
  name  = "elmsynea"
  email = "elmsynea@rhyta.com"
}

locals {
  users = [pagerduty_user.rairmana.id, pagerduty_user.idicresi.id, pagerduty_user.elmsynea.id]
}

resource "pagerduty_team_membership" "rairmana_membership" {
  for_each = local.users
  user_id  = each.key
  team_id  = pagerduty_team.demo_team.id
  role     = "observer"
}

resource "pagerduty_schedule" "demo_team_schedule" {
  name      = "Demo team rotation"
  time_zone = "Europe/Warsaw"

  layer {
    name                         = "Team rota"
    start                        = "2022-11-06T20:00:00-05:00"
    rotation_virtual_start       = "2022-11-06T20:00:00-05:00"
    rotation_turn_length_seconds = 86400
    users                        = local.users
  }

  teams = [pagerduty_team.demo_team.id]
}

resource "pagerduty_escalation_policy" "deamo_team_schedule_escalation_policy" {
  name      = "Demo team Schedule Escalation Policy"
  num_loops = 1
  teams     = [pagerduty_team.demo_team.id]

  rule {
    escalation_delay_in_minutes = 35
    target {
      type = "schedule_reference"
      id   = pagerduty_schedule.demo_team_schedule.id
    }
  }

  rule {
    escalation_delay_in_minutes = 10
    target {
      type = "user_reference"
      id   = pagerduty_user.elmsynea.id
    }
  }
}

resource "pagerduty_escalation_policy" "demo_team_all_members_escalation_policy" {
  name      = "Demo team all members Escalation Policy"
  num_loops = 0
  teams     = [pagerduty_team.demo_team.id]

  rule {
    escalation_delay_in_minutes = 10
    target {
      type = "user_reference"
      id   = pagerduty_user.rairmana.id
    }
    target {
      type = "user_reference"
      id   = pagerduty_user.idicresi.id
    }
    target {
      type = "user_reference"
      id   = pagerduty_user.elmsynea.id
    }
  }
}

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

resource "pagerduty_service_integration" "demo_service_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.demo_service.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_ruleset" "demo_service_ruleset" {
  name = "Demo Servcie Ruleset"
  team {
    id = pagerduty_team.demo_team.id
  }
}

resource "pagerduty_ruleset_rule" "catch_all" {
  ruleset  = pagerduty_ruleset.demo_service_ruleset.id
  position = 0
  conditions {
    operator = "and"
    subconditions {
      operator = "contains"
      parameter {
        value = "AWSAccountId"
        path  = "Message"
      }
    }
  }
  actions {
    route {
      value = pagerduty_service.demo_service.id
    }
    severity {
      value = "warning"
    }
    annotate {
      value = "Low priority alert"
    }
  }
}
