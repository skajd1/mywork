provider "kubernetes" {
  config_path = "~/.kube/config"
}

variable "mysql_root_password" {
  type    = string
  default = "mywork123!"
}

variable "mysql_database" {
  type    = string
  default = "myworkdb"
}

variable "mysql_host" {
  type   = string
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
    SPRING_DATASOURCE_HOST = var.mysql_host
    SPRING_DATASOURCE_USERNAME = "skajd1"
    SPRING_DATASOURCE_PASSWORD = var.mysql_root_password
    SPRING_DATASOURCE_DATABASE = var.mysql_database
  }
}

resource "kubernetes_secret" "mysql_secret" {
  metadata {
    name = "mysql-secret"
  }

  data = {
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
        volume {
          name = "mysql-initdb"
          config_map {
            name = kubernetes_config_map.mysql_init_script.metadata[0].name
          }
        }
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
          
          volume_mount {
            name      = "mysql-initdb"
            mount_path = "/docker-entrypoint-initdb.d"
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
  depends_on = [kubernetes_deployment.mysql]
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
resource "kubernetes_config_map" "mysql_init_script" {
  metadata {
    name = "mysql-init-script"
  }

  data = {
    "init.sql" = <<-EOT

      CREATE DATABASE IF NOT EXISTS myworkdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    
      CREATE USER 'skajd1'@'%' IDENTIFIED BY '${var.mysql_root_password}';
      GRANT ALL PRIVILEGES ON myworkdb.* TO 'skajd1'@'%';
      FLUSH PRIVILEGES;
    EOT
  }
}

