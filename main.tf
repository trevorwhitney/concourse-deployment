provider "google" {
  project = "${var.projectid}"
  region = "${var.region}"
}

resource "google_compute_network" "concourse" {
  name       = "concourse"
}

resource "google_compute_subnetwork" concourse-subnet {
  name          = "concourse-${var.region}"
  ip_cidr_range = "10.0.10.0/24"
  network       = "${google_compute_network.concourse.self_link}"
}

resource "google_compute_address" "concourse" {
  name = "concourse"
  region = "${var.region}"
}

resource "google_compute_http_health_check" "concourse-public" {
  name                = "concourse-public"
  port                = 80
  request_path        = "/"
  check_interval_sec  = 30
  timeout_sec         = 5
  healthy_threshold   = 10
  unhealthy_threshold = 2
}

// Load balancing target pool
resource "google_compute_target_pool" "concourse-public" {
  name = "concourse-public"
}

// Open ports to concourse
resource "google_compute_firewall" "concourse" {
  name    = "concourse"
  network = "${google_compute_network.concourse.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "6868"]
  }

  target_tags = ["concourse"]
}

resource "google_compute_forwarding_rule" "concourse-agent" {
  name       = "concourse-agent"
  target     = "${google_compute_target_pool.concourse-public.self_link}"
  ip_address = "${google_compute_address.concourse.self_link}"
  port_range = "6868"
  region     = "${var.region}"
}

resource "google_compute_forwarding_rule" "concourse-http" {
  name       = "concourse-http"
  target     = "${google_compute_target_pool.concourse-public.self_link}"
  ip_address = "${google_compute_address.concourse.self_link}"
  port_range = "80"
  region     = "${var.region}"
}

resource "google_compute_forwarding_rule" "concourse-https" {
  name       = "concourse-https"
  target     = "${google_compute_target_pool.concourse-public.self_link}"
  ip_address = "${google_compute_address.concourse.self_link}"
  port_range = "443"
  region     = "${var.region}"
}

// Allow all traffic within subnet
resource "google_compute_firewall" "concourse-internal" {
  name    = "concourse-internal"
  network = "${google_compute_network.concourse.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }

  source_tags = ["internal"]
}

output "public_ip" {
  value ="${google_compute_address.concourse.address}"
}
