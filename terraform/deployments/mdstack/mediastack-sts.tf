provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_stateful_set" "mediastack" {
  metadata {
    name      = "mediastack"
    namespace = "media"
    labels = {
      app = "mediastack"
    }
  }

  spec {
    service_name = "mediastack"
    replicas     = 3

    selector {
      match_labels = {
        app = "mediastack"
      }
    }

    template {
      metadata {
        labels = {
          app = "mediastack"
        }
      }

      spec {
        volume {
          name = "qbittorrent-configuration"
          config_map {
            name = "qbtorrent-configmap"
          }
        }

        volume {
          name = "sodarr-configuration"
          config_map {
            name = "sodarr-configmap"
          }
        }

        container { # PROWLARRs
          name  = "prowlarr"
          image = "linuxserver/prowlarr:latest"
          port {
            container_port = 9696
          }
          volume_mount {
            name       = "prowlarr-pvc"
            mount_path = "/config"
            sub_path   = "prowlarr"
          }
        }

        container { # RADARR
          name  = "radarr"
          image = "linuxserver/radarr:latest"
          env_from {
            config_map_ref {
              name = "sodarr-configuration"
            }
          }
          port {
            container_port = 7878
          }
          volume_mount {
            name       = "radarr-pvc"
            mount_path = "/config"
            sub_path   = "radarr"
          }
          volume_mount {
            name       = "media-pvc"
            mount_path = "/Movies"
          }
          volume_mount {
            name       = "media-pvc"
            mount_path = "/Downloads"
          }
        }

        container {
          name  = "sonarr"
          image = "linuxserver/sonarr:latest"
          env_from {
            config_map_ref {
              name = "sodarr-configuration"
            }
          }
          port {
            container_port = 7878
          }
          volume_mount {
            name       = "sonarr-pvc"
            mount_path = "/config"
            sub_path   = "sonarr"
          }
          volume_mount {
            name       = "media-pvc"
            mount_path = "/Movies"
          }
          volume_mount {
            name       = "media-pvc"
            mount_path = "/Downloads"
          }
        }

        container { # QBITTORRENT
          name  = "qbittorrent"
          image = "linuxserver/qbittorrent:latest"
          env_from {
            config_map_ref {
              name = "qbittorrent-configuration"
            }
          }
          port {
            container_port = 8080
            protocol = "TCP"
            name = "web-ui"
          }
          port {
            container_port = 6881
            protocol = "TCP"
            name = "torrent-tcp"
          }
          port {
            container_port = 6881
            protocol = "UDP"
            name = "torrent-udp"
          }
          
          volume_mount {
            name       = "radarr-pvc"
            mount_path = "/config"
            sub_path   = "radarr"
          }
          volume_mount {
            name       = "media-pvc"
            mount_path = "/Movies"
          }
          volume_mount {
            name       = "media-pvc"
            mount_path = "/Downloads"
          }
        }

        container { # JELLYFIN
          name  = "jellyfin"
          image = "jellyfin/jellyfin:latest"
          port {
            container_port = 8096
            protocol = "TCP"
            name = "http-tcp"
          }
          port {
            container_port = 8920
            protocol = "TCP"
            name = "https-tcp"
          }
          port {
            container_port = 1900
            protocol = "UDP"
            name = "dlna-udp"
          }
          port {
            container_port = 7359
            protocol = "UDP"
            name = "discovery-udp"
          }
          
          volume_mount {
            name       = "jellyfin-pvc"
            mount_path = "/config"
            sub_path   = "jellyfin"
          }
          volume_mount {
            name       = "media-pvc"
            mount_path = "/Movies"
          }
          volume_mount {
            name       = "media-pvc"
            mount_path = "/Downloads"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "media-pvc"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "100Gi"
          }
        }
        storage_class_name = "cstor-csi-disk"
      }
    }

    volume_claim_template {
      metadata {
        name = "prowlarr-pvc"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "10Gi"
          }
        }
        storage_class_name = "cstor-csi-disk"
      }
    }

    volume_claim_template {
      metadata {
        name = "radarr-pvc"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "10Gi"
          }
        }
        storage_class_name = "cstor-csi-disk"
      }
    }

    volume_claim_template {
      metadata {
        name = "sonarr-pvc"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "10Gi"
          }
        }
        storage_class_name = "cstor-csi-disk"
      }
    }

    volume_claim_template {
      metadata {
        name = "jellyfin-pvc"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "5Gi"
          }
        }
        storage_class_name = "cstor-csi-disk"
      }
    }

    volume_claim_template {
      metadata {
        name = "qbittorrent-pvc"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "5Gi"
          }
        }
        storage_class_name = "cstor-csi-disk"
      }
    }
  }
}