#!/bin/bash
yum update
yum install -y java-1.8.0-openjdk
wget https://artifacts.elastic.co/downloads/logstash/logstash-${version}-x86_64.rpm
rpm --install logstash-${version}-x86_64.rpm
systemctl enable logstash.service

variable1=$(aws ec2 describe-instances --region us-east-2 --instance-ids \
$(aws autoscaling describe-auto-scaling-instances --region us-east-2 --output text \
--query "AutoScalingInstances[?AutoScalingGroupName=='es'].InstanceId") \
--query "Reservations[].Instances[].PrivateIpAddress" --output text | awk  '{ print $1 }')
variable2=$(aws ec2 describe-instances --region us-east-2 --instance-ids \
$(aws autoscaling describe-auto-scaling-instances --region us-east-2 --output text \
--query "AutoScalingInstances[?AutoScalingGroupName=='es'].InstanceId") \
--query "Reservations[].Instances[].PrivateIpAddress" --output text | awk  '{ print $2 }')
variable3=$(aws ec2 describe-instances --region us-east-2 --instance-ids \
$(aws autoscaling describe-auto-scaling-instances --region us-east-2 --output text \
--query "AutoScalingInstances[?AutoScalingGroupName=='es'].InstanceId") \
--query "Reservations[].Instances[].PrivateIpAddress" --output text | awk  '{ print $3 }')
variable4=$(aws ec2 describe-instances --region us-east-2 --instance-ids \
$(aws autoscaling describe-auto-scaling-instances --region us-east-2 --output text \
--query "AutoScalingInstances[?AutoScalingGroupName=='es'].InstanceId") \
--query "Reservations[].Instances[].PrivateIpAddress" --output text | awk  '{ print $4 }')
variable5=$(aws ec2 describe-instances --region us-east-2 --instance-ids \
$(aws autoscaling describe-auto-scaling-instances --region us-east-2 --output text \
--query "AutoScalingInstances[?AutoScalingGroupName=='es'].InstanceId") \
--query "Reservations[].Instances[].PrivateIpAddress" --output text | awk  '{ print $5 }')
variable6=$(aws ec2 describe-instances --region us-east-2 --instance-ids \
$(aws autoscaling describe-auto-scaling-instances --region us-east-2 --output text \
--query "AutoScalingInstances[?AutoScalingGroupName=='es'].InstanceId") \
--query "Reservations[].Instances[].PrivateIpAddress" --output text | awk  '{ print $6 }')
echo "input {
    beats {
        port => \"5044\"
    }
}
filter {
}
output {
    elasticsearch {
        hosts => [\"http://$variable1:9200\",\"http://$variable2:9200\",\"http://$variable3:9200\",\"http://$variable4:9200\",\"http://$variable5:9200\",\"http://$variable6:9200\"]
    }
}" >> /etc/logstash/conf.d/filebeat.conf

systemctl start logstash.service
