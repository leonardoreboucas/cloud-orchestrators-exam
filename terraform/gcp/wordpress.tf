###################
# Credentials
###################

variable "project" {
  type    = string
  default = "node2faas-248113"
}

###################
# Variables
###################

variable "region_name" {
  type    = string
  default = ""
}

variable "availability_zone" {
  type    = string
  default = ""
}

variable "admin_username" {
    default = "ubuntu"
}

variable "vm_image" {
    default = "ubuntu-1404-trusty-v20170517"
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
  default = "w@rdpr3sS"
}

variable "public_key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0TiCJf98bz/0CDedyGS3Y8wC1Zn2L/xq3WguJL2A+rCl7wWOEDXzyyToHRrbjMARbmPfHxl0+JvmUgJv9H7Yml84bzyPhdXO0AfswcTS1HyVLAD5oH1cs38jUSqOupHnZtvOJ0RoG29SL0KJiDwDhUYSe0xnGNS1EP+oQZJU7X0RGc2c6ZqT70FEzizG9mSAxtw8W0HlrLA+EDEYSjIjEHrMs7G8i/bVJFRbF/jTG1oDzomL535VBzKbQgsgD4No4Mq0fnt5ZxpZF4Q3QYo2U7oO9vfLMTWBpsNAroQggz74/AH3E6qfzMOvawmKhM84astzcbSXFGhGXsKLYbTk1"
}


###################
# Provider
###################

provider "google" {
  credentials = file("/root/cloud-orchestrators-exam/common/account.json")
  project     = "${var.project}"
  region      = "${var.region_name}"
  zone        = "${var.availability_zone}"
}

resource "random_id" "bp_suffix" {
  byte_length = 4
}

###################
# Network layer
###################

resource "google_compute_network" "wordpress-network" {
  name = "wordpress-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "wordpress-subnetwork" {
  name          = "wordpress-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "${var.region_name}"
  network       = "${google_compute_network.wordpress-network.self_link}"
}

resource "google_compute_firewall" "default-in" {
  name    = "wordpress-app-in"
  network       = "${google_compute_network.wordpress-network.self_link}"
  allow {
    protocol = "tcp"
    ports    = ["80","3306","22"]
  }
  target_tags = ["wordpress"]
}

resource "google_compute_firewall" "default-out" {
  name      = "wordpress-app-out"
  network       = "${google_compute_network.wordpress-network.self_link}"
  direction = "EGRESS"
  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
  target_tags = ["wordpress"]
}

###################
# Database layer
###################

data "template_file" "config_database" {
  template = "${file("${path.module}/../config_database.tpl")}"
  vars = {
    db_name     = "${var.db_name}"
    db_user     = "${var.db_user}"
    db_password = "${var.db_pass}"
  }
}

