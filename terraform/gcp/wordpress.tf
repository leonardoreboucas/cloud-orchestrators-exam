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

resource "google_compute_network" "wordpress-network" {
  name = "wordpress-network"
  auto_create_subnetworks = false
}

output "apply-finished-wp" {
  value = "true"
}
