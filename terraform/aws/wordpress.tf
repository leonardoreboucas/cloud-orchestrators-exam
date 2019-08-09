###################
# Credentials
###################

# variable "aws_access_key" {
#   type    = string
# }
#
# variable "aws_secret_key" {
#   type    = string
# }

###################
# Variables
###################

variable "aws_region_name" {
  type    = string
  default = "us-west-2"
}

variable "availability_zone" {
  type    = string
  default = "us-west-2a"
}

variable "db_name" {
  type    = string
  default = "wordpress"
}

variable "db_user" {
  type    = string
  default = "wpuser"
}

variable "db_pass" {
  type    = string
  default = "H!Sh1CoR3!"
}

variable "public_key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0TiCJf98bz/0CDedyGS3Y8wC1Zn2L/xq3WguJL2A+rCl7wWOEDXzyyToHRrbjMARbmPfHxl0+JvmUgJv9H7Yml84bzyPhdXO0AfswcTS1HyVLAD5oH1cs38jUSqOupHnZtvOJ0RoG29SL0KJiDwDhUYSe0xnGNS1EP+oQZJU7X0RGc2c6ZqT70FEzizG9mSAxtw8W0HlrLA+EDEYSjIjEHrMs7G8i/bVJFRbF/jTG1oDzomL535VBzKbQgsgD4No4Mq0fnt5ZxpZF4Q3QYo2U7oO9vfLMTWBpsNAroQggz74/AH3E6qfzMOvawmKhM84astzcbSXFGhGXsKLYbTk1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}


###################
# Provider
###################

provider "aws" {
  region     = "${var.aws_region_name}"
  shared_credentials_file = "/root/.aws/credentiais"
  #access_key = "${var.access_key}"
  #secret_key = "${var.secret_key}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

###################
# Database layer
###################

# resource "aws_db_instance" "wordpress-db" {
#   allocated_storage         = 20
#   storage_type              = "gp2"
#   engine                    = "mysql"
#   engine_version            = "5.7"
#   instance_class            = "db.t2.micro"
#   name                      = "${var.db_name}"
#   username                  = "${var.db_user}"
#   password                  = "${var.db_pass}"
#   parameter_group_name      = "default.mysql5.7"
#   vpc_security_group_ids    = ["${aws_security_group.wordpress-db-security-group.id}"]
#   availability_zone         = "${var.availability_zone}"
#   skip_final_snapshot       = true
#   apply_immediately         = true
# }

data "template_file" "config_database" {
  template = "${file("${path.module}/../config_database.tpl")}"
  vars = {
    db_name     = "${var.db_name}"
    db_user     = "${var.db_user}"
    db_password = "${var.db_pass}"
  }
}

resource "aws_instance" "wordpress-database" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.instance_type}"
  key_name               = "wordpress"
  availability_zone      = "${var.availability_zone}"
  network_interface {
    network_interface_id = "${aws_network_interface.wordpress-database-network_interface.id}"
    device_index         = 0
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
  tags = {
    Name = "wordpress-database"
  }
  provisioner "file" {
    connection {
      host        = "${aws_eip.public-ip-database.public_ip}"
      type        = "ssh"
      user        = "admin"
      private_key = file("${path.module}/../../common/wordpress.pem")
    }
    content     = "${data.template_file.config_database.rendered}"
    destination = "/tmp/config.sh"
  }
  provisioner "remote-exec" {
    connection {
      host        = "${aws_eip.public-ip-database.public_ip}"
      type        = "ssh"
      user        = "admin"
      private_key = file("${path.module}/../../common/wordpress.pem")
    }
    inline = [
      "sudo chmod +x /tmp/config.sh",
      "sudo /tmp/config.sh",
    ]
  }
}

###################
# Apps layer
###################

data "template_file" "config" {
  template = "${file("${path.module}/../config.tpl")}"
  vars = {
    db_host     = "${aws_eip.public-ip-database.public_ip}"
    db_name     = "${var.db_name}"
    db_user     = "${var.db_user}"
    db_password = "${var.db_pass}"
  }
}

resource "aws_key_pair" "wordpress" {
  key_name   = "wordpress"
  public_key = "${var.public_key}"
}

