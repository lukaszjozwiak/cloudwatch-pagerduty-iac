module "pd" {
  source          = "./pd"
  pagerduty_token = var.pagerduty_token_global
}

module "aws" {
  source                                      = "./aws"
  demo_service_events_integration_endpoint    = module.pd.demo_service_events_integration_endpoint
  demo_service_qa_events_integration_endpoint = module.pd.demo_service_qa_events_integration_endpoint
}
