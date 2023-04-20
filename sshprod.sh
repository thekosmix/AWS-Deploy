#!/bin/sh
# This script helps you in sshing into your EBS-backed instances with dynamic IPs
# On envoking this script, it adds ssh-access to the machines, then get their IPs and ssh into instances and on exiting revokes the ssh access from them

# you need to install AWS cli and add a credential for your prod environment
# you can do it by running: aws configure --profile=prod
# for more on AWS CLI (which is a very awesome tool) read here: http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html

# prod environment profile added in AWS ClI
profile=prod

# security group Id created by Elastic Beanstalk, which can be found in Security Groups tab of EC2 dashboard
# look for SG (security Group) SecurityGroup for ElasticBeanstalk environment.
group_id=sg-xxxxxxxx

# pem file with which your prod environemtn is running
pem=prod.pem

# if you have multiple instances running then which one do you want to connect to
whichInstance=$1

# instance IP address
ipStr=`aws ec2 describe-instances --profile=$profile | grep -m $whichInstance PublicIpAddress | tail -n1`
ip=`echo $ipStr | grep -o -P '(?<="PublicIpAddress": ").*(?=",)'`

# your IP address to add port 22 access for in inbound protocol
myIp=`curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//'`

echo `date` instanceIp: $ip
echo `date` myIP: $myIp

#add my ip to security group
aws ec2 authorize-security-group-ingress --group-id $group_id --protocol tcp --port 22 --cidr $myIp/32 --profile=$profile
echo `date` added shh access to strollup security group

# shhing into it
ssh -i /path_to_pem_file/$pem ec2-user@$ip
# after sshing you can do all sorts of things like, checking/tailing on server log files, check system resurces, etc

# after running the exit command remove, ssh access
echo `date` removing ssh access 
aws ec2 revoke-security-group-ingress --group-id $group_id --protocol tcp --port 22 --cidr $myIp/32 --profile=$profile
echo `date` done...
