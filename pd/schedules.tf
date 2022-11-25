resource "pagerduty_schedule" "demo_team_schedule" {
  name      = "Demo team rotation"
  time_zone = "Europe/Warsaw"

  layer {
    name                         = "Team rota"
    start                        = "2022-11-06T20:00:00-05:00"
    rotation_virtual_start       = "2022-11-06T20:00:00-05:00"
    rotation_turn_length_seconds = 86400
    users                        = [pagerduty_user.rairmana.id, pagerduty_user.idicresi.id, pagerduty_user.elmsynea.id]
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
    dynamic "target" {
      for_each = toset([pagerduty_user.rairmana.id, pagerduty_user.idicresi.id, pagerduty_user.elmsynea.id])
      content {
        type = "user_reference"
        id   = target.value
      }
    }
  }
}
