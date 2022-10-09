module "dev_vpc" {
  source = "../../modules/vpc"
}
module "dev_securitygroups" {
  source = "../../modules/securitygroups"
  vpc_id = module.dev_vpc.vpc_id
}
# module "DB_securitygroup" {
#   source      = "../../modules/DB_securitygroup"
#   vpc_id      = module.dev_vpc.vpc_id
# }
module "keypair" {
  source             = "../../modules/key-pair"
  path_to_public_key = var.dev_path_to_public_key
  key_name           = var.dev_key_name
}
module "dev_docker" {
  source            = "../../modules/docker"
  docker_ami        = var.dev_instance_ami
  security_group_id = module.dev_securitygroups.DocJenSona_sg
  subnet_id         = module.dev_vpc.PUB_SN1
  keyname           = module.keypair.keypair_id
}
module "dev_sonarQube" {
  source           = "../../modules/sonarQube"
  sonarQube_ami    = var.dev_instance_ami
  securitygroup_id = module.dev_securitygroups.DocJenSona_sg
  subnet_id        = module.dev_vpc.PUB_SN2
  keyname          = var.dev_key_name
}
module "dev_ansible" {
  source           = "../../modules/ansible"
  Ansible_ami      = var.dev_instance_ami
  securitygroup_id = module.dev_securitygroups.DocJenSona_sg
  subnet_id        = module.dev_vpc.PUB_SN1
  keyname          = module.keypair.keypair_id
}

resource "null_resource" "configure" {
  connection {
    type        = "ssh"
    host        = module.dev_ansible.Ansible_IP
    user        = "ec2-user"
    private_key = file("~/keypairs/test-key")
  }
  provisioner "file" {
    source      = "~/myproject/Module-JenContainProject/environments/dev/yml"
    destination = "/home/ec2-user/yml"
  }
  provisioner "file" {
    source      = "~/keypairs/test-key"
    destination = "/home/ec2-user/test-key"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum upgrade -y",
      "sudo yum install python3.8 -y",
      "sudo alternatives --set python /usr/bin/python3.8",
      "sudo yum install ansible -y",
      "sudo chmod 400 /home/ec2-user/test-key",
      "sudo chown ec2-user:ec2-user /etc/ansible/hosts",
      "echo \"license_key: eu01xx11b9228cd1071fed3b8e7b7658ee5bNRAL\" | sudo tee -a /etc/newrelic-infra.yml",
      "sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo",
      "sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'",
      "sudo yum install newrelic-infra -y",
      "sudo su - \"echo Admin123@ | passwd ec2-user --stdin\"",
      "sudo su - \"sed -ie 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config\"",
      "sudo service sshd reload",
      "sudo chmod -R 700 .ssh/",
      "sudo chown -R ec2-user:ec2-user .ssh/",
      "sudo bash -c ' echo \"StrictHostKeyChecking No\" >> /etc/ssh/ssh_config'",
      "sudo yum install -y yum-utils",
      "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
      "sudo yum install docker-ce -y",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ec2-user",
      "sudo echo \"[docker_host]\" >> /etc/ansible/hosts",
      "sudo echo \"${module.dev_docker.Docker_pubIP} ansible_ssh_private_key_file=/home/ec2-user/test-key\" >> /etc/ansible/hosts",
      "sudo chmod 777 /etc/ansible/hosts",
      "sudo mkdir /opt/docker",
      "sudo chown -R ec2-user:ec2-user /opt/docker",
      "sudo chmod -R 700 /opt/docker",
      "mv yml/* /opt/docker",
      "ansible -m ping all",
    ]
  }
}
module "dev_jenkins" {
  source           = "../../modules/jenkins"
  Jenkins_ami      = var.dev_instance_ami
  securitygroup_id = module.dev_securitygroups.DocJenSona_sg
  subnet_id        = module.dev_vpc.PUB_SN1
  keyname          = module.keypair.keypair_name
}
resource "null_resource" "configure2" {
  connection {
    type        = "ssh"
    host        = module.dev_jenkins.Jenkins_pubIP
    user        = "ec2-user"
    private_key = file("~/keypairs/test-key")
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod -R 700 .ssh/",
      "sudo chown -R ec2-user:ec2-user .ssh/",
      "sudo su - ec2-user -c \"ssh-keygen -f ~/.ssh/jenkinskey_rsa4 -t rsa -b 4096 -m PEM -N ''\"",
      "sudo bash -c ' echo \"StrictHostKeyChecking No\" >> /etc/ssh/ssh_config'",
    ]
  }
}
module "dev_instance-ami" {
  source      = "../../modules/instance_ami"
  instance_id = module.dev_docker.docker_id
}
module "dev_loadbalance" {
  source           = "../../modules/loadbalancer"
  securitygroup_id = module.dev_securitygroups.DocJenSona_sg
  subnet_id1       = module.dev_vpc.PUB_SN1
  subnet_id2       = module.dev_vpc.PUB_SN2
  vpc_id           = module.dev_vpc.vpc_id
  target_id        = module.dev_docker.docker_id
}
module "dev_launch_config" {
  source           = "../../modules/launch_config"
  image_id         = module.dev_instance-ami.instance-ami
  securitygroup_id = module.dev_securitygroups.DocJenSona_sg
  keyname          = module.keypair.keypair_name
}
module "dev_autoscaling" {
  source               = "../../modules/autoscaling"
  instance-asg-lc-name = module.dev_launch_config.instance-asg-lc
  vpc_identifier1      = module.dev_vpc.PUB_SN1
  vpc_identifier2      = module.dev_vpc.PUB_SN2
  lb_target_group_arn  = module.dev_loadbalance.Jencontainer-tg
}
module "dev_route53" {
  source      = "../../modules/route53"
  lb_dns-name = module.dev_loadbalance.JenContainer-lb
  lb_zone_id  = module.dev_loadbalance.JenContainer-lb-zoneID
}