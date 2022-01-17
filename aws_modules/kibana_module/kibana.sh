#!/bin/bash 
wget https://artifacts.elastic.co/downloads/kibana/kibana-${version}-x86_64.rpm
rpm --install kibana-${version}-x86_64.rpm
systemctl enable kibana
amazon-linux-extras install nginx1 -y 
systemctl enable nginx
cat <<'EOF' >> /etc/nginx/conf.d/oauth2_proxy.conf
server {
  listen      80;
  server_name _;
  location / {
    proxy_pass http://localhost:4180/;
    proxy_http_version 1.1;   
    proxy_set_header Upgrade $http_upgrade;   
    proxy_set_header Connection 'upgrade';  
    proxy_set_header Host $host;  
    proxy_cache_bypass $http_upgrade;
  }
} 
EOF
cat <<'EOF' >> /etc/nginx/conf.d/kibana.conf 
server {
  listen      8080;
  server_name _;
  location / {
    proxy_pass http://localhost:5601/;
    proxy_http_version 1.1;   
    proxy_set_header Upgrade $http_upgrade;   
    proxy_set_header Connection 'upgrade';  
    proxy_set_header Host $host;  
    proxy_cache_bypass $http_upgrade;
  }
} 
EOF

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
echo "elasticsearch.hosts: [\"http://$variable1:9200\",\"http://$variable2:9200\",\"http://$variable3:9200\",\"http://$variable4:9200\",\"http://$variable5:9200\",\"http://$variable6:9200\"]" >> /etc/kibana/kibana.yml

cat <<EOF >> /etc/kibana/kibana.yml 
server.publicBaseUrl: "http://localhost:5601"
server.host: "localhost"
EOF
systemctl daemon-reload
systemctl start nginx
systemctl start kibana.service
wget https://github.com/oauth2-proxy/oauth2-proxy/releases/download/v7.2.1/oauth2-proxy-v7.2.1.linux-amd64.tar.gz
wget https://github.com/oauth2-proxy/oauth2-proxy/releases/download/v7.2.1/oauth2-proxy-v7.2.1.linux-amd64-sha256sum.txt
tar -xzf oauth2-proxy-v7.2.1.linux-amd64.tar.gz
sha256sum -c oauth2-proxy-v7.2.1.linux-amd64-sha256sum.txt
cd oauth2-proxy-v7.2.1.linux-amd64/

./oauth2-proxy \
--client-id  <client-id> \
--client-secret <client-secret> \
--upstream "http://127.0.0.1:8080/" \
--http-address "http://127.0.0.1:4180" \
--cookie-name "_oauth2_proxy" \
--cookie-secure false \
--cookie-secret <cookie-secret> \
--provider github \
--email-domain "*" \