# Provision Jenkins Server
resource "aws_instance" "Jenkins-Host" {
  ami                    = var.Jenkins_ami
  instance_type          = var.instance_type
  availability_zone      = var.az_A
  key_name               = var.keyname
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.securitygroup_id]
  associate_public_ip_address = var.ass_pub_ip_address
  user_data              = "${file("~/myproject/Module-JenContainProject/modules/jenkins/user_data.sh")}"
  tags = {
    Name = var.Jenkins_Server_Name
  }
}

