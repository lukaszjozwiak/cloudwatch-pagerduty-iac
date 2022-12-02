data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key is probably fine, but not required. default should be sufficient

# resource "aws_key_pair" "alertmanager_key" {
#   key_name   = "alertmanager-key"
#   public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFBX8u8mQKQ9DAhq5jMfxkjU4YFutv+EwHQnNazBM5co e-uzja@PLPC015304"
# }

# create security group for ssh and alertmanager, default sg doesn't allow inbound traffic

resource "aws_security_group" "alertmanager" {
  name        = "allow_alertmanager"
  description = "Allow Alertmanager"

  ingress {
    description      = "Allow Alertmanager"
    from_port        = 9093
    to_port          = 9093
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_alertmanager"
  }
}

# https://acloudxpert.com/install-setup-alertmanager-on-amazon-linux-centos-rhel/
# https://blog.ruanbekker.com/blog/2019/05/17/install-alertmanager-to-alert-based-on-metrics-from-prometheus/
resource "aws_instance" "alertmanager" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  # key_name      = "test-keypair" #aws_key_pair.alertmanager_key.key_name
  tags = {
    Name = "Alermanager"
  }
  security_groups             = [aws_security_group.alertmanager.name]
  user_data_replace_on_change = true
  user_data                   = <<EOF
  
  #!/bin/bash
  set -x
  pwd
  useradd --no-create-home --shell /bin/false alertmanager
  wget https://github.com/prometheus/alertmanager/releases/download/v0.24.0/alertmanager-0.24.0.linux-amd64.tar.gz
  tar -xvf alertmanager-0.24.0.linux-amd64.tar.gz
  cp alertmanager-0.24.0.linux-amd64/alertmanager /usr/local/bin/
  cp alertmanager-0.24.0.linux-amd64/amtool /usr/local/bin/
  chown alertmanager:alertmanager /usr/local/bin/alertmanager
  chown alertmanager:alertmanager /usr/local/bin/amtool
  mkdir /etc/alertmanager

  echo "

route:
  receiver: 'qa'
  routes:
    - receiver: 'qa'
      match_re:
        env: 'qa'
    - receiver: 'prod'
      match_re:
        env: 'prod'
receivers:
  - name: 'qa'
    pagerduty_configs:
      - send_resolved: false
        routing_key: \"${var.demo_service_qa_events_integration_key}\"
        client: '{{ template \"pagerduty.default.client\" . }}'
        client_url: '{{ template \"pagerduty.default.clientURL\" . }}'
        description: '{{ template \"pagerduty.default.description\" .}}'
  - name: 'prod'
    pagerduty_configs:
      - send_resolved: false
        routing_key: \"${var.demo_service_events_integration_key}\"
        client: '{{ template \"pagerduty.default.client\" . }}'
        client_url: '{{ template \"pagerduty.default.clientURL\" . }}'
        description: '{{ template \"pagerduty.default.description\" .}}'
" >> /etc/alertmanager/alertmanager.yml

  chown alertmanager:alertmanager -R /etc/alertmanager

  echo "

[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
WorkingDirectory=/etc/alertmanager/
ExecStart=/usr/local/bin/alertmanager --config.file=/etc/alertmanager/alertmanager.yml --web.external-url http://0.0.0.0:9093

[Install]
WantedBy=multi-user.target
" >> /etc/systemd/system/alertmanager.service

  systemctl daemon-reload
  systemctl restart alertmanager
  systemctl status alertmanager
  systemctl enable alertmanager
  EOF
}



