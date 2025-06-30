# in this file we will create the resources for the ToDo app infrastructure in Azure using Terraform
module "resource_group" {
  source = "../Child_Modules/Azurerm_Resource_Group"

  resource_group_name     = "infratodo-app-rg"
  resource_group_location = "Central India"

}
module "resource_group1" {
  source = "../Child_Modules/Azurerm_Resource_Group"

  resource_group_name     = "infratodo-app-rg1"
  resource_group_location = "Central India"

}

module "named_virtual_network" {
  source = "../Child_Modules/Azurerm_Virtual_Networks"

  depends_on = [module.resource_group]

  virtual_network_name     = "infratodo-vnet"
  virtual_network_location = "Central India"
  resource_group_name      = "infratodo-app-rg"
  address_space            = ["10.0.0.0/16"]

}

module "frontend_subnet" {
  source = "../Child_Modules/Azurerm_Subnets"

  depends_on = [module.named_virtual_network]

  subnet_name             = "infratodofrontend-subnet"
  resource_group_name     = "infratodo-app-rg"
  virtual_network_name    = "infratodo-vnet"
  subnet_address_prefixes = ["10.0.1.0/24"]

}

module "backend_subnet" {
  source = "../Child_Modules/Azurerm_Subnets"

  depends_on = [module.named_virtual_network]

  subnet_name             = "infratodobackend-subnet"
  resource_group_name     = "infratodo-app-rg"
  virtual_network_name    = "infratodo-vnet"
  subnet_address_prefixes = ["10.0.2.0/24"]

}

module "Front_public_ip" {
  source     = "../Child_Modules/Azurerm_Public_IP"
  depends_on = [module.resource_group]

  public_ip_name      = "infratodo-Front-public-ip"
  resource_group_name = "infratodo-app-rg"
  location            = "Central India"
  allocation_method   = "Static"
}

module "frontend_vm" {

  source = "../Child_Modules/Azurerm_Virtual_Machine"

  depends_on           = [module.frontend_subnet, module.Front_public_ip, module.key_vault, module.vmuser_name, module.vmuser_passowrd]
  resource_group_name  = "infratodo-app-rg"
  nic_name             = "infratodofrontend-nic"
  location             = "Central India"
  virtual_machine_name = "infratodofrontend-vm"
  virtual_machine_size = "Standard_B1s"
  publisher_image      = "Canonical"
  offer_image          = "0001-com-ubuntu-server-focal"
  sku_image            = "20_04-lts"
  version_image        = "latest"
  virtual_network_name = "infratodo-vnet"
  public_ip_name       = "infratodo-Front-public-ip"
  subnet_name          = "infratodofrontend-subnet"
  key_vault_name       = "infratodo-keyvault"

}

module "backend_public_ip" {
  source     = "../Child_Modules/Azurerm_Public_IP"
  depends_on = [module.resource_group]

  public_ip_name      = "infratodo-Backend-public-ip"
  resource_group_name = "infratodo-app-rg"
  location            = "Central India"
  allocation_method   = "Static"
}

module "backend_vm" {

  source = "../Child_Modules/Azurerm_Virtual_Machine"

  depends_on           = [module.backend_subnet, module.backend_public_ip, module.key_vault, module.vmuser_name, module.vmuser_passowrd]
  resource_group_name  = "infratodo-app-rg"
  nic_name             = "infratodobackend-nic"
  location             = "Central India"
  virtual_machine_name = "infratodobackend-vm"
  virtual_machine_size = "Standard_B1s"
  publisher_image      = "Canonical"
  offer_image          = "0001-com-ubuntu-server-focal"
  sku_image            = "20_04-lts"
  version_image        = "latest"
  virtual_network_name = "infratodo-vnet"
  public_ip_name       = "infratodo-Backend-public-ip"
  subnet_name          = "infratodobackend-subnet"
  key_vault_name       = "infratodo-keyvault"
}

module "key_vault" {
  source = "../Child_Modules/Azurerm_Key_Vault"

  depends_on = [module.resource_group]

  key_vault_name      = "infratodo-keyvault"
  resource_group_name = "infratodo-app-rg"
  location            = "Central India"
}
module "vmuser_name" {
  source = "../Child_Modules/Azurerm_Secret"

  depends_on = [module.key_vault]

  resource_group_name = "infratodo-app-rg"
  key_vault_name      = "infratodo-keyvault"
  secret_name         = "vmadusernname"
  secret_value        = "Luckydevopstop"

}
module "vmuser_passowrd" {
  source = "../Child_Modules/Azurerm_Secret"

  depends_on = [module.key_vault]

  resource_group_name = "infratodo-app-rg"
  key_vault_name      = "infratodo-keyvault"
  secret_name         = "vmpasshide"
  secret_value        = "Luckydevops@4321"

}
module "sql_server" {
  source     = "../Child_Modules/Azurerm_SQL_Server"
  depends_on = [module.resource_group, module.key_vault, module.sql_server_ad_name, module.sql_server_psw]

  resource_group_name = "infratodo-app-rg"
  location            = "Central India"
  sql_server_name     = "infratodosqlserver4321"
  key_vault_name      = "infratodo-keyvault"
}
module "sql_server_ad_name" {
  source = "../Child_Modules/Azurerm_Secret"

  depends_on = [module.key_vault]

  resource_group_name = "infratodo-app-rg"
  key_vault_name      = "infratodo-keyvault"
  secret_name         = "sqladusernname"
  secret_value        = "Luckydevopstop"

}
module "sql_server_psw" {
  source = "../Child_Modules/Azurerm_Secret"

  depends_on = [module.key_vault]

  resource_group_name = "infratodo-app-rg"
  key_vault_name      = "infratodo-keyvault"
  secret_name         = "sqlserverhide"
  secret_value        = "Luckydevops@4321"

}

module "sql_database" {

  source = "../Child_Modules/Azurerm_SQL_Database"

  depends_on = [module.sql_server]

  sql_database_name   = "infratodosqldatabase"
  resource_group_name = "infratodo-app-rg"
  sql_server_name     = "infratodosqlserver4321"


}