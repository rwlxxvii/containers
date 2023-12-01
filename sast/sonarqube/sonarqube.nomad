job "sonarqube" {
  region = "us"
  datacenters = ["dc1"]
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
  group "sonarqube-group" {
    count = 1
    network {
      mode = "slirp4netns/sonarqube"
      port "sonar" { to = 9000 }
      mbits = 100
    }
    service {
      name = "sonarqube"
    }
    volume "sonarqube_logs" {
      type      = "host"
      read_only = true
      source    = "sonarqube_logs"
    }
    task "sonarqube-build" {
      driver = "podman"
      resources {
      cpu    = 1500
      memory = 8192
      }
      config {
        image = "quay.io/rootshifty/sonarqube:release"
        image_pull_timeout = "5m"
        ports = ["sonar"]
        volume_mount {
          volume      = "sonarqube_logs"
          destination = "/opt/sonarqube/logs"
          read_only   = true
        }
        volumes = [ "/etc/localtime:/etc/localtime:ro,noexec" ]
        ulimit {
          nproc  = "8192"
          nofile = "65536:131072"
        }
        #auth {
        #  username = "rootshifty"
        #  password = " ----------------- "
        #  server_address  = "quay.io"
        #}
      }
      service {
        port = "sonar"
        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }  
}
