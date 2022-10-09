# Create Doocker host Server
resource "aws_instance" "JenCont-Docker-Server" {
  ami                         = var.docker_ami
  instance_type               = var.instance_type
  availability_zone           = var.az_A
  vpc_security_group_ids      = [var.security_group_id]
  subnet_id                   = var.subnet_id
  key_name                    = var.keyname
  associate_public_ip_address = var.ass_pub_ip_address
  user_data                   = "${file("~/myproject/Module-JenContainProject/modules/docker/user_data.sh")}"
  tags = {
    Name = var.Docker_Server_Name
  }
}