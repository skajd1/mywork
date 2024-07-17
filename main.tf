provider "kubernetes" {
  config_path = "~/.kube/config"
}

variable "mysql_root_password" {
  type    = string
  default = "mywork123!"
}

variable "mysql_database" {
  type    = string
  default = "mysql-service"
}

variable "spring_boot_image" {
  type    = string
  default = "spring-boot-app:latest"
}

resource "kubernetes_config_map" "spring_boot_config" {
  metadata {
    name = "spring-boot-config"
  }

  data = {
    SPRING_DATASOURCE_HOST = var.mysql_database
    SPRING_DATASOURCE_USERNAME = "root"
    SPRING_DATASOURCE_PASSWORD = var.mysql_root_password
  }
}

resource "kubernetes_secret" "mysql_secret" {
  metadata {
    name = "mysql-secret"
  }

  data = {
    username = base64encode("root")
    password = base64encode(var.mysql_root_password)
  }
}


resource "kubernetes_deployment" "mysql" {
  metadata {
    name = "mysql"
  }

  spec {
    selector {
      match_labels = {
        app = "mysql"
      }
    }

    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }

      spec {
        container {
          name  = "mysql"
          image = "mysql:5.7"

          env {
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mysql-secret"
                key  = "password"
              }
            }
          }

          env {
            name  = "MYSQL_DATABASE"
            value = var.mysql_database
          }

          port {
            container_port = 3306
          }

          
        }

      }
    }
  }
}

resource "kubernetes_service" "mysql_service" {
  metadata {
    name = "mysql-service"
  }

  spec {
    selector = {
      app = "mysql"
    }

    port {
      port        = 3306
      target_port = 3306
    }
  }
}

resource "kubernetes_deployment" "spring_boot_app" {
  metadata {
    name = "spring-boot-app"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "spring-boot-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "spring-boot-app"
        }
      }

      spec {
        container {
          name  = "spring-boot-app"
          image = var.spring_boot_image
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 8080
          }

          env_from {
            config_map_ref {
              name = "spring-boot-config"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "spring_boot_service" {
  metadata {
    name = "spring-boot-service"
  }

  spec {
    type = "NodePort"

    selector = {
      app = "spring-boot-app"
    }

    port {
      port        = 8080
      target_port = 8080
      node_port   = 30007
    }
  }
}
