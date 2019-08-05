###################
# Credentials
###################

variable "subscription_id" {
    type    = string
    default = "9cf8b4c4-cd80-43a7-bab0-9a6bf01d3b25"
}

variable "tenant_id" {
    type    = string
    default = "df7a7582-1857-4a55-85f3-b8c728226d1b"
}

variable "client_id" {
    type    = string
    default = "d40d1621-8c94-4704-9188-c5c65bf25bcf"
}

variable "client_secret" {
    type    = string
    default = "8hPfNkl6-V/Tb?6[cWdenSZvrrIrbOS7"
}

###################
# Variables
###################

variable "location" {
    type    = string
    default = "East US"
}

variable "admin_username" {
    default = "manager"
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

###################
# Provider
###################

provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  tenant_id       = "${var.tenant_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
}

resource "random_id" "bp_suffix" {
  byte_length = 4
}

###################
# Database layer
###################

resource "azurerm_mysql_database" "wordpress-db" {
  name                = "${var.db_name}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  server_name         = "${azurerm_mysql_server.wordpress-db-server.name}"
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_server" "wordpress-db-server" {
  name                = "wordpress-db-server-${random_id.bp_suffix.hex}"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  sku {
    name     = "B_Gen5_2"
    capacity = 2
    tier     = "Basic"
    family   = "Gen5"
  }

  storage_profile {
    storage_mb            = 5120
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
  }

  administrator_login          = "${var.db_user}"
  administrator_login_password = "${var.db_pass}"
  version                      = "5.7"
  ssl_enforcement              = "Disabled"
}

resource "azurerm_mysql_configuration" "wordpress-db-config" {
  name                = "interactive_timeout"
  resource_group_name = "${azurerm_resource_group.main.name}"
  server_name         = "${azurerm_mysql_server.wordpress-db-server.name}"
  value               = "600"
}

