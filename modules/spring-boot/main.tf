resource "kubernetes_config_map" "spring_boot_config" {
  metadata {
    name = "spring-boot-config"
  }

  data = {
    SPRING_DATASOURCE_HOST     = var.mysql_host
    SPRING_DATASOURCE_USERNAME = "skajd1"
    SPRING_DATASOURCE_PASSWORD = var.mysql_root_password
    SPRING_DATASOURCE_DATABASE = var.mysql_database
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
