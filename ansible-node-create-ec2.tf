terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "=6.48.0"
        }
    }
}

# Configure the AWS provider
provider "aws" {
    region = "us-east-1"
}

data "aws_security_group" "sg" {
    for_each = toset(["ansible-control-node", "common"])
    filter {
        name   = "group-name"
        values = [each.value]
    }
  
}

resource "aws_instance" "ansible" {
    ami = "ami-0220d79f3f480ecf5"
    instance_type = "t3.micro"
    vpc_security_group_ids = [
        for sg in data.aws_security_group.sg : sg.id # for pakkana em isthe adhe id ki mundu raayali
        ]
    user_data = <<-EOF
        #!/bin/bash
        dnf install ansible -y
        EOF
        
    tags = {
        Name = "Ansible Control Node"
        Project = "Expense"
    }
}

output "IP_address" {
    value = aws_instance.ansible.public_ip
}

/*
resource "aws_security_group" "ansible_sg" {
  name = "ansible-control-node"
  description = "using terraform to create ansible control node security group"

  # outbound traffic
  egress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp" # all traffic
    cidr_blocks      = ["117.98.211.63/32"]
  }
  
  tags = {
    Name = "Ansible Control Node Security Group"
    Project = "Expense"
  }
}
*/