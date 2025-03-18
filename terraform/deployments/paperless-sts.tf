terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.36.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_stateful_set_v1" "paperless-ngx" {
  metadata {
    labels = {
      app                           = "paperless"
    }

    name = "paperless"
  }

  spec {
    replicas               = 3

    selector {
      match_labels = {
        app = "paperless"
      }
    }

    service_name = "paperless"

    template {
      metadata {
        labels = {
          app = "paperless"
        }
      }

      spec {
        container {
          name              = "paperless"
          image             = "lscr.io/linuxserver/paperless-ngx:latest"
          image_pull_policy = "IfNotPresent"

          volume_mount {
            name       = "paperless-data"
            mount_path = "/data"
          }

          volume_mount {
            name       = "paperless-consume"
            mount_path = "/consume"
          }

          volume_mount {
            name       = "paperless-media"
            mount_path = "/media"
          }

          env_from {
            config_map_ref {
              name = "paperless-configmap"
            }           
          }
        }

        container {
          name              = "prometheus-server-configmap-reload"
          image             = "jimmidyson/configmap-reload:v0.1"
          image_pull_policy = "IfNotPresent"

          args = [
            "--volume-dir=/etc/config",
            "--webhook-url=http://localhost:9090/-/reload",
          ]

          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/config"
            read_only  = true
          }

          resources {
            limits = {
              cpu    = "10m"
              memory = "10Mi"
            }

            requests = {
              cpu    = "10m"
              memory = "10Mi"
            }
          }
        }

        container {
          name              = "prometheus-server"
          image             = "prom/prometheus:v2.2.1"
          image_pull_policy = "IfNotPresent"

          args = [
            "--config.file=/etc/config/prometheus.yml",
            "--storage.tsdb.path=/data",
            "--web.console.libraries=/etc/prometheus/console_libraries",
            "--web.console.templates=/etc/prometheus/consoles",
            "--web.enable-lifecycle",
          ]

          port {
            container_port = 9090
          }

          resources {
            limits = {
              cpu    = "200m"
              memory = "1000Mi"
            }

            requests = {
              cpu    = "200m"
              memory = "1000Mi"
            }
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/config"
          }

          volume_mount {
            name       = "prometheus-data"
            mount_path = "/data"
            sub_path   = ""
          }

          volume_device {
            name        = "prometheus-device"
            device_path = "/dev/xvda"
          }

          readiness_probe {
            http_get {
              path = "/-/ready"
              port = 9090
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }

          liveness_probe {
            http_get {
              path   = "/-/healthy"
              port   = 9090
              scheme = "HTTPS"
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }
        }

        termination_grace_period_seconds = 300

        volume {
          name = "config-volume"

          config_map {
            name = "prometheus-config"
          }
        }
      }
    }

    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 1
      }
    }

    volume_claim_template {
      metadata {
        name = "prometheus-data"
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "standard"

        resources {
          requests = {
            storage = "16Gi"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "prometheus-device"
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "local-storage"
        volume_mode        = "Block"

        resources {
          requests = {
            storage = "16Gi"
          }
        }
      }
    }

    persistent_volume_claim_retention_policy {
      when_deleted = "Delete"
      when_scaled  = "Delete"
    }
  }
}