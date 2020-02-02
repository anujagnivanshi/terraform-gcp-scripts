resource "google_compute_network" "custom" {

  name                    = "${format("%s", "${var.company}-${var.env}-network")}"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"

}

resource "google_compute_firewall" "fw-internal" {

  name    = "${format("%s", "${var.env}-internal-firewall")}"
  network = "${google_compute_network.custom.self_link}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [
    "${var.central_subnet}",
    "${var.west_subnet}"
  ]

}

resource "google_compute_firewall" "fw-ssh" {

  name    = "${format("%s", "${var.env}-bastion-firewall")}"
  network = "${google_compute_network.custom.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["bastion"]

  source_ranges = ["0.0.0.0/0"]

}

resource "google_compute_firewall" "fw-http" {

  name    = "${format("%s", "${var.company}-bastion-firewall")}"
  network = "${google_compute_network.custom.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags = ["http"]

  source_ranges = ["0.0.0.0/0"]
}

output "network" {
  value = "google_compute_network.netwrok.name"
}
    




