module "pd" {
  source          = "./pd"
  pagerduty_token = var.pagerduty_token_global
}

module "aws" {
  source                                 = "./aws"
  demo_service_events_integration_key    = module.pd.demo_service_events_integration_key
  demo_service_qa_events_integration_key = module.pd.demo_service_qa_events_integration_key
}