resource "aws_instance" "wordpress-app1" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.instance_type}"
  key_name               = "wordpress"
  availability_zone      = "${var.availability_zone}"
  network_interface {
    network_interface_id = "${aws_network_interface.wordpress-1-network_interface.id}"
    device_index         = 0
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
  tags = {
    Name = "wordpress-1"
  }
  provisioner "file" {
    connection {
      host        = "${aws_eip.public-ip-app1.public_ip}"
      type        = "ssh"
      user        = "admin"
      private_key = file("${path.module}/../../common/wordpress.pem")
    }
    content     = "${data.template_file.config.rendered}"
    destination = "/tmp/config.sh"
  }
  provisioner "remote-exec" {
    connection {
      host        = "${aws_eip.public-ip-app1.public_ip}"
      type        = "ssh"
      user        = "admin"
      private_key = file("${path.module}/../../common/wordpress.pem")
    }
    inline = [
      "sudo chmod +x /tmp/config.sh",
      "sudo /tmp/config.sh",
    ]
  }
}

resource "aws_instance" "wordpress-app2" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.instance_type}"
  key_name               = "wordpress"
  availability_zone      = "${var.availability_zone}"
  network_interface {
    network_interface_id = "${aws_network_interface.wordpress-2-network_interface.id}"
    device_index         = 0
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
  tags = {
    Name = "wordpress-2"
  }
  provisioner "file" {
    connection {
      host        = "${aws_eip.public-ip-app2.public_ip}"
      type        = "ssh"
      user        = "admin"
      private_key = file("${path.module}/../../common/wordpress.pem")
    }
    content     = "${data.template_file.config.rendered}"
    destination = "/tmp/config.sh"
  }
  provisioner "remote-exec" {
    connection {
      host        = "${aws_eip.public-ip-app2.public_ip}"
      type        = "ssh"
      user        = "admin"
      private_key = file("${path.module}/../../common/wordpress.pem")
    }
    inline = [
      "sudo chmod +x /tmp/config.sh",
      "sudo /tmp/config.sh",
    ]
  }
}

###################
# Network layer
###################

resource "aws_vpc" "default" {
  cidr_block       = "10.0.0.0/16"
  #instance_tenancy = "dedicated"

  tags = {
    Name = "wordpress"
  }
}

resource "aws_subnet" "default" {
  vpc_id     = "${aws_vpc.default.id}"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "wordpress"
  }
}

resource "aws_eip" "public-ip-database" {
  vpc                       = true
  network_interface         = "${aws_network_interface.wordpress-database-network_interface.id}"
  tags = {
    name = "wordpress-database"
  }
}

resource "aws_eip" "public-ip-app1" {
  vpc                       = true
  network_interface         = "${aws_network_interface.wordpress-1-network_interface.id}"
  tags = {
    name = "wordpress-1"
  }
}

resource "aws_eip" "public-ip-app2" {
  vpc                       = true
  network_interface         = "${aws_network_interface.wordpress-2-network_interface.id}"
  tags = {
    name = "wordpress-2"
  }
}

resource "aws_network_interface" "wordpress-database-network_interface" {
  subnet_id   = "${data.aws_subnet.default.id}"
  security_groups = ["${aws_security_group.wordpress-security-group.id}"]
  tags = {
    Name = "wordpress-database"
  }
}

resource "aws_network_interface" "wordpress-1-network_interface" {
  subnet_id   = "${aws_subnet.default.id}"
  security_groups = ["${aws_security_group.wordpress-security-group.id}"]
  tags = {
    Name = "wordpress-1"
  }
}

resource "aws_network_interface" "wordpress-2-network_interface" {
  subnet_id   = "${aws_subnet.default.id}"
  security_groups = ["${aws_security_group.wordpress-security-group.id}"]
  tags = {
    Name = "wordpress-2"
  }
}

resource "aws_security_group" "wordpress-security-group" {
  name        = "wordpress-security-group"
  description = "wordpress-security-group"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_security_group" "wordpress-db-security-group" {
#   name        = "wordpress-db-security-group-"
#   description = "wordpress-db-security-group"
#   vpc_id      = "${data.aws_vpc.default.id}"
#
#   ingress {
#     from_port   = 3306
#     to_port     = 3306
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

###################
# Outputs
###################

output "App1-address" {
  value = "${aws_eip.public-ip-app1.public_ip}"
}

output "App2-address" {
  value = "${aws_eip.public-ip-app2.public_ip}"
}

output "Database-address" {
  value = "${aws_eip.public-ip-database.public_ip}"
}
