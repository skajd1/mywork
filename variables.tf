variable "mysql_root_password" {
    type    = string
    default = "mywork123!"
}
variable "mysql_database" {
    type    = string
    default = "myworkdb"
}
variable "spring_boot_image" {
    type    = string
    default = "spring-boot-app:latest"
}
variable "mysql_host" {
    type    = string
    default = "mysql-service"
}