# Provision Jenkins, sonarQube Docker_host SecurityGroup
resource "aws_security_group" "DocJenSona_sg" {
  name= var.security-group_Name
  vpc_id= var.vpc_id

  ingress {
    description = "Allow all traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port = var.sona_port
    to_port = var.sona_port
    protocol = "tcp"
    cidr_blocks = [var.all_cidr]
  }
  ingress {
    from_port   = var.custom_http
    to_port     = var.custom_http
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }
  tags = {
    Name = var.security-group_Name
  }
}





# # Provision Jenkins,SonaQube and Docker_host SecurityGroup
# resource "aws_security_group" "DocJenSona_sg" { 
#   name= var.security-group_Name
#   vpc_id= var.vpc_id
# }

# resource "aws_security_group_rule" "allow_http" {
#   type="ingress"
#   security_group_id = aws_security_group.DocJenSona_sg.id
#   from_port = var.http_port
#   to_port = var.http_port
#   protocol = "tcp"
#   cidr_blocks = [var.all_cidr]
# }
# resource "aws_security_group_rule" "allow_ssh" {
#   type = "ingress"
#   security_group_id = aws_security_group.DocJenSona_sg.id
#   from_port = var.ssh_port
#   to_port = var.ssh_port
#   protocol = "tcp"
#   cidr_blocks = [var.vpc_cidr]
# }
# resource "aws_security_group_rule" "allow_sona" {
#   type = "ingress"
#   security_group_id = aws_security_group.DocJenSona_sg.id
#   from_port = var.sona_port
#   to_port = var.sona_port
#   protocol = "tcp"
#   cidr_blocks = [var.all_cidr]
# }
# resource "aws_security_group_rule" "allow_custom" {
#   type = "ingress"
#   security_group_id = aws_security_group.DocJenSona_sg.id
#   from_port = var.custom_http
#   to_port = var.custom_http
#   protocol = "tcp"
#   cidr_blocks = [var.all_cidr]
# }
# resource "aws_security_group_rule" "allow_outgoing" {
#     type = "egress"
#     security_group_id = aws_security_group.DocJenSona_sg.id
#     from_port       = 0
#      to_port         = 0
#      protocol        = "-1"
#      cidr_blocks     = [var.all_cidr]
# }
