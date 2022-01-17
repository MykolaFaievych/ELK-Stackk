#!/bin/bash
yum update
yum upgrade
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${version}-x86_64.rpm
rpm --install elasticsearch-${version}-x86_64.rpm
cd /usr/share/elasticsearch/
echo "y" | bin/elasticsearch-plugin install discovery-ec2
echo "-Xms2g" >> /etc/elasticsearch/jvm.options
echo "-Xmx2g" >> /etc/elasticsearch/jvm.options

variable=$(aws ec2 describe-instances --region us-east-2 --instance-ids \
$(aws autoscaling describe-auto-scaling-instances --region us-east-2 --output text \
--query "AutoScalingInstances[?AutoScalingGroupName=='es'].InstanceId") \
--query "Reservations[].Instances[].PrivateIpAddress")
echo "cluster.initial_master_nodes: $variable" >> /etc/elasticsearch/elasticsearch.yml 

cat <<EOF >> /etc/elasticsearch/elasticsearch.yml 
http.port: 9200
cluster.name: task1    
bootstrap.memory_lock: true  
network.host: [_local_,_site_]  
discovery.seed_providers: ec2  
discovery.ec2.endpoint: ec2.us-east-2.amazonaws.com  
cloud.node.auto_attributes: true  
cluster.routing.allocation.awareness.attributes: aws_availability_zone 
EOF
systemctl enable elasticsearch.service
systemctl start elasticsearch.service