resource "google_compute_instance" "wordpress-database" {
    name = "wordpress-database-${random_id.bp_suffix.hex}"
    machine_type = "f1-micro"
    tags = ["wordpress"]
    boot_disk {
      initialize_params {
        image = "${var.vm_image}"
      }
    }
    allow_stopping_for_update = true
    network_interface {
      network     = "${google_compute_network.wordpress-network.self_link}"
      subnetwork  = "${google_compute_subnetwork.wordpress-subnetwork.self_link}"
      access_config {}
    }
    metadata = {
      sshKeys = "${var.admin_username}:${var.public_key}"
    }
    provisioner "file" {
      connection {
        host        = "${google_compute_instance.wordpress-database.network_interface.0.access_config.0.nat_ip}"
        type        = "ssh"
        user        = "${var.admin_username}"
        private_key = file("${path.module}/../../common/wordpress.pem")
      }
      content     = "${data.template_file.config_database.rendered}"
      destination = "/tmp/config.sh"
    }
    provisioner "remote-exec" {
      connection {
        host        = "${google_compute_instance.wordpress-database.network_interface.0.access_config.0.nat_ip}"
        type        = "ssh"
        user        = "${var.admin_username}"
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
    db_host     = "${google_compute_instance.wordpress-database.network_interface.0.access_config.0.nat_ip}"
    db_name     = "${var.db_name}"
    db_user     = "${var.db_user}"
    db_password = "${var.db_pass}"
  }
}

resource "google_compute_instance" "wordpress-app1" {
    name = "wordpress-app1-${random_id.bp_suffix.hex}"
    machine_type = "f1-micro"
    tags = ["wordpress"]
    boot_disk {
      initialize_params {
        image = "${var.vm_image}"
      }
    }
    allow_stopping_for_update = true
    network_interface {
      network     = "${google_compute_network.wordpress-network.self_link}"
      subnetwork  = "${google_compute_subnetwork.wordpress-subnetwork.self_link}"
      access_config {}
    }
    metadata = {
      sshKeys = "${var.admin_username}:${var.public_key}"
    }
    provisioner "file" {
      connection {
        host        = "${google_compute_instance.wordpress-app1.network_interface.0.access_config.0.nat_ip}"
        type        = "ssh"
        user        = "${var.admin_username}"
        private_key = file("${path.module}/../../common/wordpress.pem")
      }
      content     = "${data.template_file.config.rendered}"
      destination = "/tmp/config.sh"
    }
    provisioner "remote-exec" {
      connection {
        host        = "${google_compute_instance.wordpress-app1.network_interface.0.access_config.0.nat_ip}"
        type        = "ssh"
        user        = "${var.admin_username}"
        private_key = file("${path.module}/../../common/wordpress.pem")
      }
      inline = [
        "sudo chmod +x /tmp/config.sh",
        "sudo /tmp/config.sh",
      ]
    }
}

resource "google_compute_instance" "wordpress-app2" {
    name = "wordpress-app2-${random_id.bp_suffix.hex}"
    machine_type = "f1-micro"
    tags = ["wordpress"]
    boot_disk {
      initialize_params {
        image = "${var.vm_image}"
      }
    }
    allow_stopping_for_update = true
    network_interface {
      network     = "${google_compute_network.wordpress-network.self_link}"
      subnetwork  = "${google_compute_subnetwork.wordpress-subnetwork.self_link}"
      access_config {}
    }
    metadata = {
      sshKeys = "${var.admin_username}:${var.public_key}"
    }
    provisioner "file" {
      connection {
        host        = "${google_compute_instance.wordpress-app2.network_interface.0.access_config.0.nat_ip}"
        type        = "ssh"
        user        = "${var.admin_username}"
        private_key = file("${path.module}/../../common/wordpress.pem")
      }
      content     = "${data.template_file.config.rendered}"
      destination = "/tmp/config.sh"
    }
    provisioner "remote-exec" {
      connection {
        host        = "${google_compute_instance.wordpress-app2.network_interface.0.access_config.0.nat_ip}"
        type        = "ssh"
        user        = "${var.admin_username}"
        private_key = file("${path.module}/../../common/wordpress.pem")
      }
      inline = [
        "sudo chmod +x /tmp/config.sh",
        "sudo /tmp/config.sh",
      ]
    }
}

###################
# LoadBalance layer
###################

# resource "google_compute_target_pool" "default" {
#   name = "wordpress-instance-pool"
#   instances = [
#     "${google_compute_instance.wordpress-app1.self_link}",
#     "${google_compute_instance.wordpress-app2.self_link}",
#   ]
#   health_checks = [
#     "${google_compute_http_health_check.default.name}",
#   ]
# }
#
# resource "google_compute_http_health_check" "default" {
#   name               = "default"
#   request_path       = "/"
#   check_interval_sec = 1
#   timeout_sec        = 1
# }
#
# resource "google_compute_forwarding_rule" "wordpress-lb-frontend" {
#   name       = "wordpress-lb-frontend"
#   target     = "${google_compute_target_pool.default.self_link}"
#   port_range = "80"
#   load_balancing_scheme = "EXTERNAL"
# }

###################
# Outputs
###################

# output "URL" {
#   value = "http://${google_compute_forwarding_rule.wordpress-lb-frontend.ip_address}"
# }

output "App1-addres" {
  value = "${google_compute_instance.wordpress-app1.network_interface.0.access_config.0.nat_ip}"
}

output "App2-addres" {
  value = "${google_compute_instance.wordpress-app2.network_interface.0.access_config.0.nat_ip}"
}

output "Database-addres" {
  value = "${google_compute_instance.wordpress-database.network_interface.0.access_config.0.nat_ip}"
}

output "apply-finished-wp" {
  value = "true"
}