resource "azurerm_mysql_firewall_rule" "wordpress-db-firewall" {
  name                = "office"
  resource_group_name = "${azurerm_resource_group.main.name}"
  server_name         = "${azurerm_mysql_server.wordpress-db-server.name}"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

###################
# Apps layer
###################

resource "azurerm_availability_set" "wordpress-availability" {
  name                = "wordpress-availability-${random_id.bp_suffix.hex}"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  managed             = true
}

resource "azurerm_resource_group" "main" {
  name     = "wordpress-${random_id.bp_suffix.hex}"
  location = "${var.location}"
}

data "template_file" "config" {
  template = "${file("${path.module}/../config.tpl")}"
  vars = {
    db_host     = "${azurerm_mysql_server.wordpress-db-server.fqdn}"
    db_name     = "${var.db_name}"
    db_user     = "${var.db_user}@${azurerm_mysql_server.wordpress-db-server.name}"
    db_password = "${var.db_pass}"
  }
}

resource "azurerm_virtual_machine" "wordpress-app1" {
  name                  = "wordpress-app1-${random_id.bp_suffix.hex}"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  network_interface_ids = ["${azurerm_network_interface.app1.id}"]
  vm_size               = "Standard_B1ls"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true
  availability_set_id = "${azurerm_availability_set.wordpress-availability.id}"

  os_profile_linux_config{
    disable_password_authentication = true
    ssh_keys{
      key_data = "${var.public_key}"
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
    }
  }

  storage_image_reference {
    publisher = "credativ"
    offer     = "Debian"
    sku       = "9"
    version   = "latest"
  }

  storage_os_disk {
    name              = "wordpress-app1-disc-${random_id.bp_suffix.hex}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "wordpress-app1-${random_id.bp_suffix.hex}"
    admin_username = "${var.admin_username}"
  }
}

resource "azurerm_virtual_machine" "wordpress-app2" {
  name                  = "wordpress-app2-${random_id.bp_suffix.hex}"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  network_interface_ids = ["${azurerm_network_interface.app2.id}"]
  vm_size               = "Standard_B1ls"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true
  availability_set_id = "${azurerm_availability_set.wordpress-availability.id}"

  os_profile_linux_config{
    disable_password_authentication = true
    ssh_keys{
      key_data = "${var.public_key}"
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
    }
  }

  storage_image_reference {
    publisher = "credativ"
    offer     = "Debian"
    sku       = "9"
    version   = "latest"
  }

  storage_os_disk {
    name              = "wordpress-app2-disc-${random_id.bp_suffix.hex}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "wordpress-app2-${random_id.bp_suffix.hex}"
    admin_username = "${var.admin_username}"
  }
}

resource "azurerm_virtual_machine_extension" "config-app1" {
  name                 = "wordpress-app1-config-${random_id.bp_suffix.hex}"
  location             = "${azurerm_resource_group.main.location}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_machine_name = "${azurerm_virtual_machine.wordpress-app1.name}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  settings = <<SETTINGS
    {
        "commandToExecute": "echo '${var.admin_username} ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/waagent "}
SETTINGS

  provisioner "file" {
    connection {
      host        = "${azurerm_public_ip.static-ip1.ip_address}"
      type        = "ssh"
      user        = "${var.admin_username}"
      private_key = file("${path.module}/../wordpress.pem")
    }
    content     = "${data.template_file.config.rendered}"
    destination = "/tmp/config.sh"
  }
  provisioner "remote-exec" {
    connection {
      host        = "${azurerm_public_ip.static-ip1.ip_address}"
      type        = "ssh"
      user        = "${var.admin_username}"
      private_key = file("${path.module}/../wordpress.pem")
    }
    inline = [
      "sudo chmod +x /tmp/config.sh",
      "sudo /tmp/config.sh",
    ]
  }
}

resource "azurerm_virtual_machine_extension" "config-app2" {
  name                 = "wordpress-app2-config-${random_id.bp_suffix.hex}"
  location             = "${azurerm_resource_group.main.location}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_machine_name = "${azurerm_virtual_machine.wordpress-app2.name}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  settings = <<SETTINGS
    {
        "commandToExecute": "echo '${var.admin_username} ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/waagent"}
SETTINGS

  provisioner "file" {
    connection {
      host        = "${azurerm_public_ip.static-ip2.ip_address}"
      type        = "ssh"
      user        = "${var.admin_username}"
      private_key = file("${path.module}/../wordpress.pem")
    }
    content     = "${data.template_file.config.rendered}"
    destination = "/tmp/config.sh"
  }
  provisioner "remote-exec" {
    connection {
      host        = "${azurerm_public_ip.static-ip2.ip_address}"
      type        = "ssh"
      user        = "${var.admin_username}"
      private_key = file("${path.module}/../wordpress.pem")
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

resource "azurerm_public_ip" "static-ip1" {
  name                = "wordpress-static-ip1-${random_id.bp_suffix.hex}"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "static-ip2" {
  name                = "wordpress-static-ip2-${random_id.bp_suffix.hex}"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "static-ip-lb" {
  name                = "wordpress-static-ip-lb-${random_id.bp_suffix.hex}"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  allocation_method   = "Static"
}

resource "azurerm_virtual_network" "main" {
  name                = "wordpress-network-${random_id.bp_suffix.hex}"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
}

resource "azurerm_subnet" "internal" {
  name                 = "wordpress-subnet-${random_id.bp_suffix.hex}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "app1" {
  name                = "wordpress-app1-nic-${random_id.bp_suffix.hex}"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  ip_configuration {
    name                          = "wordpress-ip1-config-${random_id.bp_suffix.hex}"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.static-ip1.id}"
  }
}

resource "azurerm_network_interface" "app2" {
  name                = "wordpress-app2-nic-${random_id.bp_suffix.hex}"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  ip_configuration {
    name                          = "wordpress-ip2-config-${random_id.bp_suffix.hex}"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.static-ip2.id}"
  }
}

###################
# LoadBalance layer
###################

resource "azurerm_lb" "wordpress-lb" {
  name                = "wordpress-load-balancer-${random_id.bp_suffix.hex}"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  frontend_ip_configuration {
    name                 = "wordpress-lb-ip-config-${random_id.bp_suffix.hex}"
    public_ip_address_id = "${azurerm_public_ip.static-ip-lb.id}"
  }
}

resource "azurerm_lb_rule" "wordpress-lb-rule" {
  resource_group_name            = "${azurerm_resource_group.main.name}"
  loadbalancer_id                = "${azurerm_lb.wordpress-lb.id}"
  name                           = "wordpress-load-balancer-rule-${random_id.bp_suffix.hex}"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "wordpress-lb-ip-config-${random_id.bp_suffix.hex}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.wordpress-lb-pool.id}"
  probe_id                       = "${azurerm_lb_probe.wordpress-lb-probe.id}"
}

resource "azurerm_lb_backend_address_pool" "wordpress-lb-pool" {
  resource_group_name = "${azurerm_resource_group.main.name}"
  loadbalancer_id     = "${azurerm_lb.wordpress-lb.id}"
  name                = "wordpress-load-balancer-pool-${random_id.bp_suffix.hex}"
}

resource "azurerm_lb_probe" "wordpress-lb-probe" {
  resource_group_name = "${azurerm_resource_group.main.name}"
  loadbalancer_id     = "${azurerm_lb.wordpress-lb.id}"
  name                = "wordpress-load-balancer-probe-${random_id.bp_suffix.hex}"
  port                = 80
}

resource "azurerm_network_interface_backend_address_pool_association" "lb-app1" {
  network_interface_id    = "${azurerm_network_interface.app1.id}"
  ip_configuration_name   = "wordpress-ip1-config-${random_id.bp_suffix.hex}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.wordpress-lb-pool.id}"
}

resource "azurerm_network_interface_backend_address_pool_association" "lb-app2" {
  network_interface_id    = "${azurerm_network_interface.app2.id}"
  ip_configuration_name   = "wordpress-ip2-config-${random_id.bp_suffix.hex}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.wordpress-lb-pool.id}"
}

###################
# Outputs
###################

output "URL" {
  value = "http://${azurerm_public_ip.static-ip-lb.ip_address}"
}

output "App1-addres" {
  value = "${azurerm_public_ip.static-ip1.ip_address}"
}

output "App2-addres" {
  value = "${azurerm_public_ip.static-ip1.ip_address}"
}

output "Database-addres" {
  value = "${azurerm_mysql_server.wordpress-db-server.fqdn}"
}
