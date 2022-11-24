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

resource "pagerduty_team_membership" "rairmana_membership" {
  user_id = pagerduty_user.rairmana.id
  team_id = pagerduty_team.demo_team.id
  role    = "observer"
}

resource "pagerduty_team_membership" "idicresi_membership" {
  user_id = pagerduty_user.idicresi.id
  team_id = pagerduty_team.demo_team.id
  role    = "observer"
}

resource "pagerduty_team_membership" "elmsynea_membership" {
  user_id = pagerduty_user.elmsynea.id
  team_id = pagerduty_team.demo_team.id
  role    = "observer"
}
