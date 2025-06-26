provider "azurerm" {
  features {}

  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "wizrg" {
  name     = "wiz-rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "wiz_vnet" {
  name                = "wiz-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.wizrg.location
  resource_group_name = azurerm_resource_group.wizrg.name
}

resource "azurerm_subnet" "wiz_subnet" {
  name                 = "wiz-subnet"
  resource_group_name  = azurerm_resource_group.wizrg.name
  virtual_network_name = azurerm_virtual_network.wiz_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "wiz_pip" {
  name                = "wiz-public-ip"
  location            = azurerm_resource_group.wizrg.location
  resource_group_name = azurerm_resource_group.wizrg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_network_interface" "wiz_nic" {
  name                = "wiz-nic"
  location            = azurerm_resource_group.wizrg.location
  resource_group_name = azurerm_resource_group.wizrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.wiz_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.wiz_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "wizvm" {
  name                  = "wiz-vm"
  resource_group_name   = azurerm_resource_group.wizrg.name
  location              = azurerm_resource_group.wizrg.location
  size                  = "Standard_B1s"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.wiz_nic.id]

  disable_password_authentication = true

  os_disk {
    name                 = "wiz-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAIG3mWgMM9yQBCm1CODN/ZwxGEgz+uHSard7r9VOPe90BsZoH5bKoEe+S7ARwIwTV1nim4U09+qK1UJ4MwtfixhlZZhmyJBVeg2bZ78BxE/T0tycRqVTS6RooUYjn19fegUY8zxX53v9zgnmPOE4Sedq2U/J/XRpjUqpCYzGLll/5KJI5zE+YHfxPgXr6lne1xtlkS8YxQlN3nSalW4tGE85SIBsouVKHoCitzgp0ltIA3vf7p1onnYBUwuSjf/Ap5PcvmNCgkjMwcis02N3eD/ydTG9JGxtAZgYDnp21di+OQft5c6NhfEoln0Rmc5M4Tf8RNhscsx314wxWw3jP7UjQyG9+I6+JtlrgHS75ESMCcScI6Af52QWvF+pWl/y4I1/0WXsl6JRn6FHG7Vy7uT4C3pWN+KapNfExbvAd/Gu238GOWDg3dVJSiygkFZ4MIvyZDZZCckMo4c9/ZRMNqjqI49Xe+xfPBncDip36Hq3VxInKlnWOWNeZqK2lfD+g055T0Zqxmsih7S0s553iluvLV8hGPueAjB08mx+5kKO7I9qH9skUW95pOekNBrk7UO6jywRCcYxPrprlfkidpbwsohI4yx4ZTwwKj0lcmS5idCQcAz8uHmM7BVmZG0OG9kEBrftABSZ4a+I50P77JKGNpNQU7mcZqspUMlqwUQ== wizvm
EOF
  }
}
