# Overview

Project sets environment for testing Pagerduty integration with Prometheus Alertmanager and AWS Cloudwatch.

# Setup

## Prerequisites

* [Pagerduty](https://www.pagerduty.com) account. Free [14-day trial](https://www.pagerduty.com/sign-up) account is sufficient.
* [AWS](https://aws.amazon.com) account with sufficient privileges. For sake of simplicity create [administrator account](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html) or use your `root` account. This project uses following AWS services:
    * [KMS](https://aws.amazon.com/kms)
    * [SNS](https://aws.amazon.com/sns)
    * [CloudWatch](https://aws.amazon.com/cloudwatch)
    * [EC2](https://aws.amazon.com/ec2) - Only free tier resources are used.
* [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) installed locally
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed locally. Project was tested with AWS CLI installed where [Terraform AWS provider](https://registry.terraform.io/providers/hashicorp/aws) uses `default` profile from `~/.aws` directory. Project was tested in `eu-central-1` region, but it uses only basic services which should be available everywhere.
* Bash shell in order to run `curl` command.

## Pagerduty

1. Go to `Integrations -> API Access Keys`
2. Click button `Create New API Key` and create key with write access (`Read-only API Key` checkbox disabled)
3. Configure project to use API key. It can be done various ways, but for sake of simplicity create file `terraform.tfvars` in project root path with following content, where `API_KEY` should be replaced with new key:
    ```
    pagerduty_token = "API_KEY"
    ```

## AWS

1. Go to IAM service, find your user and [create new API Access Key](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html)
2. [Configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) AWS CLI to use API key.



# Build
1. Go to project root directory
2. Run `terraform init`
3. Run `terraform apply -auto-approve` to create resources in Pagerduty and AWS.

# Test integration

There are two services configured in Pagerduty. Both use [Event Orchestration](https://support.pagerduty.com/docs/event-orchestration) feature to handle incoming events.
* `Demo Service` - simulates _prod_ service configuration, where low urgency incidents are created for alerts with keyword `LOW_LEVEL_ALERT` in name, and for all other alerts, high urgency incidents are created.
* `Demo Service QA` - simulates _non-prod_ service configuration, where all incoming alerts are suppressed and no incident is created.

## Pagerduty and AWS Cloudwatch

There are following alerts configured to be sent to both Pagerduty services:
* `demo-service-LOW_LEVEL_ALERT` and `demo-service-error` for `Demo Service`
* `demo-service-qa-LOW_LEVEL_ALERT` and `demo-service-qa-error` for `Demo Service QA`

In order to trigger alarm, run following command, where `<ALARM_NAME>` should be replaced with alarm name:
```
aws cloudwatch  set-alarm-state --alarm-name <ALARM_NAME> --state-value ALARM  --state-reason "Alarm test"
```
e.g.
```
aws cloudwatch  set-alarm-state --alarm-name demo-service-LOW_LEVEL_ALERT --state-value ALARM  --state-reason "Alarm test"
```

Alarm can be turned off by running command:
```
aws cloudwatch  set-alarm-state --alarm-name <ALARM_NAME> --state-value OK  --state-reason "Solved"
```
e.g.
```
aws cloudwatch  set-alarm-state --alarm-name demo-service-LOW_LEVEL_ALERT --state-value OK  --state-reason "Solved"
```

If everything went fine, then alert and possibly incident is created in Pagerduty

## Pagerduty and Prometheus Alertmanager

Alertmanager runs on EC2 instance with dynamic IP address, so you need to go to AWS EC2 instance `Alermanager` details and get its `Public IPv4 DNS` or `Public IPv4 address`.

Alerts are routed on basis of `env` label:
* If `env=prod` then alerts are routed to service `Demo Service`
* If `env=qa` then alerts are routed to service `Demo Service QA`
  
To trigger alert run following command in bash, where:
*  `<ALERTMANAGER_ADDRESS>` - ec2 instance address
*  `<ALERT_NAME>` - alert name
*  `<ENV>` - environment identifer
```
curl -H 'Content-Type: application/json' -d '[{"labels":{"alertname":"<ALERT_NAME>", "env":"<ENV>"}}]' http://<ALERTMANAGER_ADDRESS>:9093/api/v1/alerts
```
e.g.
```
curl -H 'Content-Type: application/json' -d '[{"labels":{"alertname":"co.alert.SomeAler_LOW_LEVEL_ALERT", "env":"prod"}}]' http://ec2-3-73-1-232.eu-central-1.compute.amazonaws.com:9093/api/v1/alerts
```

If everything went fine, created alert is visible in Alertmanager console `http://<ALERTMANAGER_ADDRESS>:9093//#/alerts` and alert and possibly incident is created in Pagerduty. I noticed some delay between creating alert in Alertmanager and creating alert in Pagerduty so wait few minute before checking Pagerduty console.

# Clean up

Run `terraform destroy -auto-approve` to remove all resources from Pagerduty and AWS.