/* terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=6.48.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region where resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID for the security groups."
  type        = string
}

variable "route53_zone_name" {
  description = "Route53 hosted zone name (example.com)."
  type        = string
  default = "trivikram.online"
}

variable "web_server_ip" {
  description = "Public IPv4 address for the web server A record."
  type        = string
}

variable "app_server_ip" {
  description = "Private or public IPv4 address for the app server A record."
  type        = string
}

variable "api_server_ip" {
  description = "Private or public IPv4 address for the API server A record."
  type        = string
}

variable "web_allowed_cidrs" {
  description = "CIDR blocks allowed to access the web tier."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the hosts."
  type        = string
  default     = "203.0.113.0/24"
}

data "aws_route53_zone" "expense" {
  name         = var.route53_zone_name
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.expense.zone_id
  name    = "www.${var.route53_zone_name}"
  type    = "A"
  ttl     = 300
  records = [var.web_server_ip]
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.expense.zone_id
  name    = "app.${var.route53_zone_name}"
  type    = "A"
  ttl     = 300
  records = [var.app_server_ip]
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.expense.zone_id
  name    = "api.${var.route53_zone_name}"
  type    = "A"
  ttl     = 300
  records = [var.api_server_ip]
}

resource "aws_security_group" "web" {
  name        = "expense-web-sg"
  description = "Allow inbound HTTP, HTTPS, and SSH for the web tier."
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow HTTP from the internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.web_allowed_cidrs
    ipv6_cidr_blocks = []
  }

  ingress {
    description      = "Allow HTTPS from the internet"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = var.web_allowed_cidrs
    ipv6_cidr_blocks = []
  }

  ingress {
    description      = "Allow SSH from the admin CIDR"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.allowed_ssh_cidr]
    ipv6_cidr_blocks = []
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "expense-web-sg"
  }
}

resource "aws_security_group" "app" {
  name        = "expense-app-sg"
  description = "Allow inbound app traffic from the web tier and SSH from the admin CIDR."
  vpc_id      = var.vpc_id

  ingress {
    description            = "Allow app traffic from the web security group"
    from_port              = 8080
    to_port                = 8080
    protocol               = "tcp"
    security_groups        = [aws_security_group.web.id]
    self                   = false
  }

  ingress {
    description      = "Allow SSH from the admin CIDR"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.allowed_ssh_cidr]
    ipv6_cidr_blocks = []
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "expense-app-sg"
  }
}

resource "aws_security_group" "db" {
  name        = "expense-db-sg"
  description = "Allow inbound database traffic from the app tier only."
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow MySQL from the app security group"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
    self            = false
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "expense-db-sg"
  }
}

output "route53_zone_id" {
  description = "The Route53 hosted zone ID used for the DNS records."
  value       = data.aws_route53_zone.expense.zone_id
}

output "www_record_name" {
  description = "The FQDN for the web A record."
  value       = aws_route53_record.www.fqdn
}

output "app_record_name" {
  description = "The FQDN for the app A record."
  value       = aws_route53_record.app.fqdn
}

output "api_record_name" {
  description = "The FQDN for the API A record."
  value       = aws_route53_record.api.fqdn
}

output "web_sg_id" {
  description = "ID of the web security group."
  value       = aws_security_group.web.id
}

output "app_sg_id" {
  description = "ID of the app security group."
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "ID of the database security group."
  value       = aws_security_group.db.id
}
*/