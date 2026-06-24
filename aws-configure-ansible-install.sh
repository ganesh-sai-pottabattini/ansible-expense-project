#!/bin/bash

read -p "Access Key: " ACCESS_KEY
read -s -p "Secret Key: " SECRET_KEY
echo

aws configure set aws_access_key_id "$ACCESS_KEY"
aws configure set aws_secret_access_key "$SECRET_KEY"
aws configure set region us-east-1
aws configure set output json

echo " ==========aws config and creds ================================================================================================= "

cat ~/.aws/config
cat ~/.aws/credentials

echo " ======== Install boto3 botocore netaddr ======================================================================================== "

pip3.9 install boto3 botocore netaddr

echo " ============ Install Ansible =================================================================================================== "

sudo dnf install ansible -y

# echo " ================================================================================================================== "

# ansible-galaxy collection install amazon.aws

echo " ========= Ansible Version ==================================================================================== "

ansible --version

echo " ========= mk folder , chng ownershop and permissions ==================================================================================== "

sudo mkdir /var/log/roboshop/ | tee
sudo touch /var/log/roboshop/ansible.log | tee
sudo chown -R ec2-user:ec2-user /var/log/roboshop/ansible.log | tee
sudo chmod 777 -R /var/log/roboshop/ansible.log | tee

#read -p "Access Key: " ACCESS_KEY
# read -s -p "Secret Key: " SECRET_KEY
# echo

# aws configure set aws_access_key_id "$ACCESS_KEY"
# aws configure set aws_secret_access_key "$SECRET_KEY"
# aws configure set region us-east-1