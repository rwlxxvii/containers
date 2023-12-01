client {
  enabled = true
  servers = ["myhost:port"]
  host_volume "letsencrypt" {
    path = "/etc/letsencrypt"
    read_only = true
  }
  host_volume "nessus_logs" {
    path = "/opt/nessus/var/nessus/logs"
    read_only = true
  }
}

plugin "nomad-driver-podman" {
  volumes {
    enabled = true
    selinuxlabel = "Z"
    }
  config {
  disable_log_collection = false
  }
}
