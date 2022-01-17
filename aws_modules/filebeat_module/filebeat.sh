#!/bin/bash
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${version}-x86_64.rpm
rpm --install filebeat-${version}-x86_64.rpm
systemctl enable filebeat.service
amazon-linux-extras install nginx1 -y 
systemctl enable nginx
systemctl start nginx

variable1=$(aws ec2 describe-instances --region us-east-2 --instance-ids \
$(aws autoscaling describe-auto-scaling-instances --region us-east-2 --output text \
--query "AutoScalingInstances[?AutoScalingGroupName=='log'].InstanceId") \
--query "Reservations[].Instances[].PrivateIpAddress" --output text | awk  '{ print $1 }')
variable2=$(aws ec2 describe-instances --region us-east-2 --instance-ids \
$(aws autoscaling describe-auto-scaling-instances --region us-east-2 --output text \
--query "AutoScalingInstances[?AutoScalingGroupName=='log'].InstanceId") \
--query "Reservations[].Instances[].PrivateIpAddress" --output text | awk  '{ print $2 }')

echo "filebeat.inputs:
- type: log
  paths:
    - /var/log/nginx/*.log
processors:
- drop_fields:
      fields: [verb,id]
output.logstash:
  hosts: [\"$variable1:5044\",\"$variable2:5044\"]
  loadbalance: true" > /etc/filebeat/filebeat.yml
systemctl start filebeat.service