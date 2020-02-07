resource "google_compute_subnetwork" "central_subnet" {

  name          = "${format("%s", "${var.env}-central-subnet")}"
  network       = "${google_compute_network.custom.self_link}"
  ip_cidr_range = "${var.central_subnet}"
  region        = "us-central1"

}

data "google_compute_image" "debian" {

  family  = "ubuntu-1804-lts"
  project = "gce-uefi-images"
}
resource "google_compute_instance" "central" {

  name         = "${format("%s", "${var.company}-${var.env}-central-vm")}"
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.debian.self_link}"
    }
  }

  tags = ["http"]

  network_interface {

    network    = "${module.custom.network}"
    subnetwork = "${google_compute_subnetwork.central_subnet.self_link}"
    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = data.template_file.nginx.rendered

  data "template_file" "nginx" {

    template = "${file("nginx-script.tpl")}"
    vars = {
      ufw_allow_nginx = "Nginx Http"
    }
  }

}
