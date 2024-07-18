resource "kubernetes_config_map" "mysql_init_script" {
  metadata {
    name = "mysql-init-script"
  }

  data = {
    "init.sql" = <<-EOT
      CREATE DATABASE IF NOT EXISTS ${var.mysql_database} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    
      CREATE USER 'skajd1'@'%' IDENTIFIED BY '${var.mysql_root_password}';
      GRANT ALL PRIVILEGES ON ${var.mysql_database}.* TO 'skajd1'@'%';
      FLUSH PRIVILEGES;
    EOT
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
