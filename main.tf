provider "kubernetes" {
  config_path = "~/.kube/config"
}
module "mysql" {
  source = "./modules/mysql"

  mysql_root_password = var.mysql_root_password
  mysql_database      = var.mysql_database
}

module "spring_boot" {
  source = "./modules/spring-boot"

  spring_boot_image = var.spring_boot_image
  mysql_root_password = var.mysql_root_password
  mysql_database = var.mysql_database
  mysql_host = var.mysql_host
  
}
