resource "google_compute_subnetwork" "east_subnet" {

  name          = "${format("%s", "${var.env}-east-subnet")}"
  network       = "${google_compute_network.custom.self_link}"
  ip_cidr_range = "${var.east_subnet}"
  region        = "us-east1"

}

data "google_compute_image" "debian" {

  family  = "ubuntu-1804-lts"
  project = "gce-uefi-images"
}
resource "google_compute_instance" "bastion" {

  name         = "${format("%s", "${var.company}-${var.env}-bastion-vm")}"
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.debian.self_link}"
    }
  }

  tags = ["bastion"]

  network_interface {

    network    = "${google_compute_network.custom.self_link}"
    subnetwork = "${google_compute_subnetwork.east_subnet.self_link}"
    access_config {
      // Ephemeral IP
    }
  }
}