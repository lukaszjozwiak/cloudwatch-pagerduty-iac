module "pd" {
  source          = "./pd"
  pagerduty_token = var.pagerduty_token_global
}

module "aws" {
  source                                       = "./aws"
  demo_service_low_alerts_subscription_enpoint = module.pd.demo_service_cloudwatch_integration_url
}
