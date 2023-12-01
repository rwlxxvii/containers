job "nessus" {
  region = "us"
  datacenters = ["dc2"]
  type = "service"
  update {
    max_parallel     = 1
    health_check     = "checks"
    min_healthy_time = "180s"
    healthy_deadline = "5m"
    progress_deadline = "10m"
    auto_revert = true
    auto_promote = true
    canary = 1
  }
  meta {
    run_uuid = "${uuidv4()}"
    connect.sidecar_image = "dockerhub.traefik.io:8080/envoyproxy/envoy:v1.25.0@sha256:3b11481889f78e8b3b6daf1b8b813a20bea34249f3e31539c166bf17a7ee697a"
  }
  group "nessus-group" {
    count = 1
    network {
      mode = "slirp4netns/nessus"
      port "nessus" { to = 8834 }
      port "https"  { to = 443 }
      dns {
        servers = ["Ip's of DNS1", "Ip's of DNS2"]
      }
      mbits = 100
    }
    volume "nessus_logs" {
      type      = "host"
      read_only = true
      source    = "nessus_logs"
    }
    task "nessus-build" {
      driver = "podman"
      env {
        USERNAME: ${NESSUS_USERNAME}
        PASSWORD: ${NESSUS_PASSWORD:-}
        ACTIVATION_CODE: ${ACTIVATION_CODE:-}
        AUTO_UPDATE: all
      }
      config {
        image = "docker.io/tenableofficial/nessus:latest"
        image_pull_timeout = "5m"
        ports = [ "nessus","https" ]
        volume_mount {
          volume      = "nessus_logs"
          destination = "/opt/nessus/var/nessus/logs"
          read_only   = true
        }
        volumes = [ "/etc/localtime:/etc/localtime:ro,noexec" ]
        memory_swappiness = 60
        #auth {
        #  username = "someuser"
        #  password = "sup3rs3creT"
        #  server_address  = "quay.io"
        #}
        command = "/bin/bash"
          args = [ "-c", "/opt/nessus/sbin/nessus-service --no-root -p 8834 -D" ]
      }
      resources {
      cpu    = 2500
      memory = 4096
      kill_timeout = "600s"
      kill_signal = "SIGTERM"
      }
      service {
        port = "nessus"
        check {
          type     = "tcp"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }  
}
