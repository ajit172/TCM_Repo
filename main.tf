resource "azurerm_resource_group" "rg" {
    name = "kr"
    location = "east us"

}

resource "azurerm_storgage_account" "stg" {
    name = "krstg"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    account_tier = "standart"
    account_replication_type = "LRS"

}
resource "azurerm_virtual_network" "vnet" {
    name = "sa_vnet"
    address_space = ["10.0.0.16/24"]
    resource_group_name = azurerm_resource_group.rg.namme
    location = azurerm_resource_group.rg.location

}

resource "azurerm_subnet" "subnet" {
    name = "su_subnet"
    resource_group_name = azurerm_resource_group.rg.namme
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [ "10.0.0.16/16" ]
}
resource "azurerm_public_ip" "pip" {
    name = "sa_public_ip"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    allocation_method = "Dynamic"
}
resource "azurerm_network_interface" "nic" {
    name = "su_nic"
    location = azurerm_group_location.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.pip.id
    }
}
resource "azurerm_linux_virtual_machine" "vm" {
    name = "su_vm"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_F2"
    admin_username = "adminuser"
    network_interface_ids = [azurerm_network_interface.nic.id]
    admin_ssh_key {
        username = "adminuser"
        public_key = file("~/.ssh/id_rsa.pub")
    }
    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    source_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "18.04-LTS"
        version = "latest"
    }
}