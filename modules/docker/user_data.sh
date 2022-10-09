#!/bin/bash
sudo yum update -y
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
echo "license_key: eu01xx11b9228cd1071fed3b8e7b7658ee5bNRAL" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y
sudo groupadd docker && sudo usermod -aG docker ec2-user
sudo su
echo "Admin123@" | sudo passwd ec2-user --stdin 
echo "ec2-user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sed -ie 's@PasswordAuthentication no@PasswordAuthentication yes@' /etc/ssh/sshd_config
chmod 600 .ssh/authorized_keys
sudo service sshd restart
sudo systemctl enable docker
sudo systemctl start docker